import 'package:osm_navigation/Core/models/location.dart';
import 'package:osm_navigation/Core/models/location_details.dart';
import 'package:osm_navigation/Core/models/location_dto.dart';
import 'package:osm_navigation/Core/models/selectable_location.dart';
import 'package:osm_navigation/Core/models/location_request_dtos.dart';
import 'package:osm_navigation/Core/services/location/ILocationApiService.dart';
import 'package:osm_navigation/Core/mappers/location_mapper.dart';
import './i_location_repository.dart';

/// Implementation of the Location Repository
///
/// This repository implements the Repository pattern to provide a clean separation
/// between data source (API service) and domain logic. It converts DTOs from the
/// API service to domain models for use in the application.
///
/// The repository uses the LocationMapper to convert between DTOs and domain models,
/// ensuring that the application works with consistent domain models regardless of
/// how the data is represented in external systems.
class LocationRepository implements ILocationRepository {
  final ILocationApiService _locationApiService;

  LocationRepository(this._locationApiService);
  @override
  Future<List<Location>> getAllLocations() async {
    // Get locations from API service and convert them to domain models
    final locationDtos = await _locationApiService.getAllLocations();
    // Convert to proper domain models using LocationMapper
    // Since our API service is currently returning Location objects directly,
    // we first need to convert them to DTOs and then back to domain models
    // This ensures proper separation of concerns even though it's currently redundant
    final dtos =
        locationDtos
            .map(
              (loc) => LocationDto(
                locationId: loc.locationId,
                userId: loc.userId,
                name: loc.name,
                latitude: loc.latitude,
                longitude: loc.longitude,
                description: loc.description,
                category: loc.category,
                createdAt: loc.createdAt,
                updatedAt: loc.updatedAt,
              ),
            )
            .toList();
    return LocationMapper.toDomainList(dtos);
  }

  @override
  Future<LocationDetails> getLocationById(String id) async {
    // Get location by ID and convert to domain model
    final locationDetails = await _locationApiService.getLocationById(id);
    return locationDetails;
  }

  @override
  Future<List<Location>> getLocationsByCategory(String category) async {
    // Get locations by category from API service
    final locations = await _locationApiService.getLocationsByType(category);
    // Convert to proper domain models using LocationMapper
    final dtos =
        locations
            .map(
              (loc) => LocationDto(
                locationId: loc.locationId,
                userId: loc.userId,
                name: loc.name,
                latitude: loc.latitude,
                longitude: loc.longitude,
                description: loc.description,
                category: loc.category,
                createdAt: loc.createdAt,
                updatedAt: loc.updatedAt,
              ),
            )
            .toList();
    return LocationMapper.toDomainList(dtos);
  }

  @override
  Future<LocationDetails> createLocation(CreateLocationPayload payload) async {
    final locationDetails = await _locationApiService.createLocation(payload);
    return locationDetails;
  }

  @override
  Future<LocationDetails> updateLocation(
    String id,
    UpdateLocationPayload payload,
  ) async {
    // Update an existing location
    final locationDetails = await _locationApiService.updateLocation(
      id,
      payload,
    );
    return locationDetails;
  }

  @override
  Future<void> deleteLocation(String id) async {
    // Delete a location - no mapping needed for void return type
    await _locationApiService.deleteLocation(id);
  }

  @override
  Future<Map<String, List<SelectableLocation>>>
  getGroupedSelectableLocations() async {
    // Get grouped selectable locations
    final groupedLocations =
        await _locationApiService.getGroupedSelectableLocations();
    return groupedLocations;
  }

  @override
  Future<List<String>> getUniqueCategories() async {
    final categories = await _locationApiService.getUniqueCategories();
    return categories;
  }
}
