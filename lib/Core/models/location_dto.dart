class LocationDto {
  final int locationId;
  final int? userId;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final String? category;
  final String? createdAt;
  final String? updatedAt;

  LocationDto({
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

  factory LocationDto.fromJson(Map<String, dynamic> json) {
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

    final locId = parseInt(json['locationId'] ?? json['location_id']);
    final latValue = parseDouble(json['latitude']);
    final longValue = parseDouble(json['longitude']);

    if (locId == null) {
      throw FormatException(
        "Invalid or missing 'locationId' or 'location_id' in LocationDto JSON: ${json['locationId'] ?? json['location_id']}",
      );
    }
    if (json['name'] == null) {
      throw FormatException(
        "Missing 'name' in LocationDto JSON: ${json['name']}",
      );
    }
    if (latValue == null) {
      throw FormatException(
        "Invalid or missing 'latitude' in LocationDto JSON: ${json['latitude']}",
      );
    }
    if (longValue == null) {
      throw FormatException(
        "Invalid or missing 'longitude' in LocationDto JSON: ${json['longitude']}",
      );
    }

    return LocationDto(
      locationId: locId,
      userId: parseInt(json['userId'] ?? json['user_id']),
      name: json['name'] as String,
      latitude: latValue,
      longitude: longValue,
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] ?? json['updated_at'] as String?,
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
}
