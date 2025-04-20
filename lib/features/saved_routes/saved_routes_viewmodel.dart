import 'package:flutter/material.dart';

// TODO: Define a RouteModel class to represent route data structure
// For now, using a simple Map or a placeholder class
// This class might be moved to a common 'models' directory later
class RouteSummary {
  final String id;
  final String title;
  final String subtitle;

  RouteSummary({required this.id, required this.title, required this.subtitle});
}

/// SavedRoutesViewModel: Manages the state and logic for the Saved Routes screen.
class SavedRoutesViewModel extends ChangeNotifier {
  // --- State ---

  // testDataSet
  final List<RouteSummary> _routes = [
    RouteSummary(
      id: 'route_1',
      title: 'Route_1',
      subtitle: 'Along best places in R"dam',
    ),
  ];
  List<RouteSummary> get routes => List.unmodifiable(_routes);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Initialization ---
  SavedRoutesViewModel() {}

  // --- Actions ---

  Future<void> fetchRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // TODO: Fetch routes from the backend
      // Right now it is using hardcoded data in _routes
      // If fetching fails, set _errorMessage
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
