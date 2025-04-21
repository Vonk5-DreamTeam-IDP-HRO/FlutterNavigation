import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'cesium_map_viewmodel.dart'; // Import the ViewModel

/// CesiumMapScreen: The View component for the 3D map feature.
///
/// This widget is implemented as a StatelessWidget according to MVVM principles.
/// It observes state changes from [CesiumMapViewModel] and delegates user interactions
/// back to the ViewModel.
class CesiumMapScreen extends StatelessWidget {
  final int routeId;
  const CesiumMapScreen({required this.routeId, super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel for state changes
    final viewModel = context.watch<CesiumMapViewModel>();

    // Use a listener for showing SnackBars based on ViewModel errors
    // This avoids passing context directly into the ViewModel
    // We use addPostFrameCallback to ensure the build is complete before showing SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext = context; // Capture context
      if (!currentContext.mounted) return; // Check if widget is still mounted

      // Handle general WebView/Cesium errors
      if (viewModel.errorMessage != null &&
          ModalRoute.of(currentContext)?.isCurrent == true) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Map Error: ${viewModel.errorMessage!}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }

      // Handle specific location loading errors
      if (viewModel.locationsErrorMessage != null &&
          ModalRoute.of(currentContext)?.isCurrent == true) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Route Error: ${viewModel.locationsErrorMessage!}'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    });

    return Scaffold(
      // Update AppBar title dynamically if needed, e.g., show route name
      appBar: AppBar(title: Text('Route $routeId')),
      body: Stack(
        children: [
          // Display the WebView, controller sourced from ViewModel
          WebViewWidget(controller: viewModel.webViewController),

          // Loading indicator based on ViewModel state
          if (!viewModel.isCesiumReady)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading 3D map...'),
                ],
              ),
            ),

          // Combined loading indicator for fetching locations and calculating route path
          if (viewModel.isLoadingLocations || viewModel.isLoadingRoute)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.isLoadingLocations
                            ? 'Loading route locations...'
                            : 'Calculating route path...', // Show different text based on state
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Navigation controls - delegate actions to ViewModel
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'home_3d', // Ensure unique heroTags
                  onPressed:
                      () =>
                          context.read<CesiumMapViewModel>().moveCameraToHome(),
                  tooltip: 'Go to Home View',
                  child: const Icon(Icons.home),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'refresh_3d', // Ensure unique heroTags
                  onPressed:
                      () => context.read<CesiumMapViewModel>().reloadWebView(),
                  tooltip: 'Refresh Map',
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
