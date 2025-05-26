import 'package:osm_navigation/Core/models/location.dart';
import 'package:osm_navigation/Core/models/location_details.dart';
import 'package:osm_navigation/Core/models/location_request_dtos.dart';
import 'package:osm_navigation/Core/models/selectable_location.dart';

// --- Interface for the Location API Service ---
// Defines the contract for location-related API operations.
// This promotes loose coupling and testability, allowing for different implementations
// or mocks to be used (e.g., in widget tests).
abstract class ILocationApiService {
  /// Fetches all locations.
  Future<List<Location>> getAllLocations();

  /// Fetches a specific location by its ID (which is a Uuid string), returning full details.
  Future<LocationDetails> getLocationById(String id);

  /// Fetches locations filtered by a specific category.
  Future<List<Location>> getLocationsByType(String category);

  /// Creates a new location with the given payload.
  /// Returns the details of the created location.
  Future<LocationDetails> createLocation(CreateLocationPayload payload);

  /// Updates an existing location identified by its ID (which is a Uuid string) with the given payload.
  /// Returns the details of the updated location.
  Future<LocationDetails> updateLocation(
    String id,
    UpdateLocationPayload payload,
  );

  /// Deletes a location by its ID (which is a Uuid string).
  Future<void> deleteLocation(String id);

  /// Fetches selectable locations grouped by their category.
  /// The map key is the category name, and the value is a list of [SelectableLocation] objects.
  Future<Map<String, List<SelectableLocation>>> getGroupedSelectableLocations();

  /// Fetches a list of unique category names.
  Future<List<String>> getUniqueCategories();
}
