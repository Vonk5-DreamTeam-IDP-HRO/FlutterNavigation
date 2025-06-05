import 'package:flutter/material.dart';
import 'package:osm_navigation/core/models/Location/SelectableLocation/selectable_location_dto.dart';
import 'package:provider/provider.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';

class LocationAccordionSelector extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Map<String, List<SelectableLocationDto>> groupedLocations;
  final CreateRouteViewModel viewModel;

  const LocationAccordionSelector({
    super.key,
    required this.isLoading,
    required this.error,
    required this.groupedLocations,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          'Error loading locations: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (groupedLocations.isEmpty) {
      return const Center(child: Text('No locations available.'));
    }

    return Accordion(
      maxOpenSections: groupedLocations.length,
      headerBackgroundColorOpened: Colors.black54,
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
      sectionClosingHapticFeedback: SectionHapticFeedback.light,
      scaleWhenAnimating: true,
      children: groupedLocations.entries.map((entry) {
        final category = entry.key;
        final locationsInCategory = entry.value;

        return AccordionSection(
          key: ValueKey(category),
          leftIcon: const Icon(Icons.location_city, color: Colors.white),
          header: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 200,
            child: ListView.builder(
              shrinkWrap: false,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: locationsInCategory.length,
              itemBuilder: (context, index) {
                final location = locationsInCategory[index];
                return Selector<CreateRouteViewModel, bool>(
                  selector: (_, vm) => vm.selectedLocationIds.contains(location.locationId),
                  builder: (context, isSelected, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text(location.name),
                            value: isSelected,
                            onChanged: (bool? selected) {
                              if (selected != null) {
                                viewModel.toggleLocationSelection(location.locationId);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Edit Location'),
                                  content: const Text('Edit location functionality will be implemented here.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Location'),
                                  content: Text('Are you sure you want to delete ${location.name}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Implement delete functionality
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
