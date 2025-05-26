import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../Core/config/app_config.dart';

class ValhallaService {
  // Use the configured base URL
  final String _baseUrl = ('${AppConfig.url}:${AppConfig.valhallaPort}');
  final String _fallBackUrl =
      ('${AppConfig.thijsApiUrl}:${AppConfig.valhallaPort}');
  ValhallaService();

  Future<Map<String, dynamic>> _performRouteRequest(
    String serviceUrl,
    Map<String, dynamic> requestBody,
  ) async {
    final fullUrl = '$serviceUrl/route';
    debugPrint('ValhallaService: Attempting to get route from $fullUrl');

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        debugPrint(
          'ValhallaService: Successfully received route from $fullUrl',
        );
        final routeData = jsonDecode(response.body);
        final List<LatLng> fullDecodedPolyline = [];

        if (routeData.containsKey('trip') &&
            routeData['trip'].containsKey('legs')) {
          final legs = routeData['trip']['legs'] as List;
          for (var leg in legs) {
            if (leg.containsKey('shape')) {
              final encodedPolyline = leg['shape'] as String;
              final decodedLegPolyline = decodePolyline(encodedPolyline);
              fullDecodedPolyline.addAll(decodedLegPolyline);
            }
          }
        }
        final uniquePolyline = fullDecodedPolyline.toSet().toList();
        return {'route': routeData, 'decodedPolyline': uniquePolyline};
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error'] ?? 'Unknown error from server';
        final errorCode = errorBody['error_code'] ?? response.statusCode;
        debugPrint(
          'ValhallaService: Failed to get route from $fullUrl. Status: $errorCode, Message: $errorMessage',
        );
        throw _ValhallaRequestException(
          'Failed to get route from $fullUrl: [$errorCode] $errorMessage',
          url: fullUrl,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      // Catch specific network errors
      debugPrint(
        'ValhallaService: Network error while contacting $fullUrl: $e',
      );
      throw _ValhallaRequestException(
        'Network error contacting $fullUrl: ${e.message}',
        url: fullUrl,
        isNetworkError: true,
      );
    } catch (e) {
      // Catch other errors like JSON parsing issues
      debugPrint(
        'ValhallaService: Unexpected error while processing request to $fullUrl: $e',
      );
      throw _ValhallaRequestException(
        'Unexpected error processing request to $fullUrl: $e',
        url: fullUrl,
      );
    }
  }

  /// Main functions of API for requesting optimized routes
  /// Must contain a list of LatLng points (at least 2) to be optimized
  /// Returns a Map with the route information from Valhalla
  /// Attempts primary URL, then fallback URL on failure.
  /// TODO: Add more get-function for different route options
  Future<Map<String, dynamic>> getOptimizedRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      throw ArgumentError('At least 2 waypoints are required for a route.');
    }

    final locations =
        waypoints
            .map((point) => {'lon': point.longitude, 'lat': point.latitude})
            .toList();

    final requestBody = {
      'locations': locations,
      'costing': 'pedestrian',
      'directions_options': {'units': 'kilometers'},
    };

    try {
      // Attempt 1: Primary URL
      return await _performRouteRequest(_baseUrl, requestBody);
    } catch (e) {
      debugPrint(
        'ValhallaService: Primary URL ($_baseUrl/route) failed. Error: $e',
      );
      if (e is _ValhallaRequestException && e.isNetworkError) {
        // If it's a network error with the primary, it's worth trying the fallback.
      } else if (e is _ValhallaRequestException &&
          e.statusCode != null &&
          e.statusCode! >= 500) {
        // If it's a server error (5xx) with the primary, also try fallback.
      } else if (e is! _ValhallaRequestException) {
        // If it's an unexpected error not from _performRouteRequest (e.g. programming error before the call), rethrow.
        rethrow;
      }
      // For other _ValhallaRequestException (like 4xx client errors), we might not want to retry,
      // but for this example, we'll try fallback for most _ValhallaRequestException from primary.

      debugPrint(
        'ValhallaService: Attempting fallback URL ($_fallBackUrl/route).',
      );
      try {
        // Attempt 2: Fallback URL
        return await _performRouteRequest(_fallBackUrl, requestBody);
      } catch (fallbackError) {
        debugPrint(
          'ValhallaService: Fallback URL ($_fallBackUrl/route) also failed. Error: $fallbackError',
        );
        throw Exception(
          'Failed to get route from both primary and fallback URLs. Primary error: $e, Fallback error: $fallbackError',
        );
      }
    }
  }

  // Decode the polyline from Valhalla (similar to the JS function given in the docs on official website)
  List<LatLng> decodePolyline(String encoded, {int precision = 6}) {
    // precision is typically 6 for Valhalla
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final double factor =
          pow(10, precision).toDouble(); // Use precision parameter
      points.add(LatLng(lat / factor, lng / factor));
    }

    return points;
  }
}

/// Custom exception for Valhalla request failures.
class _ValhallaRequestException implements Exception {
  final String message;
  final String url;
  final int? statusCode;
  final bool isNetworkError;

  _ValhallaRequestException(
    this.message, {
    required this.url,
    this.statusCode,
    this.isNetworkError = false,
  });

  @override
  String toString() {
    return '_ValhallaRequestException: $message (URL: $url, StatusCode: $statusCode, IsNetworkError: $isNetworkError)';
  }
}
