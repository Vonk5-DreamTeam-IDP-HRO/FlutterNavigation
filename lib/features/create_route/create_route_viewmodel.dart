import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// CreateRouteViewModel: ViewModel for the CreateRouteScreen.
///
/// Will handle the state and logic for creating a new route (e.g., map interactions,
/// waypoint management, saving the route).
class CreateRouteViewModel extends ChangeNotifier {
  // --- State ---

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Initialization ---
  CreateRouteViewModel() {
    // Initial setup
  }
  // --- Actions ---
}
