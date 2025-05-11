import 'package:osm_navigation/core/models/location.dart';
import 'package:osm_navigation/core/models/route.dart' as core_route; // Aliased to avoid conflict if any
import 'package:osm_navigation/core/models/selectable_location.dart';

/// Interface for the Route API Service.
///
/// Defines the contract for fetching route-related data,
/// such as all routes, locations for a specific route, and
/// locations suitable for selection in route creation.
abstract class IRouteApiService {
  /// Fetches a list of all available routes.
  ///
  /// Returns a list of [core_route.Route] objects.
  /// Throws an exception if fetching fails.
  Future<List<core_route.Route>> getAllRoutes();

  /// Fetches the list of locations associated with a specific route ID.
  ///
  /// [routeId] is the ID of the route for which to fetch locations.
  /// Returns a list of [Location] objects associated with the route.
  /// Throws an exception if the request fails or if the response is not in the expected format.
  Future<List<Location>> getRouteLocations(int routeId);

  /// Fetches all locations and their details to create a list of selectable locations with categories.
  ///
  /// Returns a list of [SelectableLocation] objects.
  /// Throws an exception if fetching fails.
  Future<List<SelectableLocation>> getSelectableLocations();
}
