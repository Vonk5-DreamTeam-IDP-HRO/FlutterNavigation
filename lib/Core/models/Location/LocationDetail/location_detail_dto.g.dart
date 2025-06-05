// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationDetailDto _$LocationDetailDtoFromJson(Map<String, dynamic> json) =>
    _LocationDetailDto(
      locationDetailsId: json['locationDetailsId'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      category: json['category'] as String?,
      accessibility: json['accessibility'] as String?,
    );

Map<String, dynamic> _$LocationDetailDtoToJson(_LocationDetailDto instance) =>
    <String, dynamic>{
      'locationDetailsId': instance.locationDetailsId,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'zipCode': instance.zipCode,
      'phoneNumber': instance.phoneNumber,
      'website': instance.website,
      'category': instance.category,
      'accessibility': instance.accessibility,
    };
