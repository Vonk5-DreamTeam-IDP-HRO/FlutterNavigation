/// **CesiumMapViewModel**
///
/// Core ViewModel for managing Cesium-based 3D map interactions and state.
///
/// **Purpose:**
/// Provides a bridge between the Flutter UI and Cesium.js WebView implementation,
/// managing map state, route display, and camera controls.
///
/// **Key Features:**
/// - WebView initialization and management
/// - Route loading and display
/// - Camera position control
/// - Error handling and loading states
/// - Automatic token management
///
/// **Usage:**
/// ```dart
/// final viewModel = CesiumMapViewModel(routeApiService);
/// await viewModel.moveCameraTo(51.92, 4.48, 14.0);
/// await viewModel.loadAndDisplayRoute('route123');
/// ```
///
/// **Dependencies:**
/// - `webview_flutter`: For Cesium WebView management
/// - `RouteApiService`: For route data fetching
/// - `ValhallaService`: For route calculations
/// - `AppConfig`: For Cesium token management
///
library cesium_map_viewmodel;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/config/app_config.dart';
import '../../core/services/route/route_api_service.dart';
import './services/valhalla_service.dart';

/// ViewModel that manages the Cesium 3D map state and interactions.
///
/// Handles initialization of the WebView, map state management, route loading,
/// and provides methods for map manipulation.
class CesiumMapViewModel extends ChangeNotifier {
  // --- Dependencies ---
  final ValhallaService _valhallaService = ValhallaService();
  final RouteApiService _routeApiService;
  late final WebViewController _webViewController;
  WebViewController get webViewController => _webViewController;

  // --- State ---
  bool _isCesiumLoaded = false;
  bool get isCesiumLoaded => _isCesiumLoaded;

  bool _isCesiumReady = false;
  bool get isCesiumReady => _isCesiumReady;

  bool _isLoadingRoute = false;
  bool get isLoadingRoute => _isLoadingRoute;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<LatLng>? _routeLocations;

  final LatLng _defaultCenter = const LatLng(
    51.92,
    4.48,
  ); // Rotterdam coordinates

  // --- Initialization ---
  CesiumMapViewModel(this._routeApiService) {
    debugPrint(
      'Checking token before replacement: ${AppConfig.cesiumIonToken.length} characters',
    );

    _initialize();
  }

