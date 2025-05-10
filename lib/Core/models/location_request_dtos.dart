// lib/Core/models/location_request_dtos.dart

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
    this.city = 'Rotterdam', // Default as per C# DTO plan
    this.country = 'Netherlands', // Default as per C# DTO plan
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
  final int? userId; // Optional: if creating on behalf of a user
  final CreateLocationDetailPayload? details;

  CreateLocationPayload({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.userId,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (description != null) map['description'] = description;
    if (userId != null) map['userId'] = userId;
    if (details != null) map['details'] = details!.toJson();
    return map;
  }
}

// UpdateLocationPayload can be very similar or identical to CreateLocationPayload
// if the backend handles PUT requests by replacing the entity or merging fields.
// If specific fields are not updatable or partial updates have different structures,
// this might need to be a distinct class. For now, assuming it's similar.
class UpdateLocationPayload {
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final CreateLocationDetailPayload? details; // For updating nested details

  UpdateLocationPayload({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (description != null) map['description'] = description;
    if (details != null) map['details'] = details!.toJson();
    return map;
  }
}
