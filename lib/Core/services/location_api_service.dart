import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:osm_navigation/core/models/location_details.dart';
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'package:osm_navigation/core/config/app_config.dart';

class LocationApiService {
  /// Fetches all locations and their details, groups them by category,
  /// and returns a map suitable for selection UIs.
  Future<Map<String, List<SelectableLocation>>>
  getGroupedSelectableLocations() async {
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

      // Group the locations by category before returning
      final groupedLocations = groupBy(
        selectableLocations,
        (location) => location.category,
      );
      debugPrint(
        'Grouped locations into ${groupedLocations.length} categories.',
      );

      return groupedLocations;
    } catch (e) {
      // Consider more specific error handling or logging
      debugPrint('Error fetching selectable locations: $e');
      throw Exception('Failed to load selectable locations: $e');
    }
  }
}
