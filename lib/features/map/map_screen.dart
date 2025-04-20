import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Initial focus point when opening map
  final LatLng _center = const LatLng(51.92, 4.48); // Rotterdam center


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotterdam Map (2D)')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _center, initialZoom: 13.0),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.osm_navigation',
          ),
         
        ],
      ),
    );
  }
}
