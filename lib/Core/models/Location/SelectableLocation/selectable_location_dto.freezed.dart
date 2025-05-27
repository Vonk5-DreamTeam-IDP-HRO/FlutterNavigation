// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selectable_location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SelectableLocationDto {

/// Unique identifier for the location (maps to C# Guid LocationId)
 String get locationId;/// Name of the location (maps to C# string Name)
 String get name;/// Category of the location (maps to C# string? Category)
/// Will be auto-handled by Freezed JSON generation
 String? get category;
/// Create a copy of SelectableLocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectableLocationDtoCopyWith<SelectableLocationDto> get copyWith => _$SelectableLocationDtoCopyWithImpl<SelectableLocationDto>(this as SelectableLocationDto, _$identity);

  /// Serializes this SelectableLocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectableLocationDto&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationId,name,category);

@override
String toString() {
  return 'SelectableLocationDto(locationId: $locationId, name: $name, category: $category)';
}


}

/// @nodoc
abstract mixin class $SelectableLocationDtoCopyWith<$Res>  {
  factory $SelectableLocationDtoCopyWith(SelectableLocationDto value, $Res Function(SelectableLocationDto) _then) = _$SelectableLocationDtoCopyWithImpl;
@useResult
$Res call({
 String locationId, String name, String? category
});




}
/// @nodoc
class _$SelectableLocationDtoCopyWithImpl<$Res>
    implements $SelectableLocationDtoCopyWith<$Res> {
  _$SelectableLocationDtoCopyWithImpl(this._self, this._then);

  final SelectableLocationDto _self;
  final $Res Function(SelectableLocationDto) _then;

/// Create a copy of SelectableLocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationId = null,Object? name = null,Object? category = freezed,}) {
  return _then(_self.copyWith(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SelectableLocationDto implements SelectableLocationDto {
  const _SelectableLocationDto({required this.locationId, required this.name, this.category});
  factory _SelectableLocationDto.fromJson(Map<String, dynamic> json) => _$SelectableLocationDtoFromJson(json);

/// Unique identifier for the location (maps to C# Guid LocationId)
@override final  String locationId;
/// Name of the location (maps to C# string Name)
@override final  String name;
/// Category of the location (maps to C# string? Category)
/// Will be auto-handled by Freezed JSON generation
@override final  String? category;

/// Create a copy of SelectableLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectableLocationDtoCopyWith<_SelectableLocationDto> get copyWith => __$SelectableLocationDtoCopyWithImpl<_SelectableLocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectableLocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectableLocationDto&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationId,name,category);

@override
String toString() {
  return 'SelectableLocationDto(locationId: $locationId, name: $name, category: $category)';
}


}

/// @nodoc
abstract mixin class _$SelectableLocationDtoCopyWith<$Res> implements $SelectableLocationDtoCopyWith<$Res> {
  factory _$SelectableLocationDtoCopyWith(_SelectableLocationDto value, $Res Function(_SelectableLocationDto) _then) = __$SelectableLocationDtoCopyWithImpl;
@override @useResult
$Res call({
 String locationId, String name, String? category
});




}
/// @nodoc
class __$SelectableLocationDtoCopyWithImpl<$Res>
    implements _$SelectableLocationDtoCopyWith<$Res> {
  __$SelectableLocationDtoCopyWithImpl(this._self, this._then);

  final _SelectableLocationDto _self;
  final $Res Function(_SelectableLocationDto) _then;

/// Create a copy of SelectableLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = null,Object? name = null,Object? category = freezed,}) {
  return _then(_SelectableLocationDto(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
