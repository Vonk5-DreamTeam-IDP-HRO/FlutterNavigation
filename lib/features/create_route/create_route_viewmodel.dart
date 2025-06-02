// --- Imports ---
import 'package:osm_navigation/Core/repositories/location/i_location_repository.dart';
import 'package:flutter/material.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';

// --- Class Definition ---
class CreateRouteViewModel extends ChangeNotifier {
  final ILocationRepository _locationRepository;

  // --- Constructor ---
  CreateRouteViewModel(this._locationRepository) {
    nameController.addListener(_onNameChanged);
    loadLocations(); // Load locations in accordion when the ViewModel is initialized
  }

  // --- Private methods for internal event handling ---
  void _onNameChanged() {
    // Notify listeners when the name text changes, allowing UI to update
    // based on properties like isNameValid or canSave.
    notifyListeners();
  }

  // --- State Variables ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Map<String, List<SelectableLocationDto>> _groupedLocations = {};
  Map<String, List<SelectableLocationDto>> get groupedLocations =>
      _groupedLocations;

  final Set<String> _selectedLocationIds = {};
  Set<String> get selectedLocationIds => _selectedLocationIds;

  // --- Controllers for Text Fields ---

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // --- public Validation Getters for UI ---

  // These getters can be used to determine if the form is valid
  // and can be used to enable/disable the save button or show validation messages as example.
  // So these getters are pure for frontend validation.
  bool get isNameValid => nameController.text.trim().isNotEmpty;
  bool get areLocationsValid => _selectedLocationIds.length >= 2;
  bool get canSave => isNameValid && areLocationsValid && !_isLoading;

  // -- Methods --

  // This method loads locations from the API and groups them by category
  // It uses the new LocationApiService to fetch the data.
  // The method is asynchronous and updates the loading state and error messages accordingly.
  // It also notifies listeners when the state changes.
  Future<void> loadLocations() async {
    _isLoading = true;
    _error = null;
    // Notify widgets that are listening that the state of _isLoading has changed
    notifyListeners();

    try {
      // Fetch grouped locations from the repository
      _groupedLocations =
          await _locationRepository.getGroupedSelectableLocations();
      _error = null;
    } catch (e) {
      _error = 'Failed to load locations: $e';
      _groupedLocations = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleLocationSelection(String locationId) {
    // Changed parameter from Uuid to String
    if (_selectedLocationIds.contains(locationId)) {
      _selectedLocationIds.remove(locationId);
    } else {
      _selectedLocationIds.add(locationId);
    }
    // Notify listeners to update UI
    notifyListeners();
  }

  void attemptSave() {
    notifyListeners();

    if (canSave) {
      debugPrint('Validation successful. Ready to save (not implemented).');
    } else {
      debugPrint('Validation failed.');
    }
  }

  // -- Edit Initialization --
  void initializeForEdit(dynamic route) {
    // Accepts a Route object (with displayName and description)
    nameController.text = route.displayName;
    descriptionController.text = route.description;
    notifyListeners();
  }

  // -- Cleanup --
  // Dispose of the controllers to free up resources when the ViewModel is no longer needed
  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
