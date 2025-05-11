import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:osm_navigation/core/config/app_config.dart';
import 'package:osm_navigation/core/models/location.dart';
import 'package:osm_navigation/core/models/location_details.dart'; // Keep for LocationDetails model if used by SelectableLocation indirectly
import 'package:osm_navigation/core/models/route.dart' as core_route;
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'i_route_api_service.dart';
import 'route_api_exceptions.dart';

class RouteApiService implements IRouteApiService {
  final http.Client _httpClient;

  // Define primary and fallback base URLs
  // Primary: AppConfig.url + AppConfig.valhallaPort
  // Fallback: AppConfig.thijsApiUrl + AppConfig.valhallaPort
  // Note: The original service used /routes, /location_route, etc.
  // These endpoints might not be served by Valhalla.
  // Assuming these are custom backend endpoints that happen to use the same base server as Valhalla for this task.

  static final String _primaryBaseApiUrl = 'http://localhost:65029/';
  //static final String _primaryBaseApiUrl =
  //    '${AppConfig.url}:${AppConfig.backendApiPort}';
  static final String _fallbackBaseApiUrl =
      '${AppConfig.thijsApiUrl}:${AppConfig.tempRESTPort}';

  RouteApiService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  // Helper to handle HTTP errors and convert them to custom exceptions
  RouteApiException _handleHttpError(
    dynamic e,
    String operation,
    Uri attemptedUri,
    int? statusCode,
  ) {
    debugPrint(
      '[RouteApiService] Error during $operation at $attemptedUri: $e',
    );
    if (e is http.ClientException) {
      return RouteApiNetworkException(
        'Network error during $operation: ${e.message}',
        uri: attemptedUri,
        originalException: e,
        statusCode: statusCode, // statusCode might be null for ClientException
      );
    }
    // For non-200 status codes that are not ClientExceptions
    if (statusCode != null && statusCode >= 400) {
      return RouteApiNetworkException(
        'API error during $operation: Server responded with $statusCode',
        uri: attemptedUri,
        originalException: e, // The original error/response body might be here
        statusCode: statusCode,
      );
    }
    return RouteApiException(
      'Failed $operation: ${e.toString()}',
      uri: attemptedUri,
      originalException: e,
      statusCode: statusCode,
    );
  }

  Future<T> _makeHttpRequest<T>({
    required Future<T> Function(String baseUrl) attemptRequest,
    required String operationName,
  }) async {
    Exception? primaryError;
    Uri? primaryErrorUri;
    int? primaryStatusCode;

    try {
      debugPrint(
        '[RouteApiService] Attempting $operationName with primary URL: $_primaryBaseApiUrl',
      );
      return await attemptRequest(_primaryBaseApiUrl);
    } on http.ClientException catch (e) {
      // Specific network/connection errors
      primaryError = e;
      // URI might not be available directly on ClientException, depends on context
      debugPrint(
        '[RouteApiService] Primary URL request for $operationName failed (ClientException): ${e.message}. Attempting fallback.',
      );
    } on RouteApiException catch (e) {
      // Custom exceptions thrown by attemptRequest
      primaryError = e;
      primaryErrorUri = e.uri;
      primaryStatusCode = e.statusCode;
      debugPrint(
        '[RouteApiService] Primary URL request for $operationName failed (RouteApiException): ${e.message}. Attempting fallback.',
      );
    } catch (e) {
      // Other general errors
      primaryError = e as Exception?;
      debugPrint(
        '[RouteApiService] Primary URL request for $operationName failed (General Error): $e. Attempting fallback.',
      );
    }

    // If primary attempt failed, try fallback
    try {
      debugPrint(
        '[RouteApiService] Attempting $operationName with fallback URL: $_fallbackBaseApiUrl',
      );
      return await attemptRequest(_fallbackBaseApiUrl);
    } catch (fallbackError, fallbackStackTrace) {
      debugPrint(
        '[RouteApiService] Fallback URL request for $operationName also failed: $fallbackError',
      );
      if (primaryError != null) {
        // Prefer to report the primary error if it existed.
        // We might need to re-wrap it or handle it more gracefully.
        // For now, creating a generic RouteApiException.
        throw RouteApiException(
          'All API attempts for $operationName failed. Primary error: ${primaryError.toString()}, Fallback error: ${fallbackError.toString()}',
          originalException: primaryError, // Or combine errors
          uri: primaryErrorUri,
          statusCode: primaryStatusCode,
          stackTrace: fallbackStackTrace,
        );
      }
      // If primary attempt was not an identifiable error or this is a new type of error
      throw RouteApiException(
        'Fallback API attempt for $operationName failed: ${fallbackError.toString()}',
        originalException: fallbackError,
        stackTrace: fallbackStackTrace,
        // uri and statusCode for fallback would come from the error itself if it's an http.Response or similar
      );
    }
  }

