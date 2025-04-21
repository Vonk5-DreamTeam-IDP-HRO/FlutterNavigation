import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/config/app_config.dart';
import '../../core/models/location.dart';
import '../saved_routes/services/route_api_service.dart';
import './services/valhalla_service.dart';

class CesiumMapViewModel extends ChangeNotifier {
  // --- Dependencies ---
  final ValhallaService _valhallaService = ValhallaService();
  final RouteApiService _routeApiService;
  final int _routeId;
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

  // State for specific route locations
  List<Location> _locations = [];
  List<Location> get locations => List.unmodifiable(_locations);
  bool _isLoadingLocations = true;
  bool get isLoadingLocations => _isLoadingLocations;
  String? _locationsErrorMessage;
  String? get locationsErrorMessage => _locationsErrorMessage;

  final LatLng _defaultCenter = const LatLng(
    51.92,
    4.48,
  ); // Rotterdam coordinates

  // --- Initialization ---
  CesiumMapViewModel({
    required int routeId,
    required RouteApiService routeApiService,
  }) : _routeId = routeId,
       _routeApiService = routeApiService {
    _initialize();
    fetchRouteDetails();
  }

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
      final cesiumToken = AppConfig.cesiumIonToken;
      final finalHtmlContent = htmlContent.replaceAll(
        '__CESIUM_TOKEN_PLACEHOLDER__',
        cesiumToken,
      );
      await _webViewController.loadHtmlString(finalHtmlContent);
    } catch (e) {
      _errorMessage = 'Error loading HTML content: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
      notifyListeners();
    }
  }

  Future<String> _loadHtmlContent() async {
    try {
      return await rootBundle.loadString('assets/Cesium.html');
    } catch (e) {
      if (kDebugMode) {
        print('Error loading HTML asset: $e');
      }
      rethrow; // Rethrow to be caught in _initialize
    }
  }

  // --- Cesium Interaction ---

  Timer? _readinessCheckTimer;

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

  Future<Map<String, dynamic>?> getCesiumCameraPosition() async {
    if (!_isCesiumReady) return null;
    try {
      final result = await _webViewController.runJavaScriptReturningResult(
        'JSON.stringify(window.getCesiumCameraPosition ? window.getCesiumCameraPosition() : null)',
      );

      if (result == 'null' || result == null) return null;

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

  /// Fetches the specific locations for the route associated with this ViewModel instance.
  Future<void> fetchRouteDetails() async {
    _isLoadingLocations = true;
    _locationsErrorMessage = null;
    notifyListeners();

    try {
      _locations = await _routeApiService.getRouteLocations(_routeId);
      debugPrint(
        'CesiumMapViewModel: Successfully loaded ${_locations.length} locations for route $_routeId',
      );
    } catch (e) {
      _locationsErrorMessage = 'Failed to load route locations: $e';
      debugPrint(
        'CesiumMapViewModel: Error loading locations for route $_routeId: $e',
      );
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
      // If locations loaded successfully, proceed to calculate and display the path
      if (_locations.isNotEmpty && _locationsErrorMessage == null) {
        _calculateAndDisplayPath(_locations);
      }
    }
  }

  /// Calculates a route using Valhalla based on the provided locations and displays it.
  Future<void> _calculateAndDisplayPath(List<Location> locations) async {
    if (!_isCesiumReady) return; // Don't proceed if Cesium isn't ready

    _isLoadingRoute = true; // Reuse state for loading indicator
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      // Convert Location objects to LatLng for ValhallaService
      final waypoints =
          locations.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();

      if (waypoints.length < 2) {
        throw Exception("At least 2 points are needed to calculate a route.");
      }

      final routeResult = await _valhallaService.getOptimizedRoute(waypoints);
      final decodedPolyline = routeResult['decodedPolyline'] as List<LatLng>;

      if (decodedPolyline.isEmpty) {
        _errorMessage = 'Route path calculated, but no shape data available.';
        debugPrint('CesiumMapViewModel: $_errorMessage');
      } else {
        final polylineJson = jsonEncode(
          decodedPolyline
              .map((p) => {'lat': p.latitude, 'lng': p.longitude})
              .toList(),
        );

        // Pass the polylineJson directly, as it's already a valid JSON string literal
        await _webViewController.runJavaScript(
          'if (window.showRouteOnMap) { window.showRouteOnMap($polylineJson); } else { console.error("showRouteOnMap function not found!"); }',
        );
        debugPrint(
          'CesiumMapViewModel: Called showRouteOnMap with polyline data.',
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to calculate or display route path: $e';
      debugPrint('CesiumMapViewModel: $_errorMessage');
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  // --- Public Actions for View ---
  void reloadWebView() {
    _isCesiumLoaded = false;
    _isCesiumReady = false;
    _errorMessage = null;
    _isLoadingRoute = false;
    notifyListeners();
    _webViewController.reload();
  }

  void moveCameraToHome() {
    moveCameraTo(_defaultCenter.latitude, _defaultCenter.longitude, 14.0);
  }

  // --- Cleanup ---
  @override
  void dispose() {
    _readinessCheckTimer?.cancel(); // Ensure timer is cancelled
    super.dispose();
  }
}
