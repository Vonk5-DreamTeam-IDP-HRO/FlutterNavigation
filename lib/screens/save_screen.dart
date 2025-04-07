import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;

class CesiumViewer extends StatefulWidget {
  const CesiumViewer({super.key});

  @override
  State<CesiumViewer> createState() => _CesiumViewerState();
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

class _CesiumViewerState extends State<CesiumViewer> {
  final MapController _mapController = MapController();
  final LatLng _center = LatLng(51.92, 4.48); // Rotterdam coordinates
  bool _cesiumLoaded = false;

  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color.fromARGB(0, 0, 0, 0))
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _cesiumLoaded = true);
        },
        onWebResourceError: (error) {
          print("WebView error: ${error.description}");
        },
      ),
    );

  @override
  void initState() {
    super.initState();
    loadHtmlContent().then((htmlContent) {
      _controller.loadHtmlString(htmlContent);
    }).catchError((error) {
      print("Error loading HTML content: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OSM with 3D buildings through cesium'),
      ),
      body: Stack(
        children: [
          // 2D Map layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14.0,
              onMapEvent: (event) {
                if (event.source == MapEventSource.mapController) {
                  final center = _mapController.camera.center;
                  final zoom = _mapController.camera.zoom;

                  if (_cesiumLoaded) {
                    _controller.runJavaScript(
                        'if (window.updateCesiumCamera) updateCesiumCamera(${center.latitude}, ${center.longitude}, $zoom)');
                  }
                }
              },
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.osm_navigation',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: NetworkTileProvider(),
                maxZoom: 19,
                maxNativeZoom: 18,
                keepBuffer: 2,
                tileDimension: 256, // Use tileSize instead of tileDimension
              ),
            ],
          ),

          // 3D Cesium layer with transparent background
          WebViewWidget(controller: _controller),

          // Loading indicator
          if (!_cesiumLoaded)
            const Center(
              child: CircularProgressIndicator(),
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
                    _mapController.move(_center, 14.0);
                  },
                  child: const Icon(Icons.home),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "refresh",
                  onPressed: () {
                    _controller.reload();
                    setState(() => _cesiumLoaded = false);
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
