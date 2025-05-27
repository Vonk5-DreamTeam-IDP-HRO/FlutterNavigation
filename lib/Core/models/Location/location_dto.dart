import 'package:freezed_annotation/freezed_annotation.dart';
import 'LocationDetail/location_detail_dto.dart';

part 'location_dto.freezed.dart';
part 'location_dto.g.dart';

/// Data Transfer Object for Location API responses
///
/// This matches the C# LocationDto from your ASP.NET Core API exactly
@freezed
abstract class LocationDto with _$LocationDto {
  const factory LocationDto({
    /// Unique identifier for the location (maps to C# Guid LocationId)
    required String locationId,

    /// Name of the location (maps to C# string Name)
    required String name,

    /// Latitude coordinate (maps to C# double Latitude)
    required double latitude,

    /// Longitude coordinate (maps to C# double Longitude)
    required double longitude,

    /// Optional description (maps to C# string? Description)
    String? description,

    /// Optional location details (maps to C# LocationDetailDto? LocationDetail)
    LocationDetailDto? locationDetail,
  }) = _LocationDto;

  /// Creates LocationDto from JSON response
  ///
  /// This handles the API response from your ASP.NET Core backend
  factory LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);
}
