// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'SelectableNavigationRoute.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SelectableNavigationRoute _$SelectableNavigationRouteFromJson(
  Map<String, dynamic> json
) {
    return _NavigationRoute.fromJson(
      json
    );
}

/// @nodoc
mixin _$SelectableNavigationRoute {

/// Unique identifier linking back to the full route entity
///
/// **Purpose:** Primary key for retrieving complete route data when selected
/// **Format:** UUID v4 string matching RouteDto.routeId
/// **Usage:** Navigation parameter, API lookups, deep linking
///
/// **Implementation Examples:**
/// ```dart
/// // Navigate to route details
/// context.push('/routes/${selectedRoute.id}');
///
/// // Fetch full route data
/// final fullRoute = await routeService.getRoute(selectedRoute.id);
///
/// // Update user preferences
/// await userPrefs.setLastSelectedRoute(selectedRoute.id);
/// ```
///
/// **Data Consistency:**
/// - Must match existing RouteDto.routeId in database
/// - Used for referential integrity in selection operations
/// - Links selection state back to complete route entity
 String get id;/// User-friendly name optimized for display in selection interfaces
///
/// **Naming Choice:** `displayName` (vs `name`) indicates UI-specific formatting
/// **Content:** May include enhanced formatting, truncation, or prefixes
/// **Usage:** Primary text in dropdowns, lists, and selection widgets
///
/// **Display Optimizations:**
/// - Pre-truncated for consistent UI layout
/// - May include contextual prefixes ("My Route: ...", "Public: ...")
/// - Formatted for specific UI constraints (character limits)
///
/// **Examples:**
/// - `"Morning Jog (5km)"` - includes distance hint
/// - `"Historic Center Tour..."` - truncated with ellipsis
/// - `"★ Weekend Cycling"` - includes favorite indicator
///
/// **Transformation Logic:**
/// ```dart
/// // From RouteDto.name with UI enhancements
/// displayName = route.isPrivate
///   ? "🔒 ${route.name}"
///   : route.name;
/// ```
 String get displayName;/// Brief route summary optimized for secondary UI text
///
/// **Purpose:** Provides additional context in selection interfaces
/// **Content:** Condensed route highlights, difficulty, or key features
/// **Usage:** Subtitle text in lists, tooltip content, preview information
///
/// **Content Strategy:**
/// - Shorter than full RouteDto.description (optimal for UI)
/// - Highlights most important route characteristics
/// - Helps users distinguish between similar route names
/// - May include computed metadata (distance, duration estimates)
///
/// **UI Applications:**
/// ```dart
/// // List item with subtitle
/// ListTile(
///   title: Text(route.displayName),
///   subtitle: Text(route.description),
/// )
///
/// // Tooltip for compact displays
/// Tooltip(
///   message: route.description,
///   child: Text(route.displayName),
/// )
/// ```
///
/// **Content Examples:**
/// - `"5km riverside path • Easy difficulty"` - key stats
/// - `"Historic landmarks tour through city center"` - highlights
/// - `"Created by @username • 4.5★ rating"` - social context
///
/// **Data Processing:**
/// - May aggregate information from multiple sources
/// - Could include computed fields (ratings, popularity)
/// - Optimized length for common UI component constraints
 String get description;
/// Create a copy of SelectableNavigationRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectableNavigationRouteCopyWith<SelectableNavigationRoute> get copyWith => _$SelectableNavigationRouteCopyWithImpl<SelectableNavigationRoute>(this as SelectableNavigationRoute, _$identity);

  /// Serializes this SelectableNavigationRoute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectableNavigationRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,description);

@override
String toString() {
  return 'SelectableNavigationRoute(id: $id, displayName: $displayName, description: $description)';
}


}

