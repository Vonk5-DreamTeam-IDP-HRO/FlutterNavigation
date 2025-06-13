import 'package:flutter/gestures.dart';
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
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          'Error loading locations: $error',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }

    if (groupedLocations.isEmpty) {
      return const Center(child: Text('No locations available.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: groupedLocations.entries.map((entry) {
                final category = entry.key;
                final locationsInCategory = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        key: ValueKey(category),
                        collapsedBackgroundColor: const Color(0xFF00811F),
                        backgroundColor: const Color.fromARGB(255, 0, 75, 18),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        leading: const Icon(Icons.location_city, color: Colors.white),
                        title: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Container(
                            color: Colors.white,
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.3,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: locationsInCategory.length,
                              itemBuilder: (context, index) {
                                final location = locationsInCategory[index];
                                return Selector<CreateRouteViewModel, bool>(
                                  selector: (_, vm) =>
                                      vm.selectedLocationIds.contains(location.locationId),
                                  builder: (context, isSelected, _) {
                                    return CheckboxListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 16),
                                      title: Text(
                                        location.name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      value: isSelected,
                                      onChanged: (bool? selected) {
                                        if (selected != null) {
                                          viewModel.toggleLocationSelection(location.locationId);
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
