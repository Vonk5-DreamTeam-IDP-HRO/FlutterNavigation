// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteDto _$RouteDtoFromJson(Map<String, dynamic> json) => _RouteDto(
  routeId: json['routeId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  createdBy: json['createdBy'] as String?,
  isPrivate: json['isPrivate'] as bool?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RouteDtoToJson(_RouteDto instance) => <String, dynamic>{
  'routeId': instance.routeId,
  'name': instance.name,
  'description': instance.description,
  'createdBy': instance.createdBy,
  'isPrivate': instance.isPrivate,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