  @override
  Future<List<core_route.Route>> getAllRoutes() async {
    const String operationName = 'fetching all routes';
    // Endpoint needs to be confirmed. Assuming '/routes' for now.
    // The original URL was '${AppConfig.tempRESTUrl}/routes?select=*'
    // The new base URLs are Valhalla-like. This endpoint might not exist there.
    // This is a placeholder based on the original.
    const String endpointPath =
        '/routes'; // TODO: Confirm this endpoint for the new base URLs

    return _makeHttpRequest<List<core_route.Route>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final uri = Uri.parse(
          '$baseUrl$endpointPath?select=*',
        ); // Added query params back
        debugPrint('[RouteApiService] $operationName from URL: $uri');
        try {
          final response = await _httpClient.get(uri);
          if (response.statusCode == 200) {
            final List<dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse
                .map(
                  (data) =>
                      core_route.Route.fromJson(data as Map<String, dynamic>),
                )
                .toList();
          } else {
            throw _handleHttpError(
              response.body,
              operationName,
              uri,
              response.statusCode,
            );
          }
        } on http.ClientException catch (e) {
          // Network errors
          throw _handleHttpError(e, operationName, uri, null);
        } catch (e) {
          // JSON parsing errors, etc.
          throw RouteApiParseException(
            'Error parsing $operationName response from $uri: ${e.toString()}',
            originalException: e,
            uri: uri,
          );
        }
      },
    );
  }

  @override
  Future<List<Location>> getRouteLocations(int routeId) async {
    final String operationName = 'fetching locations for route $routeId';
    // Original: '/location_route?select=*,locations:locationid(name,longitude,latitude)&routeid=eq.$routeId'
    // This is highly specific and likely not on a standard Valhalla instance.
    // TODO: Confirm this endpoint for the new base URLs
    final String endpointPath =
        '/location_route?select=*,locations:locationid(name,longitude,latitude)&routeid=eq.$routeId';

    return _makeHttpRequest<List<Location>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final uri = Uri.parse('$baseUrl$endpointPath');
        debugPrint('[RouteApiService] $operationName from URL: $uri');
        try {
          final response = await _httpClient.get(uri);
          if (response.statusCode == 200) {
            final List<dynamic> jsonResponse = json.decode(response.body);
            final locations =
                jsonResponse
                    .map(
                      (item) => Location.fromJson(
                        item['locations'] as Map<String, dynamic>,
                      ),
                    )
                    .toList();
            debugPrint(
              '[RouteApiService] Successfully fetched ${locations.length} locations for route $routeId',
            );
            return locations;
          } else {
            throw _handleHttpError(
              response.body,
              operationName,
              uri,
              response.statusCode,
            );
          }
        } on http.ClientException catch (e) {
          throw _handleHttpError(e, operationName, uri, null);
        } catch (e) {
          throw RouteApiParseException(
            'Error parsing $operationName response from $uri: ${e.toString()}',
            originalException: e,
            uri: uri,
          );
        }
      },
    );
  }

  @override
  Future<List<SelectableLocation>> getSelectableLocations() async {
    const String operationName = 'fetching selectable locations';
    // Original: '/locations' and '/location_details'
    // These are also custom endpoints.
    // TODO: Confirm these endpoints for the new base URLs
    const String locationsEndpoint = '/locations';
    const String detailsEndpoint = '/location_details';

    // This method makes two calls. The retry logic needs to be for the whole operation.
    // If primary fails for EITHER call, then BOTH calls should be retried on fallback.
    // This makes _makeHttpRequest tricky for multi-call methods.
    // Option 1: _makeHttpRequest handles single Uri calls, and this method orchestrates two _makeHttpRequest calls.
    // Option 2: _makeHttpRequest is adapted or a new helper is made for multi-URI attempts.

    // For simplicity, let's assume if the first call (locations) fails on primary,
    // we try both on fallback. This isn't perfect but simpler to implement with current _makeHttpRequest.
    // A more robust solution would involve a higher-level retry for the composite operation.

    Future<List<SelectableLocation>> attemptFetch(String baseUrl) async {
      final locationsUri = Uri.parse('$baseUrl$locationsEndpoint');
      final detailsUri = Uri.parse('$baseUrl$detailsEndpoint');

      debugPrint(
        '[RouteApiService] $operationName (locations) from URL: $locationsUri',
      );
      debugPrint(
        '[RouteApiService] $operationName (details) from URL: $detailsUri',
      );

      try {
        final responses = await Future.wait([
          _httpClient.get(locationsUri),
          _httpClient.get(detailsUri),
        ]);

        final locationsResponse = responses[0];
        final detailsResponse = responses[1];

        if (locationsResponse.statusCode != 200) {
          throw _handleHttpError(
            locationsResponse.body,
            '$operationName (locations)',
            locationsUri,
            locationsResponse.statusCode,
          );
        }
        if (detailsResponse.statusCode != 200) {
          throw _handleHttpError(
            detailsResponse.body,
            '$operationName (details)',
            detailsUri,
            detailsResponse.statusCode,
          );
        }

        final List<dynamic> locationsJson = json.decode(locationsResponse.body);
        final List<dynamic> detailsJson = json.decode(detailsResponse.body);

        final Map<int, String> categoryMap = {};
        for (var detailData in detailsJson) {
          final detail = LocationDetails.fromJson(
            detailData as Map<String, dynamic>,
          );
          categoryMap[detail.locationId] = detail.category ?? 'Uncategorized';
        }

        final List<SelectableLocation> selectableLocations = [];
        for (var locationData in locationsJson) {
          final int locationId = locationData['locationid'] as int;
          final String name = locationData['name'] as String;
          final String category = categoryMap[locationId] ?? 'Uncategorized';
          selectableLocations.add(
            SelectableLocation(
              locationId: locationId,
              name: name,
              category: category,
            ),
          );
        }
        debugPrint(
          '[RouteApiService] Successfully fetched and combined ${selectableLocations.length} selectable locations from $baseUrl',
        );
        return selectableLocations;
      } on http.ClientException catch (e) {
        // Covers network errors for Future.wait
        // Determine which URI failed if possible, or use a general one.
        // For simplicity, rethrow as a generic network error for the operation.
        throw _handleHttpError(e, operationName, Uri.parse(baseUrl), null);
      } catch (e) {
        // Covers JSON parsing or other errors
        throw RouteApiParseException(
          'Error processing $operationName response from $baseUrl: ${e.toString()}',
          originalException: e,
          uri: Uri.parse(baseUrl), // General URI for the base attempt
        );
      }
    }

    // Using the _makeHttpRequest helper for the composite operation.
    return _makeHttpRequest<List<SelectableLocation>>(
      operationName: operationName,
      attemptRequest: (baseUrl) => attemptFetch(baseUrl),
    );
  }
}
