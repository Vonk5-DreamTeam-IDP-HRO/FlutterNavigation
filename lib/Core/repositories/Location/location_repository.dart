import 'package:flutter/foundation.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';
import 'package:osm_navigation/core/models/status_code_response_dto.dart';
import 'package:osm_navigation/core/services/location/ILocationApiService.dart';
import 'package:osm_navigation/core/repositories/repository_exception.dart';
import './i_location_repository.dart';

/// Implementation of [ILocationRepository] for location data operations.
///
/// This class serves as an abstraction layer between the domain/application layer
/// and the data source (represented by [ILocationApiService]). It is responsible for:
/// - Invoking methods on [ILocationApiService].
/// - Interpreting the [StatusCodeResponseDto] returned by the service.
/// - Extracting the actual data ([T]) from the DTO upon successful API calls.
/// - Throwing specific [RepositoryException]s (e.g., [DataNotFoundRepositoryException])
///   or a generic [RepositoryException] based on the API response status and message,
///   allowing the application layer to handle errors in a standardized way.
///
/// The repository pattern provides several key benefits:
/// 1. **Abstraction**: Hides the complexity of data source operations
/// 2. **Testability**: Enables easy mocking for unit tests
/// 3. **Consistency**: Provides a unified interface for data operations
/// 4. **Separation of Concerns**: Keeps business logic separate from data access
/// 5. **Type Safety**: Uses Freezed DTOs with compile-time validation
///
/// This approach adheres to the Repository pattern, promoting separation of concerns
/// and enhancing testability.
class LocationRepository implements ILocationRepository {
  final ILocationApiService _locationApiService;

  LocationRepository(this._locationApiService);

  @override
  Future<List<LocationDto>> getAllLocations() async {
    final String operationName = 'getAllLocations';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.getAllLocations();
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[LocationRepository] $operationName successful, ${response.data!.length} locations fetched.',
        );
        return response.data!;
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed or returned no data. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get all locations: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching all locations: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<SelectableLocationDto>> getSelectableLocations() async {
    final String operationName = 'getSelectableLocations';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.getSelectableLocations();
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[LocationRepository] $operationName successful, ${response.data!.length} selectable locations fetched.',
        );
        return response.data!;
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed or returned no data. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get selectable locations: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching selectable locations: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<LocationDto> getLocationById(String id) async {
    final String operationName = 'getLocationById $id';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.getLocationById(id);
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint('[LocationRepository] $operationName successful.');
        return response.data!;
      } else if (response.statusCodeResponse == StatusCodeResponse.notFound) {
        debugPrint('[LocationRepository] $operationName: Location not found.');
        throw DataNotFoundRepositoryException(
          'Location with ID $id not found.',
        );
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get location by ID $id: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      if (e is DataNotFoundRepositoryException) rethrow;
      throw RepositoryException(
        'Error fetching location by ID $id: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<LocationDto>> getLocationsByCategory(String category) async {
    final String operationName = 'getLocationsByCategory $category';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.getLocationsByType(category);
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[LocationRepository] $operationName successful, ${response.data!.length} locations fetched for category $category.',
        );
        return response.data!;
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get locations for category $category: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching locations for category $category: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<LocationDto> createLocation(CreateLocationDto payload) async {
    final String operationName = 'createLocation';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.createLocation(payload);
      if ((response.statusCodeResponse == StatusCodeResponse.created ||
              response.statusCodeResponse == StatusCodeResponse.success) &&
          response.data != null) {
        debugPrint(
          '[LocationRepository] $operationName successful. Location ID: ${response.data!.locationId}',
        );
        return response.data!;
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to create location: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error creating location: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<LocationDto> updateLocation(
    String id,
    UpdateLocationDto payload,
  ) async {
    final String operationName = 'updateLocation $id';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.updateLocation(id, payload);
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint('[LocationRepository] $operationName successful.');
        return response.data!;
      } else if (response.statusCodeResponse == StatusCodeResponse.notFound) {
        debugPrint(
          '[LocationRepository] $operationName: Location not found for update.',
        );
        throw DataNotFoundRepositoryException(
          'Location with ID $id not found for update.',
        );
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to update location $id: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      if (e is DataNotFoundRepositoryException) rethrow;
      throw RepositoryException(
        'Error updating location $id: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    final String operationName = 'deleteLocation $id';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.deleteLocation(id);
      if (response.statusCodeResponse == StatusCodeResponse.success ||
          response.statusCodeResponse == StatusCodeResponse.noContent) {
        debugPrint('[LocationRepository] $operationName successful.');
        return; // Success
      } else if (response.statusCodeResponse == StatusCodeResponse.notFound) {
        debugPrint(
          '[LocationRepository] $operationName: Location not found for deletion.',
        );
        throw DataNotFoundRepositoryException(
          'Location with ID $id not found for deletion.',
        );
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to delete location $id: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      if (e is DataNotFoundRepositoryException) rethrow;
      throw RepositoryException(
        'Error deleting location $id: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<Map<String, List<SelectableLocationDto>>>
  getGroupedSelectableLocations() async {
    final String operationName = 'getGroupedSelectableLocations';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response =
          await _locationApiService.getGroupedSelectableLocations();
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[LocationRepository] $operationName successful, ${response.data!.keys.length} groups fetched.',
        );
        return response.data!;
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get grouped selectable locations: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching grouped selectable locations: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<String>> getUniqueCategories() async {
    final String operationName = 'getUniqueCategories';
    debugPrint('[LocationRepository] Starting $operationName');
    try {
      final response = await _locationApiService.getUniqueCategories();
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[LocationRepository] $operationName successful, ${response.data!.length} categories fetched.',
        );
        return response.data!;
      } else {
        debugPrint(
          '[LocationRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get unique categories: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[LocationRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching unique categories: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }
}
