import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/status_code_response_dto.dart';
import 'ILocationApiService.dart';
import 'package:osm_navigation/core/config/app_config.dart';

class LocationApiService implements ILocationApiService {
  final Dio _dio;

  static final String _primaryBaseApiUrl =
      '${AppConfig.url}:${AppConfig.backendApiPort}';
  static final String _fallbackBaseApiUrl =
      '${AppConfig.thijsApiUrl}:${AppConfig.localhostPort}';

  LocationApiService(this._dio);

  // Helper method to manage API requests with primary and fallback logic
  Future<StatusCodeResponseDto<T>> _makeApiRequest<T>({
    required Future<StatusCodeResponseDto<T>> Function(String baseUrl)
    attemptRequest,
    required String operationName,
  }) async {
    debugPrint('\n=== STARTING OPERATION: $operationName ===');
    StatusCodeResponseDto<T> result;

    // Try primary URL
    debugPrint(
      'Attempting $operationName with primary URL: $_primaryBaseApiUrl',
    );
    try {
      result = await attemptRequest(_primaryBaseApiUrl);
      if (result.statusCodeResponse == StatusCodeResponse.success ||
          result.statusCodeResponse == StatusCodeResponse.created ||
          result.statusCodeResponse == StatusCodeResponse.noContent) {
        debugPrint('$operationName SUCCEEDED on primary URL.');
        debugPrint('=== OPERATION ENDED: $operationName ===\n');
        return result;
      }
      debugPrint(
        '$operationName FAILED on primary URL with status: ${result.statusCodeResponse.name}. Message: ${result.message}. Trying fallback.',
      );
    } catch (e, s) {
      debugPrint(
        'Exception during $operationName on primary URL: $_primaryBaseApiUrl. Error: $e. Stacktrace: $s. Trying fallback.',
      );
      // Store primary error details if needed for a final error DTO, though typically the fallback's error is more relevant if it also fails.
    }

    // Try fallback URL
    debugPrint(
      'Attempting $operationName with fallback URL: $_fallbackBaseApiUrl',
    );
    try {
      result = await attemptRequest(_fallbackBaseApiUrl);
      if (result.statusCodeResponse == StatusCodeResponse.success ||
          result.statusCodeResponse == StatusCodeResponse.created ||
          result.statusCodeResponse == StatusCodeResponse.noContent) {
        debugPrint('$operationName SUCCEEDED on fallback URL.');
      } else {
        debugPrint(
          '$operationName FAILED on fallback URL with status: ${result.statusCodeResponse.name}. Message: ${result.message}.',
        );
      }
    } catch (e, s) {
      debugPrint(
        'Exception during $operationName on fallback URL: $_fallbackBaseApiUrl. Error: $e. Stacktrace: $s.',
      );
      result = StatusCodeResponseDto(
        statusCodeResponse: StatusCodeResponse.internalServerError,
        message:
            'Both primary and fallback attempts for $operationName failed with exceptions. Fallback error: ${e.toString()}',
        data: null,
      );
    }
    debugPrint('=== OPERATION ENDED: $operationName ===\n');
    return result;
  }

