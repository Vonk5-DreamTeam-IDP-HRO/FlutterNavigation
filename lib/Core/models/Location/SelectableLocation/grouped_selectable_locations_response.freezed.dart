// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grouped_selectable_locations_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupedSelectableLocationsResponse {

/// Dictionary of categories mapped to their selectable locations
/// Key: Category name (string)
/// Value: List of SelectableLocationDto for that category
 Map<String, List<SelectableLocationDto>> get groupedLocations;
/// Create a copy of GroupedSelectableLocationsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupedSelectableLocationsResponseCopyWith<GroupedSelectableLocationsResponse> get copyWith => _$GroupedSelectableLocationsResponseCopyWithImpl<GroupedSelectableLocationsResponse>(this as GroupedSelectableLocationsResponse, _$identity);

  /// Serializes this GroupedSelectableLocationsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupedSelectableLocationsResponse&&const DeepCollectionEquality().equals(other.groupedLocations, groupedLocations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groupedLocations));

@override
String toString() {
  return 'GroupedSelectableLocationsResponse(groupedLocations: $groupedLocations)';
}


}

/// @nodoc
abstract mixin class $GroupedSelectableLocationsResponseCopyWith<$Res>  {
  factory $GroupedSelectableLocationsResponseCopyWith(GroupedSelectableLocationsResponse value, $Res Function(GroupedSelectableLocationsResponse) _then) = _$GroupedSelectableLocationsResponseCopyWithImpl;
@useResult
$Res call({
 Map<String, List<SelectableLocationDto>> groupedLocations
});




}
/// @nodoc
class _$GroupedSelectableLocationsResponseCopyWithImpl<$Res>
    implements $GroupedSelectableLocationsResponseCopyWith<$Res> {
  _$GroupedSelectableLocationsResponseCopyWithImpl(this._self, this._then);

  final GroupedSelectableLocationsResponse _self;
  final $Res Function(GroupedSelectableLocationsResponse) _then;

/// Create a copy of GroupedSelectableLocationsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupedLocations = null,}) {
  return _then(_self.copyWith(
groupedLocations: null == groupedLocations ? _self.groupedLocations : groupedLocations // ignore: cast_nullable_to_non_nullable
as Map<String, List<SelectableLocationDto>>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _GroupedSelectableLocationsResponse implements GroupedSelectableLocationsResponse {
  const _GroupedSelectableLocationsResponse({required final  Map<String, List<SelectableLocationDto>> groupedLocations}): _groupedLocations = groupedLocations;
  factory _GroupedSelectableLocationsResponse.fromJson(Map<String, dynamic> json) => _$GroupedSelectableLocationsResponseFromJson(json);

/// Dictionary of categories mapped to their selectable locations
/// Key: Category name (string)
/// Value: List of SelectableLocationDto for that category
 final  Map<String, List<SelectableLocationDto>> _groupedLocations;
/// Dictionary of categories mapped to their selectable locations
/// Key: Category name (string)
/// Value: List of SelectableLocationDto for that category
@override Map<String, List<SelectableLocationDto>> get groupedLocations {
  if (_groupedLocations is EqualUnmodifiableMapView) return _groupedLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupedLocations);
}


/// Create a copy of GroupedSelectableLocationsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupedSelectableLocationsResponseCopyWith<_GroupedSelectableLocationsResponse> get copyWith => __$GroupedSelectableLocationsResponseCopyWithImpl<_GroupedSelectableLocationsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupedSelectableLocationsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupedSelectableLocationsResponse&&const DeepCollectionEquality().equals(other._groupedLocations, _groupedLocations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groupedLocations));

@override
String toString() {
  return 'GroupedSelectableLocationsResponse(groupedLocations: $groupedLocations)';
}


}

/// @nodoc
abstract mixin class _$GroupedSelectableLocationsResponseCopyWith<$Res> implements $GroupedSelectableLocationsResponseCopyWith<$Res> {
  factory _$GroupedSelectableLocationsResponseCopyWith(_GroupedSelectableLocationsResponse value, $Res Function(_GroupedSelectableLocationsResponse) _then) = __$GroupedSelectableLocationsResponseCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<SelectableLocationDto>> groupedLocations
});




}
/// @nodoc
class __$GroupedSelectableLocationsResponseCopyWithImpl<$Res>
    implements _$GroupedSelectableLocationsResponseCopyWith<$Res> {
  __$GroupedSelectableLocationsResponseCopyWithImpl(this._self, this._then);

  final _GroupedSelectableLocationsResponse _self;
  final $Res Function(_GroupedSelectableLocationsResponse) _then;

/// Create a copy of GroupedSelectableLocationsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupedLocations = null,}) {
  return _then(_GroupedSelectableLocationsResponse(
groupedLocations: null == groupedLocations ? _self._groupedLocations : groupedLocations // ignore: cast_nullable_to_non_nullable
as Map<String, List<SelectableLocationDto>>,
  ));
}


}

// dart format on
