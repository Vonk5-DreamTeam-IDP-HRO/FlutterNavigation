import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/config/app_config.dart';
import 'package:osm_navigation/core/models/Route/SelectableNavigationRoute.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'IRouteApiService.dart';
import 'route_api_exceptions.dart';
import 'package:osm_navigation/core/services/api_exceptions.dart'
    as generic_api_exceptions;
import 'package:osm_navigation/core/utils/api_error_handler.dart'
    as api_error_handler;

/// RouteApiService implementation providing HTTP API operations for routes
///
/// **Architecture:** Clean Architecture - Infrastructure Layer
/// **Purpose:** Handles HTTP communication with the route backend API
/// **Features:**
/// - Primary/fallback URL resilience for server reliability
/// - Comprehensive error handling and mapping
/// - Structured logging for debugging
/// - Type-safe DTO transformations
///
/// **Error Handling Strategy:**
/// - Primary server attempt with automatic fallback
/// - Domain-specific exception mapping
/// - Detailed logging for troubleshooting
/// - Graceful degradation when servers are unavailable
class RouteApiService implements IRouteApiService {
  final Dio _dio;

  // Define primary and fallback base URLs
  static final String _primaryBaseApiUrl =
      '${AppConfig.url}:${AppConfig.backendApiPort}';
  static final String _fallbackBaseApiUrl =
      '${AppConfig.thijsApiUrl}:${AppConfig.localhostPort}';

  RouteApiService(this._dio);

  /// Maps generic API exceptions to domain-specific route exceptions
  RouteApiException _wrapGenericRouteApiException(
    generic_api_exceptions.ApiException e,
    String operationName,
  ) {
    if (e is generic_api_exceptions.ApiNetworkException) {
      return RouteApiNetworkException(
        e.message,
        statusCode: e.statusCode,
        statusMessage: e.statusMessage,
        uri: e.uri,
        originalException: e.originalException,
        stackTrace: e.stackTrace,
      );
    } else if (e is generic_api_exceptions.ApiNotFoundException) {
      return RouteNotFoundException(
        e.message,
        uri: e.uri,
        originalException: e.originalException,
        stackTrace: e.stackTrace,
      );
    } else if (e is generic_api_exceptions.ApiParseException) {
      return RouteApiParseException(
        e.message,
        originalException: e.originalException,
        stackTrace: e.stackTrace,
      );
    }
    // Fallback for other ApiException types
    return RouteApiException(
      e.message,
      originalException: e.originalException,
      stackTrace: e.stackTrace,
      statusCode:
          e is generic_api_exceptions.ApiNetworkException ? e.statusCode : null,
    );
  }

  /// Helper method to manage API requests with primary and fallback logic
  Future<T> _makeApiRequest<T>({
    required Future<T> Function(String baseUrl) attemptRequest,
    required String operationName,
  }) async {
    DioException? primaryError;
    String primaryErrorUrl = _primaryBaseApiUrl;

    try {
      debugPrint(
        '[RouteApiService] Attempting $operationName with primary URL: $_primaryBaseApiUrl',
      );
      return await attemptRequest(_primaryBaseApiUrl);
    } on DioException catch (e) {
      primaryError = e;
      primaryErrorUrl = e.requestOptions.uri.toString();
      debugPrint(
        '[RouteApiService] Primary URL request for $operationName failed (DioException): ${e.message}. Attempting fallback.',
      );
    } on RouteApiException catch (e) {
      primaryError = DioException(
        requestOptions: RequestOptions(path: 'unknown_primary_path'),
        error: e,
        message: e.message,
      );
      // Try to get URI from the RouteApiException if possible
      if (e is RouteApiNetworkException) {
        primaryErrorUrl = e.uri?.toString() ?? primaryErrorUrl;
      }
      if (e is RouteNotFoundException) {
        primaryErrorUrl = e.uri?.toString() ?? primaryErrorUrl;
      }
      debugPrint(
        '[RouteApiService] Primary URL request for $operationName failed (RouteApiException): ${e.message}. Attempting fallback.',
      );
    } catch (e) {
      // Catch other general errors from the attempt
      primaryError = DioException(
        requestOptions: RequestOptions(path: 'unknown_primary_path'),
        error: e,
        message:
            'A non-Dio error occurred during primary attempt: ${e.toString()}',
      );
      debugPrint(
        '[RouteApiService] Primary URL request for $operationName failed (General Error): $e. Attempting fallback.',
      );
    }

    // If primary attempt failed, try fallback
    // This is added because HRO server kept crashing outside our control
    // and we needed a way to get the app working again.
    try {
      debugPrint(
        '[RouteApiService] Attempting $operationName with fallback URL: $_fallbackBaseApiUrl',
      );
      return await attemptRequest(_fallbackBaseApiUrl);
    } on DioException catch (e) {
      debugPrint(
        '[RouteApiService] Fallback URL request for $operationName also failed (DioException): $e',
      );
      final genericException = api_error_handler.handleDioError(
        primaryError,
        operationName,
        primaryErrorUrl,
      );
      throw _wrapGenericRouteApiException(
        genericException as generic_api_exceptions.ApiException,
        operationName,
      );
    } catch (fallbackGeneralError) {
      // Catch other general errors from fallback
      debugPrint(
        '[RouteApiService] Fallback URL request for $operationName also failed with non-Dio error: $fallbackGeneralError',
      );
      final genericException = api_error_handler.handleDioError(
        primaryError,
        operationName,
        primaryErrorUrl,
      );
      throw _wrapGenericRouteApiException(
        genericException as generic_api_exceptions.ApiException,
        operationName,
      );
    }
  }

