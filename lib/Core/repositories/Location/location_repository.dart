import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';
import 'package:osm_navigation/core/services/location/ILocationApiService.dart';
import './i_location_repository.dart';

/// Implementation of the Location Repository
///
/// This repository implements the Repository pattern to provide a clean separation
/// between data source (API service) and domain logic. It uses Freezed DTOs to
/// ensure type safety and immutability throughout the application.
///
/// The repository pattern provides several key benefits:
/// 1. **Abstraction**: Hides the complexity of data source operations
/// 2. **Testability**: Enables easy mocking for unit tests
/// 3. **Consistency**: Provides a unified interface for data operations
/// 4. **Separation of Concerns**: Keeps business logic separate from data access
/// 5. **Type Safety**: Uses Freezed DTOs with compile-time validation
class LocationRepository implements ILocationRepository {
  final ILocationApiService _locationApiService;

  LocationRepository(this._locationApiService);

  /// Fetches all locations from the API service
  /// Returns strongly-typed LocationDto objects with validation
  @override
  Future<List<LocationDto>> getAllLocations() async {
    final locations = await _locationApiService.getAllLocations();

    // Convert API response to our Freezed DTOs
    // This ensures type safety and validation at the repository boundary
    return locations
        .map((location) => LocationDto.fromJson(location.toJson()))
        .toList();
  }

  @override
  Future<List<SelectableLocationDto>> getSelectableLocations() async {
    /// Fetches locations formatted for selection UI components
    ///
    /// **Purpose:** Provides location data optimized for dropdowns, pickers, etc.
    /// **Performance:** Returns lightweight SelectableLocationDto objects
    /// **Use Cases:** Location selection in route creation, waypoint picking
    /// **Data Flow:** API Service → Repository → UI Components
    ///
    /// **Type Safety:** Ensures all returned objects are properly validated DTOs
    try {
      return await _locationApiService.getSelectableLocations();
    } catch (e) {
      // Log error and rethrow for service layer to handle
      rethrow;
    }
  }

  /// Fetches a specific location with full details
  /// Returns LocationDto with nested LocationDetailDto information
  @override
  Future<LocationDto> getLocationById(String id) async {
    final locationDetail = await _locationApiService.getLocationById(id);

    // Convert to our strongly-typed DTO with validation
    return LocationDto.fromJson(locationDetail.toJson());
  }

  /// Fetches locations filtered by category
  /// Maintains type safety through Freezed DTOs
  @override
  Future<List<LocationDto>> getLocationsByCategory(String category) async {
    final locations = await _locationApiService.getLocationsByType(category);

    // Convert each location to validated DTO
    return locations
        .map((location) => LocationDto.fromJson(location.toJson()))
        .toList();
  }

  /// Creates a new location using validated input DTO
  /// The CreateLocationDto ensures all validation rules are met before API call
  @override
  Future<LocationDto> createLocation(CreateLocationDto payload) async {
    final locationDetail = await _locationApiService.createLocation(payload);

    // Return validated response DTO (API returns LocationDto, not LocationDetailDto)
    return LocationDto.fromJson(locationDetail.toJson());
  }

  /// Updates an existing location with validated data
  /// UpdateLocationDto provides same validation as CreateLocationDto
  @override
  Future<LocationDto> updateLocation(
    String id,
    UpdateLocationDto payload,
  ) async {
    final locationDetail = await _locationApiService.updateLocation(
      id,
      payload,
    );

    // Return validated updated location (API returns LocationDto, not LocationDetailDto)
    return LocationDto.fromJson(locationDetail.toJson());
  }

  /// Deletes a location by ID
  /// No DTO conversion needed for void operations
  @override
  Future<void> deleteLocation(String id) async {
    await _locationApiService.deleteLocation(id);
  }

  /// Fetches locations grouped by category for selection UI
  /// Returns type-safe SelectableLocationDto objects
  @override
  Future<Map<String, List<SelectableLocationDto>>>
  getGroupedSelectableLocations() async {
    final groupedLocations =
        await _locationApiService.getGroupedSelectableLocations();

    // Convert each group to validated DTOs
    final Map<String, List<SelectableLocationDto>> result = {};
    for (final entry in groupedLocations.entries) {
      result[entry.key] =
          entry.value
              .map(
                (location) => SelectableLocationDto.fromJson(location.toJson()),
              )
              .toList();
    }
    return result;
  }

  /// Fetches available location categories
  /// Simple string list - no DTO conversion needed
  @override
  Future<List<String>> getUniqueCategories() async {
    return await _locationApiService.getUniqueCategories();
  }
}
