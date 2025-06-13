/// **NewHomeViewModel.dart**
///
/// **Purpose:**
/// Serves as the state management and business logic handler for the home screen.
///
/// **Usage:**
/// Used by NewHomeScreen to manage any future state or business logic that may
/// be needed for the home screen functionality.
///
/// **Key Features:**
/// - Basic loading state management
/// - Error message handling
/// - Expandable for future home screen features
///
/// **Dependencies:**
/// - `ChangeNotifier`: For state management notifications
///
/// **workflow:**
/// ```
/// 1. Initialize basic state
/// 2. Manage loading states
/// 3. Handle potential errors
/// ```
///

library new_home_viewmodel;

import 'package:flutter/material.dart';

class NewHomeViewModel extends ChangeNotifier {
  // --- State ---

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Initialization ---
  NewHomeViewModel() {
    // Initial setup if needed
  }
}
