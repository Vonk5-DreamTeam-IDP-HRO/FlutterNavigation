import 'package:flutter/material.dart';
import 'package:osm_navigation/features/map/CesiumMapViewModel.dart';
import 'package:osm_navigation/features/map/cesium_map_screen.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/features/create_route/create_route_screen.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/Core/repositories/location/i_location_repository.dart';
import './saved_routes_viewmodel.dart';

/// SavedRoutesScreen: The View component for the saved routes list feature.
/// Displays a list of saved routes fetched via [SavedRoutesViewModel].
/// Delegates user actions (view, edit) to the ViewModel.
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
                title: Text(route.displayName),
                subtitle: Text(route.description),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        // Create the ViewModel, initialize for edit, then navigate
                        final locationRepo = Provider.of<ILocationRepository>(
                          // Explicit type
                          context,
                          listen: false,
                        );
                        final viewModel = CreateRouteViewModel(locationRepo);
                        viewModel.initializeForEdit(route);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider.value(
                                  value: viewModel,
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
                        // TODO: Pass route.id and modify CesiumMapViewModel to load the specific route
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider(
                                  create: (_) => CesiumMapViewModel(),
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
