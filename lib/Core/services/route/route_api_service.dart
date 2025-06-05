import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/config/app_config.dart';
import 'package:osm_navigation/core/models/Route/SelectableNavigationRoute.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/status_code_response_dto.dart';
import 'IRouteApiService.dart';

class RouteApiService implements IRouteApiService {
  final Dio _dio;
  static String get _primaryBaseApiUrl =>
      '${AppConfig.url}:${AppConfig.backendApiPort}';
  static String get _fallbackBaseApiUrl =>
      '${AppConfig.thijsApiUrl}:${AppConfig.backendApiPort}';

  RouteApiService(this._dio);

  Future<StatusCodeResponseDto<T>> _makeApiRequest<T>({
    required Future<StatusCodeResponseDto<T>> Function(String baseUrl)
    attemptRequest,
    required String operationName,
  }) async {
    debugPrint('\n=== STARTING OPERATION: $operationName ===');
    StatusCodeResponseDto<T> result;

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
        '$operationName FAILED on primary URL with status: ${result.statusCodeResponse}. Message: ${result.message}. Trying fallback.',
      );
    } catch (e, s) {
      debugPrint(
        'Exception during $operationName on primary URL: $_primaryBaseApiUrl. Error: $e. Stacktrace: $s. Trying fallback.',
      );
      result = StatusCodeResponseDto(
        statusCodeResponse: StatusCodeResponse.internalServerError,
        message:
            'Primary attempt for $operationName failed with exception: ${e.toString()}',
        data: null,
      );
    }

    if (!result.isSuccess) {
      debugPrint(
        'Attempting $operationName with fallback URL: $_fallbackBaseApiUrl',
      );
      try {
        result = await attemptRequest(_fallbackBaseApiUrl);
        if (result.isSuccess) {
          debugPrint('$operationName SUCCEEDED on fallback URL.');
        } else {
          debugPrint(
            '$operationName FAILED on fallback URL with status: ${result.statusCodeResponse}. Message: ${result.message}.',
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
    }
    debugPrint('=== OPERATION ENDED: $operationName ===\n');
    return result;
  }

  @override
  Future<StatusCodeResponseDto<List<RouteDto>>> getAllRoutes() async {
    const String operationName = 'Get All Routes';
    const String endpointPath = '/api/Route';

    return _makeApiRequest<List<RouteDto>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status (HTTP): ${response.statusCode}');
          debugPrint('  Response Headers: ${response.headers}');
          debugPrint('  Response Data (Raw): ${response.data}');

          if (response.statusCode == 200 &&
              response.data is Map<String, dynamic>) {
            final responseMap = response.data as Map<String, dynamic>;
            final int appStatusCode =
                responseMap['statusCodeResponse'] as int? ??
                responseMap['statusCode'] as int? ??
                0;
            final String? appMessage = responseMap['message'] as String?;

            if ((appStatusCode == 200 ||
                    appStatusCode ==
                        200) && // Using actual status code instead of enum code
                responseMap['data'] is List) {
              final List<dynamic> routesData =
                  responseMap['data'] as List<dynamic>;
              final routes =
                  routesData
                      .map(
                        (item) =>
                            RouteDto.fromJson(item as Map<String, dynamic>),
                      )
                      .toList();
              debugPrint(
                '  Successfully parsed ${routes.length} routes from response data key.',
              );
              return StatusCodeResponseDto(
                statusCodeResponse: StatusCodeResponse.success,
                data: routes,
                message: appMessage ?? '$operationName successful.',
              );
            } else {
              // Application level error or data is not a list
              debugPrint(
                '  Application level error or data key is not a list. AppStatusCode: $appStatusCode, Message: $appMessage',
              );
              return StatusCodeResponseDto(
                statusCodeResponse: StatusCodeResponse.fromCode(appStatusCode),
                message:
                    appMessage ??
                    '$operationName failed: Unexpected data structure in response.',
                data: null,
              );
            }
          } else if (response.statusCode == 200 && response.data is List) {
            // Fallback: if the API directly returns a list of routes (older or different endpoint version)
            final List<dynamic> data = response.data;
            final routes =
                data
                    .map(
                      (item) => RouteDto.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
            debugPrint(
              '  Successfully parsed ${routes.length} routes directly from response list.',
            );
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: routes,
              message: '$operationName successful (direct list).',
            );
          } else {
            // HTTP error or unexpected response.data type
            debugPrint(
              '  HTTP error or unexpected response data type. HTTP Status: ${response.statusCode}',
            );
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown HTTP error"}',
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
  Future<StatusCodeResponseDto<List<LocationDto>>> getRouteLocations(
    String routeId,
  ) async {
    final String operationName = 'Get Locations for Route $routeId';
    final String endpointPath = '/api/Route/$routeId';

    return _makeApiRequest<List<LocationDto>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status (HTTP): ${response.statusCode}');
          debugPrint('  Response Data (Raw): ${response.data}');

          if (response.statusCode == 200) {
            if (response.data is Map<String, dynamic>) {
              final responseMap = response.data as Map<String, dynamic>;
              final int appStatusCode =
                  responseMap['statusCodeResponse'] as int? ??
                  responseMap['statusCode'] as int? ??
                  0;
              final String? appMessage = responseMap['message'] as String?;

              if ((appStatusCode == 200) && responseMap['data'] is List) {
                final List<dynamic> locationsData =
                    responseMap['data'] as List<dynamic>;
                final locations =
                    locationsData
                        .map(
                          (item) => LocationDto.fromJson(
                            item as Map<String, dynamic>,
                          ),
                        )
                        .toList();
                return StatusCodeResponseDto(
                  statusCodeResponse: StatusCodeResponse.success,
                  data: locations,
                  message: appMessage ?? '$operationName successful.',
                );
              } else {
                return StatusCodeResponseDto(
                  statusCodeResponse: StatusCodeResponse.fromCode(
                    appStatusCode,
                  ),
                  message:
                      appMessage ??
                      '$operationName failed: Unexpected data structure.',
                  data: null,
                );
              }
            }
          } else if (response.data is List) {
            final List<dynamic> data = response.data;
            final locations =
                data
                    .map(
                      (item) =>
                          LocationDto.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.success,
              data: locations,
              message: '$operationName successful (direct list).',
            );
          }

          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              response.statusCode ?? 500,
            ),
            message:
                '$operationName failed: ${response.statusMessage ?? "Unknown error"}',
            data: null,
          );
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<List<SelectableNavigationRoute>>>
  getSelectableRoutes() async {
    const String operationName = 'Get Selectable Routes';
    const String endpointPath = '/api/Route/selectable';

    return _makeApiRequest<List<SelectableNavigationRoute>>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status (HTTP): ${response.statusCode}');
          debugPrint('  Response Data (Raw): ${response.data}');

          if (response.statusCode == 200) {
            if (response.data is Map<String, dynamic>) {
              final responseMap = response.data as Map<String, dynamic>;
              final int appStatusCode =
                  responseMap['statusCodeResponse'] as int? ??
                  responseMap['statusCode'] as int? ??
                  0;
              final String? appMessage = responseMap['message'] as String?;

              if (appStatusCode == 200 && responseMap['data'] is List) {
                final List<dynamic> routesData =
                    responseMap['data'] as List<dynamic>;
                final routes =
                    routesData
                        .map(
                          (item) => SelectableNavigationRoute.fromJson(
                            item as Map<String, dynamic>,
                          ),
                        )
                        .toList();
                return StatusCodeResponseDto(
                  statusCodeResponse: StatusCodeResponse.success,
                  data: routes,
                  message: appMessage ?? '$operationName successful.',
                );
              } else {
                return StatusCodeResponseDto(
                  statusCodeResponse: StatusCodeResponse.fromCode(
                    appStatusCode,
                  ),
                  message:
                      appMessage ??
                      '$operationName failed: Unexpected data structure.',
                  data: null,
                );
              }
            } else if (response.data is List) {
              final List<dynamic> data = response.data;
              final routes =
                  data
                      .map(
                        (item) => SelectableNavigationRoute.fromJson(
                          item as Map<String, dynamic>,
                        ),
                      )
                      .toList();
              return StatusCodeResponseDto(
                statusCodeResponse: StatusCodeResponse.success,
                data: routes,
                message: '$operationName successful (direct list).',
              );
            }
          }
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              response.statusCode ?? 500,
            ),
            message:
                '$operationName failed: ${response.statusMessage ?? "Unknown error"}',
            data: null,
          );
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<RouteDto?>> getRouteById(String routeId) async {
    final String operationName = 'Get Route By ID $routeId';
    final String endpointPath = '/api/Route/$routeId';

    return _makeApiRequest<RouteDto?>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        debugPrint('  Attempting $operationName from: $fullUrl (Method: GET)');
        try {
          final response = await _dio.get(fullUrl);
          debugPrint('  Response Status (HTTP): ${response.statusCode}');
          debugPrint('  Response Data (Raw): ${response.data}');

          if (response.statusCode == 200 &&
              response.data is Map<String, dynamic>) {
            final responseMap = response.data as Map<String, dynamic>;
            final int appStatusCode =
                responseMap['statusCodeResponse'] as int? ??
                responseMap['statusCode'] as int? ??
                0;
            final String? appMessage = responseMap['message'] as String?;

            if (appStatusCode == 200 && responseMap['data'] != null) {
              return StatusCodeResponseDto(
                statusCodeResponse: StatusCodeResponse.success,
                data: RouteDto.fromJson(
                  responseMap['data'] as Map<String, dynamic>,
                ),
                message: appMessage ?? '$operationName successful.',
              );
            } else if (appStatusCode == 404) {
              return StatusCodeResponseDto(
                statusCodeResponse: StatusCodeResponse.notFound,
                message: appMessage ?? 'Route with ID $routeId not found.',
                data: null,
              );
            } else {
              return StatusCodeResponseDto(
                statusCodeResponse: StatusCodeResponse.fromCode(appStatusCode),
                message:
                    appMessage ??
                    '$operationName failed: Unexpected data structure or error in response.',
                data: null,
              );
            }
          } else if (response.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message: 'Route with ID $routeId not found (HTTP 404).',
              data: null,
            );
          } else {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.fromCode(
                response.statusCode ?? 500,
              ),
              message:
                  '$operationName failed: ${response.statusMessage ?? "Unknown HTTP error"}',
              data: null,
            );
          }
        } on DioException catch (e) {
          debugPrint(
            '  DioException in $operationName at $fullUrl: ${e.message}',
          );
          if (e.response?.statusCode == 404) {
            return StatusCodeResponseDto(
              statusCodeResponse: StatusCodeResponse.notFound,
              message:
                  e.response?.data?['message']?.toString() ??
                  'Route with ID $routeId not found.',
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
                'Network error.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }

  @override
  Future<StatusCodeResponseDto<RouteDto?>> addRoute(
    CreateRouteDto createRouteDto,
  ) async {
    const String operationName = 'Add New Route';
    const String endpointPath = '/api/Route';

    return _makeApiRequest<RouteDto?>(
      operationName: operationName,
      attemptRequest: (baseUrl) async {
        final String fullUrl = '$baseUrl$endpointPath';
        final jsonData = createRouteDto.toJson();
        debugPrint('  Attempting $operationName at: $fullUrl (Method: POST)');
        debugPrint('  Request Body: $jsonData');
        try {
          final response = await _dio.post(fullUrl, data: jsonData);
          debugPrint('  Response Status (HTTP): ${response.statusCode}');
          debugPrint('  Response Data (Raw): ${response.data}');

          if ((response.statusCode == 201 || response.statusCode == 200) &&
              response.data is Map<String, dynamic>) {
            final responseMap = response.data as Map<String, dynamic>;

            if (responseMap.containsKey('statusCodeResponse') &&
                responseMap.containsKey('data')) {
              final int appStatusCode =
                  responseMap['statusCodeResponse'] as int? ??
                  responseMap['statusCode'] as int? ??
                  0;
              final String? appMessage = responseMap['message'] as String?;
              final dynamic appData = responseMap['data'];

              if ((appStatusCode == 201 || appStatusCode == 200) &&
                  appData != null) {
                return StatusCodeResponseDto(
                  statusCodeResponse: StatusCodeResponse.fromCode(
                    appStatusCode == 201 ? 201 : 200,
                  ),
                  data: RouteDto.fromJson(appData as Map<String, dynamic>),
                  message: appMessage ?? 'Route created successfully.',
                );
              } else {
                return StatusCodeResponseDto(
                  statusCodeResponse: StatusCodeResponse.fromCode(
                    appStatusCode,
                  ),
                  message:
                      appMessage ??
                      '$operationName failed: Error in wrapped response.',
                  data: null,
                );
              }
            } else {
              return StatusCodeResponseDto(
                statusCodeResponse: StatusCodeResponse.fromCode(
                  response.statusCode!,
                ),
                data: RouteDto.fromJson(responseMap),
                message: 'Route created successfully (direct object).',
              );
            }
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
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.fromCode(
              e.response?.statusCode ?? 500,
            ),
            message:
                e.response?.data?['message']?.toString() ??
                e.message ??
                'Network error.',
            data: null,
          );
        } catch (e, s) {
          debugPrint(
            '  Unexpected error in $operationName at $fullUrl: $e\nStacktrace: $s',
          );
          return StatusCodeResponseDto(
            statusCodeResponse: StatusCodeResponse.internalServerError,
            message: 'Unexpected error: ${e.toString()}',
            data: null,
          );
        }
      },
    );
  }
}
