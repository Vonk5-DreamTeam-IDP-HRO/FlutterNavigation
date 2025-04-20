import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './home_viewmodel.dart';

/// HomeScreen: The View component for the home/route list feature.
/// Displays a list of saved routes fetched via [HomeViewModel].
/// Delegates user actions (view, edit) to the ViewModel.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Watch the HomeViewModel to rebuild when the list of routes or loading/error state changes.
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Routes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HomeViewModel>().fetchRoutes(),
            tooltip: 'Refresh Routes',
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
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
                title: Text(route.title),
                subtitle: Text(route.subtitle),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        /// Use read() in callbacks to trigger ViewModel actions.
                        context.read<HomeViewModel>().editRoute(route.id);
                      },
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8), // Spacing between buttons
                    TextButton(
                      onPressed: () {
                        context.read<HomeViewModel>().viewRoute(route.id);
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
