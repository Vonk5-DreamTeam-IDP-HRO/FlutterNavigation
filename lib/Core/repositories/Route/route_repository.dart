import 'package:flutter/foundation.dart';
import 'package:osm_navigation/core/services/route/IRouteApiService.dart';
import 'package:osm_navigation/core/models/Route/SelectableNavigationRoute.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/models/Location/location_dto.dart';
import 'package:osm_navigation/core/models/status_code_response_dto.dart';
import 'package:osm_navigation/core/repositories/repository_exception.dart';
import 'IRouteRepository.dart';

/// Implementation of [IRouteRepository] for route data operations.
///
/// This class serves as an abstraction layer between the domain/application layer
/// and the data source (represented by [IRouteApiService]). It is responsible for:
/// - Invoking methods on [IRouteApiService].
/// - Interpreting the [StatusCodeResponseDto] returned by the service.
/// - Extracting the actual data ([T]) from the DTO upon successful API calls.
/// - Throwing specific [RepositoryException]s (e.g., [DataNotFoundRepositoryException])
///   or a generic [RepositoryException] based on the API response status and message,
///   allowing the application layer to handle errors in a standardized way.
///
/// This approach adheres to the Repository pattern, promoting separation of concerns
/// and enhancing testability.
class RouteRepository implements IRouteRepository {
  final IRouteApiService _routeApiService;

  RouteRepository(this._routeApiService);

  @override
  Future<List<RouteDto>> getAllRoutes() async {
    const String operationName = 'getAllRoutes';
    debugPrint('[RouteRepository] Starting $operationName');
    try {
      final response = await _routeApiService.getAllRoutes();
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[RouteRepository] $operationName successful, ${response.data!.length} routes fetched.',
        );
        return response.data!;
      } else {
        debugPrint(
          '[RouteRepository] $operationName failed or returned no data. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get all routes: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[RouteRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching all routes: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<RouteDto?> getRouteById(String routeId) async {
    final String operationName = 'getRouteById $routeId';
    debugPrint('[RouteRepository] Starting $operationName');
    try {
      final response = await _routeApiService.getRouteById(routeId);
      if (response.statusCodeResponse == StatusCodeResponse.success) {
        debugPrint(
          '[RouteRepository] $operationName successful. Data: ${response.data != null}',
        );
        return response.data;
      } else if (response.statusCodeResponse == StatusCodeResponse.notFound) {
        debugPrint('[RouteRepository] $operationName: Route not found.');
        return null;
      } else {
        debugPrint(
          '[RouteRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get route by ID $routeId: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[RouteRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching route by ID $routeId: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<RouteDto> addRoute(CreateRouteDto createRouteDto) async {
    const String operationName = 'addRoute';
    debugPrint('[RouteRepository] Starting $operationName');
    try {
      final response = await _routeApiService.addRoute(createRouteDto);
      if ((response.statusCodeResponse == StatusCodeResponse.created ||
              response.statusCodeResponse == StatusCodeResponse.success) &&
          response.data != null) {
        debugPrint(
          '[RouteRepository] $operationName successful. Route Name: ${response.data!.name}',
        );
        return response.data!;
      } else {
        debugPrint(
          '[RouteRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to add route: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[RouteRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error adding route: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<LocationDto>> getRouteLocations(String routeId) async {
    final String operationName = 'getRouteLocations for route $routeId';
    debugPrint('[RouteRepository] Starting $operationName');
    try {
      final response = await _routeApiService.getRouteLocations(routeId);
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[RouteRepository] $operationName successful, ${response.data!.length} locations fetched.',
        );
        return response.data!;
      } else if (response.statusCodeResponse == StatusCodeResponse.notFound) {
        debugPrint(
          '[RouteRepository] $operationName: Route or its locations not found.',
        );
        throw DataNotFoundRepositoryException(
          'Route with ID $routeId or its locations not found.',
        );
      } else {
        debugPrint(
          '[RouteRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get locations for route $routeId: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[RouteRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      if (e is DataNotFoundRepositoryException) rethrow;
      throw RepositoryException(
        'Error fetching locations for route $routeId: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<SelectableNavigationRoute>> getSelectableRoutes() async {
    const String operationName = 'getSelectableRoutes';
    debugPrint('[RouteRepository] Starting $operationName');
    try {
      final response = await _routeApiService.getSelectableRoutes();
      if (response.statusCodeResponse == StatusCodeResponse.success &&
          response.data != null) {
        debugPrint(
          '[RouteRepository] $operationName successful, ${response.data!.length} selectable routes fetched.',
        );
        return response.data!;
      } else {
        debugPrint(
          '[RouteRepository] $operationName failed. Status: ${response.statusCodeResponse.name}, Message: ${response.message}',
        );
        throw RepositoryException(
          'Failed to get selectable routes: ${response.message ?? response.statusCodeResponse.name}',
        );
      }
    } catch (e, s) {
      debugPrint(
        '[RouteRepository] Exception in $operationName: $e\nStacktrace: $s',
      );
      throw RepositoryException(
        'Error fetching selectable routes: ${e.toString()}',
        originalException: e,
        stackTrace: s,
      );
    }
  }
}
