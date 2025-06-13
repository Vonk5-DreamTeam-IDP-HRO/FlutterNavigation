import 'package:flutter/material.dart';
import 'package:osm_navigation/core/navigation/navigation.dart';
import 'package:osm_navigation/Core/services/secure_storage_service.dart';

class AppState extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  final _storage = SecureStorageService();
  
  int selectedTabIndex = MainScreen.homeIndex;
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Flag to track if we're initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppState() {
    _initDarkMode();
  }

  void _initDarkMode() {
    // Start with default value
    _isDarkMode = false;
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    try {
      final darkMode = await _storage.readValue(_darkModeKey);
      _isDarkMode = darkMode == 'true';
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dark mode preference: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveDarkMode(bool value) async {
    try {
      await _storage.writeValue(_darkModeKey, value.toString());
    } catch (e) {
      debugPrint('Error saving dark mode preference: $e');
    }
  }

  void changeTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveDarkMode(_isDarkMode);
  }
}
