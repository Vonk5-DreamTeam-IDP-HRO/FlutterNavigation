import 'opening_time.dart';

// Represents the data transfer object for location details.
class LocationDetailDto {
  final String? locationDetailId;
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? phoneNumber;
  final String? website;
  final String? accessibility;
  final List<OpeningTime> openingTimes;
  final String? category;

  LocationDetailDto({
    this.locationDetailId,
    this.address,
    this.city,
    this.country,
    this.zipCode,
    this.phoneNumber,
    this.website,
    this.accessibility,
    this.openingTimes = const [],
    this.category,
  });

  factory LocationDetailDto.fromJson(Map<String, dynamic> json) {
    var openingTimesList = <OpeningTime>[];
    if (json['openingTimes'] != null && json['openingTimes'] is List) {
      openingTimesList =
          (json['openingTimes'] as List)
              .map((i) => OpeningTime.fromJson(i as Map<String, dynamic>))
              .toList();
    }

    return LocationDetailDto(
      locationDetailId:
          json['locationDetailId'] as String? ??
          json['location_details_id'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String? ?? json['zip_code'] as String?,
      phoneNumber:
          json['phoneNumber'] as String? ?? json['phone_number'] as String?,
      website: json['website'] as String?,
      accessibility: json['accessibility'] as String?,
      openingTimes: openingTimesList,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (locationDetailId != null) map['locationDetailId'] = locationDetailId;
    if (address != null) map['address'] = address;
    if (city != null) map['city'] = city;
    if (country != null) map['country'] = country;
    if (zipCode != null) map['zipCode'] = zipCode;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (website != null) map['website'] = website;
    if (accessibility != null) map['accessibility'] = accessibility;
    if (openingTimes.isNotEmpty) {
      map['openingTimes'] = openingTimes.map((ot) => ot.toJson()).toList();
    }
    if (category != null) map['category'] = category;
    return map;
  }
}
