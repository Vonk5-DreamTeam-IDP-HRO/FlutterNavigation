import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Core/config/app_config.dart';
import './services/valhalla_service.dart';

class CesiumMapViewModel extends ChangeNotifier {
  // --- Dependencies ---
  final ValhallaService _valhallaService = ValhallaService();
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

  // TODO: Make waypoints dynamic, loaded from elsewhere (e.g., user input, backend)
  final List<LatLng> _waypointsData = [
    const LatLng(51.9201, 4.4869), // Markthal
    const LatLng(51.9249, 4.4692), // Centraal Station
    const LatLng(51.9206, 4.4733), // Schouwburgplein
    const LatLng(51.9135, 4.4879), // Boompjeskade
    const LatLng(51.9093, 4.4884), // Erasmusbrug
    const LatLng(51.9144, 4.4735), // Museum Boijmans
  ];

  final LatLng _defaultCenter = const LatLng(
    51.92,
    4.48,
  ); // Rotterdam coordinates

  // --- Initialization ---
  CesiumMapViewModel() {
    _initialize();
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
      final finalHtmlContent = htmlContent.replaceAll(
        '__CESIUM_TOKEN_PLACEHOLDER__',
        AppConfig.cesiumIonToken,
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

  Future<void> loadAndDisplayRoute() async {
    if (!_isCesiumReady || _isLoadingRoute) return;

    _isLoadingRoute = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final routeResult = await _valhallaService.getOptimizedRoute(
        _waypointsData,
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
