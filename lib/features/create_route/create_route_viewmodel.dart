// --- Imports ---
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'package:osm_navigation/core/services/location_api_service.dart';
import 'package:flutter/material.dart';

// --- Class Definition ---
class CreateRouteViewModel extends ChangeNotifier {
  final LocationApiService _locationApiService;

  // --- Constructor ---
  CreateRouteViewModel(this._locationApiService) {
    nameController.addListener(_onNameChanged);
    //loadLocations();
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

  Map<String, List<SelectableLocation>> _groupedLocations = {};
  Map<String, List<SelectableLocation>> get groupedLocations =>
      _groupedLocations;

  final Set<int> _selectedLocationIds = {};
  Set<int> get selectedLocationIds => _selectedLocationIds;

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

  // This method is currently commented out because the API is not ready yet.
  // TODO: Call the correct API method to load grouped locations when API is ready
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
      // Fetch grouped locations directly from the new service
      _groupedLocations =
          await _locationApiService.getGroupedSelectableLocations();
      _error = null;
    } catch (e) {
      _error = 'Failed to load locations: $e';
      _groupedLocations = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleLocationSelection(int locationId) {
    if (_selectedLocationIds.contains(locationId)) {
      _selectedLocationIds.remove(locationId);
    } else {
      _selectedLocationIds.add(locationId);
    }
    // Notify listeners to update UI (e.g., checkbox state and save button state)
    notifyListeners();
  }

  // TODO: Implement a method to save the route using the selected locations
  // This must be implemented in the future when the API is ready
  // For now, we will just print the selected locations to the console

  // Call this when saving is attempted (currently just for validation feedback)
  void attemptSave() {
    notifyListeners();

    if (canSave) {
      // In the future, this would trigger the API call
      debugPrint('Validation successful. Ready to save (not implemented).');
    } else {
      debugPrint('Validation failed.');
    }
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
