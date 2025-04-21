/// Represents a geographical location with name and coordinates.
class Location {
  final String name;
  final double latitude;
  final double longitude;

  /// Creates a Location instance.
  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a Location instance from a JSON map.
  /// Expects 'name', 'latitude', and 'longitude' keys.
  factory Location.fromJson(Map<String, dynamic> json) {
    // Ensure latitude and longitude are parsed as doubles, handling potential int types.
    return Location(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Converts this Location instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'Location(name: $name, lat: $latitude, lon: $longitude)';
  }
}
