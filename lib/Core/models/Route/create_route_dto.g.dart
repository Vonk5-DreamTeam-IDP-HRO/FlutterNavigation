// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_route_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateRouteDto _$CreateRouteDtoFromJson(Map<String, dynamic> json) =>
    _CreateRouteDto(
      name: json['name'] as String,
      description: json['description'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? true,
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$CreateRouteDtoToJson(_CreateRouteDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'isPrivate': instance.isPrivate,
      'createdBy': instance.createdBy,
    };
