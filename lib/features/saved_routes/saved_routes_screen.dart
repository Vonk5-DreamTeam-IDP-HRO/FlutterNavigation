library saved_routes_screen;

import 'package:flutter/material.dart';
import 'package:osm_navigation/core/repositories/Route/route_repository.dart';
import 'package:osm_navigation/core/services/route/route_api_service.dart';
import 'package:osm_navigation/features/map/cesium_map_viewmodel.dart';
import 'package:osm_navigation/features/map/cesium_map_screen.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/features/create_route/create_route_screen.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/core/repositories/Location/location_repository.dart';
import 'package:osm_navigation/core/services/location/location_api_service.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
import './saved_routes_viewmodel.dart';

/// **SavedRoutesScreen**
///
/// A screen that displays and manages saved navigation routes with options
/// to view routes in 3D and edit route details.
///
/// **Purpose:**
/// Provides a centralized view of all saved routes with actions for viewing
/// and managing route data.
///
/// **Key Features:**
/// - List view of saved routes
/// - Route editing capability
/// - 3D route visualization
/// - Pull-to-refresh functionality
/// - Loading and error states
///
/// **Dependencies:**
/// - SavedRoutesViewModel: For state management
/// - CesiumMapViewModel: For 3D route visualization
/// - CreateRouteViewModel: For route editing
///
/// **Usage:**
/// ```dart
/// ChangeNotifierProvider(
///   create: (context) => SavedRoutesViewModel(repository),
///   child: SavedRoutesScreen(),
/// )
/// ```
///

class SavedRoutesScreen extends StatelessWidget {
  const SavedRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the SavedRoutesViewModel to rebuild when the list of routes or loading/error state changes.
    final viewModel = context.watch<SavedRoutesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Routes'), // Title matches task
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SavedRoutesViewModel>().fetchRoutes(),
            tooltip: 'Refresh Routes',
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
    );
  }

  /// Builds the main content of the screen based on the current state.
  ///
  /// Handles different states:
  /// - Loading: Shows progress indicator
  /// - Error: Displays error message
  /// - Empty: Shows "No routes" message
  /// - Success: Displays route list
  ///
  /// Parameters:
  /// - [context]: Build context for theming and dependencies
  /// - [viewModel]: Current state of saved routes
  Widget _buildBody(BuildContext context, SavedRoutesViewModel viewModel) {
    // Display loading indicator
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Display error message
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: ${viewModel.errorMessage}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Display message if no routes are available
    if (viewModel.routes.isEmpty) {
      return const Center(child: Text('No saved routes found.'));
    }

    // Display the list of routes
    // TODO: Create & Add resuable widget for route item
    return ListView.builder(
      itemCount: viewModel.routes.length,
      itemBuilder: (context, index) {
        final route = viewModel.routes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.route_outlined),
                title: Text(route.name),
                subtitle: Text(route.description ?? 'No description'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        // Create the repository and viewmodel for editing
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider.value(
                                      value: context.read<AppState>(),
                                    ),
                                    ChangeNotifierProvider(
                                      create: (context) {
                                        final dio = context.read<Dio>();
                                        final authViewModel =
                                            context.read<AuthViewModel>();
                                        final locationApiService =
                                            LocationApiService(dio);
                                        final locationRepository =
                                            LocationRepository(
                                              locationApiService,
                                            );
                                        final routeApiService = RouteApiService(
                                          dio,
                                        );
                                        final routeRepository = RouteRepository(
                                          routeApiService,
                                        );

                                        final createRouteViewModel =
                                            CreateRouteViewModel(
                                              routeRepository,
                                              locationRepository,
                                            );
                                        createRouteViewModel.initializeForEdit(
                                          route,
                                        );
                                        return createRouteViewModel;
                                      },
                                    ),
                                  ],
                                  child: const CreateRouteScreen(),
                                ),
                          ),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8), // Spacing between buttons
                    TextButton(
                      onPressed: () {
                        // Navigate to the Cesium 3D Map screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider(
                                  create:
                                      (context) => CesiumMapViewModel(
                                        RouteApiService(context.read<Dio>()),
                                      )..loadAndDisplayRoute(route.routeId),
                                  child: const CesiumMapScreen(),
                                ),
                          ),
                        );
                      },
                      child: const Text('View Route'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
