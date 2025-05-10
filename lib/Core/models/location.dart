class Location {
  final int locationId;
  final int? userId; // Nullable if a location might not have a user_id
  final String name;
  final double latitude;
  final double longitude;
  final String? description; // Nullable
  final String? category; // Added for DTOs that might include it directly
  final String? createdAt; // nullable
  final String? updatedAt; // nullable

  Location({
    required this.locationId,
    this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.category,
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

    // Backend might use 'locationId' or 'location_id'. Prioritize 'locationId'.
    final locId = parseInt(json['locationId'] ?? json['location_id']);
    final latValue = parseDouble(json['latitude']);
    final longValue = parseDouble(json['longitude']);

    if (locId == null) {
      throw FormatException(
        "Invalid or missing 'locationId' or 'location_id' in Location JSON: ${json['locationId'] ?? json['location_id']}",
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
      userId: parseInt(json['userId'] ?? json['user_id']),
      name: json['name'] as String,
      latitude: latValue,
      longitude: longValue,
      description: json['description'] as String?,
      category: json['category'] as String?, // Added
      createdAt: json['createdAt'] ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] ?? json['updated_at'] as String?,
    );
  }

  // returning a new Location object with parsed values
  // reverse Location object to json
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'locationId':
          locationId, // Prefer camelCase for JSON consistency if possible
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (userId != null) map['userId'] = userId;
    if (description != null) map['description'] = description;
    if (category != null) map['category'] = category; // Added
    if (createdAt != null) map['createdAt'] = createdAt;
    if (updatedAt != null) map['updatedAt'] = updatedAt;
    return map;
  }

  @override
  String toString() {
    return 'Location(locationId: $locationId, name: $name, latitude: $latitude, longitude: $longitude, userId: $userId, description: $description, category: $category, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
