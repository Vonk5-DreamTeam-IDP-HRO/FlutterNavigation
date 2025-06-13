import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/Route/SelectableNavigationRoute.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';

/// Repository interface for route data operations
///
/// **Architecture Pattern:** Repository Pattern with Clean Architecture
/// **Purpose:** Defines the contract for route domain operations
abstract class IRouteRepository {
  Future<List<RouteDto>> getAllRoutes();
  Future<List<LocationDto>> getRouteLocations(String routeId);
  Future<List<SelectableNavigationRoute>> getSelectableRoutes();
  Future<RouteDto?> getRouteById(String routeId);
  Future<RouteDto> addRoute(CreateRouteDto createRouteDto);
}
