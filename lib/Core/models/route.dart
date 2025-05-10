class Route {
  final int routeId;
  final String name;
  final String description;

  // Constructor
  Route({
    required this.routeId,
    required this.name,
    required this.description,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    // TODO: Ensure 'route_id' is not null and is an int before casting.
    // If it can be null or missing, more robust error handling or default values might be needed.
    // It went wrong in the past.
    final routeIdValue = json['route_id'];
    if (routeIdValue == null) {
      throw FormatException("Missing 'route_id' in route JSON: $json");
    }
    if (routeIdValue is! int) {
      try {
        // If it's a String, try to parse. If not a String or int, it's an issue.
        if (routeIdValue is String) {
          // Allow parsing from string, though API currently sends int
        } else {
          // If not int and not String, it's an unexpected type.
          throw FormatException(
            "Invalid type for 'route_id' in route JSON (expected int or String): ${routeIdValue.runtimeType}",
          );
        }
      } catch (e) {
        throw FormatException(
          "Could not parse 'route_id' to int from route JSON: $routeIdValue. Error: $e",
        );
      }
    }

    return Route(
      routeId: json['route_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
