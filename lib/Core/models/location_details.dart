import 'package:osm_navigation/core/models/location.dart';
import 'opening_time.dart';

/// Represents detailed information about a location.
class LocationDetails extends Location {
  // locationId, name, latitude, longitude, description, category are inherited from Location
  final int?
  locationDetailsId; // This specific ID for the details record, if separate
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? phoneNumber;
  final String? website;
  final String? accessibility;
  final List<OpeningTime> openingTimes;

  LocationDetails({
    required super.locationId,
    super.userId,
    required super.name,
    required super.latitude,
    required super.longitude,
    super.description,
    super.category, // This is a named parameter
    super.createdAt,
    super.updatedAt,
    this.locationDetailsId,
    this.address,
    this.city,
    this.country,
    this.zipCode,
    this.phoneNumber,
    this.website,
    this.accessibility,
    this.openingTimes = const [],
  });

  /// Creates a LocationDetails instance from a JSON map.
  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    var openingTimesList = <OpeningTime>[];
    if (json['openingTimes'] != null && json['openingTimes'] is List) {
      openingTimesList =
          (json['openingTimes'] as List)
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
      locationDetailsId: parseInt(
        json['locationDetailsId'] ?? json['location_details_id'],
      ),
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
