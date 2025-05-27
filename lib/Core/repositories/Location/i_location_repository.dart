import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';

/// Interface for Location Repository
///
/// Defines the contract for location data operations. This abstraction allows
/// for easy testing and swapping of different data sources (API, local DB, cache).
///
/// **API Contract Alignment:**
/// All methods return LocationDto to match the C# API structure where LocationDto
/// contains an optional LocationDetailDto nested inside it.
///
/// **Error Handling:**
/// - All methods should handle network errors gracefully
/// - DTOs should be validated before API calls
/// - Throws [NetworkException] if API calls fail
/// - Throws [ValidationException] if input data is invalid
abstract class ILocationRepository {
  /// Fetches all locations from the data source
  ///
  /// Returns a list of LocationDto objects. Each LocationDto may contain
  /// a nested LocationDetailDto with additional information.
  ///
  /// Throws [NetworkException] if API call fails.
  Future<List<LocationDto>> getAllLocations();

  /// Fetches a specific location by its ID with full details
  ///
  /// Returns a LocationDto containing the location with nested LocationDetailDto.
  /// This matches the C# API GET /api/locations/{id} endpoint.
  ///
  /// Throws [NetworkException] if API call fails.
  /// Throws [NotFoundException] if location with given ID doesn't exist.
  Future<LocationDto> getLocationById(String id);

  /// Fetches locations filtered by a specific category
  ///
  /// Returns a list of LocationDto objects matching the specified category.
  /// Category filtering is performed on the server side.
  ///
  /// Throws [NetworkException] if API call fails.
  Future<List<LocationDto>> getLocationsByCategory(String category);

  /// Creates a new location with the given payload
  ///
  /// Accepts a CreateLocationDto with validation and returns the created
  /// LocationDto from the API response. The response includes the generated ID
  /// and any server-side defaults.
  ///
  /// Throws [NetworkException] if API call fails.
  /// Throws [ValidationException] if payload validation fails.
  Future<LocationDto> createLocation(CreateLocationDto payload);

  /// Updates an existing location identified by its ID
  ///
  /// Accepts an UpdateLocationDto with validation and returns the updated
  /// LocationDto from the API response.
  ///
  /// Throws [NetworkException] if API call fails.
  /// Throws [NotFoundException] if location with given ID doesn't exist.
  /// Throws [ValidationException] if payload validation fails.
  Future<LocationDto> updateLocation(String id, UpdateLocationDto payload);

  /// Deletes a location by its ID
  ///
  /// Permanently removes the location from the data source.
  /// No return value as the C# API returns void for DELETE operations.
  ///
  /// Throws [NetworkException] if API call fails.
  /// Throws [NotFoundException] if location with given ID doesn't exist.
  Future<void> deleteLocation(String id);

  /// Fetches selectable locations grouped by their category
  ///
  /// Returns a map where keys are category names and values are lists of
  /// SelectableLocationDto objects. Used for UI selection components.
  ///
  /// Throws [NetworkException] if API call fails.
  Future<Map<String, List<SelectableLocationDto>>>
  getGroupedSelectableLocations();

  /// Fetches a list of unique category names from the underlying data source
  ///
  /// Returns a list of distinct category strings available in the system.
  /// Used for category filtering and selection UI components.
  ///
  /// Throws [NetworkException] if API call fails.
  Future<List<String>> getUniqueCategories();
}
