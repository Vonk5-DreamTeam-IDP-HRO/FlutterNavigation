import 'package:flutter/foundation.dart';
import 'package:osm_navigation/Core/models/location_request_dtos.dart';
import 'package:osm_navigation/Core/repositories/i_location_repository.dart';
import 'package:osm_navigation/Core/services/location/location_api_exceptions.dart';

class CreateLocationViewModel extends ChangeNotifier {
  final ILocationRepository _locationRepository;

  CreateLocationViewModel({required ILocationRepository locationRepository})
    : _locationRepository = locationRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Properties for categories
  List<String> _categories = [];
  List<String> get categories => _categories;

  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;

  String? _categoriesErrorMessage;
  String? get categoriesErrorMessage => _categoriesErrorMessage;

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoriesErrorMessage = null;
    notifyListeners();

    try {
      _categories = await _locationRepository.getUniqueCategories();
    } on LocationApiException catch (e) {
      // Catch specific API exceptions
      _categoriesErrorMessage = 'Failed to load categories: ${e.message}';
      _categories = []; // Clear categories on error
      debugPrint(
        '[CreateLocationViewModel] LocationApiException fetching categories: $e',
      );
    } catch (e) {
      // Catch any other unexpected errors
      _categoriesErrorMessage =
          'An unexpected error occurred while fetching categories: ${e.toString()}';
      _categories = []; // Clear categories on error
      debugPrint(
        '[CreateLocationViewModel] Unexpected error fetching categories: $e',
      );
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<bool> submitLocation({
    required String name,
    required String address, // Address from the form
    String? description,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // TODO: Geocode 'address' to get actual latitude and longitude.
      // Using placeholder values for now.
      const double placeholderLatitude = 0.0;
      const double placeholderLongitude = 0.0;

      if (address.isEmpty &&
          (placeholderLatitude == 0.0 && placeholderLongitude == 0.0)) {
        // A more robust check or actual geocoding would be needed.
        // For now, if address is empty and we are using placeholders, this is an issue.
        // However, the form validation should catch empty address.
        // This is more about the geocoding step being missing.
        debugPrint(
          '[CreateLocationViewModel] Warning: Address is present, but using placeholder lat/lng (0.0, 0.0) as geocoding is not implemented.',
        );
      }

      // Create the details payload first
      final detailPayload = CreateLocationDetailPayload(
        category: category,
        address: address, // Pass the address to details as well
        // Other details like city, country can be added here if collected or defaulted
      );

      final payload = CreateLocationPayload(
        name: name,
        description: description ?? '', // Ensure description is not null
        latitude:
            placeholderLatitude, // TODO: Still placeholder, geocoding remains
        longitude:
            placeholderLongitude, // TODO: Still placeholder, geocoding todo remains
        details: detailPayload,
      );
      debugPrint(
        '[CreateLocationViewModel] Creating location with payload: ${payload.toJson()}',
      );
      // Now using the repository to create the location
      await _locationRepository.createLocation(payload);

      _successMessage = 'Location created successfully!';
      _isLoading = false;
      notifyListeners();
      return true;
    } on LocationApiException catch (e) {
      _errorMessage = 'Failed to create location: ${e.message}';
      debugPrint('[CreateLocationViewModel] LocationApiException: $e');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      debugPrint('[CreateLocationViewModel] Unexpected error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    // notifyListeners(); // Optionally notify if UI should react instantly to clearing
  }
}
