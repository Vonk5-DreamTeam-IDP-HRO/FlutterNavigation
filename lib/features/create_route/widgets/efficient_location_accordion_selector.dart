// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:accordion/accordion.dart';
// import 'package:accordion/controllers.dart';
// import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';

// /// Efficient location accordion that loads data on demand when sections are expanded
// class EfficientLocationAccordionSelector extends StatefulWidget {
//   final bool isLoading;
//   final String? error;
//   final CreateRouteViewModel viewModel;

//   const EfficientLocationAccordionSelector({
//     super.key,
//     required this.isLoading,
//     required this.error,
//     required this.viewModel,
//   });

//   @override
//   State<EfficientLocationAccordionSelector> createState() =>
//       _EfficientLocationAccordionSelectorState();
// }

// class _EfficientLocationAccordionSelectorState
//     extends State<EfficientLocationAccordionSelector> {
//   @override
//   Widget build(BuildContext context) {
//     if (widget.isLoading) {
//       // Use widget.isLoading
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading categories...'),
//           ],
//         ),
//       );
//     }

//     if (widget.error != null) {
//       // Use widget.error
//       return Center(
//         child: Text(
//           'Error loading locations: ${widget.error}',
//           style: TextStyle(color: Theme.of(context).colorScheme.error),
//         ),
//       );
//     }

//     return Consumer<CreateRouteViewModel>(
//       builder: (context, vm, child) {
//         if (vm.availableCategories.isEmpty) {
//           return const Center(child: Text('No categories available.'));
//         }

//         String? categoryToOpenJustNow = vm.categoryToOpenAfterLoad;
//         if (categoryToOpenJustNow != null) {
//           // Clear the flag immediately after reading it for this build cycle
//           // Use addPostFrameCallback to ensure it's cleared after the build.
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             vm.clearCategoryToOpen();
//           });
//         }

//         return SingleChildScrollView(
//           child: Accordion(
//             key: ValueKey('accordion_${categoryToOpenJustNow ?? "default"}'),
//             maxOpenSections: 3,
//           openAndCloseAnimation: true,
//           headerBackgroundColorOpened: Colors.black54,
//           headerPadding: const EdgeInsets.symmetric(
//             vertical: 7,
//             horizontal: 15,
//           ),
//           sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
//           sectionClosingHapticFeedback: SectionHapticFeedback.light,
//           children:
//               vm.availableCategories.map((category) {
//                 bool shouldBeOpen = category == categoryToOpenJustNow;
//                 return AccordionSection(
//                   key: ValueKey(category),
//                   isOpen: shouldBeOpen, // Control isOpen state here
//                   leftIcon: const Icon(
//                     Icons.location_city,
//                     color: Colors.white,
//                   ),
//                   header: Text(
//                     category,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   content: _buildCategoryContent(
//                     category,
//                     vm,
//                   ), // vm is from Consumer
//                   contentHorizontalPadding: 20,
//                   contentBorderWidth: 1,
//                   onOpenSection: () {
//                     if (!vm.isCategoryLoaded(category)) {
//                       vm.loadLocationsByCategory(
//                         category,
//                         triggeredByButton: false,
//                       );
//                     }
//                   },
//                 );
//               }).toList(),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCategoryContent(String category, CreateRouteViewModel vm) {
//     // vm is passed from the Consumer, no need for widget.viewModel here
//     if (!vm.isCategoryLoaded(category)) {
//       if (vm.isLoadingCategory && vm.categoryToOpenAfterLoad == category) {
//         // Check if this specific category is being loaded due to button press
//         return const Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 8),
//                 Text('Loading locations...'),
//               ],
//             ),
//           ),
//         );
//       } else {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Center(
//             child: ElevatedButton(
//               onPressed:
//                   () => vm.loadLocationsByCategory(
//                     category,
//                     triggeredByButton: true,
//                   ),
//               child: Text('Load $category locations'),
//             ),
//           ),
//         );
//       }
//     }

//     final locations = vm.groupedLocations[category] ?? [];

//     if (locations.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(child: Text('No locations in this category')),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const ScrollPhysics(),
//       itemCount: locations.length,
//       itemBuilder: (context, index) {
//         final location = locations[index];
//         return Selector<CreateRouteViewModel, bool>(
//           selector:
//               (_, vm) => vm.selectedLocationIds.contains(location.locationId),
//           builder: (context, isSelected, _) {
//             return CheckboxListTile(
//               title: Text(location.name),
//               value: isSelected,
//               onChanged: (bool? selected) {
//                 if (selected != null) {
//                   vm.toggleLocationSelection(location.locationId);
//                 }
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
