import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/config/app_config.dart';
import 'package:osm_navigation/Core/models/location.dart';
import 'package:osm_navigation/Core/models/location_details.dart';
import 'package:osm_navigation/Core/models/route_dto.dart';
import 'package:osm_navigation/Core/models/selectable_location.dart';
import 'package:osm_navigation/Core/models/route_dtos.dart';
import 'IRouteApiService.dart';
import 'route_api_exceptions.dart';
import 'package:osm_navigation/Core/services/api_exceptions.dart'
    as generic_api_exceptions;
import 'package:osm_navigation/Core/utils/api_error_handler.dart'
    as api_error_handler;

class RouteApiService implements IRouteApiService {
  final Dio _dio;

  // Define primary and fallback base URLs
  static final String _primaryBaseApiUrl =
      '${AppConfig.url}:${AppConfig.backendApiPort}';
  static final String _fallbackBaseApiUrl =
      '${AppConfig.thijsApiUrl}:${AppConfig.localhostPort}';

  RouteApiService(this._dio);

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
        e.message, // The generic message already indicates parsing failure
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

  Future<T> _makeApiRequest<T>({
    required Future<T> Function(String baseUrl) attemptRequest,
    required String operationName,
  }) async {
    DioException? primaryError;
    String primaryErrorUrl =
        _primaryBaseApiUrl; // Store URL of primary attempt for error reporting

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
        '[RouteApiService] Primary URL request for $operationName failed (RouteApiException from attempt): ${e.message}. Attempting fallback.',
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
    // This is pure added because HRO server kept crashing outside our control
    // and we needed a way to get the app working again.
    try {
      debugPrint(
        '[RouteApiService] Attempting $operationName with fallback URL: $_fallbackBaseApiUrl',
      );
      return await attemptRequest(_fallbackBaseApiUrl);
    } on DioException catch (e) {
      // Changed to DioException
      debugPrint(
        '[RouteApiService] Fallback URL request for $operationName also failed (DioException): $e',
      );
      final genericException = api_error_handler.handleDioError(
        primaryError,
        operationName,
        primaryErrorUrl,
      );
      throw _wrapGenericRouteApiException(genericException, operationName);
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
      throw _wrapGenericRouteApiException(genericException, operationName);
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
            // Let _makeApiRequest handle DioException by rethrowing a new one for non-200s not caught by Dio itself
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message: 'Failed to load routes: ${response.statusCode}',
            );
          }
        } on DioException {
          // Re-throw DioExceptions to be caught by _makeApiRequest
          rethrow;
        } catch (e, s) {
          // Catch other unexpected errors
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
  Future<List<Location>> getRouteLocations(String routeId) async {
    final String operationName = 'fetching locations for route $routeId';
    final String endpointPath = '/location_route';
    final Map<String, dynamic> queryParams = {
      'select': '*,locations:locationid(name,longitude,latitude)',
      'routeid': 'eq.$routeId',
    };

    return _makeApiRequest<List<Location>>(
      // Renamed helper
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
  Future<List<SelectableLocation>> getSelectableLocations() async {
    const String operationName = 'fetching selectable locations';
    const String locationsEndpoint = '/locations'; // TODO: Confirm endpoint
    const String detailsEndpoint =
        '/location_details'; // TODO: Confirm endpoint

    return _makeApiRequest<List<SelectableLocation>>(
      // Renamed helper
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final locationsFullUrl = '$baseUrl$locationsEndpoint';
        final detailsFullUrl = '$baseUrl$detailsEndpoint';

        debugPrint(
          '[RouteApiService] $operationName (locations) from URL: $locationsFullUrl',
        );
        debugPrint(
          '[RouteApiService] $operationName (details) from URL: $detailsFullUrl',
        );

        try {
          // Perform requests in parallel
          final responses = await Future.wait([
            _dio.get(locationsFullUrl),
            _dio.get(detailsFullUrl),
          ]);

          final locationsResponse = responses[0];
          final detailsResponse = responses[1];

          if (locationsResponse.statusCode != 200 ||
              locationsResponse.data is! List) {
            throw DioException(
              requestOptions: RequestOptions(path: locationsFullUrl),
              response: locationsResponse,
              message:
                  'Failed to load locations: ${locationsResponse.statusCode}',
            );
          }
          if (detailsResponse.statusCode != 200 ||
              detailsResponse.data is! List) {
            throw DioException(
              requestOptions: RequestOptions(path: detailsFullUrl),
              response: detailsResponse,
              message:
                  'Failed to load location details: ${detailsResponse.statusCode}',
            );
          }
          final List<dynamic> locationsData = locationsResponse.data;
          final List<dynamic> detailsData = detailsResponse.data;

          // Create a map of Location Uuid to Category from detailsData
          final Map<String, String> categoryMap = {};
          for (var detailItemJson in detailsData) {
            if (detailItemJson is Map<String, dynamic>) {
              try {
                // Assuming LocationDetails.fromJson correctly parses locationId as Uuid
                final detail = LocationDetails.fromJson(detailItemJson);
                categoryMap[detail.locationId] =
                    detail.category ?? 'Uncategorized';
              } catch (e, s) {
                debugPrint(
                  '[RouteApiService] Error parsing LocationDetails item in getSelectableLocations: $e. JSON: $detailItemJson',
                );
                // Optionally skip this item or rethrow as a RouteApiParseException
                throw RouteApiParseException(
                  'Error parsing LocationDetails item in getSelectableLocations: ${e.toString()}',
                  originalException: e,
                  stackTrace: s,
                );
              }
            }
          }

          //Create SelectableLocation list from locationsData, using categoryMap
          final List<SelectableLocation> selectableLocations = [];
          for (var locationItemJson in locationsData) {
            if (locationItemJson is Map<String, dynamic>) {
              try {
                // Assume 'locationId' (or 'locationid') from locationsData is a String Guid
                // The C# SelectableLocationDto has Guid LocationId, so API should send string.
                // Prioritize 'locationId', fallback to 'locationid'
                final locationIdString =
                    locationItemJson['locationId'] as String? ??
                    locationItemJson['locationid'] as String?;
                final name = locationItemJson['name'] as String?;

                if (locationIdString == null) {
                  debugPrint(
                    '[RouteApiService] Missing locationId in locationItemJson: $locationItemJson',
                  );
                  continue; // Skip this item
                }
                if (name == null) {
                  debugPrint(
                    '[RouteApiService] Missing name in locationItemJson: $locationItemJson',
                  );
                  continue; // Skip this item
                }

                final category =
                    categoryMap[locationIdString] ?? 'Uncategorized';

                // Using SelectableLocation's constructor directly as per current structure.
                // SelectableLocation.locationId now expects a String.
                selectableLocations.add(
                  SelectableLocation(
                    locationId: locationIdString,
                    name: name,
                    category: category,
                  ),
                );
              } catch (e, s) {
                debugPrint(
                  '[RouteApiService] Error processing locationItemJson in getSelectableLocations: $e. JSON: $locationItemJson',
                );
                // Optionally skip or rethrow
                throw RouteApiParseException(
                  'Error processing locationItemJson in getSelectableLocations: ${e.toString()}',
                  originalException: e,
                  stackTrace: s,
                );
              }
            }
          }
          debugPrint(
            '[RouteApiService] Successfully fetched and combined ${selectableLocations.length} selectable locations from $baseUrl',
          );
          return selectableLocations;
        } on DioException {
          rethrow; // Let _makeApiRequest handle it
        } catch (e, s) {
          // Catch other unexpected errors (e.g. model parsing issues)
          debugPrint(
            '[RouteApiService] Unexpected error in $operationName attempt: $e',
          );
          throw RouteApiParseException(
            'Error processing $operationName response: ${e.toString()}',
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
            throw RouteNotFoundException(
              'Route with ID $routeId not found at $fullUrl.',
              uri: Uri.parse(fullUrl),
            );
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message: 'Failed to load route $routeId: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } on RouteNotFoundException {
          rethrow; // Allow specific exceptions to pass through _makeApiRequest
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
            // Let _makeApiRequest handle DioException by rethrowing a new one
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
