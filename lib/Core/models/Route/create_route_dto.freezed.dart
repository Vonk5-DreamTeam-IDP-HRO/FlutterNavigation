// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_route_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateRouteDto {

/// Name of the route to create
///
/// **Validation:** Required, max 255 characters
/// **API Mapping:** Maps to C# `[Required][StringLength(255)] string Name`
///
/// Examples: "Morning Jog Route", "Historic City Center Tour"
 String get name;/// Optional description providing route details
///
/// **API Mapping:** Maps to C# `string? Description`
///
/// Can include route highlights, difficulty level, estimated duration, etc.
/// Examples: "A peaceful 5km route along the waterfront with cafe stops"
 String? get description;/// Privacy setting for route visibility
///
/// **Validation:** Required boolean
/// **API Mapping:** Maps to C# `[Required] bool IsPrivate`
/// **Default:** `true` for user privacy
///
/// - `true`: Only creator can see the route
/// - `false`: Route is publicly discoverable
 bool get isPrivate;/// Optional creator identifier
///
/// **API Behavior:** Will be overridden by backend service layer
/// **Security:** Backend extracts user ID from JWT authentication token
/// **API Mapping:** Maps to C# `Guid? CreatedBy`
///
/// Note: This field is included for API compatibility but the backend
/// service will populate it from the authenticated user context.
 String? get createdBy;
/// Create a copy of CreateRouteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRouteDtoCopyWith<CreateRouteDto> get copyWith => _$CreateRouteDtoCopyWithImpl<CreateRouteDto>(this as CreateRouteDto, _$identity);

  /// Serializes this CreateRouteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRouteDto&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,isPrivate,createdBy);

@override
String toString() {
  return 'CreateRouteDto(name: $name, description: $description, isPrivate: $isPrivate, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $CreateRouteDtoCopyWith<$Res>  {
  factory $CreateRouteDtoCopyWith(CreateRouteDto value, $Res Function(CreateRouteDto) _then) = _$CreateRouteDtoCopyWithImpl;
@useResult
$Res call({
 String name, String? description, bool isPrivate, String? createdBy
});




}
/// @nodoc
class _$CreateRouteDtoCopyWithImpl<$Res>
    implements $CreateRouteDtoCopyWith<$Res> {
  _$CreateRouteDtoCopyWithImpl(this._self, this._then);

  final CreateRouteDto _self;
  final $Res Function(CreateRouteDto) _then;

/// Create a copy of CreateRouteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? isPrivate = null,Object? createdBy = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CreateRouteDto implements CreateRouteDto {
  const _CreateRouteDto({required this.name, this.description, this.isPrivate = true, this.createdBy});
  factory _CreateRouteDto.fromJson(Map<String, dynamic> json) => _$CreateRouteDtoFromJson(json);

/// Name of the route to create
///
/// **Validation:** Required, max 255 characters
/// **API Mapping:** Maps to C# `[Required][StringLength(255)] string Name`
///
/// Examples: "Morning Jog Route", "Historic City Center Tour"
@override final  String name;
/// Optional description providing route details
///
/// **API Mapping:** Maps to C# `string? Description`
///
/// Can include route highlights, difficulty level, estimated duration, etc.
/// Examples: "A peaceful 5km route along the waterfront with cafe stops"
@override final  String? description;
/// Privacy setting for route visibility
///
/// **Validation:** Required boolean
/// **API Mapping:** Maps to C# `[Required] bool IsPrivate`
/// **Default:** `true` for user privacy
///
/// - `true`: Only creator can see the route
/// - `false`: Route is publicly discoverable
@override@JsonKey() final  bool isPrivate;
/// Optional creator identifier
///
/// **API Behavior:** Will be overridden by backend service layer
/// **Security:** Backend extracts user ID from JWT authentication token
/// **API Mapping:** Maps to C# `Guid? CreatedBy`
///
/// Note: This field is included for API compatibility but the backend
/// service will populate it from the authenticated user context.
@override final  String? createdBy;

/// Create a copy of CreateRouteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRouteDtoCopyWith<_CreateRouteDto> get copyWith => __$CreateRouteDtoCopyWithImpl<_CreateRouteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRouteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRouteDto&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,isPrivate,createdBy);

@override
String toString() {
  return 'CreateRouteDto(name: $name, description: $description, isPrivate: $isPrivate, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$CreateRouteDtoCopyWith<$Res> implements $CreateRouteDtoCopyWith<$Res> {
  factory _$CreateRouteDtoCopyWith(_CreateRouteDto value, $Res Function(_CreateRouteDto) _then) = __$CreateRouteDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, bool isPrivate, String? createdBy
});




}
/// @nodoc
class __$CreateRouteDtoCopyWithImpl<$Res>
    implements _$CreateRouteDtoCopyWith<$Res> {
  __$CreateRouteDtoCopyWithImpl(this._self, this._then);

  final _CreateRouteDto _self;
  final $Res Function(_CreateRouteDto) _then;

/// Create a copy of CreateRouteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? isPrivate = null,Object? createdBy = freezed,}) {
  return _then(_CreateRouteDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
