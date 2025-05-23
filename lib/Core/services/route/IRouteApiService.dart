import 'package:osm_navigation/Core/models/location.dart';
import 'package:osm_navigation/Core/models/route.dart'
    as core_route; //specified to avoid name conflicts
import 'package:osm_navigation/Core/models/route_dto.dart';
import 'package:osm_navigation/Core/models/selectable_location.dart';
import 'package:osm_navigation/Core/models/route_dtos.dart';

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
  Future<List<RouteDto>> getAllRoutes();

  /// Fetches the list of locations associated with a specific route ID.
  ///
  /// [routeId] is the ID of the route for which to fetch locations.
  /// Returns a list of [Location] objects associated with the route.
  /// Throws an exception if the request fails or if the response is not in the expected format.
  Future<List<Location>> getRouteLocations(String routeId);

  /// Fetches all locations and their details to create a list of selectable locations with categories.
  ///
  /// Returns a list of [SelectableLocation] objects.
  /// Throws an exception if fetching fails.
  Future<List<SelectableLocation>> getSelectableLocations();

  /// Fetches a specific route by its ID.
  ///
  /// [routeId] is the ID of the route to fetch.
  /// Returns a [core_route.Route] object.
  /// Throws an exception if the request fails or if the route is not found.
  Future<RouteDto?> getRouteById(String routeId);

  /// Adds a new route.
  ///
  /// [createRouteDto] is the DTO containing the data for the new route.
  /// Returns the created [RouteDto] object.
  /// Throws an exception if the request fails.
  Future<RouteDto> addRoute(CreateRouteDto createRouteDto);
}
