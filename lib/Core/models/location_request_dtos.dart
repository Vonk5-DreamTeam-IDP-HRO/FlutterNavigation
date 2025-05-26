class CreateLocationDetailPayload {
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? phoneNumber;
  final String? website;
  final String? category;
  final String? accessibility;
  // final List<CreateOpeningTimePayload>? openingTimes; // Placeholder if needed

  CreateLocationDetailPayload({
    this.address,
    this.city = 'Rotterdam',
    this.country = 'Netherlands',
    this.zipCode,
    this.phoneNumber,
    this.website,
    this.category,
    this.accessibility,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    // Only include non-null values to support partial updates or optional fields
    if (address != null) map['address'] = address;
    if (city != null) map['city'] = city;
    if (country != null) map['country'] = country;
    if (zipCode != null) map['zipCode'] = zipCode;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (website != null) map['website'] = website;
    if (category != null) map['category'] = category;
    if (accessibility != null) map['accessibility'] = accessibility;
    return map;
  }
}

class CreateLocationPayload {
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final String userId;
  final CreateLocationDetailPayload? locationDetail;

  CreateLocationPayload({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.userId, // Now expects a String (UUID string)
    this.locationDetail,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
    };

    if (description != null) {
      map['description'] = description;
    }
    if (locationDetail != null) {
      map['locationDetail'] = locationDetail!.toJson();
    }
    return map;
  }
}

// TODO: Check if update is correct and need to be changed
class UpdateLocationPayload {
  final String? locationId;
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? userId;
  final CreateLocationDetailPayload?
  locationDetail; // Renamed from 'details' for consistency

  UpdateLocationPayload({
    this.locationId,
    this.name,
    this.latitude,
    this.longitude,
    this.description,
    this.userId,
    this.locationDetail, // Renamed
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (description != null) map['description'] = description;
    if (locationDetail != null)
      map['locationDetail'] = locationDetail!.toJson();
    return map;
  }
}
