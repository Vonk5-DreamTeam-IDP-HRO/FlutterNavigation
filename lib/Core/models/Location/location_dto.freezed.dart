// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationDto {

/// Unique identifier for the location (maps to C# Guid LocationId)
 String get locationId;/// Name of the location (maps to C# string Name)
 String get name;/// Latitude coordinate (maps to C# double Latitude)
 double get latitude;/// Longitude coordinate (maps to C# double Longitude)
 double get longitude;/// Optional description (maps to C# string? Description)
 String? get description;/// Optional location details (maps to C# LocationDetailDto? LocationDetail)
 LocationDetailDto? get locationDetail;
/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationDtoCopyWith<LocationDto> get copyWith => _$LocationDtoCopyWithImpl<LocationDto>(this as LocationDto, _$identity);

  /// Serializes this LocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationDto&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.description, description) || other.description == description)&&(identical(other.locationDetail, locationDetail) || other.locationDetail == locationDetail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationId,name,latitude,longitude,description,locationDetail);

@override
String toString() {
  return 'LocationDto(locationId: $locationId, name: $name, latitude: $latitude, longitude: $longitude, description: $description, locationDetail: $locationDetail)';
}


}

/// @nodoc
abstract mixin class $LocationDtoCopyWith<$Res>  {
  factory $LocationDtoCopyWith(LocationDto value, $Res Function(LocationDto) _then) = _$LocationDtoCopyWithImpl;
@useResult
$Res call({
 String locationId, String name, double latitude, double longitude, String? description, LocationDetailDto? locationDetail
});


$LocationDetailDtoCopyWith<$Res>? get locationDetail;

}
/// @nodoc
class _$LocationDtoCopyWithImpl<$Res>
    implements $LocationDtoCopyWith<$Res> {
  _$LocationDtoCopyWithImpl(this._self, this._then);

  final LocationDto _self;
  final $Res Function(LocationDto) _then;

/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationId = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? description = freezed,Object? locationDetail = freezed,}) {
  return _then(_self.copyWith(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as LocationDetailDto?,
  ));
}
/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationDetailDtoCopyWith<$Res>? get locationDetail {
    if (_self.locationDetail == null) {
    return null;
  }

  return $LocationDetailDtoCopyWith<$Res>(_self.locationDetail!, (value) {
    return _then(_self.copyWith(locationDetail: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _LocationDto implements LocationDto {
  const _LocationDto({required this.locationId, required this.name, required this.latitude, required this.longitude, this.description, this.locationDetail});
  factory _LocationDto.fromJson(Map<String, dynamic> json) => _$LocationDtoFromJson(json);

/// Unique identifier for the location (maps to C# Guid LocationId)
@override final  String locationId;
/// Name of the location (maps to C# string Name)
@override final  String name;
/// Latitude coordinate (maps to C# double Latitude)
@override final  double latitude;
/// Longitude coordinate (maps to C# double Longitude)
@override final  double longitude;
/// Optional description (maps to C# string? Description)
@override final  String? description;
/// Optional location details (maps to C# LocationDetailDto? LocationDetail)
@override final  LocationDetailDto? locationDetail;

/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationDtoCopyWith<_LocationDto> get copyWith => __$LocationDtoCopyWithImpl<_LocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationDto&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.description, description) || other.description == description)&&(identical(other.locationDetail, locationDetail) || other.locationDetail == locationDetail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationId,name,latitude,longitude,description,locationDetail);

@override
String toString() {
  return 'LocationDto(locationId: $locationId, name: $name, latitude: $latitude, longitude: $longitude, description: $description, locationDetail: $locationDetail)';
}


}

/// @nodoc
abstract mixin class _$LocationDtoCopyWith<$Res> implements $LocationDtoCopyWith<$Res> {
  factory _$LocationDtoCopyWith(_LocationDto value, $Res Function(_LocationDto) _then) = __$LocationDtoCopyWithImpl;
@override @useResult
$Res call({
 String locationId, String name, double latitude, double longitude, String? description, LocationDetailDto? locationDetail
});


@override $LocationDetailDtoCopyWith<$Res>? get locationDetail;

}
/// @nodoc
class __$LocationDtoCopyWithImpl<$Res>
    implements _$LocationDtoCopyWith<$Res> {
  __$LocationDtoCopyWithImpl(this._self, this._then);

  final _LocationDto _self;
  final $Res Function(_LocationDto) _then;

/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? description = freezed,Object? locationDetail = freezed,}) {
  return _then(_LocationDto(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as LocationDetailDto?,
  ));
}

/// Create a copy of LocationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationDetailDtoCopyWith<$Res>? get locationDetail {
    if (_self.locationDetail == null) {
    return null;
  }

  return $LocationDetailDtoCopyWith<$Res>(_self.locationDetail!, (value) {
    return _then(_self.copyWith(locationDetail: value));
  });
}
}

// dart format on
