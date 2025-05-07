class Location {
  final int locationId;
  final int? userId; // Nullable if a location might not have a user_id
  final String name;
  final double latitude;
  final double longitude;
  final String? description; // Nullable
  final String? createdAt; // nullable
  final String? updatedAt; // nullable

  Location({
    required this.locationId,
    this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a Location object from a Map<String, dynamic>
  factory Location.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers that might come as int or double
    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper to safely parse integers
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    final latValue = parseDouble(json['latitude']);
    final longValue = parseDouble(json['longitude']);
    final locId = parseInt(json['location_id']);

    if (locId == null) {
      throw FormatException(
        "Invalid or missing 'location_id' in Location JSON: ${json['location_id']}",
      );
    }
    if (json['name'] == null) {
      throw FormatException("Missing 'name' in Location JSON: ${json['name']}");
    }
    if (latValue == null) {
      throw FormatException(
        "Invalid or missing 'latitude' in Location JSON: ${json['latitude']}",
      );
    }
    if (longValue == null) {
      throw FormatException(
        "Invalid or missing 'longitude' in Location JSON: ${json['longitude']}",
      );
    }

    // returning a new Location object with parsed values
    // from json towards an Map<String, dynamic>
    // this is an key-value pair that matches the Location class properties
    return Location(
      locationId: locId,
      userId: parseInt(json['user_id']),
      name: json['name'] as String,
      latitude: latValue,
      longitude: longValue,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // returning a new Location object with parsed values
  // reverse Location object to json
  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Location(locationId: $locationId, name: $name, latitude: $latitude, longitude: $longitude, userId: $userId, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
