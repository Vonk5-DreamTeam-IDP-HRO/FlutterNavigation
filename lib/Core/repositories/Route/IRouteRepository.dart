import 'package:osm_navigation/core/models/route.dart';
import 'package:osm_navigation/core/models/route_dtos.dart';

abstract class IRouteRepository {
  Future<List<Route>> getAllRoutes();
  Future<Route?> getRouteById(int routeId);
  Future<Route> addRoute(CreateRouteDto createRouteDto);
}
