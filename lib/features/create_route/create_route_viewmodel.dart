/// **CreateRouteViewModel.dart**
///
/// **Purpose:** Handles all logic for creating a route. This includes loading all locations
/// in form of SelectableLocationDto, validating the form, tracking user selection from accordion
/// and saving the route using the repository pattern.
///
/// **Usage:** This ViewModel is used in the CreateRouteView to manage the state of the form,
/// validate user input, and interact with the repositories to save the route.
///
/// **Key Features:**
/// - Loads locations from the ILocationRepository and groups them by category
/// - Validates user input for route name and selected locations
/// - Handles saving the route using the IRouteRepository
///
/// **Dependencies:**
/// - `IRouteRepository`: For saving the route
/// - `ILocationRepository`: For loading locations
/// - `package:flutter/material.dart`: For ChangeNotifier and TextEditingController
/// - `package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart`: For SelectableLocationDto model
/// - `package:osm_navigation/core/models/Route/create_route_dto.dart`: For CreateRouteDto model
/// - `package:osm_navigation/core/models/Route/route_dto.dart`: For RouteDto model
///
/// **workflow:**
/// ```
/// 1. Initialize the ViewModel with repositories
/// 2. Load locations using `loadLocations()`, which fetches and groups locations
/// 3. User interacts with the form, entering a name and selecting locations
/// 4. Validate the form using `isNameValid`, `areLocationsValid`, and `canSave`
/// 5. Call `attemptSave()` to save the route if validation passes
/// 6. If save is successful, `newlyCreatedRoute` will contain the saved route data
/// ```
///
/// **Possible improvements:**
/// - Accordion for locations could be made more dynamic. It is loading all locations
/// - Consider implementing pagination or lazy loading for each category.
/// - Consider adding search functionality to filter locations.
///
library create_route_viewmodel;

// --- Imports ---
import 'package:flutter/material.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Route/create_route_dto.dart'
    as route_models;
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/repositories/Location/i_location_repository.dart';
import 'package:osm_navigation/core/repositories/Route/IRouteRepository.dart';

class CreateRouteViewModel extends ChangeNotifier {
  // --- Dependencies ---
  final IRouteRepository _routeRepository;
  final ILocationRepository _locationRepository;

  // --- Controllers ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // --- State ---
  bool _isLoading = false;
  String? _locationLoadingError;
  String? _routeSaveError;
  bool _saveSuccess = false;
  RouteDto? _newlyCreatedRoute;
  Map<String, List<SelectableLocationDto>> _groupedLocations = {};
  final Set<String> _selectedLocationIds = {};

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get locationLoadingError => _locationLoadingError;
  String? get routeSaveError => _routeSaveError;
  bool get saveSuccess => _saveSuccess;
  RouteDto? get newlyCreatedRoute => _newlyCreatedRoute;
  Map<String, List<SelectableLocationDto>> get groupedLocations =>
      _groupedLocations;
  Set<String> get selectedLocationIds => _selectedLocationIds;
  bool get isNameValid => nameController.text.trim().isNotEmpty;
  bool get areLocationsValid => _selectedLocationIds.length >= 2;
  bool get canSave => isNameValid && areLocationsValid && !_isLoading;

  // --- Initialization ---
  CreateRouteViewModel(this._routeRepository, this._locationRepository) {
    nameController.addListener(_onNameChanged);
    loadLocations(); // Load locations in accordion when the ViewModel is initialized
  }

  // --- Private Methods ---
  void _onNameChanged() {
    notifyListeners();
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    _selectedLocationIds.clear();
    notifyListeners();
  }

  // --- Public Methods ---

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

  // --- Route Edit Methods ---
  void initializeForEdit(dynamic route) {
    // Accepts a Route object (with name and description)
    nameController.text = route.name;
    descriptionController.text = route.description;
    notifyListeners();
  }

  // --- Cleanup Methods ---

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
