import 'package:flutter/foundation.dart';
import 'dart:convert'; // Added for JSON encoding
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart'; // Removed unused import
import 'package:webview_flutter/webview_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'services/valhalla_service.dart'; // Import ValhallaService - Corrected path

class CesiumMapScreen extends StatefulWidget {
  const CesiumMapScreen({super.key});

  @override
  State<CesiumMapScreen> createState() => _CesiumMapScreenState();
}

Future<String> loadHtmlContent() async {
  try {
    final String htmlContentCesium = await rootBundle.loadString(
      'assets/Cesium.html',
    );
    return htmlContentCesium;
  } catch (e) {
    if (kDebugMode) {
      print('Error loading HTML content: $e');
    }
    rethrow;
  }
}

class _CesiumMapScreenState extends State<CesiumMapScreen> {
  final LatLng _center = const LatLng(51.92, 4.48); // Rotterdam coordinates
  bool _cesiumLoaded = false;
  bool _cesiumReady = false;
  bool _isLoadingRoute = false; // Added to track route loading state

  late final WebViewController _controller;
  final ValhallaService _valhallaService =
      ValhallaService(); // Instantiate ValhallaService

  // Waypoint data to use when route is requested
  final List<LatLng> _waypointsData = [
    const LatLng(51.9201, 4.4869), // Markthal
    const LatLng(51.9249, 4.4692), // Centraal Station
    const LatLng(51.9206, 4.4733), // Schouwburgplein
    const LatLng(51.9135, 4.4879), // Boompjeskade
    const LatLng(51.9093, 4.4884), // Erasmusbrug
    const LatLng(51.9144, 4.4735), // Museum Boijmans
  ];

  @override
  void initState() {
    super.initState();

    _initWebView();

    // Set up periodic check for Cesium readiness
    Future.delayed(const Duration(seconds: 2), _checkCesiumReady);
  }

  void _initWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color.fromARGB(0, 0, 0, 0))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                setState(() => _cesiumLoaded = true);
                _checkCesiumReady();
              },
              onWebResourceError: (error) {
                if (kDebugMode) {
                  print('WebView error: ${error.description}');
                }
              },
            ),
          );

    loadHtmlContent()
        .then((htmlContent) {
          _controller.loadHtmlString(htmlContent);
        })
        .catchError((error) {
          if (kDebugMode) {
            print('Error loading HTML content: $error');
          }
        });
  }

  // Check if Cesium is fully initialized and ready
  // This is for preventing that Cesium is not ready when the user clicks on the button
  // to move the camera to the center of Rotterdam
  Future<void> _checkCesiumReady() async {
    if (!_cesiumLoaded) return;

    try {
      final result = await _controller.runJavaScriptReturningResult(
        'window.isCesiumReady ? "ready" : "not-ready"',
      );

      final isReady = result.toString().contains('ready');
      if (isReady && !_cesiumReady) {
        setState(() => _cesiumReady = true);

        // Once ready, synchronize the map positions
        _moveCesiumCamera(_center.latitude, _center.longitude, 14.0);
      } else if (!isReady) {
        // Check again in a moment
        Future.delayed(const Duration(seconds: 1), _checkCesiumReady);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Cesium ready state: $e');
      }
      Future.delayed(const Duration(seconds: 2), _checkCesiumReady);
    }
  }

  // Method to move the Cesium camera
  Future<void> _moveCesiumCamera(double lat, double lng, double zoom) async {
    try {
      await _controller.runJavaScript(
        'if (window.updateCesiumCamera) { updateCesiumCamera($lat, $lng, $zoom); }',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error moving Cesium camera: $e');
      }
    }
  }

  // Method to get current Cesium camera position
  // This is used to synchronize the map and Cesium views
  // This is possibly needed in the future.
  Future<Map<String, dynamic>?> _getCesiumCameraPosition() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        'JSON.stringify(window.getCesiumCameraPosition ? getCesiumCameraPosition() : null)',
      );

      if (result == 'null') return null;

      // Parse the JSON string and convert to Map
      final String jsonString = result.toString().replaceAll('"', '');
      final Map<String, dynamic> cameraData = {};

      // Extract properties from JSON string (basic parsing)
      final regex = RegExp(r'(\w+):([^,}]+)');
      final matches = regex.allMatches(jsonString);

      for (final match in matches) {
        final key = match.group(1);
        final value = match.group(2);
        if (key != null && value != null) {
          cameraData[key] = double.tryParse(value) ?? value;
        }
      }

      return cameraData;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting camera position: $e');
      }
      return null;
    }
  }

  // Removed unused _syncMapAndCesium method

  // Function to load and display the Valhalla route
  Future<void> _loadAndDisplayValhallaRoute() async {
    if (!_cesiumReady || _isLoadingRoute) return; // Prevent multiple calls

    setState(() => _isLoadingRoute = true); // Show loading indicator

    try {
      final routeResult = await _valhallaService.getOptimizedRoute(
        _waypointsData,
      );
      final decodedPolyline = routeResult['decodedPolyline'] as List<LatLng>;

      // Convert LatLng list to JSON string suitable for JavaScript
      final polylineJson = jsonEncode(
        decodedPolyline
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
      );

      // Call the JavaScript function in Cesium to display the route
      await _controller.runJavaScript(
        'if (window.displayValhallaRoute) { window.displayValhallaRoute(\'$polylineJson\'); }',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading or displaying Valhalla route: $e');
      }
      // Optionally show an error message to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load route: $e')));
    } finally {
      setState(() => _isLoadingRoute = false); // Hide loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotterdam 3D Viewer'),
        // Removed unused sync button from actions
      ),
      body: Stack(
        children: [
          // 3D Cesium layer with transparent background
          // This is a WebView that loads the Cesium HTML content
          // and displays the 3D map and with all the selected layers.
          WebViewWidget(controller: _controller),

          // Loading indicator
          if (!_cesiumReady)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading 3D map...'),
                ],
              ),
            ),

          // Navigation controls
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'home',
                  onPressed: () {
                    // Only move Cesium camera now
                    // _mapController.move(_center, 14.0); // Removed
                    _moveCesiumCamera(
                      _center.latitude,
                      _center.longitude,
                      14.0,
                    );
                  },
                  child: const Icon(Icons.home),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'refresh',
                  onPressed: () {
                    _controller.reload();
                    setState(() {
                      _cesiumLoaded = false;
                      _cesiumReady = false;
                    });
                  },
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 8), // Add space
                FloatingActionButton(
                  heroTag: 'valhalla_route',
                  onPressed: _loadAndDisplayValhallaRoute,
                  tooltip: 'Load Valhalla Route',
                  child:
                      _isLoadingRoute
                          ? const SizedBox(
                            // Show progress indicator when loading
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(
                            Icons.route,
                          ), // Show route icon otherwise
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
