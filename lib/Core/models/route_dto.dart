class RouteDto {
  final int routeId;
  final String name;
  final String? description;

  // presenting general data structure of route
  RouteDto({required this.routeId, required this.name, this.description});

  factory RouteDto.fromJson(Map<String, dynamic> json) {
    return RouteDto(
      routeId: json['routeId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'route_id': routeId, 'name': name, 'description': description};
  }
}
