// --- Imports ---
import 'package:flutter/material.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart'
    as route_models;
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/repositories/Location/i_location_repository.dart';
import 'package:osm_navigation/core/repositories/Route/IRouteRepository.dart';

// --- Class Definition ---
class CreateRouteViewModel extends ChangeNotifier {
  final IRouteRepository _routeRepository;
  final ILocationRepository _locationRepository;

  // --- Constructor ---
  CreateRouteViewModel(this._routeRepository, this._locationRepository) {
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

  String? _locationLoadingError;
  String? _routeSaveError;
  String? get locationLoadingError => _locationLoadingError;
  String? get routeSaveError => _routeSaveError;

  bool _saveSuccess = false;
  bool get saveSuccess => _saveSuccess;

  RouteDto? _newlyCreatedRoute;
  RouteDto? get newlyCreatedRoute => _newlyCreatedRoute;

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
    _locationLoadingError = null;
    // Notify widgets that are listening that the state of _isLoading has changed
    notifyListeners();

    try {
      // Fetch grouped locations from the repository
      _groupedLocations =
          await _locationRepository.getGroupedSelectableLocations();
      _locationLoadingError = null;
    } catch (e) {
      _locationLoadingError = 'Failed to load locations: $e';
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

  Future<void> attemptSave() async {
    if (!canSave) {
      debugPrint('Validation failed.');
      return;
    }

    _isLoading = true;
    _routeSaveError = null;
    notifyListeners();

    try {
      final dto = route_models.CreateRouteDto(
        name: nameController.text.trim(),
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        locationIds: _selectedLocationIds.toList(),
      );
      // Validate before sending
      if (!route_models.CreateRouteDtoValidation(dto).isValid()) {
        final errors =
            route_models.CreateRouteDtoValidation(dto).getValidationErrors();
        _routeSaveError = 'Validation failed: ${errors.join(', ')}';
        debugPrint(_routeSaveError!);
        notifyListeners();
        return;
      }

      // Save the route and store the result
      _newlyCreatedRoute = await _routeRepository.addRoute(dto);
      debugPrint('Route saved successfully.');

      // Set success flag and clear form
      _saveSuccess = true;
      _clearForm();
    } catch (e) {
      _routeSaveError = 'Failed to save route: $e';
      debugPrint(_routeSaveError!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -- Edit Initialization --
  void initializeForEdit(dynamic route) {
    // Accepts a Route object (with name and description)
    nameController.text = route.name;
    descriptionController.text = route.description;
    notifyListeners();
  }

  // -- Cleanup --

  // Dispose of the controllers to free up resources when the ViewModel is no longer needed
  /// Clear any route save error
  void clearRouteSaveError() {
    if (_routeSaveError != null) {
      _routeSaveError = null;
      notifyListeners();
    }
  }

  /// Clear success state and newly created route
  void clearSuccess() {
    if (_saveSuccess || _newlyCreatedRoute != null) {
      _saveSuccess = false;
      _newlyCreatedRoute = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    _selectedLocationIds.clear();
    notifyListeners();
  }

  // -- validation summery --
  String? get validationSummary {
    final errors = <String>[];

    if (!isNameValid) errors.add('Route name is required');
    if (!areLocationsValid) {
      if (_selectedLocationIds.isEmpty) {
        errors.add('Please select at least 2 locations');
      } else {
        errors.add(
          'Please select at least ${2 - _selectedLocationIds.length} more location(s)',
        );
      }
    }

    return errors.isEmpty ? null : errors.join(', ');
  }
}
