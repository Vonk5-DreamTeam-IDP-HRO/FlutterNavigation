import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/models/location.dart';
import 'package:osm_navigation/core/models/location_details.dart';
import 'package:osm_navigation/core/models/location_request_dtos.dart';
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'i_location_api_service.dart';
import 'location_api_exceptions.dart';
import 'package:osm_navigation/core/config/app_config.dart';

// --- Concrete Implementation of the Location API Service ---
// Provides the actual implementation for fetching location data using Dio.
class LocationApiService implements ILocationApiService {
  final Dio _dio;

  // Define primary and fallback base URLs
  static final String _primaryBaseApiUrl =
      '${AppConfig.url}:${AppConfig.backendApiPort}';
  static final String _fallbackBaseApiUrl =
      '${AppConfig.thijsApiUrl}:${AppConfig.tempRESTPort}';

  // Constructor requires a pre-configured Dio instance.
  LocationApiService(this._dio);

  // Helper to handle Dio errors and convert them to custom exceptions
  LocationApiException _handleDioError(
    DioException e,
    String operation,
    String urlAttempted,
  ) {
    debugPrint(
      '[LocationApiService] DioError during $operation at $urlAttempted: ${e.message}',
    );
    if (e.response != null) {
      return LocationApiNetworkException(
        'Network error during $operation: ${e.response?.statusCode}',
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
        uri: e.requestOptions.uri,
        originalException: e,
        stackTrace: e.stackTrace,
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return LocationApiNetworkException(
        'Request timed out during $operation',
        uri: e.requestOptions.uri,
        originalException: e,
        stackTrace: e.stackTrace,
      );
    }
    // Use named parameters as per the updated LocationApiException constructor
    return LocationApiException(
      'Failed $operation: ${e.message}',
      stackTrace: e.stackTrace,
      originalException: e,
    );
  }

  // Helper method to manage API requests with primary and fallback logic
  Future<T> _makeApiRequest<T>({
    required Future<T> Function(String baseUrl) attemptRequest,
    required String
    operationName, // For logging and error handling in _handleDioError
  }) async {
    DioException? primaryError;
    String primaryErrorUrl = _primaryBaseApiUrl;

    try {
      debugPrint(
        '[LocationApiService] Attempting $operationName with primary URL: $_primaryBaseApiUrl',
      );
      return await attemptRequest(_primaryBaseApiUrl);
    } on DioException catch (e) {
      primaryError = e;
      primaryErrorUrl =
          e.requestOptions.uri
              .toString(); // Get the actual URL from the request
      debugPrint(
        '[LocationApiService] Primary URL request for $operationName failed: $e. Attempting fallback.',
      );
    } catch (e) {
      // Catch non-Dio exceptions from the first attempt
      debugPrint(
        '[LocationApiService] Primary URL request for $operationName failed with non-Dio error: $e. Attempting fallback.',
      );
      // We don't have a DioException here, so we'll just rethrow if fallback also fails with a generic message.
      // Or, wrap it in a generic LocationApiException if preferred.
      // For now, let fallback attempt proceed.
    }

    // If primary attempt failed, try fallback
    try {
      debugPrint(
        '[LocationApiService] Attempting $operationName with fallback URL: $_fallbackBaseApiUrl',
      );
      return await attemptRequest(_fallbackBaseApiUrl);
    } on DioException catch (e) {
      debugPrint(
        '[LocationApiService] Fallback URL request for $operationName also failed: $e',
      );
      // If primary also had a DioError, use that for more specific error handling
      // Otherwise, use the fallback error.
      throw _handleDioError(e, operationName, e.requestOptions.uri.toString());
    } catch (fallbackGeneralError) {
      debugPrint(
        '[LocationApiService] Fallback URL request for $operationName also failed with non-Dio error: $fallbackGeneralError',
      );
      if (primaryError != null) {
        // Prefer to report the primary Dio error if it existed, as it was the first point of failure.
        throw _handleDioError(primaryError, operationName, primaryErrorUrl);
      }
      // If primary attempt also had a non-Dio error, or if primary succeeded but something else went wrong before fallback
      // we throw a more generic exception.
      throw LocationApiException(
        'All API attempts for $operationName failed. Primary error: ${primaryError?.message ?? "Non-Dio error"}, Fallback error: ${fallbackGeneralError.toString()}',
        originalException: fallbackGeneralError,
      );
    }
  }

  // --- New CRUD Methods ---

  @override
  Future<List<Location>> getAllLocations() async {
    const String operationName = 'fetching all locations';
    const String endpoint = 'api/Location';

    return _makeApiRequest<List<Location>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        // debugPrint is now handled by _makeApiRequest for the attempt itself
        // debugPrint('[LocationApiService] Fetching all locations from: $fullUrl');
        try {
          final response = await _dio.get(fullUrl);
          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            return data
                .map((json) => Location.fromJson(json as Map<String, dynamic>))
                .toList();
          } else {
            // Throw a DioException to be handled by _makeApiRequest or _handleDioError
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message: 'Failed to load locations: ${response.statusCode}',
            );
          }
        } on DioException {
          // Re-throw DioExceptions to be caught by _makeApiRequest
          rethrow;
        } catch (e, s) {
          // Catch other unexpected errors from this attempt
          debugPrint(
            '[LocationApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          // Wrap in a LocationApiException or rethrow as a generic error
          // For _makeApiRequest to handle it, it's better to ensure it's an exception it expects or can pass through.
          // Throwing a new DioException might be misleading if it wasn't a Dio error originally.
          // For now, let's wrap in LocationApiException to signify it's from our service logic.
          throw LocationApiException(
            'An unexpected error occurred during $operationName attempt: ${e.toString()}',
            stackTrace: s,
            originalException: e,
          );
        }
      },
    );
  }

  @override
  Future<LocationDetails> getLocationById(int id) async {
    final String operationName = 'fetching location by ID $id';
    final String endpoint = 'api/Location/$id';

    return _makeApiRequest<LocationDetails>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        try {
          final response = await _dio.get(fullUrl);
          if (response.statusCode == 200 && response.data != null) {
            return LocationDetails.fromJson(
              response.data as Map<String, dynamic>,
            );
          } else if (response.statusCode == 404) {
            // For 404, we throw a specific exception that might not warrant a retry.
            // _makeApiRequest will catch this and, if it's the primary attempt,
            // it might still try the fallback depending on its internal logic.
            // However, a 404 is often a "definitive" client error.
            throw LocationNotFoundException(
              'Location with ID $id not found at $fullUrl.',
              errorData: response.data,
            );
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message: 'Failed to load location $id: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } on LocationNotFoundException {
          // Allow specific exceptions to pass through
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[LocationApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          if (e.toString().contains("parameter 'category' isn't defined")) {
            throw LocationApiParseException(
              'Error parsing LocationDetails for ID $id during $operationName attempt at $fullUrl due to category issue: ${e.toString()}',
              stackTrace: s,
              originalException: e,
            );
          }
          throw LocationApiException(
            'An unexpected error occurred during $operationName attempt: ${e.toString()}',
            stackTrace: s,
            originalException: e,
          );
        }
      },
    );
  }

  @override
  Future<List<Location>> getLocationsByType(String category) async {
    final String operationName = 'fetching locations by type $category';
    final String endpoint = 'api/Location/ByType/$category';

    return _makeApiRequest<List<Location>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        try {
          final response = await _dio.get(fullUrl);
          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            return data
                .map((json) => Location.fromJson(json as Map<String, dynamic>))
                .toList();
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message:
                  'Failed to load locations for category $category: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[LocationApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          throw LocationApiException(
            'An unexpected error occurred during $operationName attempt: ${e.toString()}',
            stackTrace: s,
            originalException: e,
          );
        }
      },
    );
  }

  @override
  Future<LocationDetails> createLocation(CreateLocationPayload payload) async {
    const String operationName = 'creating location';
    const String endpoint = 'api/Location';

    return _makeApiRequest<LocationDetails>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint(
          '[LocationApiService] $operationName at: $fullUrl with payload: ${payload.toJson()}',
        );
        try {
          final response = await _dio.post(fullUrl, data: payload.toJson());
          if (response.statusCode == 201 && response.data != null) {
            return LocationDetails.fromJson(
              response.data as Map<String, dynamic>,
            );
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message:
                  'Failed to create location: ${response.statusCode} - ${response.data?.toString() ?? "No data"}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[LocationApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          if (e.toString().contains("parameter 'category' isn't defined")) {
            throw LocationApiParseException(
              'Error parsing created LocationDetails during $operationName attempt at $fullUrl due to category issue: ${e.toString()}',
              stackTrace: s,
              originalException: e,
            );
          }
          throw LocationApiException(
            'An unexpected error occurred during $operationName attempt: ${e.toString()}',
            stackTrace: s,
            originalException: e,
          );
        }
      },
    );
  }

  @override
  Future<LocationDetails> updateLocation(
    int id,
    UpdateLocationPayload payload,
  ) async {
    final String operationName = 'updating location $id';
    final String endpoint = 'api/Location/$id';

    return _makeApiRequest<LocationDetails>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint(
          '[LocationApiService] $operationName at: $fullUrl with payload: ${payload.toJson()}',
        );
        try {
          final response = await _dio.put(fullUrl, data: payload.toJson());
          if (response.statusCode == 200 && response.data != null) {
            return LocationDetails.fromJson(
              response.data as Map<String, dynamic>,
            );
          } else if (response.statusCode == 404) {
            throw LocationNotFoundException(
              'Location with ID $id not found for update at $fullUrl.',
              errorData: response.data,
            );
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message:
                  'Failed to update location $id: ${response.statusCode} - ${response.data?.toString() ?? "No data"}',
            );
          }
        } on DioException {
          rethrow;
        } on LocationNotFoundException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[LocationApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          // Note: Original code didn't have specific parsing error check here,
          // but it's good practice if applicable for the response of an update.
          throw LocationApiException(
            'An unexpected error occurred during $operationName attempt: ${e.toString()}',
            stackTrace: s,
            originalException: e,
          );
        }
      },
    );
  }

  @override
  Future<void> deleteLocation(int id) async {
    final String operationName = 'deleting location $id';
    final String endpoint = 'api/Location/$id';

    return _makeApiRequest<void>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('[LocationApiService] $operationName at: $fullUrl');
        try {
          final response = await _dio.delete(fullUrl);
          // Successful deletion typically returns 204 No Content
          if (response.statusCode != 204) {
            // Also check for 200 or 202 if the API might return those on delete
            // For now, strictly 204
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message:
                  'Failed to delete location $id: ${response.statusCode}, Data: ${response.data?.toString() ?? "No data"}',
            );
          }
          // No return value for void
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[LocationApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          throw LocationApiException(
            'An unexpected error occurred during $operationName attempt: ${e.toString()}',
            stackTrace: s,
            originalException: e,
          );
        }
      },
    );
  }

  @override
  Future<Map<String, List<SelectableLocation>>>
  getGroupedSelectableLocations() async {
    const String operationName = 'fetching grouped selectable locations';
    // Assuming an endpoint like this based on typical API design and the C# controller action name.
    // This needs to be confirmed with the actual backend API documentation.
    const String endpoint = 'api/Location/GroupedSelectableLocations';

    return _makeApiRequest<Map<String, List<SelectableLocation>>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        try {
          final response = await _dio.get(fullUrl);
          if (response.statusCode == 200 && response.data is Map) {
            final Map<String, dynamic> data =
                response.data as Map<String, dynamic>;

            // The backend sends Map<string, List<SomeSelectableLocationDto>>
            // We need to parse this into Map<String, List<SelectableLocation>>
            final Map<String, List<SelectableLocation>> groupedLocations = {};
            data.forEach((category, locationsJson) {
              if (locationsJson is List) {
                groupedLocations[category] =
                    locationsJson
                        .map(
                          (json) => SelectableLocation(
                            locationId:
                                json['locationId']
                                    as int, // Assuming DTO fields
                            name: json['name'] as String,
                            category: json['category'] as String,
                          ),
                        )
                        .toList();
              }
            });
            return groupedLocations;
          } else {
            throw DioException(
              requestOptions: RequestOptions(path: fullUrl),
              response: response,
              message:
                  'Failed to load grouped selectable locations: ${response.statusCode}',
            );
          }
        } on DioException {
          rethrow;
        } catch (e, s) {
          debugPrint(
            '[LocationApiService] Unexpected error in $operationName attempt at $fullUrl: $e',
          );
          // Check if it's a parsing error related to SelectableLocation structure
          if (e.toString().contains('locationId') ||
              e.toString().contains('name') ||
              e.toString().contains('category')) {
            throw LocationApiParseException(
              'Error parsing $operationName response from $fullUrl: ${e.toString()}',
              stackTrace: s,
              originalException: e,
            );
          }
          throw LocationApiException(
            'An unexpected error occurred during $operationName attempt: ${e.toString()}',
            stackTrace: s,
            originalException: e,
          );
        }
      },
    );
  }
}
