import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ValhallaService {
  // URL of your Valhalla server
  final String _baseUrl;
  
  /// Constructor for ValhallaService
  /// [baseUrl] is the URL of the Valhalla server. Default is 'http://145.24.222.95:8002'
  /// This gives the freedom to set a different server URL if needed.
  ValhallaService({String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'http://145.24.222.95:8002';
  
  /// Main functions of API for requesting optimized routes
  /// Must contain a list of LatLng points (at least 2) to be optimized
  /// Returns a Map with the route information from Valhalla
  ///
  /// TODO: Add more get-function for different route options
  Future<Map<String, dynamic>> getOptimizedRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      throw Exception('At least 2 waypoints are required');
    }
    
    try {
      // Format waypoints for Valhalla
      final locations = waypoints.map((point) => {
        'lon': point.longitude,
        'lat': point.latitude
      }).toList();
      
      // Create Valhalla request body
      final requestBody = {
        'locations': locations,
        'costing': 'auto',  // Can be auto, bicycle, pedestrian, etc.
        'directions_options': {
          'units': 'kilometers'
        }
      };
      
      // Send request to Valhalla server
      final response = await http.post(
        Uri.parse('$_baseUrl/route'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final routeData = jsonDecode(response.body);
        final encodedPolyline = routeData['trip']['legs'][0]['shape'] as String;
        final decodedPolyline = decodePolyline(encodedPolyline);
        return {
          'route': routeData,
          'decodedPolyline': decodedPolyline,
        };
      } else {
        throw Exception('Failed to get route: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Valhalla routing error: $e');
      rethrow;
    }
  }
  
     // Decode the polyline from Valhalla (similar to the JS function)
  List<LatLng> decodePolyline(String encoded, {int precision = 6}) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double factor = pow(10, precision).toDouble();
      points.add(LatLng(lat / factor, lng / factor));
    }

    return points;
  }
}
