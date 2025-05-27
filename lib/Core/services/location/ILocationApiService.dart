import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/models/Location/UpdateLocation/update_location_dto.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';

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
  /// **Returns:** List of LocationDto objects representing all accessible locations
  /// **Security:** Returns locations visible to authenticated user
  /// **Performance:** May include pagination in future implementations
  Future<List<LocationDto>> getAllLocations();

  /// Fetches a specific location by its unique identifier
  ///
  /// **API Endpoint:** GET /api/locations/{id}
  /// **Parameters:** id - UUID string of the location to retrieve
  /// **Returns:** LocationDto object with full location details
  /// **Error Handling:** Throws LocationNotFoundException if not found
  Future<LocationDto> getLocationById(String id);

  /// Fetches locations filtered by category/type
  ///
  /// **API Endpoint:** GET /api/locations/category/{category}
  /// **Parameters:** category - Category name to filter by
  /// **Returns:** List of LocationDto objects matching the category
  /// **Use Cases:** Filter locations by type (restaurants, attractions, etc.)
  Future<List<LocationDto>> getLocationsByType(String category);

  /// Creates a new location using validated input data
  ///
  /// **API Endpoint:** POST /api/locations
  /// **Parameters:** payload - CreateLocationDto with validated location data
  /// **Returns:** Complete LocationDto of the newly created location
  /// **Security:** Validates user permissions for location creation
  Future<LocationDto> createLocation(CreateLocationDto payload);

  /// Updates an existing location with validated data
  ///
  /// **API Endpoint:** PUT /api/locations/{id}
  /// **Parameters:**
  /// - id - UUID of location to update
  /// - payload - UpdateLocationDto with validated changes
  /// **Returns:** Updated LocationDto object
  /// **Security:** Validates user has permission to modify location
  Future<LocationDto> updateLocation(String id, UpdateLocationDto payload);

  /// Deletes a location by its unique identifier
  ///
  /// **API Endpoint:** DELETE /api/locations/{id}
  /// **Parameters:** id - UUID of location to delete
  /// **Returns:** void (no content on success)
  /// **Security:** Validates user has permission to delete location
  Future<void> deleteLocation(String id);

  /// Fetches locations grouped by category for selection UI
  ///
  /// **API Endpoint:** GET /api/locations/grouped-selectable
  /// **Purpose:** Provides location data organized by category for UI components
  /// **Returns:** Map where keys are category names, values are lists of SelectableLocationDto
  /// **Performance:** Optimized for dropdown/picker UI components
  /// **Use Cases:** Location selection in route creation, categorized location browsers
  Future<Map<String, List<SelectableLocationDto>>>
  getGroupedSelectableLocations();

  /// Fetches locations formatted for selection UI components
  ///
  /// **API Endpoint:** GET /api/locations/selectable
  /// **Purpose:** Provides location data optimized for dropdowns, pickers, etc.
  /// **Returns:** List of SelectableLocationDto objects with minimal UI-focused data
  /// **Performance:** Lightweight objects for fast UI rendering
  /// **Use Cases:** Location selection in route creation, waypoint picking
  Future<List<SelectableLocationDto>> getSelectableLocations();

  /// Fetches unique location categories available in the system
  ///
  /// **API Endpoint:** GET /api/locations/categories
  /// **Purpose:** Provides list of all available location categories
  /// **Returns:** List of category name strings
  /// **Use Cases:** Category filters, dropdown population, validation
  Future<List<String>> getUniqueCategories();
}
