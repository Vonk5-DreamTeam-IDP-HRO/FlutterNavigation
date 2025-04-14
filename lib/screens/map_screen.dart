import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_navigation/services/valhalla_test.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class MapScreen extends StatefulWidget {
  // We don't need this parameter anymore as we're using AppState
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ValhallaService _valhallaService = ValhallaService();
  final MapController _mapController = MapController();

  //Initial focus point when opening map
  final LatLng _center = LatLng(51.92, 4.48);

  //TODO: Fix hardcoded & import data from database
  //Start with empty waypoints list - will be populated when route is requested
  List<LatLng> _waypoints = [];

  // Waypoint data to use when route is requested
  final List<LatLng> _waypointsData = [
    LatLng(51.9201, 4.4869), // Markthal
    LatLng(51.9249, 4.4692), // Centraal Station
    LatLng(51.9206, 4.4733), // Schouwburgplein
    LatLng(51.9135, 4.4879), // Boompjeskade
    LatLng(51.9093, 4.4884), // Erasmusbrug
    LatLng(51.9144, 4.4735), // Museum Boijmans
  ];

  List<LatLng> _routePoints = [];
  String _tripSummary = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valhalla Navigation'),
      ),
      body: Column(
        children: [
          if (_tripSummary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_tripSummary,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),

          // Map in the middle (expanding to fill space)
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.osm_navigation',
                ),

                // Display all waypoint markers
                if (_waypoints.isNotEmpty)
                  MarkerLayer(
                    markers: _waypoints
                        .map((point) => Marker(
                              point: point,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 30,
                              ),
                            ))
                        .toList(),
                  ),

                // Display route polyline if available
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getOptimizedRoute() async {
    // Store context to avoid async gap issues
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // First set the waypoints from the waypoints data
      if (mounted) {
        setState(() {
          _waypoints =
              List.from(_waypointsData);
        });
      }

      final List<LatLng> roundTripWaypoints = [
        _waypointsData.first,
        ..._waypointsData,
        _waypointsData.first,
      ];

      final response =
          await _valhallaService.getOptimizedRoute(roundTripWaypoints);

      if (response.containsKey('trip') &&
          response['trip'].containsKey('legs')) {
        List<LatLng> allPoints = [];

        for (var leg in response['trip']['legs']) {
          if (leg.containsKey('shape')) {
            List<LatLng> legPoints =
                _valhallaService.decodePolyline(leg['shape']);
            allPoints.addAll(legPoints);
          }
        }

        // Extract summary information
        if (response['trip'].containsKey('summary')) {
          final summary = response['trip']['summary'];
          final totalDistance = summary['length'].toStringAsFixed(2);
          final totalTimeMin = (summary['time'] / 60).round();

          if (mounted) {
            setState(() {
              _tripSummary =
                  "Distance: $totalDistance km, Time: $totalTimeMin minutes";
            });
          }
        }
        if (mounted) {
          setState(() {
            _routePoints = allPoints;
          });
        }

        if (allPoints.isNotEmpty) {
          var bounds = LatLngBounds.fromPoints(allPoints);

      
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error fetching route: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);

        if (appState.shouldShowRouteOnMap) {
          _getOptimizedRoute();
          appState.routeShown();
        }
      }
    });
  }
}
