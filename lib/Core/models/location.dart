class Location {
  final String locationId;
  final String? userId;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final String? category;
  final String? createdAt;
  final String? updatedAt;

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
    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final locIdString =
        json['locationId'] as String? ?? json['location_id'] as String?;
    final userIdString =
        json['userId'] as String? ?? json['user_id'] as String?;

    final latValue = parseDouble(json['latitude']);
    final longValue = parseDouble(json['longitude']);

    if (locIdString == null) {
      throw FormatException(
        "Invalid or missing 'locationId' or 'location_id' in Location JSON: ${json['locationId'] ?? json['location_id']}",
      );
    }
    final nameString = json['name'] as String?;
    if (nameString == null) {
      throw FormatException("Missing 'name' in Location JSON");
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

    return Location(
      locationId: locIdString,
      userId: userIdString,
      name: nameString,
      latitude: latValue,
      longitude: longValue,
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'locationId': locationId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (userId != null) map['userId'] = userId;
    if (description != null) map['description'] = description;
    if (category != null) map['category'] = category;
    if (createdAt != null) map['createdAt'] = createdAt;
    if (updatedAt != null) map['updatedAt'] = updatedAt;
    return map;
  }

  @override
  String toString() {
    return 'Location(locationId: $locationId, name: $name, latitude: $latitude, longitude: $longitude, userId: $userId, description: $description, category: $category, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
