import 'package:osm_navigation/core/services/route/IRouteApiService.dart';
import 'package:osm_navigation/core/models/Route/SelectableNavigationRoute.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/services/route/route_api_service.dart';
import 'IRouteRepository.dart';

/// Repository implementation for route data operations
class RouteRepository implements IRouteRepository {
  final IRouteApiService _routeApiService;

  RouteRepository(this._routeApiService);

  @override
  Future<List<RouteDto>> getAllRoutes() async {
    try {
      return await _routeApiService.getAllRoutes();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RouteDto?> getRouteById(String routeId) async {
    try {
      return await _routeApiService.getRouteById(routeId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RouteDto> addRoute(CreateRouteDto createRouteDto) async {
    try {
      return await _routeApiService.addRoute(createRouteDto);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<LocationDto>> getRouteLocations(String routeId) async {
    try {
      return await _routeApiService.getRouteLocations(routeId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SelectableNavigationRoute>> getSelectableRoutes() async {
    try {
      /// Fetches routes formatted for selection UI components
      ///
      /// **Purpose:** Provides route data optimized for dropdowns, navigation pickers
      /// **Performance:** Returns lightweight SelectableNavigationRoute objects
      /// **Use Cases:** Route selection in navigation, route comparison interfaces
      return await _routeApiService.getSelectableRoutes();
    } catch (e) {
      rethrow;
    }
  }
}
