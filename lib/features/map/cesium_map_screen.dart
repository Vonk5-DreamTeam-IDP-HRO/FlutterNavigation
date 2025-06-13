library cesium_map_screen;

import 'package:flutter/material.dart';
import 'package:osm_navigation/features/map/cesium_map_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// **CesiumMapScreen Widget**
///
/// A screen widget that displays a 3D map of Rotterdam using Cesium.js through
/// WebView integration.
///
/// **Purpose:**
/// Provides an interactive 3D map interface with route display capabilities
/// while following MVVM architecture principles.
///
/// **Key Features:**
/// - 3D map display using Cesium.js
/// - Loading state management
/// - Error handling with SnackBar feedback
/// - Navigation controls (home view, refresh)
/// - Route visualization
///
/// **Usage:**
/// ```dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(
///       create: (context) => CesiumMapViewModel(routeApiService),
///     ),
///   ],
///   child: const CesiumMapScreen(),
/// )
/// ```
///
/// **Dependencies:**
/// - `CesiumMapViewModel`: For state management
/// - `WebView`: For Cesium integration
/// - `Provider`: For state observation
///

/// Widget implementation for the 3D map screen.
///
/// This widget observes [CesiumMapViewModel] for state changes and renders
/// the appropriate UI components based on the current state.
class CesiumMapScreen extends StatelessWidget {
  /// Creates a CesiumMapScreen widget.
  ///
  /// The widget automatically connects to its corresponding ViewModel through
  /// the Provider package, requiring a [CesiumMapViewModel] ancestor in the
  /// widget tree.
  const CesiumMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel for state changes
    final viewModel = context.watch<CesiumMapViewModel>();

    // Use a listener for showing SnackBars based on ViewModel errors
    // This avoids passing context directly into the ViewModel
    // We use addPostFrameCallback to ensure the build is complete before showing SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.errorMessage != null &&
          ModalRoute.of(context)?.isCurrent == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
        // TODO: Add a method to ViewModel to clear the error message after it's shown
        // viewModel.clearErrorMessage();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Rotterdam 3D Viewer (MVVM)')),
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
                if (viewModel.isLoadingRoute) const SizedBox(height: 8),
                if (viewModel.isLoadingRoute)
                  const FloatingActionButton(
                    heroTag: 'loading_route',
                    onPressed: null,
                    tooltip: 'Loading Route...',
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
