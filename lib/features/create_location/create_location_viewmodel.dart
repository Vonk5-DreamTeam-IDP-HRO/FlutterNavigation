/// **CreateLocationViewModel.dart**
///
/// **Purpose:**
/// Manages the state and business logic for location creation, including address search,
/// geocoding, category management, and location submission. Handles the interaction
/// between UI and location-related repositories.
///
/// **Usage:**
/// This ViewModel is used by the CreateLocationScreen to handle address searching,
/// location validation, and creation of new locations with proper coordinates and
/// address details.
///
/// **Key Features:**
/// - Address search and geocoding using PhotonService
/// - Location categories management
/// - Coordinate handling and validation
/// - Location creation with detailed address information
/// - Loading and error state management
///
/// **Dependencies:**
/// - `ILocationRepository`: For location creation and category fetching
/// - `PhotonService`: For address search and geocoding
/// - `CreateLocationDto`: For location data structure
/// - `RepositoryException`: For error handling
///
/// **workflow:**
/// ```
/// 1. Initialize with required repositories
/// 2. Fetch available location categories
/// 3. Handle address search and selection
/// 4. Validate and process location details
/// 5. Submit location to repository
/// 6. Manage success/error feedback
/// ```
///
/// **Possible improvements:**
/// - Add location preview on map
/// - Add support for custom categories
/// - Consider caching frequent searches
///
import 'package:flutter/foundation.dart';
import 'package:osm_navigation/core/repositories/Location/i_location_repository.dart';
import 'package:osm_navigation/core/models/Location/CreateLocation/create_location_dto.dart';
import 'package:osm_navigation/core/repositories/repository_exception.dart';
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
  // For selected location coordinates and address details
  num? _selectedLatitude;
  num? _selectedLongitude;
  PhotonResultExtension? _selectedAddressDetails;

  // Set the selected coordinates and address details when an address is selected from suggestions
  void setSelectedCoordinates(num latitude, num longitude) {
    _selectedLatitude = latitude;
    _selectedLongitude = longitude;
  }

  // Set the selected address details from Photon suggestion
  void setSelectedAddressDetails(PhotonResultExtension addressDetails) {
    _selectedAddressDetails = addressDetails;
    setSelectedCoordinates(addressDetails.latitude, addressDetails.longitude);
  }

  // Search for addresses using PhotonService
  Future<List<PhotonResultExtension>> searchAddresses(String query) async {
    debugPrint(
      'CreateLocationViewModel: searchAddresses called with query: "$query"',
    );
    try {
      final results = await _photonService.searchAddresses(query);
      debugPrint(
        'CreateLocationViewModel: Received ${results.length} results from PhotonService',
      );
      return results;
    } catch (e) {
      debugPrint('CreateLocationViewModel: Error in searchAddresses: $e');
      return [];
    }
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoriesErrorMessage = null;
    notifyListeners();

    try {
      _categories = await _locationRepository.getUniqueCategories();
    } on RepositoryException catch (e) {
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
        address:
            _selectedAddressDetails?.street != null
                ? (_selectedAddressDetails!.housenumber != null
                    ? '${_selectedAddressDetails!.street} ${_selectedAddressDetails!.housenumber}'
                    : _selectedAddressDetails!.street)
                : _selectedAddressDetails
                    ?.name, // Fallback to name if no street
        city: _selectedAddressDetails?.city,
        country: _selectedAddressDetails?.country,
        zipCode: _selectedAddressDetails?.postcode,
      );

      final payload = CreateLocationDto(
        name: name,
        description: description,
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
        locationDetail: detailPayload,
      );

      await _locationRepository.createLocation(
        payload,
      ); // Reset selected coordinates and address details
      _selectedLatitude = null;
      _selectedLongitude = null;
      _selectedAddressDetails = null;

      _successMessage = 'Location created successfully!';
      return true;
    } on RepositoryException catch (e) {
      // Changed from LocationApiException
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
