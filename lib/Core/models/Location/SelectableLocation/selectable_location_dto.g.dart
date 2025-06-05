// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selectable_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SelectableLocationDto _$SelectableLocationDtoFromJson(
  Map<String, dynamic> json,
) => _SelectableLocationDto(
  locationId: json['locationId'] as String,
  name: json['name'] as String,
  category: json['category'] as String?,
);

Map<String, dynamic> _$SelectableLocationDtoToJson(
  _SelectableLocationDto instance,
) => <String, dynamic>{
  'locationId': instance.locationId,
  'name': instance.name,
  'category': instance.category,
};
