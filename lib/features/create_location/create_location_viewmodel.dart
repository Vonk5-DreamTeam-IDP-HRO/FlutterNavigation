import 'package:flutter/foundation.dart';
import 'package:osm_navigation/Core/repositories/location/i_location_repository.dart';
import 'package:osm_navigation/Core/services/location/location_api_exceptions.dart';
import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'Services/Photon.dart';

class CreateLocationViewModel extends ChangeNotifier {
  final ILocationRepository _locationRepository;
  final PhotonService _photonService;

  CreateLocationViewModel({
    required ILocationRepository locationRepository,
    required PhotonService photonService,
  }) : _locationRepository = locationRepository,
       _photonService = photonService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<String> _categories = [];
  List<String> get categories => _categories;

  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;

  String? _categoriesErrorMessage;
  String? get categoriesErrorMessage => _categoriesErrorMessage;

  // For selected location coordinates
  num? _selectedLatitude;
  num? _selectedLongitude;

  // Set the selected coordinates when an address is selected from suggestions
  void setSelectedCoordinates(num latitude, num longitude) {
    _selectedLatitude = latitude;
    _selectedLongitude = longitude;
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoriesErrorMessage = null;
    notifyListeners();

    try {
      _categories = await _locationRepository.getUniqueCategories();
    } on LocationApiException catch (e) {
      _categoriesErrorMessage = 'Failed to load categories: ${e.message}';
      _categories = [];
    } catch (e) {
      _categoriesErrorMessage = 'Unexpected error: ${e.toString()}';
      _categories = [];
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<bool> submitLocation({
    required String name,
    required String address,
    String? description,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Use pre-selected coordinates if available, otherwise geocode the address
      late num latitude;
      late num longitude;

      if (_selectedLatitude != null && _selectedLongitude != null) {
        // Use pre-selected coordinates (from typeahead selection)
        latitude = _selectedLatitude!;
        longitude = _selectedLongitude!;
      } else {
        // Geocode the address to get coordinates
        final coordinates = await _photonService.geocodeAddress(address);
        latitude = coordinates.$1; // This is num
        longitude = coordinates.$2; // This is num
      }
      final detailPayload = CreateLocationDetailDto(
        category: category,
        address: address,
      );

      final payload = CreateLocationDto(
        name: name,
        description: description,
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
        locationDetail: detailPayload,
      );

      await _locationRepository.createLocation(payload);

      // Reset selected coordinates
      _selectedLatitude = null;
      _selectedLongitude = null;

      _successMessage = 'Location created successfully!';
      return true;
    } on LocationApiException catch (e) {
      _errorMessage = 'Failed to create location: ${e.message}';
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}
