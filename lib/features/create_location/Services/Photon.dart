import 'package:flutter_photon/flutter_photon.dart';
import 'package:flutter/foundation.dart';

// Created by Gemini 2.5 PRO with Cline.

// Custom exception for geocoding errors
class PhotonGeocodingException implements Exception {
  final String message;
  PhotonGeocodingException(this.message);

  @override
  String toString() => 'PhotonGeocodingException: $message';
}

class PhotonService {
  final PhotonApi _api = PhotonApi();

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

      if (longitude == null) {
        throw PhotonGeocodingException(
          'Coordinates are missing in the result.',
        );
      }

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
    if (query.isEmpty) return [];

    try {
      final results = await _api.forwardSearch(
        query,
        params: const PhotonForwardParams(limit: 5, langCode: 'en'),
      );

      // Process results to ensure they have formatted addresses
      return results.map((feature) => PhotonResultExtension(feature)).toList();
    } catch (e) {
      debugPrint('Error searching addresses: $e');
      return [];
    }
  }
}

/// Extension class to add formatted address to PhotonFeature
class PhotonResultExtension {
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
