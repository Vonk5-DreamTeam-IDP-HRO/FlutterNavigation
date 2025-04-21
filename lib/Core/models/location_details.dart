/// Represents detailed information about a location.
class LocationDetails {
  final int locationDetailsId;
  final int locationId;
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? phoneNumber;
  final String? website;
  final String? category;
  final String? accessibility;

  LocationDetails({
    required this.locationDetailsId,
    required this.locationId,
    this.address,
    this.city,
    this.country,
    this.zipCode,
    this.phoneNumber,
    this.website,
    this.category,
    this.accessibility,
  });

  /// Creates a LocationDetails instance from a JSON map.
  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    return LocationDetails(
      locationDetailsId: json['locationdetailsid'] as int,
      locationId: json['locationid'] as int,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      zipCode: json['zip_code'] as String?,
      phoneNumber: json['phone_number'] as String?,
      website: json['website'] as String?,
      category: json['category'] as String?,
      accessibility: json['accessibility'] as String?,
    );
  }

  /// Converts this LocationDetails instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'locationdetailsid': locationDetailsId,
      'locationid': locationId,
      'address': address,
      'city': city,
      'country': country,
      'zip_code': zipCode,
      'phone_number': phoneNumber,
      'website': website,
      'category': category,
      'accessibility': accessibility,
    };
  }

  @override
  String toString() {
    return 'LocationDetails(id: $locationDetailsId, locationId: $locationId, category: $category)';
  }
}
