import 'package:osm_navigation/core/models/location.dart';
import 'opening_time.dart';

/// Represents detailed information about a location.
class LocationDetails extends Location {
  final String? locationDetailsId;
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? phoneNumber;
  final String? website;
  final String? accessibility;
  final List<OpeningTime> openingTimes;

  LocationDetails({
    required String locationId,
    String? userId,
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    String? category,
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
    this.openingTimes = const [],
  }) : super(
         locationId: locationId,
         userId: userId,
         name: name,
         latitude: latitude,
         longitude: longitude,
         description: description,
         category: category,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Creates a LocationDetails instance from a JSON map.
  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    var openingTimesList = <OpeningTime>[];
    if (json['openingTimes'] != null && json['openingTimes'] is List) {
      openingTimesList =
          (json['openingTimes'] as List)
              .map((i) => OpeningTime.fromJson(i as Map<String, dynamic>))
              .toList();
    }

    final locationIdString =
        json['locationId'] as String? ?? json['location_id'] as String?;
    final userIdString =
        json['userId'] as String? ?? json['user_id'] as String?;
    final locationDetailsIdString =
        json['locationDetailsId'] as String? ??
        json['location_details_id'] as String?;

    final nameString = json['name'] as String?;
    if (nameString == null) {
      throw FormatException("Missing 'name' in LocationDetails JSON");
    }
    if (locationIdString == null) {
      throw FormatException("Missing 'locationId' in LocationDetails JSON");
    }

    return LocationDetails(
      locationId: locationIdString,
      userId: userIdString,
      name: nameString,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
      locationDetailsId: locationDetailsIdString,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String? ?? json['zip_code'] as String?,
      phoneNumber:
          json['phoneNumber'] as String? ?? json['phone_number'] as String?,
      website: json['website'] as String?,
      accessibility: json['accessibility'] as String?,
      openingTimes: openingTimesList,
    );
  }

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
    return 'LocationDetails(${super.toString()}, address: $address, city: $city, openingTimes: ${openingTimes.length}, detailsId: $locationDetailsId)'; // locationDetailsId is already a String?
  }
}
