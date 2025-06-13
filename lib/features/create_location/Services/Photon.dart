/// **PhotonService**
///
/// A service wrapper for the Photon geocoding API that provides address search
/// and geocoding functionality with rate limiting and error handling.
///
/// **Purpose:**
/// Provides a reliable interface to perform geocoding operations while maintaining
/// rate limits and providing proper error handling.
///
/// **Key Features:**
/// - Forward geocoding (address to coordinates)
/// - Address search with autocompletion
/// - Rate limiting protection (1 request/second)
/// - Detailed error handling
/// - Formatted address generation
///
/// **Usage:**
/// ```dart
/// final service = PhotonService();
///
/// // Geocode an address
/// final (lat, lon) = await service.geocodeAddress('123 Main St, City');
///
/// // Search for addresses
/// final results = await service.searchAddresses('Main St');
/// ```
///
/// **Dependencies:**
/// - `flutter_photon`: For Photon API communication
/// - `foundation`: For debug logging
///
library photon_service;

import 'package:flutter_photon/flutter_photon.dart';
import 'package:flutter/foundation.dart';

// Created by Gemini 2.5 PRO with Cline.

/// Exception thrown when geocoding operations fail.
///
/// Contains details about what went wrong during the geocoding process.
class PhotonGeocodingException implements Exception {
  final String message;
  PhotonGeocodingException(this.message);

  @override
  String toString() => 'PhotonGeocodingException: $message';
}

/// Service class for interacting with the Photon geocoding API.
///
/// Provides methods for address searching and geocoding while implementing
/// rate limiting and error handling.
class PhotonService {
  // --- Dependencies ---
  final PhotonApi _api;

  // --- State ---
  DateTime? _lastRequest;
  static const _minRequestInterval = Duration(
    milliseconds: 1000,
  ); // Rate limiting

  PhotonService() : _api = PhotonApi() {
    debugPrint('PhotonService: Initialized with new PhotonApi instance');
  }

  /// Preforms forward geocoding using Photon API
  /// Returns a tuple of (latitude, longitude)
  /// Throws a [PhotonGeocodingException] if no coordinates are found or an error occurs.
  Future<(num, num)> geocodeAddress(String address) async {
    try {
      // Assuming forwardSearch can take params for language if needed, though not strictly for geocoding a single address.
      final results = await _api.forwardSearch(
        address,
        params: const PhotonForwardParams(limit: 1),
      );

      if (results.isEmpty) {
        throw PhotonGeocodingException(
          'No coordinates found for the given address.',
        );
      }

      final firstResult = results.first;
      final num latitude = firstResult.coordinates.latitude;
      final num longitude = firstResult.coordinates.longitude;

      return (latitude, longitude);
    } catch (e) {
      // Catching potential errors from _api.forwardSearch or re-throwing our custom one
      if (e is PhotonGeocodingException) {
        rethrow; // Re-throw if it's already our specific exception
      }
      // Wrap other exceptions
      throw PhotonGeocodingException(
        'Failed to geocode address: ${e.toString()}',
      );
    }
  }

  /// Searches for addresses that match the given query
  /// Returns a list of PhotonResultExtension objects containing address information
  /// Returns an empty list if the query is empty or an error occurs during the search.
  Future<List<PhotonResultExtension>> searchAddresses(String query) async {
    debugPrint('PhotonService: Starting search for query: "$query"');

    if (query.isEmpty) {
      debugPrint('PhotonService: Query is empty, returning empty list');
      return [];
    }

    // Implement rate limiting
    if (_lastRequest != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequest!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        debugPrint(
          'PhotonService: Rate limiting - waiting ${waitTime.inMilliseconds}ms',
        );
        await Future.delayed(waitTime);
      }
    }
    _lastRequest = DateTime.now();

    try {
      debugPrint(
        'PhotonService: Making API call to Photon service with query: "$query"',
      );
      final results = await _api.forwardSearch(
        query,
        params: const PhotonForwardParams(limit: 5, langCode: 'en'),
      );
      debugPrint('PhotonService: Raw API response received');

      if (results.isEmpty) {
        debugPrint('PhotonService: No results received from API');
        return [];
      }

      debugPrint('PhotonService: Received ${results.length} results from API');
      debugPrint('PhotonService: First result - ${results.first.name}');

      // Process results to ensure they have formatted addresses
      final processedResults =
          results.map((feature) => PhotonResultExtension(feature)).toList();
      debugPrint(
        'PhotonService: Returning ${processedResults.length} processed results',
      );

      return processedResults;
    } catch (e) {
      debugPrint('PhotonService: Error searching addresses: $e');
      debugPrint('PhotonService: Error type: ${e.runtimeType}');
      return [];
    }
  }
}

/// Extension class to add formatted address to PhotonFeature
/// Extension wrapper for PhotonFeature that adds formatted address functionality.
///
/// Provides easy access to address components and generates properly formatted
/// address strings from the raw Photon data.
class PhotonResultExtension {
  // --- Dependencies ---
  final PhotonFeature _feature;

  PhotonResultExtension(this._feature);

  // Properties directly from PhotonFeature
  String? get name => _feature.name;
  String? get street => _feature.street;
  String? get housenumber =>
      _feature.houseNumber; // Assuming this exists directly
  String? get city => _feature.city;
  String? get district => _feature.district;
  String? get state => _feature.state;
  String? get county => _feature.county;
  String? get country => _feature.country;
  String? get postcode => _feature.postcode;
  String? get type => _feature.type;

  num get latitude {
    return _feature.coordinates.latitude;
  }

  num get longitude {
    return _feature.coordinates.longitude;
  }

  String get formattedAddress {
    final List<String> addressParts = [];

    // Use properties from PhotonFeature
    if (street != null) {
      String streetPart = street!;
      if (housenumber != null) {
        streetPart += ' ${housenumber!}';
      }
      addressParts.add(streetPart);
    }

    if (postcode != null && city != null) {
      addressParts.add('$postcode $city');
    } else if (city != null) {
      addressParts.add(city!);
    } else if (district != null) {
      addressParts.add(district!);
    }

    if (state != null && state != city) {
      // Avoid duplicating city if it's also the state
      addressParts.add(state!);
    } else if (county != null && county != city) {
      addressParts.add(county!);
    }

    if (country != null) {
      addressParts.add(country!);
    }

    if (addressParts.isEmpty && name != null) {
      // Fallback to name if no other parts are available (e.g. for oceans, large areas)
      return name!;
    }

    return addressParts.join(', ');
  }
}
