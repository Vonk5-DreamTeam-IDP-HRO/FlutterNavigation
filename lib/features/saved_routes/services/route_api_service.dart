import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:osm_navigation/core/models/app_route.dart';
import 'package:osm_navigation/core/config/app_config.dart';

class RouteApiService {
  Future<List<AppRoute>> getAllRoutes() async {
    //TODO: Change the URL to the correct one for your backend this is a placeholder URL and should be replaced with the actual endpoint when it is finished.
    final url = Uri.parse('${AppConfig.tempRESTUrl}/routes?select=*');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((route) => AppRoute.fromJson(route)).toList();
      } else {
        throw Exception('Failed to load routes');
      }
    } catch (e) {
      throw Exception('Failed to load routes: $e');
    }
  }
}
