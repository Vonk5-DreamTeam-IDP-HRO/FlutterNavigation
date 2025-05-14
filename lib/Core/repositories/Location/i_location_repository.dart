import 'package:osm_navigation/Core/models/location.dart';
import 'package:osm_navigation/Core/models/location_details.dart';
import 'package:osm_navigation/Core/models/selectable_location.dart';
import 'package:osm_navigation/Core/models/location_request_dtos.dart';

/// Interface for Location Repository
abstract class ILocationRepository {
  /// Fetches all locations
  Future<List<Location>> getAllLocations();

  /// Fetches a specific location by its ID
  Future<LocationDetails> getLocationById(int id);

  /// Fetches locations filtered by a specific category
  Future<List<Location>> getLocationsByCategory(String category);

  /// Creates a new location with the given payload
  Future<LocationDetails> createLocation(CreateLocationPayload payload);

  /// Updates an existing location identified by its ID
  Future<LocationDetails> updateLocation(int id, UpdateLocationPayload payload);

  /// Deletes a location by its ID
  Future<void> deleteLocation(int id);

  /// Fetches selectable locations grouped by their category
  Future<Map<String, List<SelectableLocation>>> getGroupedSelectableLocations();

  /// Fetches a list of unique category names from the underlying data source.
  Future<List<String>> getUniqueCategories();
}
