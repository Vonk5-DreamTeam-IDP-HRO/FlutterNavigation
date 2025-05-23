import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:osm_navigation/Core/models/selectable_location.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';

/// Widget responsible for displaying the location selection accordion.
class LocationAccordionSelector extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Map<String, List<SelectableLocation>> groupedLocations;
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

    // Build the Accordion
    return Accordion(
      maxOpenSections: groupedLocations.length,
      headerBackgroundColorOpened: Colors.black54,
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
      sectionClosingHapticFeedback: SectionHapticFeedback.light,
      children:
          groupedLocations.entries.map((entry) {
            final category = entry.key;
            final locationsInCategory = entry.value;

            return AccordionSection(
              key: ValueKey(category), // Keep the key
              // isOpen state is managed internally by Accordion now
              leftIcon: const Icon(Icons.location_city, color: Colors.white),
              header: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locationsInCategory.length,
                itemBuilder: (context, index) {
                  final location = locationsInCategory[index];
                  // Use Selector for the Checkbox state only
                  // Note: Selector needs access to the ViewModel provided higher up the tree
                  return Selector<CreateRouteViewModel, bool>(
                    selector:
                        (_, vm) => vm.selectedLocationIds.contains(
                          location.locationId,
                        ),
                    builder: (context, isSelected, _) {
                      return CheckboxListTile(
                        title: Text(location.name),
                        value: isSelected,
                        onChanged: (bool? selected) {
                          if (selected != null) {
                            // Use the viewModel instance passed to this widget
                            viewModel.toggleLocationSelection(
                              location.locationId,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
              contentHorizontalPadding: 20,
              contentBorderWidth: 1,
            );
          }).toList(),
    );
  }
}
