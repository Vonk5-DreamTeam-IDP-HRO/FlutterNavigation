import 'package:osm_navigation/Core/mappers/route_mapper.dart';
import 'package:osm_navigation/Core/models/route.dart';
import 'package:osm_navigation/Core/models/route_dto.dart';
import 'package:osm_navigation/Core/models/route_dtos.dart';
import 'package:osm_navigation/Core/services/route/IRouteApiService.dart';
import 'IRouteRepository.dart';

class RouteRepository implements IRouteRepository {
  final IRouteApiService _routeApiService;

  RouteRepository(this._routeApiService);

  @override
  Future<List<Route>> getAllRoutes() async {
    final List<RouteDto> routeDtos = await _routeApiService.getAllRoutes();
    return routeDtos.map((dto) => RouteMapper.toDomain(dto)).toList();
  }

  @override
  Future<Route?> getRouteById(int routeId) async {
    final RouteDto? routeDto = await _routeApiService.getRouteById(routeId);
    if (routeDto == null) {
      return null;
    }
    return RouteMapper.toDomain(routeDto);
  }

  @override
  Future<Route> addRoute(CreateRouteDto createRouteDto) async {
    // CreateRouteDto is already in the correct format for the API service,
    // as it's a DTO specifically for creation.
    // The API service will return a RouteDto.
    final RouteDto newRouteDto = await _routeApiService.addRoute(
      createRouteDto,
    );
    return RouteMapper.toDomain(newRouteDto);
  }
}