  @override
  Future<StatusCodeResponseDto<List<LocationDto>>> getAllLocations() async {
    const String operationName = 'Get All Locations';
    const String endpoint = 'api/Location';

    return _makeApiRequest<List<LocationDto>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);

          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            final locations =
                data
                    .map(
                      (json) =>
                          LocationDto.fromJson(json as Map<String, dynamic>),
                    )
                    .toList();
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: locations,
              message: '$operationName successful.',
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<LocationDto?>> getLocationById(String id) async {
    final String operationName = 'Get Location By ID $id';
    final String endpoint = 'api/Location/$id';

    return _makeApiRequest<LocationDto?>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 200 && response.data != null) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: LocationDto.fromJson(response.data as Map<String, dynamic>),
              message: '$operationName successful.',
            );
          } else if (response.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message: 'Location with ID $id not found.',
              data: null,
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          if (e.response?.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message:
                  e.response?.data?['message']?.toString() ??
                  'Location with ID $id not found.',
              data: null,
            );
          }
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<List<LocationDto>>> getLocationsByType(
    String category,
  ) async {
    final String operationName = 'Get Locations By Type $category';
    final String endpoint =
        'api/Location/ByType/$category'; // Assuming this endpoint exists

    return _makeApiRequest<List<LocationDto>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            final locations =
                data
                    .map(
                      (json) =>
                          LocationDto.fromJson(json as Map<String, dynamic>),
                    )
                    .toList();
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: locations,
              message: '$operationName successful.',
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown error for category $category"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<LocationDto?>> createLocation(
    CreateLocationDto payload,
  ) async {
    const String operationName = 'Create Location';
    const String endpoint = 'api/Location';

    return _makeApiRequest<LocationDto?>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        final jsonData = payload.toJson();
        debugPrint('  Attempting $operationName at: $fullUrl (Method: POST)');
        debugPrint('  Request Body: $jsonData');
        try {
          final response = await _dio.post(fullUrl, data: jsonData);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 201 && response.data != null) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.created,
              data: LocationDto.fromJson(response.data as Map<String, dynamic>),
              message:
                  'Location created successfully with ID: ${(response.data as Map<String, dynamic>)['id']}',
            );
          } else {
            // Handle cases where API might return 200 OK on create
            if (response.statusCode == 200 && response.data != null) {
              return StatusCodeResponseDto(
                statusCodeResponse:
                    StatusCodeResponse
                        .success, // Or .created if that's more semantically correct for your API
                data: LocationDto.fromJson(
                  response.data as Map<String, dynamic>,
                ),
                message:
                    'Location created (API returned 200 OK). ID: ${(response.data as Map<String, dynamic>)['id']}',
              );
            }
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.data?['message']?.toString() ?? response.statusMessage ?? "Unknown error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<LocationDto?>> updateLocation(
    String id,
    UpdateLocationDto payload,
  ) async {
    final String operationName = 'Update Location $id';
    final String endpoint = 'api/Location/$id';

    return _makeApiRequest<LocationDto?>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        final jsonData = payload.toJson();
        debugPrint('  Attempting $operationName at: $fullUrl (Method: PUT)');
        debugPrint('  Request Body: $jsonData');
        try {
          final response = await _dio.put(fullUrl, data: jsonData);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 200 && response.data != null) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: LocationDto.fromJson(response.data as Map<String, dynamic>),
              message: 'Location with ID $id updated successfully.',
            );
          } else if (response.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message: 'Location with ID $id not found for update.',
              data: null,
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.data?['message']?.toString() ?? response.statusMessage ?? "Unknown error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          if (e.response?.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message:
                  e.response?.data?['message']?.toString() ??
                  'Location with ID $id not found for update.',
              data: null,
            );
          }
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<bool>> deleteLocation(String id) async {
    final String operationName = 'Delete Location $id';
    final String endpoint = 'api/Location/$id';

    return _makeApiRequest<bool>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('  Attempting $operationName at: $fullUrl (Method: DELETE)');
        try {
          final response = await _dio.delete(fullUrl);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 200 || response.statusCode == 204) {
            bool successValue = true;
            // If backend sends a boolean in response.data for 200
            if (response.statusCode == 200 &&
                response.data is Map &&
                response.data['data'] is bool) {
              successValue = response.data['data'];
            } else if (response.statusCode == 200 && response.data is bool) {
              successValue = response.data;
            }
            return StatusCodeResponseDto(
              statusCodeResponse:
                  response.statusCode == 204
                      ? StatusCodeResponse.noContent
                      : StatusCodeResponse.success,
              data: successValue,
              message: 'Location with ID $id deleted successfully.',
            );
          } else if (response.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message: 'Location with ID $id not found for deletion.',
              data: false,
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.data?['message']?.toString() ?? response.statusMessage ?? "Unknown error"}',
              data: false,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          if (e.response?.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message:
                  e.response?.data?['message']?.toString() ??
                  'Location with ID $id not found for deletion.',
              data: false,
            );
          }
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: false,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: false,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<Map<String, List<SelectableLocationDto>>>>
  getGroupedSelectableLocations() async {
    const String operationName = 'Get Grouped Selectable Locations';
    const String endpoint = 'api/Location/GroupedSelectableLocations';

    return _makeApiRequest<Map<String, List<SelectableLocationDto>>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 200 && response.data is Map) {
            final Map<String, dynamic> data =
                response.data as Map<String, dynamic>;
            final Map<String, List<SelectableLocationDto>> groupedLocations =
                {};
            data.forEach((category, locationsJson) {
              if (locationsJson is List) {
                groupedLocations[category] =
                    locationsJson
                        .map(
                          (json) => SelectableLocationDto.fromJson(
                            json as Map<String, dynamic>,
                          ),
                        )
                        .toList();
              }
            });
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: groupedLocations,
              message: '$operationName successful.',
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<List<SelectableLocationDto>>>
  getSelectableLocations() async {
    const String operationName = 'Get Selectable Locations';
    const String endpoint = 'api/Location/selectable';

    return _makeApiRequest<List<SelectableLocationDto>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            final locations =
                data
                    .map(
                      (json) => SelectableLocationDto.fromJson(
                        json as Map<String, dynamic>,
                      ),
                    )
                    .toList();
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: locations,
              message: '$operationName successful.',
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<List<String>>> getUniqueCategories() async {
    const String operationName = 'Get Unique Categories';
    const String endpoint = 'api/Location/categories';

    return _makeApiRequest<List<String>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl/$endpoint';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status: ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data: ${response.data}');

          if (response.statusCode == 200 && response.data is List) {
            final List<dynamic> data = response.data;
            final categories = data.whereType<String>().toList();
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: categories,
              message: '$operationName successful.',
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          debugPrint('  DioException Response: ${e.response?.data}');
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error during $operationName.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error during $operationName: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }
}
