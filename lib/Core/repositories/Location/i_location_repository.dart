import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';

/// Repository interface for location data operations
///
/// **Architecture Pattern:** Repository Pattern with Clean Architecture
/// **Purpose:** Defines the contract for location domain operations
/// **Benefits:**
/// - Abstracts data source details from business logic
/// - Enables easy testing through interface mocking
/// - Provides consistent API for location operations
/// - Supports multiple data source implementations
abstract class ILocationRepository {
  /// Retrieves all available locations
  Future<List<LocationDto>> getAllLocations();

  /// Retrieves a specific location by its ID
  Future<LocationDto> getLocationById(String id);

  /// Retrieves locations filtered by category
  Future<List<LocationDto>> getLocationsByCategory(String category);

  /// Creates a new location
  Future<LocationDto> createLocation(CreateLocationDto payload);

  /// Updates an existing location
  Future<LocationDto> updateLocation(String id, UpdateLocationDto payload);

  /// Deletes a location
  Future<void> deleteLocation(String id);

  /// Retrieves locations grouped by category for selection UI
  Future<Map<String, List<SelectableLocationDto>>>
  getGroupedSelectableLocations();

  /// Retrieves locations formatted for selection UI components
  Future<List<SelectableLocationDto>> getSelectableLocations();

  /// Retrieves unique location categories
  Future<List<String>> getUniqueCategories();
}
