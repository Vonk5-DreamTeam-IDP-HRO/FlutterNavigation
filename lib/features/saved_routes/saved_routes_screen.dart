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
        title: const Text('Saved Routes'),
        backgroundColor: const Color(0xFF00811F),
        foregroundColor: Colors.white,
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
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      );
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
      return Center(
        child: Text(
          'No saved routes found.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    // Display the list of routes
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: viewModel.routes.length,
      itemBuilder: (context, index) {
        final route = viewModel.routes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: Icon(
                  Icons.route_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32.0,
                ),
                title: Text(
                  route.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    route.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton.icon(
                      icon: Icon(
                        Icons.edit,
                        size: 18.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        'Edit',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        final locationRepo = Provider.of<ILocationRepository>(
                          context,
                          listen: false,
                        );
                        final viewModel = CreateRouteViewModel(locationRepo);
                        viewModel.initializeForEdit(route);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: viewModel,
                              child: const CreateRouteScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16.0),
                    TextButton.icon(
                      icon: Icon(
                        Icons.map,
                        size: 18.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        'View Route',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => CesiumMapViewModel(),
                              child: const CesiumMapScreen(),
                            ),
                          ),
                        );
                      },
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
