import 'location_detail_dto.dart';

class LocationDto {
  final String locationId;
  final String? userId;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final LocationDetailDto? locationDetail;

  LocationDto({
    required this.locationId,
    this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.locationDetail,
  });

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final locIdString =
        json['locationId'] as String? ?? json['location_id'] as String?;
    final userIdString =
        json['userId'] as String? ?? json['user_id'] as String?;
    final nameString = json['name'] as String?;

    final latValue = parseDouble(json['latitude']);
    final longValue = parseDouble(json['longitude']);

    if (locIdString == null) {
      throw FormatException(
        "Invalid or missing 'locationId' or 'location_id' in LocationDto JSON: ${json['locationId'] ?? json['location_id']}",
      );
    }
    if (nameString == null) {
      throw const FormatException("Missing 'name' in LocationDto JSON");
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

    LocationDetailDto? locationDetail;
    if (json['locationDetail'] != null &&
        json['locationDetail'] is Map<String, dynamic>) {
      locationDetail = LocationDetailDto.fromJson(
        json['locationDetail'] as Map<String, dynamic>,
      );
    } else if (json['location_detail'] != null &&
        json['location_detail'] is Map<String, dynamic>) {
      locationDetail = LocationDetailDto.fromJson(
        json['location_detail'] as Map<String, dynamic>,
      );
    }

    return LocationDto(
      locationId: locIdString,
      userId: userIdString,
      name: nameString,
      latitude: latValue,
      longitude: longValue,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
      locationDetail: locationDetail,
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
    if (createdAt != null) map['createdAt'] = createdAt;
    if (updatedAt != null) map['updatedAt'] = updatedAt;
    if (locationDetail != null) {
      map['locationDetail'] = locationDetail!.toJson();
    }
    return map;
  }
}
