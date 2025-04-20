class AppRoute {
  final int routeId;
  final String name;
  final String description;

  // Constructor
  AppRoute({
    required this.routeId,
    required this.name,
    required this.description,
  });

  factory AppRoute.fromJson(Map<String, dynamic> json) {
    return AppRoute(
      routeId: json['routeid'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
