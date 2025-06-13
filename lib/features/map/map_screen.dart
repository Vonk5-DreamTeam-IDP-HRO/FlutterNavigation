library map_screen;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import './map_viewmodel.dart';

/// An interactive map widget displaying Rotterdam's geographical data and routes.
///
/// Implements the View component in MVVM architecture, observing [MapViewModel] for
/// state changes and delegating user interactions. Features include:
/// * OpenStreetMap tile display
/// * Route polyline visualization
/// * Error message handling
/// * Loading state indicators
///
/// Example usage:
/// ```dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => MapViewModel()),
///   ],
///   child: MapScreen(),
/// )
/// ```

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use context.watch<MapViewModel>() here in the build method.
    // This ensures the widget rebuilds whenever the MapViewModel calls notifyListeners(),
    // keeping the UI synchronized with the state.
    final viewModel = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotterdam Map'),
        backgroundColor: const Color(0xFF00811F),
        foregroundColor: Colors.white,
        actions: [
          // Display a loading indicator in the AppBar when the ViewModel is busy.
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        // Stack allows overlaying elements like error messages or loading indicators.
        children: [
          FlutterMap(
            mapController: viewModel.mapController,
            options: MapOptions(
              initialCenter: viewModel.currentCenter,
              initialZoom: viewModel.currentZoom,
              onPositionChanged: viewModel.onMapPositionChanged,

              // TODO: Example for future implementation:
              // onTap: (tapPosition, point) => context.read<MapViewModel>().handleMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.osm_navigation',
              ),
              // Only draw the PolylineLayer if the routePolyline is not empty
              if (viewModel.routePolyline.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: viewModel.routePolyline,
                      strokeWidth: 5.0,
                      color: Colors.deepOrange,
                    ),
                  ],
                ),

              // TODO: Future extension: Markers could be added here, sourced from viewModel.markers
              // MarkerLayer(markers: viewModel.markers),
            ],
          ),
          // Display an error message overlay if the ViewModel reports an error.
          if (viewModel.errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.redAccent.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Move this logic to the ViewModel.
          // Define sample waypoints for demonstration. Replace with actual user input logic later.
          final List<LatLng> waypoints = [
            const LatLng(51.9225, 4.47917), // Rotterdam Centraal
            const LatLng(51.9175, 4.4883), // Markthal
            const LatLng(51.9230, 4.4670), // Euromast
          ];

          // Use context.read<MapViewModel>() within callbacks like onPressed.
          // This accesses the ViewModel to call methods without listening for changes,
          // preventing unnecessary rebuilds of this widget when the action is triggered.
          context.read<MapViewModel>().fetchRoute(waypoints);
        },
        tooltip: 'Fetch Sample Route',
        child: const Icon(Icons.route),
      ),
    );
  }
}
