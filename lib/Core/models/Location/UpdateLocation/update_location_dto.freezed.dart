// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateLocationDto {

 String get name; double get latitude; double get longitude; String? get description; UpdateLocationDetailDto? get locationDetail;
/// Create a copy of UpdateLocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateLocationDtoCopyWith<UpdateLocationDto> get copyWith => _$UpdateLocationDtoCopyWithImpl<UpdateLocationDto>(this as UpdateLocationDto, _$identity);

  /// Serializes this UpdateLocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateLocationDto&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.description, description) || other.description == description)&&(identical(other.locationDetail, locationDetail) || other.locationDetail == locationDetail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,latitude,longitude,description,locationDetail);

@override
String toString() {
  return 'UpdateLocationDto(name: $name, latitude: $latitude, longitude: $longitude, description: $description, locationDetail: $locationDetail)';
}


}

/// @nodoc
abstract mixin class $UpdateLocationDtoCopyWith<$Res>  {
  factory $UpdateLocationDtoCopyWith(UpdateLocationDto value, $Res Function(UpdateLocationDto) _then) = _$UpdateLocationDtoCopyWithImpl;
@useResult
$Res call({
 String name, double latitude, double longitude, String? description, UpdateLocationDetailDto? locationDetail
});


$UpdateLocationDetailDtoCopyWith<$Res>? get locationDetail;

}
/// @nodoc
class _$UpdateLocationDtoCopyWithImpl<$Res>
    implements $UpdateLocationDtoCopyWith<$Res> {
  _$UpdateLocationDtoCopyWithImpl(this._self, this._then);

  final UpdateLocationDto _self;
  final $Res Function(UpdateLocationDto) _then;

/// Create a copy of UpdateLocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? latitude = null,Object? longitude = null,Object? description = freezed,Object? locationDetail = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as UpdateLocationDetailDto?,
  ));
}
/// Create a copy of UpdateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateLocationDetailDtoCopyWith<$Res>? get locationDetail {
    if (_self.locationDetail == null) {
    return null;
  }

  return $UpdateLocationDetailDtoCopyWith<$Res>(_self.locationDetail!, (value) {
    return _then(_self.copyWith(locationDetail: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _UpdateLocationDto implements UpdateLocationDto {
  const _UpdateLocationDto({required this.name, required this.latitude, required this.longitude, this.description, this.locationDetail});
  factory _UpdateLocationDto.fromJson(Map<String, dynamic> json) => _$UpdateLocationDtoFromJson(json);

@override final  String name;
@override final  double latitude;
@override final  double longitude;
@override final  String? description;
@override final  UpdateLocationDetailDto? locationDetail;

/// Create a copy of UpdateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateLocationDtoCopyWith<_UpdateLocationDto> get copyWith => __$UpdateLocationDtoCopyWithImpl<_UpdateLocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateLocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateLocationDto&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.description, description) || other.description == description)&&(identical(other.locationDetail, locationDetail) || other.locationDetail == locationDetail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,latitude,longitude,description,locationDetail);

@override
String toString() {
  return 'UpdateLocationDto(name: $name, latitude: $latitude, longitude: $longitude, description: $description, locationDetail: $locationDetail)';
}


}

/// @nodoc
abstract mixin class _$UpdateLocationDtoCopyWith<$Res> implements $UpdateLocationDtoCopyWith<$Res> {
  factory _$UpdateLocationDtoCopyWith(_UpdateLocationDto value, $Res Function(_UpdateLocationDto) _then) = __$UpdateLocationDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, double latitude, double longitude, String? description, UpdateLocationDetailDto? locationDetail
});


@override $UpdateLocationDetailDtoCopyWith<$Res>? get locationDetail;

}
/// @nodoc
class __$UpdateLocationDtoCopyWithImpl<$Res>
    implements _$UpdateLocationDtoCopyWith<$Res> {
  __$UpdateLocationDtoCopyWithImpl(this._self, this._then);

  final _UpdateLocationDto _self;
  final $Res Function(_UpdateLocationDto) _then;

/// Create a copy of UpdateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? latitude = null,Object? longitude = null,Object? description = freezed,Object? locationDetail = freezed,}) {
  return _then(_UpdateLocationDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as UpdateLocationDetailDto?,
  ));
}

/// Create a copy of UpdateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateLocationDetailDtoCopyWith<$Res>? get locationDetail {
    if (_self.locationDetail == null) {
    return null;
  }

  return $UpdateLocationDetailDtoCopyWith<$Res>(_self.locationDetail!, (value) {
    return _then(_self.copyWith(locationDetail: value));
  });
}
}


