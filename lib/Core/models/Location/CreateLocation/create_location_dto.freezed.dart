// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateLocationDto {

/// Location name (maps to C# string Name)
/// Must be non-empty and max 255 characters
 String get name;/// Latitude coordinate (maps to C# double Latitude)
/// Must be between 51.80 and 52.00 for Rotterdam area
 double get latitude;/// Longitude coordinate (maps to C# double Longitude)
/// Must be between 4.40 and 4.60 for Rotterdam area
 double get longitude;/// Optional description (maps to C# string? Description)
 String? get description;/// Optional location details (maps to C# CreateLocationDetailDto? LocationDetail)
 CreateLocationDetailDto? get locationDetail;
/// Create a copy of CreateLocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateLocationDtoCopyWith<CreateLocationDto> get copyWith => _$CreateLocationDtoCopyWithImpl<CreateLocationDto>(this as CreateLocationDto, _$identity);

  /// Serializes this CreateLocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateLocationDto&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.description, description) || other.description == description)&&(identical(other.locationDetail, locationDetail) || other.locationDetail == locationDetail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,latitude,longitude,description,locationDetail);

@override
String toString() {
  return 'CreateLocationDto(name: $name, latitude: $latitude, longitude: $longitude, description: $description, locationDetail: $locationDetail)';
}


}

/// @nodoc
abstract mixin class $CreateLocationDtoCopyWith<$Res>  {
  factory $CreateLocationDtoCopyWith(CreateLocationDto value, $Res Function(CreateLocationDto) _then) = _$CreateLocationDtoCopyWithImpl;
@useResult
$Res call({
 String name, double latitude, double longitude, String? description, CreateLocationDetailDto? locationDetail
});


$CreateLocationDetailDtoCopyWith<$Res>? get locationDetail;

}
/// @nodoc
class _$CreateLocationDtoCopyWithImpl<$Res>
    implements $CreateLocationDtoCopyWith<$Res> {
  _$CreateLocationDtoCopyWithImpl(this._self, this._then);

  final CreateLocationDto _self;
  final $Res Function(CreateLocationDto) _then;

/// Create a copy of CreateLocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? latitude = null,Object? longitude = null,Object? description = freezed,Object? locationDetail = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as CreateLocationDetailDto?,
  ));
}
/// Create a copy of CreateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateLocationDetailDtoCopyWith<$Res>? get locationDetail {
    if (_self.locationDetail == null) {
    return null;
  }

  return $CreateLocationDetailDtoCopyWith<$Res>(_self.locationDetail!, (value) {
    return _then(_self.copyWith(locationDetail: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _CreateLocationDto implements CreateLocationDto {
  const _CreateLocationDto({required this.name, required this.latitude, required this.longitude, this.description, this.locationDetail});
  factory _CreateLocationDto.fromJson(Map<String, dynamic> json) => _$CreateLocationDtoFromJson(json);

/// Location name (maps to C# string Name)
/// Must be non-empty and max 255 characters
@override final  String name;
/// Latitude coordinate (maps to C# double Latitude)
/// Must be between 51.80 and 52.00 for Rotterdam area
@override final  double latitude;
/// Longitude coordinate (maps to C# double Longitude)
/// Must be between 4.40 and 4.60 for Rotterdam area
@override final  double longitude;
/// Optional description (maps to C# string? Description)
@override final  String? description;
/// Optional location details (maps to C# CreateLocationDetailDto? LocationDetail)
@override final  CreateLocationDetailDto? locationDetail;

/// Create a copy of CreateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateLocationDtoCopyWith<_CreateLocationDto> get copyWith => __$CreateLocationDtoCopyWithImpl<_CreateLocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateLocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateLocationDto&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.description, description) || other.description == description)&&(identical(other.locationDetail, locationDetail) || other.locationDetail == locationDetail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,latitude,longitude,description,locationDetail);

@override
String toString() {
  return 'CreateLocationDto(name: $name, latitude: $latitude, longitude: $longitude, description: $description, locationDetail: $locationDetail)';
}


}

/// @nodoc
abstract mixin class _$CreateLocationDtoCopyWith<$Res> implements $CreateLocationDtoCopyWith<$Res> {
  factory _$CreateLocationDtoCopyWith(_CreateLocationDto value, $Res Function(_CreateLocationDto) _then) = __$CreateLocationDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, double latitude, double longitude, String? description, CreateLocationDetailDto? locationDetail
});


@override $CreateLocationDetailDtoCopyWith<$Res>? get locationDetail;

}
/// @nodoc
class __$CreateLocationDtoCopyWithImpl<$Res>
    implements _$CreateLocationDtoCopyWith<$Res> {
  __$CreateLocationDtoCopyWithImpl(this._self, this._then);

  final _CreateLocationDto _self;
  final $Res Function(_CreateLocationDto) _then;

/// Create a copy of CreateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? latitude = null,Object? longitude = null,Object? description = freezed,Object? locationDetail = freezed,}) {
  return _then(_CreateLocationDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as CreateLocationDetailDto?,
  ));
}

/// Create a copy of CreateLocationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateLocationDetailDtoCopyWith<$Res>? get locationDetail {
    if (_self.locationDetail == null) {
    return null;
  }

  return $CreateLocationDetailDtoCopyWith<$Res>(_self.locationDetail!, (value) {
    return _then(_self.copyWith(locationDetail: value));
  });
}
}


