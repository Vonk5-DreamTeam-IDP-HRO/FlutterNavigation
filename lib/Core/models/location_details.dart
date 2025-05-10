import 'package:osm_navigation/core/models/location.dart';

// Assuming DayOfWeek might be an enum or you'll handle string conversion
// For simplicity, using String for DayOfWeek for now.
// This class definition is based on the plan.
class OpeningTime {
  final int? openingId; // Nullable if not always present (e.g., new entries)
  final String dayOfWeek; // e.g., "Monday", "Tuesday"
  final String? openTime; // e.g., "09:00"
  final String? closeTime; // e.g., "17:00"
  final bool is24Hours;
  final String? timezone; // e.g., "CEST"

  OpeningTime({
    this.openingId,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.is24Hours,
    this.timezone,
  });

  factory OpeningTime.fromJson(Map<String, dynamic> json) {
    return OpeningTime(
      openingId: json['openingId'] as int?,
      dayOfWeek: json['dayOfWeek'] as String,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      is24Hours: json['is24Hours'] as bool? ?? false,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'dayOfWeek': dayOfWeek,
      'is24Hours': is24Hours,
    };
    if (openingId != null) map['openingId'] = openingId;
    if (openTime != null) map['openTime'] = openTime;
    if (closeTime != null) map['closeTime'] = closeTime;
    if (timezone != null) map['timezone'] = timezone;
    return map;
  }
}

/// Represents detailed information about a location.
class LocationDetails extends Location {
  // locationId, name, latitude, longitude, description, category are inherited from Location
  final int? locationDetailsId; // This specific ID for the details record, if separate
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? phoneNumber;
  final String? website;
  final String? accessibility;
  final List<OpeningTime> openingTimes;

  LocationDetails({
    required int locationId,
    int? userId,
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    String? category, // This is a named parameter
    String? createdAt,
    String? updatedAt,
    this.locationDetailsId,
    this.address,
    this.city,
    this.country,
    this.zipCode,
    this.phoneNumber,
    this.website,
    this.accessibility,
    this.openingTimes = const [], // Default to empty list
  }) : super(
          locationId: locationId,
          userId: userId,
          name: name,
          latitude: latitude,
          longitude: longitude,
          description: description,
          category: category, // Passed to super
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Creates a LocationDetails instance from a JSON map.
  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    var openingTimesList = <OpeningTime>[];
    if (json['openingTimes'] != null && json['openingTimes'] is List) {
      openingTimesList = (json['openingTimes'] as List)
          .map((i) => OpeningTime.fromJson(i as Map<String, dynamic>))
          .toList();
    }
    
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    final String? categoryFromJson = json['category'] as String?;

    return LocationDetails(
      locationId: parseInt(json['locationId'] ?? json['location_id'])!,
      userId: parseInt(json['userId'] ?? json['user_id']),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      category: categoryFromJson, // Using the explicitly extracted variable
      createdAt: json['createdAt'] ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] ?? json['updated_at'] as String?,
      locationDetailsId: parseInt(json['locationDetailsId'] ?? json['location_details_id']),
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] ?? json['zip_code'] as String?,
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] as String?,
      website: json['website'] as String?,
      accessibility: json['accessibility'] as String?,
      openingTimes: openingTimesList,
    );
  }

  /// Converts this LocationDetails instance to a JSON map.
  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson(); 
    map.addAll({
      'address': address,
      'city': city,
      'country': country,
      'zipCode': zipCode, 
      'phoneNumber': phoneNumber,
      'website': website,
      'accessibility': accessibility,
      'openingTimes': openingTimes.map((ot) => ot.toJson()).toList(),
    });
    if (locationDetailsId != null) map['locationDetailsId'] = locationDetailsId;
    return map;
  }

  @override
  String toString() {
    return 'LocationDetails(locationId: $locationId, name: $name, address: $address, city: $city, openingTimes: ${openingTimes.length}, detailsId: $locationDetailsId)';
  }
}
