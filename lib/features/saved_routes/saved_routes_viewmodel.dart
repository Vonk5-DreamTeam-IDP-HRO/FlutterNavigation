library saved_routes_viewmodel;

import 'package:flutter/material.dart';
import 'package:osm_navigation/core/repositories/Route/IRouteRepository.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';

/// **SavedRoutesViewModel**
///
/// Manages the state and business logic for the saved routes feature, following
/// the MVVM pattern for clean separation of concerns.
///
/// **Purpose:**
/// Handles data fetching, state management, and user interactions for the saved
/// routes list screen.
///
/// **Key Features:**
/// - Automatic initial route loading
/// - Route list management
/// - Loading state tracking
/// - Error handling
/// - Immutable route list access
///
/// **State Management:**
/// - [_routes]: List of saved routes
/// - [_isLoading]: Loading state indicator
/// - [_errorMessage]: Error state tracking
///
/// **Usage:**
/// ```dart
/// final viewModel = SavedRoutesViewModel(routeRepository: repository);
/// await viewModel.fetchRoutes();  // Manual refresh
/// final routes = viewModel.routes; // Access routes
/// ```
///
/// **Dependencies:**
/// - [IRouteRepository]: For data access
/// - [RouteDto]: For route data structure
///

class SavedRoutesViewModel extends ChangeNotifier {
  // --- Dependencies ---
  /// Repository for accessing route data
  final IRouteRepository _routeRepository;

  // --- State ---
  /// Internal list of routes, exposed as unmodifiable through getter
  List<RouteDto> _routes = [];
  List<RouteDto> get routes => List.unmodifiable(_routes);
  bool _isLoading = true; // Start loading initially
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Initialization ---
  // Constructor requires the IRouteRepository
  // Fetch routes when the ViewModel is created
  SavedRoutesViewModel({required IRouteRepository routeRepository})
    : _routeRepository = routeRepository {
    fetchRoutes();
  }

  // --- Actions ---

  /// Fetches the list of saved routes from the repository.
  ///
  /// Updates loading state during fetch:
  /// 1. Sets [_isLoading] to true
  /// 2. Clears any existing [_errorMessage]
  /// 3. Attempts to fetch routes
  /// 4. Updates state and notifies listeners
  Future<void> fetchRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch routes from the repository
      _routes = await _routeRepository.getAllRoutes();
    } catch (e) {
      _errorMessage = 'Failed to load routes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiates the editing process for a specific route.
  ///
  /// Currently a placeholder that logs the action.
  /// TODO: Implement full editing functionality
  void editRoute(String routeId) {
    debugPrint('Edit route requested: $routeId');
    // TODO: Implement navigation to an edit screen or show editing UI
  }

  /// Initiates the route viewing process.
  ///
  /// Placeholder for map visualization functionality.
  /// TODO: Integrate with MapViewModel for route display
  void viewRoute(String routeId) {
    debugPrint('View route requested: $routeId');
    // TODO: Implement logic to load the selected route onto the map.
  }
}