/// @nodoc
abstract mixin class $SelectableNavigationRouteCopyWith<$Res>  {
  factory $SelectableNavigationRouteCopyWith(SelectableNavigationRoute value, $Res Function(SelectableNavigationRoute) _then) = _$SelectableNavigationRouteCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String description
});




}
/// @nodoc
class _$SelectableNavigationRouteCopyWithImpl<$Res>
    implements $SelectableNavigationRouteCopyWith<$Res> {
  _$SelectableNavigationRouteCopyWithImpl(this._self, this._then);

  final SelectableNavigationRoute _self;
  final $Res Function(SelectableNavigationRoute) _then;

/// Create a copy of SelectableNavigationRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? description = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _NavigationRoute implements SelectableNavigationRoute {
  const _NavigationRoute({required this.id, required this.displayName, required this.description});
  factory _NavigationRoute.fromJson(Map<String, dynamic> json) => _$NavigationRouteFromJson(json);

/// Unique identifier linking back to the full route entity
///
/// **Purpose:** Primary key for retrieving complete route data when selected
/// **Format:** UUID v4 string matching RouteDto.routeId
/// **Usage:** Navigation parameter, API lookups, deep linking
///
/// **Implementation Examples:**
/// ```dart
/// // Navigate to route details
/// context.push('/routes/${selectedRoute.id}');
///
/// // Fetch full route data
/// final fullRoute = await routeService.getRoute(selectedRoute.id);
///
/// // Update user preferences
/// await userPrefs.setLastSelectedRoute(selectedRoute.id);
/// ```
///
/// **Data Consistency:**
/// - Must match existing RouteDto.routeId in database
/// - Used for referential integrity in selection operations
/// - Links selection state back to complete route entity
@override final  String id;
/// User-friendly name optimized for display in selection interfaces
///
/// **Naming Choice:** `displayName` (vs `name`) indicates UI-specific formatting
/// **Content:** May include enhanced formatting, truncation, or prefixes
/// **Usage:** Primary text in dropdowns, lists, and selection widgets
///
/// **Display Optimizations:**
/// - Pre-truncated for consistent UI layout
/// - May include contextual prefixes ("My Route: ...", "Public: ...")
/// - Formatted for specific UI constraints (character limits)
///
/// **Examples:**
/// - `"Morning Jog (5km)"` - includes distance hint
/// - `"Historic Center Tour..."` - truncated with ellipsis
/// - `"★ Weekend Cycling"` - includes favorite indicator
///
/// **Transformation Logic:**
/// ```dart
/// // From RouteDto.name with UI enhancements
/// displayName = route.isPrivate
///   ? "🔒 ${route.name}"
///   : route.name;
/// ```
@override final  String displayName;
/// Brief route summary optimized for secondary UI text
///
/// **Purpose:** Provides additional context in selection interfaces
/// **Content:** Condensed route highlights, difficulty, or key features
/// **Usage:** Subtitle text in lists, tooltip content, preview information
///
/// **Content Strategy:**
/// - Shorter than full RouteDto.description (optimal for UI)
/// - Highlights most important route characteristics
/// - Helps users distinguish between similar route names
/// - May include computed metadata (distance, duration estimates)
///
/// **UI Applications:**
/// ```dart
/// // List item with subtitle
/// ListTile(
///   title: Text(route.displayName),
///   subtitle: Text(route.description),
/// )
///
/// // Tooltip for compact displays
/// Tooltip(
///   message: route.description,
///   child: Text(route.displayName),
/// )
/// ```
///
/// **Content Examples:**
/// - `"5km riverside path • Easy difficulty"` - key stats
/// - `"Historic landmarks tour through city center"` - highlights
/// - `"Created by @username • 4.5★ rating"` - social context
///
/// **Data Processing:**
/// - May aggregate information from multiple sources
/// - Could include computed fields (ratings, popularity)
/// - Optimized length for common UI component constraints
@override final  String description;

/// Create a copy of SelectableNavigationRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationRouteCopyWith<_NavigationRoute> get copyWith => __$NavigationRouteCopyWithImpl<_NavigationRoute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NavigationRouteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,description);

@override
String toString() {
  return 'SelectableNavigationRoute(id: $id, displayName: $displayName, description: $description)';
}


}

/// @nodoc
abstract mixin class _$NavigationRouteCopyWith<$Res> implements $SelectableNavigationRouteCopyWith<$Res> {
  factory _$NavigationRouteCopyWith(_NavigationRoute value, $Res Function(_NavigationRoute) _then) = __$NavigationRouteCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String description
});




}
/// @nodoc
class __$NavigationRouteCopyWithImpl<$Res>
    implements _$NavigationRouteCopyWith<$Res> {
  __$NavigationRouteCopyWithImpl(this._self, this._then);

  final _NavigationRoute _self;
  final $Res Function(_NavigationRoute) _then;

/// Create a copy of SelectableNavigationRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? description = null,}) {
  return _then(_NavigationRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
