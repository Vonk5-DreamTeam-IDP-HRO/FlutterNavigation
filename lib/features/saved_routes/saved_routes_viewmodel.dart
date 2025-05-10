import 'package:flutter/material.dart';
import 'package:osm_navigation/core/models/route.dart' as app_route;
import 'package:osm_navigation/features/saved_routes/services/route_api_service.dart';

/// SavedRoutesViewModel: Manages the state and logic for the Saved Routes screen.
class SavedRoutesViewModel extends ChangeNotifier {
  // --- Dependencies ---
  final RouteApiService _apiService;

  // --- State ---
  List<app_route.Route> _routes = [];
  List<app_route.Route> get routes => List.unmodifiable(_routes);
  bool _isLoading = true; // Start loading initially
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Initialization ---
  // Constructor requires the ApiService
  // Fetch routes when the ViewModel is created
  SavedRoutesViewModel({required RouteApiService apiService})
    : _apiService = apiService {
    fetchRoutes();
  }

  // --- Actions ---

  Future<void> fetchRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch routes from the backend API service
      _routes = await _apiService.getAllRoutes();
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
