import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/status_code_response_dto.dart';

/// Interface for the Location API Service
///
/// **Purpose:** Defines the contract for location-related API operations
/// **Architecture:** Clean Architecture - Infrastructure Layer Interface
/// **Responsibilities:**
/// - Define HTTP API contracts for location operations
/// - Specify data transformation requirements (JSON ↔ DTO)
/// - Document API endpoint behaviors and error conditions
/// - Handle location-specific business logic requirements
///
/// **Implementation Notes:**
/// - All methods should handle network failures gracefully
/// - DTOs should be validated before API calls
/// - Authentication is handled at the HTTP client level
/// - Location data includes coordinates, details, and categorization
abstract class ILocationApiService {
  /// Fetches all available locations from the backend
  ///
  /// **API Endpoint:** GET /api/locations
  /// **Returns:** StatusCodeResponseDto containing a list of LocationDto objects
  /// **Security:** Returns locations visible to authenticated user
  /// **Performance:** May include pagination in future implementations
  Future<StatusCodeResponseDto<List<LocationDto>>> getAllLocations();

  /// Fetches a specific location by its unique identifier
  ///
  /// **API Endpoint:** GET /api/locations/{id}
  /// **Parameters:** id - UUID string of the location to retrieve
  /// **Returns:** StatusCodeResponseDto containing a LocationDto object
  /// **Error Handling:** Returns appropriate status code (e.g., NotFound)
  Future<StatusCodeResponseDto<LocationDto?>> getLocationById(String id);

  /// Fetches locations filtered by category/type
  ///
  /// **API Endpoint:** GET /api/locations/category/{category}
  /// **Parameters:** category - Category name to filter by
  /// **Returns:** StatusCodeResponseDto containing a list of LocationDto objects
  /// **Use Cases:** Filter locations by type (restaurants, attractions, etc.)
  Future<StatusCodeResponseDto<List<LocationDto>>> getLocationsByType(
    String category,
  );

  /// Creates a new location using validated input data
  ///
  /// **API Endpoint:** POST /api/locations
  /// **Parameters:** payload - CreateLocationDto with validated location data
  /// **Returns:** StatusCodeResponseDto containing the created LocationDto
  /// **Security:** Validates user permissions for location creation
  Future<StatusCodeResponseDto<LocationDto?>> createLocation(
    CreateLocationDto payload,
  );

  /// Updates an existing location with validated data
  ///
  /// **API Endpoint:** PUT /api/locations/{id}
  /// **Parameters:**
  /// - id - UUID of location to update
  /// - payload - UpdateLocationDto with validated changes
  /// **Returns:** StatusCodeResponseDto containing the updated LocationDto
  /// **Security:** Validates user has permission to modify location
  Future<StatusCodeResponseDto<LocationDto?>> updateLocation(
    String id,
    UpdateLocationDto payload,
  );

  /// Deletes a location by its unique identifier
  ///
  /// **API Endpoint:** DELETE /api/locations/{id}
  /// **Parameters:** id - UUID of location to delete
  /// **Returns:** StatusCodeResponseDto containing a boolean indicating success
  /// **Security:** Validates user has permission to delete location
  Future<StatusCodeResponseDto<bool>> deleteLocation(String id);

  /// Fetches locations grouped by category for selection UI
  ///
  /// **API Endpoint:** GET /api/locations/grouped-selectable
  /// **Purpose:** Provides location data organized by category for UI components
  /// **Returns:** StatusCodeResponseDto containing a map of category names to lists of SelectableLocationDto
  /// **Performance:** Optimized for dropdown/picker UI components
  /// **Use Cases:** Location selection in route creation, categorized location browsers
  Future<StatusCodeResponseDto<Map<String, List<SelectableLocationDto>>>>
  getGroupedSelectableLocations();

  /// Fetches locations formatted for selection UI components
  ///
  /// **API Endpoint:** GET /api/locations/selectable
  /// **Purpose:** Provides location data optimized for dropdowns, pickers, etc.
  /// **Returns:** StatusCodeResponseDto containing a list of SelectableLocationDto objects
  /// **Performance:** Lightweight objects for fast UI rendering
  /// **Use Cases:** Location selection in route creation, waypoint picking
  Future<StatusCodeResponseDto<List<SelectableLocationDto>>>
  getSelectableLocations();

  /// Fetches unique location categories available in the system
  ///
  /// **API Endpoint:** GET /api/locations/categories
  /// **Purpose:** Provides list of all available location categories
  /// **Returns:** StatusCodeResponseDto containing a list of category name strings
  /// **Use Cases:** Category filters, dropdown population, validation
  Future<StatusCodeResponseDto<List<String>>> getUniqueCategories();
}
