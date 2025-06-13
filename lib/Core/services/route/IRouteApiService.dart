import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/Route/SelectableNavigationRoute.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/models/status_code_response_dto.dart';

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
  /// **Returns:** StatusCodeResponseDto containing a list of RouteDto objects
  /// **Security:** Returns only routes visible to authenticated user (public + own private)
  Future<StatusCodeResponseDto<List<RouteDto>>> getAllRoutes();

  /// Fetches location points that make up a specific route
  ///
  /// **API Endpoint:** GET /api/routes/{routeId}/locations
  /// **Parameters:** routeId - UUID of the route to fetch locations for
  /// **Returns:** StatusCodeResponseDto containing an ordered list of LocationDto objects
  /// **Security:** Validates user has access to the route (public or owns private route)
  Future<StatusCodeResponseDto<List<LocationDto>>> getRouteLocations(
    String routeId,
  );

  /// Fetches route data formatted for selection UI components
  ///
  /// **API Endpoint:** GET /api/routes/selectable (or transform from getAllRoutes)
  /// **Purpose:** Provides route data optimized for dropdowns, navigation pickers
  /// **Returns:** StatusCodeResponseDto containing a list of SelectableNavigationRoute objects
  /// **Performance:** Lightweight objects for fast UI rendering in route selection
  /// **Use Cases:** Route selection in navigation, route comparison interfaces
  Future<StatusCodeResponseDto<List<SelectableNavigationRoute>>>
  getSelectableRoutes();

  /// Fetches a specific route by its unique identifier
  ///
  /// **API Endpoint:** GET /api/routes/{routeId}
  /// **Parameters:** routeId - UUID string of the route to retrieve
  /// **Returns:** StatusCodeResponseDto containing a RouteDto object (nullable if not found)
  /// **Security:** Validates user has access to the route
  Future<StatusCodeResponseDto<RouteDto?>> getRouteById(String routeId);

  /// Creates a new route using the provided creation data
  ///
  /// **API Endpoint:** POST /api/routes
  /// **Parameters:** createRouteDto - Validated route creation data
  /// **Returns:** StatusCodeResponseDto containing the created RouteDto (nullable if creation fails)
  /// **Security:** Uses authenticated user as route creator
  Future<StatusCodeResponseDto<RouteDto?>> addRoute(
    CreateRouteDto createRouteDto,
  );

  // Consider adding Delete and Update route methods if they are part of the C# API
  // For example:
  // Future<StatusCodeResponseDto<bool>> deleteRoute(String routeId);
  // Future<StatusCodeResponseDto<RouteDto?>> updateRoute(String routeId, UpdateRouteDto updateRouteDto);
}
