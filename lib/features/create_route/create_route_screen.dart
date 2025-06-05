/// **CreateRouteScreen.dart**
///
/// **Purpose:** Handles the UI layer for creating a route. This includes displaying a form
/// with name and description fields, showing a location selection accordion, managing
/// authentication state, and providing visual feedback for loading and error states.
///
/// **Usage:** This screen works with CreateRouteViewModel to provide a complete route
/// creation interface. It handles user input validation and provides immediate feedback
/// while delegating business logic to the ViewModel.
///
/// **Key Features:**
/// - Displays form with route name and description inputs
/// - Shows grouped locations in an accordion selector
/// - Handles authentication state with login dialog
/// - Provides loading indicators and error messages
/// - Implements real-time validation feedback
///
/// **Dependencies:**
/// - `CreateRouteViewModel`: For state management and business logic
/// - `AuthViewModel`: For authentication state handling
/// - `AppState`: For tab navigation management
/// - `Provider`: For state management
/// - `LocationAccordionSelector`: For location selection UI
///
/// **workflow:**
/// ```
/// 1. Screen loads and checks authentication state
/// 2. If not authenticated, shows login dialog
/// 3. Displays form with text inputs and location selector
/// 4. Updates UI based on ViewModel state changes
/// 5. Shows loading overlay during save operation
/// 6. Displays success/error feedback after save attempt
/// ```
///
/// **Possible improvements:**
/// - Consider implementing long term storage for route data so users can resume later
/// - Add confirmation dialog before discarding changes
/// - Add search functionality in location selector
///

// --- Import Statements ---

import 'package:flutter/material.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:osm_navigation/core/models/Route/route_dto.dart';
import 'package:osm_navigation/core/navigation/navigation.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/core/utils/feedback_util.dart';
import 'package:osm_navigation/core/utils/tuple.dart';
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
import 'package:osm_navigation/features/auth/screens/login_screen.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/features/create_route/widgets/location_accordion_selector.dart';
import 'package:provider/provider.dart';

