// --- Import Statements ---

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'package:osm_navigation/core/utils/tuple.dart';
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
import 'package:osm_navigation/features/auth/screens/login_screen.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/features/create_route/widgets/location_accordion_selector.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/core/navigation/navigation.dart'; // For MainScreen.createRouteIndex

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
    // Listen to both AuthViewModel and AppState for changes
    final authViewModel = Provider.of<AuthViewModel>(context); 
    final appState = Provider.of<AppState>(context);

    bool shouldShowDialog = !authViewModel.isAuthenticated &&
                            appState.selectedTabIndex == MainScreen.createRouteIndex &&
                            !_isLoginDialogShown;

    if (shouldShowDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isLoginDialogShown) { // Check mounted & flag again before showing
          _showLoginDialog(context);
          if (mounted) { // Check mounted again before setState
            setState(() {
              _isLoginDialogShown = true;
            });
          }
        }
      });
    } else if ((authViewModel.isAuthenticated || appState.selectedTabIndex != MainScreen.createRouteIndex) && _isLoginDialogShown) {
      // If user is now authenticated OR navigated away from create tab, and dialog was shown, reset flag
      if (mounted) {
         setState(() {
           _isLoginDialogShown = false;
         });
      }
    }
  }

  void _showLoginDialog(BuildContext dialogContext) {
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to log in or register to create a route.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(alertContext).pop();
                if (mounted) {
                  setState(() { _isLoginDialogShown = false; });
                  // Optionally, navigate to home tab if user cancels
                  Provider.of<AppState>(context, listen: false).changeTab(MainScreen.homeIndex);
                }
              },
            ),
            ElevatedButton(
              child: const Text('Login / Register'),
              onPressed: () {
                Navigator.of(alertContext).pop();
                 if (mounted) {
                    setState(() { _isLoginDialogShown = false; });
                 }
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ));
              },
            ),
          ],
        );
      },
    ).then((_) {
      // After dialog is dismissed, ensure flag is reset if still needed
      if (mounted && _isLoginDialogShown) {
        final auth = Provider.of<AuthViewModel>(context, listen: false);
        final appState = Provider.of<AppState>(context, listen: false);
        // If still not authenticated and on create route tab, dialog might reappear
        // This logic ensures it's reset if conditions for showing are no longer met.
        if(auth.isAuthenticated || appState.selectedTabIndex != MainScreen.createRouteIndex) {
            setState(() { _isLoginDialogShown = false; });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CreateRouteViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    // If user logs in while this screen is visible, and dialog was shown, reset flag
    if (authViewModel.isAuthenticated && _isLoginDialogShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isLoginDialogShown) {
                 setState(() { _isLoginDialogShown = false; });
            }
        });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Route')),
      body: Stack(
        fit: StackFit.expand, // Ensure stack fills the body
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Selector<CreateRouteViewModel, bool>(
                    selector: (_, vm) => vm.isNameValid,
                    builder: (context, isNameValid, _) {
                      return TextField(
                        controller: viewModel.nameController,
                        onChanged: (_) => viewModel.notifyListeners(),
                        decoration: InputDecoration(
                          labelText: 'Route Name*',
                          hintText: 'Enter the name for your route',
                          errorText: viewModel.nameController.text.isNotEmpty && !isNameValid
                              ? 'Route name cannot be empty'
                              : null,
                        ),
                        enabled: authViewModel.isAuthenticated,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: viewModel.descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter an optional description',
                    ),
                    maxLines: 3,
                    enabled: authViewModel.isAuthenticated,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select Locations (at least 2)*',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  AbsorbPointer(
                    absorbing: !authViewModel.isAuthenticated,
                    child: Selector<
                        CreateRouteViewModel,
                        Tuple3<bool, String?, Map<String, List<SelectableLocation>>>>(
                      selector: (_, vm) => Tuple3(vm.isLoading, vm.error, vm.groupedLocations),
                      builder: (context, data, _) {
                        return LocationAccordionSelector(
                          isLoading: data.item1,
                          error: data.item2,
                          groupedLocations: data.item3,
                          viewModel: viewModel,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Selector<CreateRouteViewModel, bool>(
                      selector: (_, vm) => vm.canSave,
                      builder: (context, canSave, _) {
                        return ElevatedButton(
                          onPressed: authViewModel.isAuthenticated && canSave
                              ? viewModel.attemptSave
                              : null,
                          child: const Text('Save Route'),
                        );
                      },
                    ),
                  ),
                  Selector<CreateRouteViewModel, Tuple2<bool, bool>>(
                    selector: (_, vm) => Tuple2(
                      vm.areLocationsValid,
                      vm.selectedLocationIds.isNotEmpty,
                    ),
                    builder: (context, data, _) {
                      if (!data.item1 && data.item2) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Text(
                              'Please select at least 2 locations.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
          if (!authViewModel.isAuthenticated)
            Positioned.fill(
              child: AbsorbPointer( 
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Positioned.fill handles sizing
                ),
              ),
            ),
        ],
      ),
    );
  }
}