  /// Initializes the WebView controller and loads the Cesium map.
  ///
  /// Sets up:
  /// - JavaScript configuration
  /// - Navigation delegates
  /// - Error handling
  /// - HTML content loading
  /// - Token injection
  Future<void> _initialize() async {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color.fromARGB(0, 0, 0, 0))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                _isCesiumLoaded = true;
                notifyListeners();
                _checkCesiumReady();
              },
              onWebResourceError: (error) {
                _errorMessage = 'WebView error: ${error.description}';
                if (kDebugMode) {
                  print(_errorMessage);
                }
                notifyListeners();
              },
            ),
          );

    try {
      final htmlContent = await _loadHtmlContent();
      if (htmlContent != null && htmlContent.isNotEmpty) {
        debugPrint('HTML asset loaded successfully.');
        if (AppConfig.cesiumIonToken.isEmpty) {
          throw Exception('Cesium Ion Token is empty');
        }
        debugPrint('Cesium token length: ${AppConfig.cesiumIonToken.length}');
        if (!htmlContent.contains('__CESIUM_TOKEN_PLACEHOLDER__')) {
          throw Exception('Token placeholder not found in HTML content');
        }
        debugPrint('Token placeholder found in HTML content');
        final finalHtmlContent = htmlContent.replaceAll(
          '__CESIUM_TOKEN_PLACEHOLDER__',
          AppConfig.cesiumIonToken,
        );
        debugPrint(
          'Token replacement complete. Content length: ${finalHtmlContent.length}',
        );
        if (finalHtmlContent.contains('__CESIUM_TOKEN_PLACEHOLDER__')) {
          throw Exception('Token was not properly replaced');
        }
        debugPrint('Loading HTML into WebView...');
        await _webViewController.loadHtmlString(finalHtmlContent);
      } else {
        throw Exception('HTML content is null or empty');
      }
    } catch (e) {
      _errorMessage = 'Error loading HTML content: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
      // Load a fallback HTML content in case of error
      await _webViewController.loadHtmlString('''
        <!DOCTYPE html>
        <html>
          <body>
            <div style="display: flex; justify-content: center; align-items: center; height: 100vh;">
              <p>Failed to load map. Please try refreshing.</p>
            </div>
          </body>
        </html>
      ''');
      notifyListeners();
    }
  }

  /// Loads the Cesium HTML template from assets.
  ///
  /// Returns:
  /// - String containing the HTML content
  /// - null if loading fails
  ///
  /// Throws:
  /// - Exception if the asset is empty or invalid
  Future<String?> _loadHtmlContent() async {
    try {
      debugPrint('Loading HTML asset from: assets/Cesium.html');
      final content = await rootBundle.loadString('assets/Cesium.html');
      if (content.isEmpty) {
        throw Exception('The asset exists but has empty data');
      }
      return content;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading HTML asset: $e');
        print('The asset does not exist or has empty data.');
      }
      return null;
    }
  }

  // --- Cesium Interaction ---

  Timer? _readinessCheckTimer;

  /// Checks if the Cesium map is initialized and ready for interaction.
  ///
  /// Performs periodic checks until the map is ready, then:
  /// 1. Updates ready state
  /// 2. Cancels further checks
  /// 3. Moves camera to default position
  ///
  /// Uses JavaScript bridge to verify Cesium initialization.
  Future<void> _checkCesiumReady() async {
    if (!_isCesiumLoaded || _isCesiumReady) {
      _readinessCheckTimer
          ?.cancel(); // Stop timer if already ready or not loaded
      return;
    }

    try {
      final result = await _webViewController.runJavaScriptReturningResult(
        'window.isCesiumReady && typeof window.isCesiumReady === "function" ? window.isCesiumReady() : false',
      );

      // Check result type and value robustly
      final isReady =
          (result is bool && result == true) ||
          (result is String &&
              (result.toLowerCase() == 'true' || result.contains('ready')));

      if (isReady) {
        _isCesiumReady = true;
        _readinessCheckTimer?.cancel(); // Stop timer
        notifyListeners();
        // Once ready, move camera to default position
        moveCameraTo(_defaultCenter.latitude, _defaultCenter.longitude, 14.0);
      } else {
        // Schedule next check if not ready
        _scheduleNextReadinessCheck();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Cesium ready state: $e');
      }
      // Schedule next check even on error, maybe it's temporary
      _scheduleNextReadinessCheck();
    }
  }

  void _scheduleNextReadinessCheck() {
    _readinessCheckTimer?.cancel();
    _readinessCheckTimer = Timer(const Duration(seconds: 1), _checkCesiumReady);
  }

  /// Moves the Cesium camera to specified coordinates and zoom level.
  ///
  /// Parameters:
  /// - [lat]: Latitude in degrees
  /// - [lng]: Longitude in degrees
  /// - [zoom]: Zoom level (higher values = closer to ground)
  ///
  /// Only works when Cesium is ready. Silently fails if map isn't ready.
  Future<void> moveCameraTo(double lat, double lng, double zoom) async {
    if (!_isCesiumReady) return;
    try {
      await _webViewController.runJavaScript(
        'if (window.updateCesiumCamera) { window.updateCesiumCamera($lat, $lng, $zoom); }',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error moving Cesium camera: $e');
      }
      // Optionally set an error state
      // _errorMessage = 'Failed to move camera: $e';
      // notifyListeners();
    }
  }

  /// Retrieves the current camera position from Cesium.
  ///
  /// Returns:
  /// Map containing camera position data:
  /// - latitude: Current latitude
  /// - longitude: Current longitude
  /// - height: Camera height above ground
  ///
  /// Returns null if:
  /// - Map isn't ready
  /// - JavaScript execution fails
  /// - Position data is invalid
  Future<Map<String, dynamic>?> getCesiumCameraPosition() async {
    if (!_isCesiumReady) return null;
    try {
      final result = await _webViewController.runJavaScriptReturningResult(
        'JSON.stringify(window.getCesiumCameraPosition ? window.getCesiumCameraPosition() : null)',
      );

      if (result == 'null') return null;

      // More robust JSON parsing
      final dynamic decodedResult = jsonDecode(result.toString());
      if (decodedResult is Map<String, dynamic>) {
        return decodedResult;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting camera position: $e');
      }
      return null;
    }
  }

  /// Fetches location data for a specific route from the API.
  ///
  /// Parameters:
  /// - [routeId]: The ID of the route to load
  ///
  /// Updates:
  /// - [_routeLocations] with the fetched coordinates
  /// - [_errorMessage] if the fetch fails
  ///
  /// Throws:
  /// - Exception if the API request fails or returns empty data
  Future<void> _loadRouteLocations(String routeId) async {
    try {
      final result = await _routeApiService.getRouteLocations(routeId);
      if (result.isSuccess && result.data != null) {
        _routeLocations =
            result.data!
                .map(
                  (location) => LatLng(location.latitude, location.longitude),
                )
                .toList();
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      _errorMessage = 'Failed to load route locations: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
      _routeLocations = null;
    }
  }

  /// Loads and displays a route on the Cesium map.
  ///
  /// Workflow:
  /// 1. Fetches route locations from API
  /// 2. Calculates optimized route using Valhalla
  /// 3. Displays route on the Cesium map
  ///
  /// Parameters:
  /// - [routeId]: The ID of the route to display
  ///
  /// Updates UI state through [_isLoadingRoute] and [_errorMessage].
  /// Notifies listeners of state changes.
  Future<void> loadAndDisplayRoute(String routeId) async {
    if (!_isCesiumReady || _isLoadingRoute) return;

    _isLoadingRoute = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadRouteLocations(routeId);

      if (_routeLocations == null || _routeLocations!.isEmpty) {
        throw Exception('No route locations available');
      }

      final routeResult = await _valhallaService.getOptimizedRoute(
        _routeLocations!,
      );
      final decodedPolyline = routeResult['decodedPolyline'] as List<LatLng>;

      if (decodedPolyline.isEmpty) {
        _errorMessage = 'Route found, but no shape data available.';
        if (kDebugMode) print(_errorMessage);
      } else {
        final polylineJson = jsonEncode(
          decodedPolyline
              .map((p) => {'lat': p.latitude, 'lng': p.longitude})
              .toList(),
        );

        await _webViewController.runJavaScript(
          'if (window.displayValhallaRoute) { window.displayValhallaRoute(\'$polylineJson\'); }',
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load route: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  // --- Public Actions for View ---
  /// Reloads the Cesium WebView and resets all state.
  ///
  /// Use this method to recover from errors or reinitialize the map.
  /// Resets:
  /// - Loading states
  /// - Error messages
  /// - Route display
  /// - WebView content
  void reloadWebView() {
    _isCesiumLoaded = false;
    _isCesiumReady = false;
    _errorMessage = null;
    _isLoadingRoute = false;
    notifyListeners();
    _webViewController.reload();
  }

  /// Moves the camera to the default Rotterdam city center position.
  ///
  /// Uses predefined [_defaultCenter] coordinates and a zoom level of 14.0.
  /// This is typically used for resetting the view or initial positioning.
  void moveCameraToHome() {
    moveCameraTo(_defaultCenter.latitude, _defaultCenter.longitude, 14.0);
  }

  // --- Cleanup ---
  /// Cleans up resources when the ViewModel is disposed.
  ///
  /// Ensures proper cleanup of:
  /// - Timer resources
  /// - WebView resources
  /// - State notifications
  @override
  void dispose() {
    _readinessCheckTimer?.cancel(); // Ensure timer is cancelled
    super.dispose();
  }
}
