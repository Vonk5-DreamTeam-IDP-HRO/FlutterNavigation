import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../core/config/app_config.dart';

class ValhallaService {
  // Use the configured base URL
  final String _baseUrl = AppConfig.valhallaUrl;
  ValhallaService();

  /// Main functions of API for requesting optimized routes
  /// Must contain a list of LatLng points (at least 2) to be optimized
  /// Returns a Map with the route information from Valhalla
  /// TODO: Add more get-function for different route options
  Future<Map<String, dynamic>> getOptimizedRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      throw Exception('At least 2 waypoints are required');
    }

    try {
      // Format waypoints for Valhalla
      final locations =
          waypoints
              .map((point) => {'lon': point.longitude, 'lat': point.latitude})
              .toList();

      // Create Valhalla request body
      final requestBody = {
        'locations': locations,
        'costing': 'pedestrian', // Can be auto, bicycle, pedestrian, etc.
        'directions_options': {'units': 'kilometers'},
      };

      // Send request to Valhalla server
      final response = await http.post(
        Uri.parse('$_baseUrl/route'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final routeData = jsonDecode(response.body);
        final List<LatLng> fullDecodedPolyline = [];

        // Iterate through all legs and decode/combine their shapes
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

        // Remove duplicate points that might occur at the connection between legs
        final uniquePolyline = fullDecodedPolyline.toSet().toList();

        return {'route': routeData, 'decodedPolyline': uniquePolyline};
      } else {
        // Provide more detailed error information
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error'] ?? 'Unknown error';
        final errorCode = errorBody['error_code'] ?? response.statusCode;
        throw Exception('Failed to get route: [$errorCode] $errorMessage');
      }
    } catch (e) {
      debugPrint('Valhalla routing error: $e');
      rethrow;
    }
  }

  // Decode the polyline from Valhalla (similar to the JS function given in the docs on official website)
  List<LatLng> decodePolyline(String encoded, {int precision = 6}) {
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

      final double factor = pow(10, precision).toDouble();
      points.add(LatLng(lat / factor, lng / factor));
    }

    return points;
  }
}
