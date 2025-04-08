import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});
  
  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

Future<String> loadHtmlContent() async {
  try {
    String htmlContentCesium =
        await rootBundle.loadString('lib/services/Cesium.html');
    return htmlContentCesium;
  } catch (e) {
    if (kDebugMode) {
      print("Error loading HTML content: $e");
    }
    rethrow;
  }
}

class _SaveScreenState extends State<SaveScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = LatLng(51.92, 4.48); // Rotterdam coordinates
  bool _cesiumLoaded = false;
  bool _cesiumReady = false;
  
  late final WebViewController _controller;
  
  @override
  void initState() {
    super.initState();
    
    _initWebView();
    
    // Set up periodic check for Cesium readiness
    Future.delayed(const Duration(seconds: 2), _checkCesiumReady);
  }
  
  void _initWebView() {
    _controller = WebViewController()
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
              print("WebView error: ${error.description}");
            }
          },
        ),
      );
      
    loadHtmlContent().then((htmlContent) {
      _controller.loadHtmlString(htmlContent);
    }).catchError((error) {
      if (kDebugMode) {
        print("Error loading HTML content: $error");
      }
    });
  }
  
  // Check if Cesium is fully initialized and ready
  Future<void> _checkCesiumReady() async {
    if (!_cesiumLoaded) return;
    
    try {
      final result = await _controller.runJavaScriptReturningResult(
          'window.isCesiumReady ? "ready" : "not-ready"');
      
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
        print("Error checking Cesium ready state: $e");
      }
      Future.delayed(const Duration(seconds: 2), _checkCesiumReady);
    }
  }
  
  // Method to move the Cesium camera
  Future<void> _moveCesiumCamera(double lat, double lng, double zoom) async {
    try {
      await _controller.runJavaScript(
          'if (window.updateCesiumCamera) { updateCesiumCamera($lat, $lng, $zoom); }');
    } catch (e) {
      if (kDebugMode) {
        print("Error moving Cesium camera: $e");
      }
    }
  }
  
  // Method to get current Cesium camera position
  Future<Map<String, dynamic>?> _getCesiumCameraPosition() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
          'JSON.stringify(window.getCesiumCameraPosition ? getCesiumCameraPosition() : null)');
      
      if (result == "null") return null;
      
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
        print("Error getting camera position: $e");
      }
      return null;
    }
  }
  
  // Synchronize map and Cesium view
  void _syncMapAndCesium() async {
    final cameraPosition = await _getCesiumCameraPosition();
    if (cameraPosition != null) {
      final lat = cameraPosition['lat'] as double;
      final lng = cameraPosition['lng'] as double;
      
      // Update flutter_map position
      _mapController.move(LatLng(lat, lng), _mapController.camera.zoom);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotterdam 3D Viewer'),
        actions: [
          if (_cesiumReady)
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Sync 2D and 3D views',
              onPressed: _syncMapAndCesium,
            ),
        ],
      ),
      body: Stack(
        children: [
          // 3D Cesium layer with transparent background
          WebViewWidget(controller: _controller),
          
          // Loading indicator
          if (!_cesiumReady)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading 3D map...')
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
                  heroTag: "home",
                  onPressed: () {
                    // Move both map controllers to center
                    _mapController.move(_center, 14.0);
                    _moveCesiumCamera(_center.latitude, _center.longitude, 14.0);
                  },
                  child: const Icon(Icons.home),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "refresh",
                  onPressed: () {
                    _controller.reload();
                    setState(() {
                      _cesiumLoaded = false;
                      _cesiumReady = false;
                    });
                  },
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}