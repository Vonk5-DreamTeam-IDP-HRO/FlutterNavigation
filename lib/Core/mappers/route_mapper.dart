import '../models/route_dto.dart';
import '../models/route.dart';

class RouteMapper {
  static Route toDomain(RouteDto dto) {
    return Route(
      id: dto.routeId,
      displayName: dto.name,
      description: dto.description ?? '',
    );
  }

  static RouteDto toDto(Route model) {
    return RouteDto(
      routeId: model.id,
      name: model.displayName,
      description: model.description,
    );
  }
}