/// @nodoc
mixin _$UpdateLocationDetailDto {

 String? get address; String? get city; String? get country; String? get zipCode; String? get phoneNumber; String? get website; String? get category; String? get accessibility;
/// Create a copy of UpdateLocationDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateLocationDetailDtoCopyWith<UpdateLocationDetailDto> get copyWith => _$UpdateLocationDetailDtoCopyWithImpl<UpdateLocationDetailDto>(this as UpdateLocationDetailDto, _$identity);

  /// Serializes this UpdateLocationDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateLocationDetailDto&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.website, website) || other.website == website)&&(identical(other.category, category) || other.category == category)&&(identical(other.accessibility, accessibility) || other.accessibility == accessibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,country,zipCode,phoneNumber,website,category,accessibility);

@override
String toString() {
  return 'UpdateLocationDetailDto(address: $address, city: $city, country: $country, zipCode: $zipCode, phoneNumber: $phoneNumber, website: $website, category: $category, accessibility: $accessibility)';
}


}

/// @nodoc
abstract mixin class $UpdateLocationDetailDtoCopyWith<$Res>  {
  factory $UpdateLocationDetailDtoCopyWith(UpdateLocationDetailDto value, $Res Function(UpdateLocationDetailDto) _then) = _$UpdateLocationDetailDtoCopyWithImpl;
@useResult
$Res call({
 String? address, String? city, String? country, String? zipCode, String? phoneNumber, String? website, String? category, String? accessibility
});




}
/// @nodoc
class _$UpdateLocationDetailDtoCopyWithImpl<$Res>
    implements $UpdateLocationDetailDtoCopyWith<$Res> {
  _$UpdateLocationDetailDtoCopyWithImpl(this._self, this._then);

  final UpdateLocationDetailDto _self;
  final $Res Function(UpdateLocationDetailDto) _then;

/// Create a copy of UpdateLocationDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? zipCode = freezed,Object? phoneNumber = freezed,Object? website = freezed,Object? category = freezed,Object? accessibility = freezed,}) {
  return _then(_self.copyWith(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,accessibility: freezed == accessibility ? _self.accessibility : accessibility // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UpdateLocationDetailDto implements UpdateLocationDetailDto {
  const _UpdateLocationDetailDto({this.address, this.city, this.country, this.zipCode, this.phoneNumber, this.website, this.category, this.accessibility});
  factory _UpdateLocationDetailDto.fromJson(Map<String, dynamic> json) => _$UpdateLocationDetailDtoFromJson(json);

@override final  String? address;
@override final  String? city;
@override final  String? country;
@override final  String? zipCode;
@override final  String? phoneNumber;
@override final  String? website;
@override final  String? category;
@override final  String? accessibility;

/// Create a copy of UpdateLocationDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateLocationDetailDtoCopyWith<_UpdateLocationDetailDto> get copyWith => __$UpdateLocationDetailDtoCopyWithImpl<_UpdateLocationDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateLocationDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateLocationDetailDto&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.website, website) || other.website == website)&&(identical(other.category, category) || other.category == category)&&(identical(other.accessibility, accessibility) || other.accessibility == accessibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,country,zipCode,phoneNumber,website,category,accessibility);

@override
String toString() {
  return 'UpdateLocationDetailDto(address: $address, city: $city, country: $country, zipCode: $zipCode, phoneNumber: $phoneNumber, website: $website, category: $category, accessibility: $accessibility)';
}


}

/// @nodoc
abstract mixin class _$UpdateLocationDetailDtoCopyWith<$Res> implements $UpdateLocationDetailDtoCopyWith<$Res> {
  factory _$UpdateLocationDetailDtoCopyWith(_UpdateLocationDetailDto value, $Res Function(_UpdateLocationDetailDto) _then) = __$UpdateLocationDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String? address, String? city, String? country, String? zipCode, String? phoneNumber, String? website, String? category, String? accessibility
});




}
/// @nodoc
class __$UpdateLocationDetailDtoCopyWithImpl<$Res>
    implements _$UpdateLocationDetailDtoCopyWith<$Res> {
  __$UpdateLocationDetailDtoCopyWithImpl(this._self, this._then);

  final _UpdateLocationDetailDto _self;
  final $Res Function(_UpdateLocationDetailDto) _then;

/// Create a copy of UpdateLocationDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? zipCode = freezed,Object? phoneNumber = freezed,Object? website = freezed,Object? category = freezed,Object? accessibility = freezed,}) {
  return _then(_UpdateLocationDetailDto(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,accessibility: freezed == accessibility ? _self.accessibility : accessibility // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
