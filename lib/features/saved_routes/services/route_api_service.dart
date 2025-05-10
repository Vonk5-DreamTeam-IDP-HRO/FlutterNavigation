import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:osm_navigation/core/models/route.dart';
import 'package:osm_navigation/core/models/location.dart';
import 'package:osm_navigation/core/models/location_details.dart';
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'package:osm_navigation/core/config/app_config.dart';

class RouteApiService {
  /// Fetches a list of all available routes.
  Future<List<Route>> getAllRoutes() async {
    // TODO: Change the URL to the correct one for your backend this is a placeholder URL and should be replaced with the actual endpoint when it is finished.
    final url = Uri.parse('${AppConfig.tempRESTUrl}/routes?select=*');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((route) => Route.fromJson(route)).toList();
      } else {
        throw Exception('Failed to load routes');
      }
    } catch (e) {
      throw Exception('Failed to load routes: $e');
    }
  }

  /// Fetches the list of locations associated with a specific route ID.
  /// /// [routeId] is the ID of the route for which to fetch locations.
  /// /// Returns a list of [Location] objects associated with the route.
  /// Throws an exception if the request fails or if the response is not in the expected format.
  Future<List<Location>> getRouteLocations(int routeId) async {
    // Construct the URL to fetch locations for a specific route
    final url = Uri.parse(
      '${AppConfig.tempRESTUrl}/location_route?select=*,locations:locationid(name,longitude,latitude)&routeid=eq.$routeId',
    );

    debugPrint(
      'Fetching locations for route $routeId from URL: $url',
    ); // Debug print

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        // Extract the nested 'locations' object from each item in the list
        // and parse it into a Location object.
        final locations =
            jsonResponse
                .map(
                  (item) => Location.fromJson(
                    item['locations'] as Map<String, dynamic>,
                  ),
                )
                .toList();
        debugPrint(
          'Successfully fetched ${locations.length} locations for route $routeId',
        ); // Debug print
        return locations;
      } else {
        throw Exception(
          'Failed to load locations for route $routeId (Status code: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to load locations for route $routeId: $e');
    }
  }

  /// Fetches all locations and their details to create a list of selectable locations with categories.
  Future<List<SelectableLocation>> getSelectableLocations() async {
    final locationsUrl = Uri.parse('${AppConfig.tempRESTUrl}/locations');
    final detailsUrl = Uri.parse('${AppConfig.tempRESTUrl}/location_details');

    debugPrint('Fetching all locations from URL: $locationsUrl');
    debugPrint('Fetching all location details from URL: $detailsUrl');

    try {
      // Fetch both lists concurrently
      final responses = await Future.wait([
        http.get(locationsUrl),
        http.get(detailsUrl),
      ]);

      final locationsResponse = responses[0];
      final detailsResponse = responses[1];

      if (locationsResponse.statusCode != 200) {
        throw Exception(
          'Failed to load locations (Status code: ${locationsResponse.statusCode})',
        );
      }
      if (detailsResponse.statusCode != 200) {
        throw Exception(
          'Failed to load location details (Status code: ${detailsResponse.statusCode})',
        );
      }

      final List<dynamic> locationsJson = json.decode(locationsResponse.body);
      final List<dynamic> detailsJson = json.decode(detailsResponse.body);

      // Create a map of locationId to category from details
      final Map<int, String> categoryMap = {};
      for (var detailData in detailsJson) {
        final detail = LocationDetails.fromJson(
          detailData as Map<String, dynamic>,
        );
        categoryMap[detail.locationId] =
            detail.category ?? 'Uncategorized'; // Use 'Uncategorized' if null
      }

      // Create SelectableLocation list
      final List<SelectableLocation> selectableLocations = [];
      for (var locationData in locationsJson) {
        // Assuming /locations response structure includes 'locationid' and 'name'
        final int locationId = locationData['locationid'] as int;
        final String name = locationData['name'] as String;
        final String category =
            categoryMap[locationId] ??
            'Uncategorized'; // Default if no details found

        selectableLocations.add(
          SelectableLocation(
            locationId: locationId,
            name: name,
            category: category,
          ),
        );
      }

      debugPrint(
        'Successfully fetched and combined ${selectableLocations.length} selectable locations.',
      );
      return selectableLocations;
    } catch (e) {
      throw Exception('Failed to load selectable locations: $e');
    }
  }
}
