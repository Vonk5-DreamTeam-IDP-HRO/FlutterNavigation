import 'dart:async';
// Still needed for manual parsing if not using dio's transformers extensively for this specific structure
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:collection/collection.dart';
import 'package:osm_navigation/core/models/location.dart';
import 'package:osm_navigation/core/models/location_details.dart';
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'package:osm_navigation/core/models/location_request_dtos.dart'; 
import 'i_location_api_service.dart';
import 'location_api_exceptions.dart';
import 'package:osm_navigation/core/config/app_config.dart';

// --- Concrete Implementation of the Location API Service ---
// Provides the actual implementation for fetching location data using Dio.
class LocationApiService implements ILocationApiService {
  final Dio _dio;

  // Constructor requires a pre-configured Dio instance.
  // AppConfig.tempRESTUrl will be used directly for base URL.
  LocationApiService(this._dio);

  // Helper to handle Dio errors and convert them to custom exceptions
  LocationApiException _handleDioError(DioException e, String operation) {
    debugPrint('[LocationApiService] DioError during $operation: ${e.message}');
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

  // --- New CRUD Methods ---

  @override
  Future<List<Location>> getAllLocations() async {
    final String endpoint = 'api/Location'; // New endpoint structure
    final String fullUrl = '${AppConfig.tempRESTUrl}/$endpoint';
    debugPrint('[LocationApiService] Fetching all locations from: $fullUrl');

    try {
      final response = await _dio.get(fullUrl);
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => Location.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[LocationApiService] Failed to load locations: ${response.statusCode}, Data: ${response.data}');
        throw LocationApiException('Failed to load locations: ${response.statusCode}', statusCode: response.statusCode, errorData: response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'fetching all locations');
    } catch (e, s) {
      debugPrint('[LocationApiService] Unexpected error in getAllLocations: $e');
      throw LocationApiException('An unexpected error occurred: ${e.toString()}', stackTrace: s, originalException: e);
    }
  }

  @override
  Future<LocationDetails> getLocationById(int id) async {
    final String endpoint = 'api/Location/$id';
    final String fullUrl = '${AppConfig.tempRESTUrl}/$endpoint';
    debugPrint('[LocationApiService] Fetching location by ID $id from: $fullUrl');

    try {
      final response = await _dio.get(fullUrl);
      if (response.statusCode == 200 && response.data != null) {
        return LocationDetails.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw LocationNotFoundException('Location with ID $id not found.', errorData: response.data);
      } else {
        debugPrint('[LocationApiService] Failed to load location $id: ${response.statusCode}, Data: ${response.data}');
        throw LocationApiException('Failed to load location $id: ${response.statusCode}', statusCode: response.statusCode, errorData: response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'fetching location by ID $id');
    } catch (e, s) {
      debugPrint('[LocationApiService] Unexpected error in getLocationById for $id: $e');
      if (e.toString().contains("parameter 'category' isn't defined")) {
         throw LocationApiParseException('Error parsing LocationDetails for ID $id due to category issue: ${e.toString()}', stackTrace: s, originalException: e);
      }
      throw LocationApiException('An unexpected error occurred: ${e.toString()}', stackTrace: s, originalException: e);
    }
  }

  @override
  Future<List<Location>> getLocationsByType(String category) async {
    final String endpoint = 'api/Location/ByType/$category'; // Assuming this endpoint structure
    final String fullUrl = '${AppConfig.tempRESTUrl}/$endpoint';
    debugPrint('[LocationApiService] Fetching locations by type $category from: $fullUrl');

    try {
      final response = await _dio.get(fullUrl);
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => Location.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[LocationApiService] Failed to load locations for category $category: ${response.statusCode}, Data: ${response.data}');
        throw LocationApiException('Failed to load locations for category $category: ${response.statusCode}', statusCode: response.statusCode, errorData: response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'fetching locations by type $category');
    } catch (e, s) {
      debugPrint('[LocationApiService] Unexpected error in getLocationsByType for $category: $e');
      throw LocationApiException('An unexpected error occurred: ${e.toString()}', stackTrace: s, originalException: e);
    }
  }

  @override
  Future<LocationDetails> createLocation(CreateLocationPayload payload) async {
    final String endpoint = 'api/Location';
    final String fullUrl = '${AppConfig.tempRESTUrl}/$endpoint';
    debugPrint('[LocationApiService] Creating location at: $fullUrl with payload: ${payload.toJson()}');

    try {
      final response = await _dio.post(
        fullUrl,
        data: payload.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return LocationDetails.fromJson(response.data as Map<String, dynamic>);
      } else {
        debugPrint('[LocationApiService] Failed to create location: ${response.statusCode}, Data: ${response.data}');
        throw LocationApiException('Failed to create location: ${response.statusCode} - ${response.data?.toString() ?? "No data"}', statusCode: response.statusCode, errorData: response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'creating location');
    } catch (e, s) {
      debugPrint('[LocationApiService] Unexpected error in createLocation: $e');
      if (e.toString().contains("parameter 'category' isn't defined")) {
         throw LocationApiParseException('Error parsing created LocationDetails due to category issue: ${e.toString()}', stackTrace: s, originalException: e);
      }
      throw LocationApiException('An unexpected error occurred: ${e.toString()}', stackTrace: s, originalException: e);
    }
  }

  @override
  Future<LocationDetails> updateLocation(int id, UpdateLocationPayload payload) async {
    final String endpoint = 'api/Location/$id';
    final String fullUrl = '${AppConfig.tempRESTUrl}/$endpoint';
    debugPrint('[LocationApiService] Updating location $id at: $fullUrl with payload: ${payload.toJson()}');

    try {
      final response = await _dio.put(
        fullUrl,
        data: payload.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return LocationDetails.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw LocationNotFoundException('Location with ID $id not found for update.', errorData: response.data);
      } else {
        debugPrint('[LocationApiService] Failed to update location $id: ${response.statusCode}, Data: ${response.data}');
        throw LocationApiException('Failed to update location $id: ${response.statusCode} - ${response.data?.toString() ?? "No data"}', statusCode: response.statusCode, errorData: response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'updating location $id');
    } catch (e, s) {
      debugPrint('[LocationApiService] Unexpected error in updateLocation for $id: $e');
      throw LocationApiException('An unexpected error occurred: ${e.toString()}', stackTrace: s, originalException: e);
    }
  }

  @override
  Future<void> deleteLocation(int id) async {
    final String endpoint = 'api/Location/$id';
    final String fullUrl = '${AppConfig.tempRESTUrl}/$endpoint';
    debugPrint('[LocationApiService] Deleting location $id at: $fullUrl');

    try {
      final response = await _dio.delete(fullUrl);
      if (response.statusCode != 204) {
        debugPrint('[LocationApiService] Failed to delete location $id: ${response.statusCode}, Data: ${response.data}');
        throw LocationApiException('Failed to delete location $id: ${response.statusCode}', statusCode: response.statusCode, errorData: response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'deleting location $id');
    } catch (e, s) {
      debugPrint('[LocationApiService] Unexpected error in deleteLocation for $id: $e');
      throw LocationApiException('An unexpected error occurred: ${e.toString()}', stackTrace: s, originalException: e);
    }
  }
}
