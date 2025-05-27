import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_location_dto.freezed.dart';
part 'create_location_dto.g.dart';

@freezed
abstract class CreateLocationDto with _$CreateLocationDto {
  const factory CreateLocationDto({
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    CreateLocationDetailDto? locationDetail,
  }) = _CreateLocationDto;

  factory CreateLocationDto.fromJson(Map<String, dynamic> json) =>
      _$CreateLocationDtoFromJson(json);
}

// Extension for validation methods
extension CreateLocationDtoValidation on CreateLocationDto {
  String? validateName() {
    if (name.isEmpty) return 'Name is required';
    if (name.length > 255) return 'Name must be 255 characters or less';
    return null;
  }

  String? validateLatitude() {
    if (latitude < 51.80 || latitude > 52.00) {
      return 'Latitude must be between 51.80 and 52.00 (Rotterdam area)';
    }
    return null;
  }

  String? validateLongitude() {
    if (longitude < 4.40 || longitude > 4.60) {
      return 'Longitude must be between 4.40 and 4.60 (Rotterdam area)';
    }
    return null;
  }

  bool isValid() {
    return validateName() == null &&
        validateLatitude() == null &&
        validateLongitude() == null;
  }
}

@freezed
abstract class CreateLocationDetailDto with _$CreateLocationDetailDto {
  const factory CreateLocationDetailDto({
    String? address, // max 255 chars in C#
    String? city, // max 100 chars in C#
    String? country, // max 100 chars in C#
    String? zipCode, // max 20 chars in C#
    String? phoneNumber, // max 20 chars in C#, phone validation
    String? website, // max 2048 chars in C#, URL validation
    String? category, // max 100 chars in C#
    String? accessibility, // max 500 chars in C#
  }) = _CreateLocationDetailDto;

  factory CreateLocationDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CreateLocationDetailDtoFromJson(json);
}

// Extension for validation methods
extension CreateLocationDetailDtoValidation on CreateLocationDetailDto {
  String? validateAddress() {
    if (address != null && address!.length > 255) {
      return 'Address must be 255 characters or less';
    }
    return null;
  }

  String? validateCity() {
    if (city != null && city!.length > 100) {
      return 'City must be 100 characters or less';
    }
    return null;
  }

  String? validateCountry() {
    if (country != null && country!.length > 100) {
      return 'Country must be 100 characters or less';
    }
    return null;
  }

  String? validateZipCode() {
    if (zipCode != null && zipCode!.length > 20) {
      return 'Zip code must be 20 characters or less';
    }
    return null;
  }

  String? validatePhoneNumber() {
    if (phoneNumber != null) {
      if (phoneNumber!.length > 20) {
        return 'Phone number must be 20 characters or less';
      }
      // Basic phone validation - you might want to use a more sophisticated regex
      final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]+$');
      if (!phoneRegex.hasMatch(phoneNumber!)) {
        return 'Invalid phone number format';
      }
    }
    return null;
  }

  String? validateWebsite() {
    if (website != null) {
      if (website!.length > 2048) {
        return 'Website URL must be 2048 characters or less';
      }
      // Basic URL validation
      final urlRegex = RegExp(r'^https?://[^\s]+$');
      if (!urlRegex.hasMatch(website!)) {
        return 'Invalid website URL format';
      }
    }
    return null;
  }

  String? validateCategory() {
    if (category != null && category!.length > 100) {
      return 'Category must be 100 characters or less';
    }
    return null;
  }

  String? validateAccessibility() {
    if (accessibility != null && accessibility!.length > 500) {
      return 'Accessibility must be 500 characters or less';
    }
    return null;
  }

  bool isValid() {
    return validateAddress() == null &&
        validateCity() == null &&
        validateCountry() == null &&
        validateZipCode() == null &&
        validatePhoneNumber() == null &&
        validateWebsite() == null &&
        validateCategory() == null &&
        validateAccessibility() == null;
  }
}