  @override
  Future<List<RouteDto>> getAllRoutes() async {
    const String operationName = 'fetching all routes';
    const String endpointPath = '/api/Route';

    return _makeApiRequest<List<RouteDto>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint('[RouteApiService] $operationName from URL: $fullUrl');
        try {
          final response = await _dio.get(fullUrl);
          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            return data
                .map((item) => RouteDto.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message: 'Failed to load routes: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[RouteApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          throw RouteApiParseException(
            'Error parsing $operationName response: ${e.toString()}',
            originalException: e,
            stackTrace: s,
          );
        }
      },
    );
  }

  @override
  Future<List<LocationDto>> getRouteLocations(String routeId) async {
    final String operationName = 'fetching locations for route $routeId';
    const String endpointPath = '/location_route';
    final Map<String, dynamic> queryParams = {
      'select': '*,locations:locationid(name,longitude,latitude)',
      'routeid': 'eq.$routeId',
    };

    return _makeApiRequest<List<LocationDto>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint(
          '[RouteApiService] $operationName from URL: $fullUrl with params: $queryParams',
        );
        try {
          final response = await _dio.get(
            fullUrl,
            queryParameters: queryParams,
          );
          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            final locations =
                data
                    .map(
                      (item) => LocationDto.fromJson(
                        item['locations'] as Map<String, dynamic>,
                      ),
                    )
                    .toList();
            debugPrint(
              '[RouteApiService] Successfully fetched ${locations.length} locations for route $routeId',
            );
            return locations;
          } else {
            throw DioException(
              requestOptions: RequestOptions(
                path: fullUrl,
                queryParameters: queryParams,
              ),
              response: response,
              message:
                  'Failed to load locations for route $routeId: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[RouteApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          throw RouteApiParseException(
            'Error parsing $operationName response: ${e.toString()}',
            originalException: e,
            stackTrace: s,
          );
        }
      },
    );
  }

  @override
  Future<List<SelectableNavigationRoute>> getSelectableRoutes() async {
    const String operationName = 'fetching selectable routes';
    const String endpointPath = '/api/Route/selectable';

    return _makeApiRequest<List<SelectableNavigationRoute>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint('[RouteApiService] $operationName from URL: $fullUrl');
        try {
          final response = await _dio.get(fullUrl);
          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            return data
                .map(
                  (item) => SelectableNavigationRoute.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message:
                  'Failed to load selectable routes: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[RouteApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          throw RouteApiParseException(
            'Error parsing $operationName response: ${e.toString()}',
            originalException: e,
            stackTrace: s,
          );
        }
      },
    );
  }

  @override
  Future<RouteDto?> getRouteById(String routeId) async {
    final String operationName = 'fetching route by ID $routeId';
    final String endpointPath = '/api/Route/$routeId';

    return _makeApiRequest<RouteDto?>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint('[RouteApiService] $operationName from URL: $fullUrl');
        try {
          final response = await _dio.get(fullUrl);
          if (response.statusCode == 200 && response.data != null) {
            return RouteDto.fromJson(response.data as Map<String, dynamic>);
          } else if (response.statusCode == 404) {
            // Return null for 404 instead of throwing exception
            // This matches the interface contract of returning RouteDto?
            return null;
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message: 'Failed to load route $routeId: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[RouteApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          throw RouteApiParseException(
            'Error parsing $operationName response: ${e.toString()}',
            originalException: e,
            stackTrace: s,
          );
        }
      },
    );
  }

  @override
  Future<RouteDto> addRoute(CreateRouteDto createRouteDto) async {
    const String operationName = 'adding new route';
    const String endpointPath = '/api/Route';

    return _makeApiRequest<RouteDto>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint(
          '[RouteApiService] $operationName at URL: $fullUrl with payload: ${createRouteDto.toJson()}',
        );
        try {
          final response = await _dio.post(
            fullUrl,
            data: createRouteDto.toJson(),
          );
          // C# controller returns 201 Created with the created route DTO in the body
          if (response.statusCode == 201 && response.data != null) {
            return RouteDto.fromJson(response.data as Map<String, dynamic>);
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message:
                  'Failed to add route: ${response.statusCode} - ${response.data?.toString() ?? "No data"}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[RouteApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          throw RouteApiParseException(
            'Error parsing $operationName response: ${e.toString()}',
            originalException: e,
            stackTrace: s,
          );
        }
      },
    );
  }
}