/// @nodoc
mixin _$CreateLocationDetailDto {

/// Street address (maps to C# string? Address)
/// Max 255 characters as per C# backend constraint
 String? get address;/// City name (maps to C# string? City)
/// Max 100 characters as per C# backend constraint
 String? get city;/// Country name (maps to C# string? Country)
/// Max 100 characters as per C# backend constraint
 String? get country;/// Postal/ZIP code (maps to C# string? ZipCode)
/// Max 20 characters as per C# backend constraint
 String? get zipCode;/// Contact phone number (maps to C# string? PhoneNumber)
/// Max 20 characters with format validation as per C# backend
 String? get phoneNumber;/// Website URL (maps to C# string? Website)
/// Max 2048 characters with URL format validation as per C# backend
 String? get website;/// Location category/type (maps to C# string? Category)
/// Max 100 characters as per C# backend constraint
 String? get category;/// Accessibility information (maps to C# string? Accessibility)
/// Max 500 characters as per C# backend constraint
 String? get accessibility;
/// Create a copy of CreateLocationDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateLocationDetailDtoCopyWith<CreateLocationDetailDto> get copyWith => _$CreateLocationDetailDtoCopyWithImpl<CreateLocationDetailDto>(this as CreateLocationDetailDto, _$identity);

  /// Serializes this CreateLocationDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateLocationDetailDto&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.website, website) || other.website == website)&&(identical(other.category, category) || other.category == category)&&(identical(other.accessibility, accessibility) || other.accessibility == accessibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,country,zipCode,phoneNumber,website,category,accessibility);

@override
String toString() {
  return 'CreateLocationDetailDto(address: $address, city: $city, country: $country, zipCode: $zipCode, phoneNumber: $phoneNumber, website: $website, category: $category, accessibility: $accessibility)';
}


}

/// @nodoc
abstract mixin class $CreateLocationDetailDtoCopyWith<$Res>  {
  factory $CreateLocationDetailDtoCopyWith(CreateLocationDetailDto value, $Res Function(CreateLocationDetailDto) _then) = _$CreateLocationDetailDtoCopyWithImpl;
@useResult
$Res call({
 String? address, String? city, String? country, String? zipCode, String? phoneNumber, String? website, String? category, String? accessibility
});




}
/// @nodoc
class _$CreateLocationDetailDtoCopyWithImpl<$Res>
    implements $CreateLocationDetailDtoCopyWith<$Res> {
  _$CreateLocationDetailDtoCopyWithImpl(this._self, this._then);

  final CreateLocationDetailDto _self;
  final $Res Function(CreateLocationDetailDto) _then;

/// Create a copy of CreateLocationDetailDto
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

class _CreateLocationDetailDto implements CreateLocationDetailDto {
  const _CreateLocationDetailDto({this.address, this.city, this.country, this.zipCode, this.phoneNumber, this.website, this.category, this.accessibility});
  factory _CreateLocationDetailDto.fromJson(Map<String, dynamic> json) => _$CreateLocationDetailDtoFromJson(json);

/// Street address (maps to C# string? Address)
/// Max 255 characters as per C# backend constraint
@override final  String? address;
/// City name (maps to C# string? City)
/// Max 100 characters as per C# backend constraint
@override final  String? city;
/// Country name (maps to C# string? Country)
/// Max 100 characters as per C# backend constraint
@override final  String? country;
/// Postal/ZIP code (maps to C# string? ZipCode)
/// Max 20 characters as per C# backend constraint
@override final  String? zipCode;
/// Contact phone number (maps to C# string? PhoneNumber)
/// Max 20 characters with format validation as per C# backend
@override final  String? phoneNumber;
/// Website URL (maps to C# string? Website)
/// Max 2048 characters with URL format validation as per C# backend
@override final  String? website;
/// Location category/type (maps to C# string? Category)
/// Max 100 characters as per C# backend constraint
@override final  String? category;
/// Accessibility information (maps to C# string? Accessibility)
/// Max 500 characters as per C# backend constraint
@override final  String? accessibility;

/// Create a copy of CreateLocationDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateLocationDetailDtoCopyWith<_CreateLocationDetailDto> get copyWith => __$CreateLocationDetailDtoCopyWithImpl<_CreateLocationDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateLocationDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateLocationDetailDto&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.website, website) || other.website == website)&&(identical(other.category, category) || other.category == category)&&(identical(other.accessibility, accessibility) || other.accessibility == accessibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,country,zipCode,phoneNumber,website,category,accessibility);

@override
String toString() {
  return 'CreateLocationDetailDto(address: $address, city: $city, country: $country, zipCode: $zipCode, phoneNumber: $phoneNumber, website: $website, category: $category, accessibility: $accessibility)';
}


}

/// @nodoc
abstract mixin class _$CreateLocationDetailDtoCopyWith<$Res> implements $CreateLocationDetailDtoCopyWith<$Res> {
  factory _$CreateLocationDetailDtoCopyWith(_CreateLocationDetailDto value, $Res Function(_CreateLocationDetailDto) _then) = __$CreateLocationDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String? address, String? city, String? country, String? zipCode, String? phoneNumber, String? website, String? category, String? accessibility
});




}
/// @nodoc
class __$CreateLocationDetailDtoCopyWithImpl<$Res>
    implements _$CreateLocationDetailDtoCopyWith<$Res> {
  __$CreateLocationDetailDtoCopyWithImpl(this._self, this._then);

  final _CreateLocationDetailDto _self;
  final $Res Function(_CreateLocationDetailDto) _then;

/// Create a copy of CreateLocationDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? zipCode = freezed,Object? phoneNumber = freezed,Object? website = freezed,Object? category = freezed,Object? accessibility = freezed,}) {
  return _then(_CreateLocationDetailDto(
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
