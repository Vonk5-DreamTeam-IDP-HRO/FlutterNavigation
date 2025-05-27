import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/Route/SelectableNavigationRoute.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';

/// Interface for the Route API Service.
///
/// **Purpose:** Defines the contract for route-related API operations
/// **Architecture:** Clean Architecture - Infrastructure Layer Interface
/// **Responsibilities:**
/// - Define HTTP API contracts for route operations
/// - Specify data transformation requirements (JSON ↔ DTO)
/// - Document API endpoint behaviors and error conditions
///
/// **Implementation Notes:**
/// - All methods should handle network failures gracefully
/// - DTOs should be validated before API calls
/// - Authentication is handled at the HTTP client level
abstract class IRouteApiService {
  /// Fetches all available routes from the backend
  ///
  /// **API Endpoint:** GET /api/routes
  /// **Returns:** List of RouteDto objects representing all accessible routes
  /// **Security:** Returns only routes visible to authenticated user (public + own private)
  /// **Error Handling:** Throws RouteApiException on network/server errors
  Future<List<RouteDto>> getAllRoutes();

  /// Fetches location points that make up a specific route
  ///
  /// **API Endpoint:** GET /api/routes/{routeId}/locations
  /// **Parameters:** routeId - UUID of the route to fetch locations for
  /// **Returns:** Ordered list of LocationDto objects representing route waypoints
  /// **Security:** Validates user has access to the route (public or owns private route)
  Future<List<LocationDto>> getRouteLocations(String routeId);

  /// Fetches route data formatted for selection UI components
  ///
  /// **API Endpoint:** GET /api/routes/selectable (or transform from getAllRoutes)
  /// **Purpose:** Provides route data optimized for dropdowns, navigation pickers
  /// **Returns:** List of SelectableNavigationRoute objects with minimal UI-focused data
  /// **Performance:** Lightweight objects for fast UI rendering in route selection
  /// **Use Cases:** Route selection in navigation, route comparison interfaces
  Future<List<SelectableNavigationRoute>> getSelectableRoutes();

  /// Fetches a specific route by its unique identifier
  ///
  /// **API Endpoint:** GET /api/routes/{routeId}
  /// **Parameters:** routeId - UUID string of the route to retrieve
  /// **Returns:** RouteDto object if found, null if not found or no access
  /// **Security:** Validates user has access to the route
  Future<RouteDto?> getRouteById(String routeId);

  /// Creates a new route using the provided creation data
  ///
  /// **API Endpoint:** POST /api/routes
  /// **Parameters:** createRouteDto - Validated route creation data
  /// **Returns:** Complete RouteDto of the newly created route with generated IDs
  /// **Security:** Uses authenticated user as route creator
  Future<RouteDto> addRoute(CreateRouteDto createRouteDto);
}
