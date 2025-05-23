import 'package:osm_navigation/Core/models/route.dart';
import 'package:osm_navigation/Core/models/route_dtos.dart';

abstract class IRouteRepository {
  Future<List<Route>> getAllRoutes();
  Future<Route?> getRouteById(String routeId);
  Future<Route> addRoute(CreateRouteDto createRouteDto);
}
