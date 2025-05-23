import '../models/location_dto.dart';
import '../models/location.dart';
import '../models/location_detail_dto.dart';

/// Mapper class to convert between Location domain models and DTOs
class LocationMapper {
  /// Convert a LocationDto to a Location domain model
  static Location toDomain(LocationDto dto) {
    return Location(
      locationId: dto.locationId,
      userId: dto.userId,
      name: dto.name,
      latitude: dto.latitude,
      longitude: dto.longitude,
      description: dto.description,
      category: dto.locationDetail?.category,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Convert a Location domain model to a LocationDto
  static LocationDto toDto(Location model) {
    return LocationDto(
      locationId: model.locationId,
      userId: model.userId,
      name: model.name,
      latitude: model.latitude,
      longitude: model.longitude,
      description: model.description,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      locationDetail:
          model.category != null
              ? LocationDetailDto(category: model.category)
              : null, // Create LocationDetailDto for category
    );
  }

  /// Convert a list of LocationDto objects to a list of Location domain models
  static List<Location> toDomainList(List<LocationDto> dtoList) {
    return dtoList.map((dto) => toDomain(dto)).toList();
  }

  /// Convert a list of Location domain models to a list of LocationDto objects
  static List<LocationDto> toDtoList(List<Location> modelList) {
    return modelList.map((model) => toDto(model)).toList();
  }
}
