import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  // --- State ---

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Initialization ---
  SettingsViewModel() {
    // --- Actions ---
  }
}
