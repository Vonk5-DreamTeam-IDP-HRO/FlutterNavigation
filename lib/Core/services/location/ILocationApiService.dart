import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/LocationDetail/location_detail_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';

// --- Interface for the Location API Service ---
// Defines the contract for location-related API operations.
// This promotes loose coupling and testability, allowing for different implementations
// or mocks to be used (e.g., in widget tests).
abstract class ILocationApiService {
  /// Fetches all locations.
  Future<List<LocationDto>> getAllLocations();

  /// Fetches a specific location by its ID (which is a Uuid string), returning full details.
  Future<LocationDto> getLocationById(String id);

  /// Fetches locations filtered by a specific category.
  Future<List<LocationDto>> getLocationsByType(String category);

  /// Creates a new location with the given payload.
  /// Returns the details of the created location.
  Future<LocationDto> createLocation(CreateLocationDto payload);

  /// Updates an existing location identified by its ID (which is a Uuid string) with the given payload.
  /// Returns the details of the updated location.
  Future<LocationDto> updateLocation(String id, UpdateLocationDto payload);

  /// Deletes a location by its ID (which is a Uuid string).
  Future<void> deleteLocation(String id);

  /// Fetches selectable locations grouped by their category.
  /// The map key is the category name, and the value is a list of [SelectableLocation] objects.
  Future<Map<String, List<SelectableLocationDto>>>
  getGroupedSelectableLocations();

  /// Fetches a list of unique category names.
  Future<List<String>> getUniqueCategories();
}
