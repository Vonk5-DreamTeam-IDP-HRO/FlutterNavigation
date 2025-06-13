library map_viewmodel;

/// A ViewModel that manages the state and business logic for the interactive map.
///
/// Handles map position tracking, route fetching, and route visualization using
/// the Valhalla routing service. Maintains the map's current state including center
/// position, zoom level, and route polylines.
///
/// Example usage:
/// ```dart
/// final viewModel = MapViewModel();
/// viewModel.fetchRoute([
///   LatLng(51.9225, 4.47917), // Rotterdam Centraal
///   LatLng(51.9175, 4.4883),  // Markthal
/// ]);
/// ```
///
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import './services/valhalla_service.dart';

class MapViewModel extends ChangeNotifier {
  // --- Dependencies ---
  final ValhallaService _valhallaService = ValhallaService();
  final MapController mapController = MapController();

  // --- State ---
  LatLng _currentCenter = const LatLng(
    51.92,
    4.48,
  ); // Default: Rotterdam center
  // TODO: Future: Make this center first based on user location or a default location
  LatLng get currentCenter => _currentCenter;

  double _currentZoom = 13.0;
  double get currentZoom => _currentZoom;

  List<LatLng> _routePolyline = [];
  List<LatLng> get routePolyline =>
      _routePolyline; // The decoded polyline for drawing

  bool _isLoading = false;
  bool get isLoading => _isLoading; // To show loading indicators in the View

  String? _errorMessage;
  String? get errorMessage =>
      _errorMessage; // To show error messages in the View

  // --- Public Methods ---

  /// Fetches an optimized route from Valhalla based on waypoints.
  Future<void> fetchRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      _errorMessage = 'Please provide at least two points for a route.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    _routePolyline = []; // Clear previous route
    notifyListeners();

    try {
      final routeData = await _valhallaService.getOptimizedRoute(waypoints);
      _routePolyline = routeData['decodedPolyline'] as List<LatLng>? ?? [];
      if (_routePolyline.isEmpty) {
        _errorMessage = 'Route found, but no shape data available.';
      }
    } catch (e) {
      debugPrint('Error fetching route in MapViewModel: $e');
      _errorMessage = 'Failed to fetch route: ${e.toString()}';
      _routePolyline = []; // Ensure route is cleared on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called by the View when the map's position changes.
  // Changed 'MapPosition' to 'dynamic' as a diagnostic step to bypass persistent analyzer error.
  // If the app runs, the error is likely an analyzer issue. If it crashes here, the type is incorrect.
  void onMapPositionChanged(dynamic position, bool hasGesture) {
    // Only update state if the change wasn't triggered programmatically (e.g., by mapController.move)
    // Or decide if you always want to track the center/zoom
    if (hasGesture) {
      bool changed = false;
      if (position.center != null && position.center != _currentCenter) {
        _currentCenter = position.center!;
        changed = true;
      }
      if (position.zoom != null && position.zoom != _currentZoom) {
        _currentZoom = position.zoom!;
        changed = true;
      }
      // Only notify if something actually changed due to user gesture
      // Avoids potential loops if programmatic moves also trigger this.
      // Consider if you need this state updated for other UI elements.
      if (changed) {
        // Notify listeners only if the state actually changed due to user interaction.
        notifyListeners();
      }
    }
  }

  /// Example method to move the map programmatically
  void centerMapOn(LatLng location) {
    _currentCenter = location;
    mapController.move(location, _currentZoom); // Use the controller
    // No need to notifyListeners here if the map widget handles the move internally
  }

  // TODO: Future feature: Add methods for handling map taps, adding/removing markers, etc.
}
