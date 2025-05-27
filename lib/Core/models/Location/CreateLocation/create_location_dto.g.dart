// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateLocationDto _$CreateLocationDtoFromJson(Map<String, dynamic> json) =>
    _CreateLocationDto(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      locationDetail:
          json['locationDetail'] == null
              ? null
              : CreateLocationDetailDto.fromJson(
                json['locationDetail'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$CreateLocationDtoToJson(_CreateLocationDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'locationDetail': instance.locationDetail,
    };

_CreateLocationDetailDto _$CreateLocationDetailDtoFromJson(
  Map<String, dynamic> json,
) => _CreateLocationDetailDto(
  address: json['address'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  zipCode: json['zipCode'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  website: json['website'] as String?,
  category: json['category'] as String?,
  accessibility: json['accessibility'] as String?,
);

Map<String, dynamic> _$CreateLocationDetailDtoToJson(
  _CreateLocationDetailDto instance,
) => <String, dynamic>{
  'address': instance.address,
  'city': instance.city,
  'country': instance.country,
  'zipCode': instance.zipCode,
  'phoneNumber': instance.phoneNumber,
  'website': instance.website,
  'category': instance.category,
  'accessibility': instance.accessibility,
};
