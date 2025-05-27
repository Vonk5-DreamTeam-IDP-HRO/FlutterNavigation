import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_location_dto.freezed.dart';
part 'update_location_dto.g.dart';

@freezed
abstract class UpdateLocationDto with _$UpdateLocationDto {
  const factory UpdateLocationDto({
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    UpdateLocationDetailDto? locationDetail,
  }) = _UpdateLocationDto;

  factory UpdateLocationDto.fromJson(Map<String, Object?> json) =>
      _$UpdateLocationDtoFromJson(json);
}

@freezed
abstract class UpdateLocationDetailDto with _$UpdateLocationDetailDto {
  const factory UpdateLocationDetailDto({
    String? address,
    String? city,
    String? country,
    String? zipCode,
    String? phoneNumber,
    String? website,
    String? category,
    String? accessibility,
  }) = _UpdateLocationDetailDto;

  factory UpdateLocationDetailDto.fromJson(Map<String, Object?> json) =>
      _$UpdateLocationDetailDtoFromJson(json);
}

// Validation extensions
extension UpdateLocationDtoValidation on UpdateLocationDto {
  bool get isValid {
    return isNameValid &&
        areCoordinatesValid &&
        isDescriptionValid &&
        (locationDetail?.isValid ?? true);
  }

  bool get isNameValid => name.trim().isNotEmpty && name.length <= 100;

  bool get areCoordinatesValid {
    // Rotterdam area validation
    return latitude >= 51.80 &&
        latitude <= 52.00 &&
        longitude >= 4.40 &&
        longitude <= 4.60;
  }

  bool get isDescriptionValid =>
      description == null || description!.length <= 500;

  List<String> get validationErrors {
    List<String> errors = [];

    if (!isNameValid) {
      errors.add('Name must be between 1 and 100 characters');
    }

    if (!areCoordinatesValid) {
      errors.add('Coordinates must be within Rotterdam area');
    }

    if (!isDescriptionValid) {
      errors.add('Description must be 500 characters or less');
    }

    if (locationDetail != null && !locationDetail!.isValid) {
      errors.addAll(locationDetail!.validationErrors);
    }

    return errors;
  }
}

extension UpdateLocationDetailDtoValidation on UpdateLocationDetailDto {
  bool get isValid {
    return isAddressValid &&
        isCityValid &&
        isCountryValid &&
        isZipCodeValid &&
        isPhoneNumberValid &&
        isWebsiteValid &&
        isCategoryValid &&
        isAccessibilityValid;
  }

  bool get isAddressValid => address == null || address!.length <= 200;
  bool get isCityValid => city == null || city!.length <= 100;
  bool get isCountryValid => country == null || country!.length <= 100;
  bool get isZipCodeValid => zipCode == null || zipCode!.length <= 20;
  bool get isPhoneNumberValid {
    if (phoneNumber == null) return true;
    // Dutch phone number format
    final phoneRegex = RegExp(r'^(\+31|0031|0)[1-9][0-9]{8}$');
    return phoneRegex.hasMatch(phoneNumber!.replaceAll(RegExp(r'[\s\-]'), ''));
  }

  bool get isWebsiteValid {
    if (website == null) return true;
    final urlRegex = RegExp(r'^https?:\/\/.+\..+');
    return urlRegex.hasMatch(website!);
  }

  bool get isCategoryValid => category == null || category!.length <= 50;
  bool get isAccessibilityValid =>
      accessibility == null || accessibility!.length <= 200;

  List<String> get validationErrors {
    List<String> errors = [];

    if (!isAddressValid) errors.add('Address must be 200 characters or less');
    if (!isCityValid) errors.add('City must be 100 characters or less');
    if (!isCountryValid) errors.add('Country must be 100 characters or less');
    if (!isZipCodeValid) errors.add('Zip code must be 20 characters or less');
    if (!isPhoneNumberValid)
      errors.add('Phone number must be a valid Dutch number');
    if (!isWebsiteValid)
      errors.add(
        'Website must be a valid URL starting with http:// or https://',
      );
    if (!isCategoryValid) errors.add('Category must be 50 characters or less');
    if (!isAccessibilityValid)
      errors.add('Accessibility must be 200 characters or less');

    return errors;
  }
}
