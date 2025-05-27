import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_detail_dto.freezed.dart';
part 'location_detail_dto.g.dart';

/// Data Transfer Object for Location Detail API responses
///
/// This matches the C# LocationDetailDto from your ASP.NET Core API exactly
@freezed
abstract class LocationDetailDto with _$LocationDetailDto {
  const factory LocationDetailDto({
    /// Unique identifier for the location details (maps to C# Guid LocationDetailsId)
    required String locationDetailsId,

    /// Street address (maps to C# string? Address)
    String? address,

    /// City name (maps to C# string? City)
    String? city,

    /// Country name (maps to C# string? Country)
    String? country,

    /// Postal/ZIP code (maps to C# string? ZipCode)
    String? zipCode,

    /// Phone number (maps to C# string? PhoneNumber)
    String? phoneNumber,

    /// Website URL (maps to C# string? Website)
    String? website,

    /// Category/type of location (maps to C# string? Category)
    String? category,

    /// Accessibility information (maps to C# string? Accessibility)
    String? accessibility,
  }) = _LocationDetailDto;

  /// Creates LocationDetailDto from JSON response
  ///
  /// This handles the API response from your ASP.NET Core backend
  factory LocationDetailDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDetailDtoFromJson(json);
}
