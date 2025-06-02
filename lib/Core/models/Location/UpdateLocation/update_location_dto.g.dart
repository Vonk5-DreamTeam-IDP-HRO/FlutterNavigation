// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateLocationDto _$UpdateLocationDtoFromJson(Map<String, dynamic> json) =>
    _UpdateLocationDto(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      locationDetail:
          json['locationDetail'] == null
              ? null
              : UpdateLocationDetailDto.fromJson(
                json['locationDetail'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$UpdateLocationDtoToJson(_UpdateLocationDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'locationDetail': instance.locationDetail,
    };

_UpdateLocationDetailDto _$UpdateLocationDetailDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateLocationDetailDto(
  address: json['address'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  zipCode: json['zipCode'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  website: json['website'] as String?,
  category: json['category'] as String?,
  accessibility: json['accessibility'] as String?,
);

Map<String, dynamic> _$UpdateLocationDetailDtoToJson(
  _UpdateLocationDetailDto instance,
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
