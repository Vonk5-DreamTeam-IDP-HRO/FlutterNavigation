// --- Import Statements ---

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'package:osm_navigation/core/utils/tuple.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/features/create_route/widgets/location_accordion_selector.dart';

// --- Class Definition ---
class CreateRouteScreen extends StatelessWidget {
  const CreateRouteScreen({super.key});

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Get the ViewModel instance without listening (for actions)
    final viewModel = context.read<CreateRouteViewModel>();

    // --- UI Elements ---
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Route')),
      body: Padding(
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
                    // Add listener directly to controller to trigger validation check
                    onChanged: (_) => viewModel.notifyListeners(),
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
                Tuple3<bool, String?, Map<String, List<SelectableLocation>>>
              >(
                selector:
                    (_, vm) =>
                        Tuple3(vm.isLoading, vm.error, vm.groupedLocations),
                builder: (context, data, _) {
                  final isLoading = data.item1;
                  final error = data.item2;
                  final groupedLocations = data.item3;
                  // Use the new widget
                  return LocationAccordionSelector(
                    isLoading: isLoading,
                    error: error,
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
              Selector<CreateRouteViewModel, Tuple2<bool, bool>>(
                selector:
                    (_, vm) => Tuple2(
                      vm.areLocationsValid,
                      vm.selectedLocationIds.isNotEmpty,
                    ),
                builder: (context, data, _) {
                  final areLocationsValid = data.item1;
                  final hasSelections = data.item2;
                  if (!areLocationsValid && hasSelections) {
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
    );
  }
}