// --- Class Definition ---
class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  bool _isLoginDialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use Builder to ensure we have the correct context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Builder(
        builder: (builderContext) {
          final authViewModel = Provider.of<AuthViewModel>(
            builderContext,
            listen: false,
          );
          final appState = Provider.of<AppState>(builderContext, listen: false);

          // Check initial state
          final bool shouldShowDialog =
              !authViewModel.isAuthenticated &&
              appState.selectedTabIndex == MainScreen.createRouteIndex &&
              !_isLoginDialogShown;

          if (shouldShowDialog) {
            _showLoginDialog(builderContext);
            if (mounted) {
              setState(() {
                _isLoginDialogShown = true;
              });
            }
          }

          // Listen for changes with separate Provider.of calls
          final authChanges = Provider.of<AuthViewModel>(builderContext);
          final appStateChanges = Provider.of<AppState>(builderContext);

          if ((authChanges.isAuthenticated ||
                  appStateChanges.selectedTabIndex !=
                      MainScreen.createRouteIndex) &&
              _isLoginDialogShown) {
            if (mounted) {
              setState(() {
                _isLoginDialogShown = false;
              });
            }
          }
          return const SizedBox.shrink(); // Builder needs to return a widget
        },
      );
    });
  }

  void _showLoginDialog(BuildContext dialogContext) {
    if (!mounted) return;

    // Create a new context using Builder to ensure we have access to all providers
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder:
          (BuildContext alertContext) => Builder(
            builder:
                (builderContext) => AlertDialog(
                  title: const Text('Login Required'),
                  content: const Text(
                    'You need to log in or register to create a route.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(alertContext).pop();
                        if (mounted) {
                          setState(() {
                            _isLoginDialogShown = false;
                          });
                          // Use the builderContext to access providers
                          Provider.of<AppState>(
                            builderContext,
                            listen: false,
                          ).changeTab(MainScreen.homeIndex);
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Login / Register'),
                      onPressed: () {
                        Navigator.of(alertContext).pop();
                        if (mounted) {
                          setState(() {
                            _isLoginDialogShown = false;
                          });
                        }
                        Navigator.of(builderContext).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
          ),
    ).then((_) {
      if (!mounted) return;

      // Use a new Builder to get fresh context
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);

      if (auth.isAuthenticated ||
          appState.selectedTabIndex != MainScreen.createRouteIndex) {
        setState(() {
          _isLoginDialogShown = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the ViewModel instance without listening (for actions)
    final viewModel = context.read<CreateRouteViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    // If user logs in while this screen is visible, and dialog was shown, reset flag
    if (authViewModel.isAuthenticated && _isLoginDialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isLoginDialogShown) {
          setState(() {
            _isLoginDialogShown = false;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Route')),
      body: Stack(
        // Use Stack for layering
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Allow scrolling for long lists/small screens
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Route Name Input ---
                  Selector<CreateRouteViewModel, bool>(
                    selector: (_, vm) => vm.isNameValid,
                    builder: (context, isNameValid, _) {
                      return TextField(
                        controller: viewModel.nameController,
                        // The ViewModel now listens to this controller internally
                        // and calls notifyListeners() when the text changes.
                        decoration: InputDecoration(
                          labelText: 'Route Name*',
                          hintText: 'Enter the name for your route',
                          errorText:
                              viewModel.nameController.text.isNotEmpty &&
                                      !isNameValid
                                  ? 'Route name cannot be empty'
                                  : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Route Description Input ---
                  TextField(
                    controller: viewModel.descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter an optional description',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // --- Location Selection Title ---
                  Text(
                    'Select Locations (at least 2)*',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),

                  // --- Accordion Section ---
                  Selector<
                    CreateRouteViewModel,
                    Tuple3<
                      bool,
                      String?,
                      Map<String, List<SelectableLocationDto>>
                    >
                  >(
                    selector:
                        (_, vm) => Tuple3(
                          vm.isLoading,
                          vm.locationLoadingError,
                          vm.groupedLocations,
                        ),
                    builder: (context, data, _) {
                      final isLoading = data.item1;
                      final locationLoadingError = data.item2;
                      final groupedLocations = data.item3;
                      // Use the new widget
                      return LocationAccordionSelector(
                        isLoading: isLoading,
                        error: locationLoadingError,
                        groupedLocations: groupedLocations,
                        viewModel: viewModel,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ---Save Button ---
                  Center(
                    child: Selector<CreateRouteViewModel, bool>(
                      selector: (_, vm) => vm.canSave,
                      builder: (context, canSave, _) {
                        return ElevatedButton(
                          onPressed: canSave ? viewModel.attemptSave : null,
                          child: const Text('Save Route'),
                        );
                      },
                    ),
                  ),

                  // --- Validation message ---
                  Selector<CreateRouteViewModel, String?>(
                    selector: (_, vm) => vm.validationSummary,
                    builder: (context, validationSummary, _) {
                      if (validationSummary != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Text(
                              validationSummary,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ), // Closes Column
            ), // Closes SingleChildScrollView
          ), // Closes Padding
          // --- Error/Success Feedback Handler ---
          Selector<CreateRouteViewModel, Tuple3<String?, bool, RouteDto?>>(
            selector:
                (_, vm) => Tuple3(
                  vm.routeSaveError,
                  vm.saveSuccess,
                  vm.newlyCreatedRoute,
                ),
            builder: (context, data, _) {
              final routeSaveError = data.item1;
              final saveSuccess = data.item2;
              final newlyCreatedRoute = data.item3;

              // Handle error feedback
              if (routeSaveError != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    FeedbackUtil.showErrorSnackbar(context, routeSaveError);
                    viewModel.clearRouteSaveError();
                  }
                });
              }

              // Handle success feedback
              if (saveSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    FeedbackUtil.showSuccessSnackbar(
                      context,
                      'Route created successfully!',
                      actionLabel:
                          newlyCreatedRoute != null ? 'View Route' : 'OK',
                      onActionPressed:
                          newlyCreatedRoute != null
                              ? () {
                                // TODO: Navigate to route details screen
                                debugPrint(
                                  'Navigate to route: ${newlyCreatedRoute.routeId}',
                                );
                              }
                              : null,
                    );
                    viewModel.clearSuccess();
                  }
                });
              }

              return const SizedBox.shrink();
            },
          ),

          // --- Loading Overlay ---
          Selector<CreateRouteViewModel, bool>(
            selector: (_, vm) => vm.isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Creating route...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // --- Authentication Overlay ---
          if (!authViewModel.isAuthenticated)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
        ], // Closes Stack children
      ), // Closes Stack widget
    ); // Closes Scaffold
  }
}
