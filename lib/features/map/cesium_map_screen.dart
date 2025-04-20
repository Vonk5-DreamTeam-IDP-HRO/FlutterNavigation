import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './CesiumMapViewModel.dart'; // Import the ViewModel

/// CesiumMapScreen: The View component for the 3D map feature.
///
/// This widget is implemented as a StatelessWidget according to MVVM principles.
/// It observes state changes from [CesiumMapViewModel] and delegates user interactions
/// back to the ViewModel.
class CesiumMapScreen extends StatelessWidget {
  const CesiumMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel for state changes
    final viewModel = context.watch<CesiumMapViewModel>();

    // Use a listener for showing SnackBars based on ViewModel errors
    // This avoids passing context directly into the ViewModel
    // We use addPostFrameCallback to ensure the build is complete before showing SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.errorMessage != null && ModalRoute.of(context)?.isCurrent == true) {
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
                  onPressed: () => context.read<CesiumMapViewModel>().moveCameraToHome(),
                  tooltip: 'Go to Home View',
                  child: const Icon(Icons.home),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'refresh_3d', // Ensure unique heroTags
                  onPressed: () => context.read<CesiumMapViewModel>().reloadWebView(),
                  tooltip: 'Refresh Map',
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'valhalla_route_3d', // Ensure unique heroTags
                  onPressed: () => context.read<CesiumMapViewModel>().loadAndDisplayRoute(),
                  tooltip: 'Load Valhalla Route',
                  child: viewModel.isLoadingRoute
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.route),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
