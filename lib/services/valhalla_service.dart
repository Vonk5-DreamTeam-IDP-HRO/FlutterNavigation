import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ValhallaService {
  final String baseUrl;

  ValhallaService({this.baseUrl = 'http://145.24.222.95:8002'});

  Future<Map<String, dynamic>> getOptimizedRoute(List<LatLng> waypoints) async {
    // Convert waypoints to Valhalla format
    final List<Map<String, dynamic>> locations = waypoints.map((point) => {
      'lat': point.latitude,
      'lon': point.longitude,
      'type': 'break'
    }).toList();

    // Build request data
    final requestData = {
      'locations': locations,
      'costing': 'pedestrian',
      'directions_options': {
        'units': 'kilometers',
        'language': 'en'
      }
    };

    // Make the API request
    final response = await http.get(
      Uri.parse('$baseUrl/optimized_route?json=${Uri.encodeComponent(jsonEncode(requestData))}'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get route: ${response.statusCode}');
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