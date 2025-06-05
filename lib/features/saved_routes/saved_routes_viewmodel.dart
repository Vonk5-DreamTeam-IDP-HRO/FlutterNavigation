import 'package:flutter/material.dart';
import 'package:osm_navigation/core/repositories/Route/IRouteRepository.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';

/// SavedRoutesViewModel: Manages the state and logic for the Saved Routes screen.
class SavedRoutesViewModel extends ChangeNotifier {
  // --- Dependencies ---
  final IRouteRepository _routeRepository;

  // --- State ---
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

  // Method to handle editing a route (placeholder)
  void editRoute(String routeId) {
    debugPrint('Edit route requested: $routeId');
    // TODO: Implement navigation to an edit screen or show editing UI
  }

  // Method to handle viewing a route (placeholder - might involve navigation and passing data)
  // This might interact with AppState or another ViewModel (like MapViewModel)
  void viewRoute(String routeId) {
    debugPrint('View route requested: $routeId');
    // TODO: Implement logic to load the selected route onto the map.
  }
}
