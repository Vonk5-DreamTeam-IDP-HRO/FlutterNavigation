// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) => _LocationDto(
  locationId: json['locationId'] as String,
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  description: json['description'] as String?,
  locationDetail:
      json['locationDetail'] == null
          ? null
          : LocationDetailDto.fromJson(
            json['locationDetail'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$LocationDtoToJson(_LocationDto instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'locationDetail': instance.locationDetail,
    };
