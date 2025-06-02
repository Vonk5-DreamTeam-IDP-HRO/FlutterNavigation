import 'package:flutter/material.dart';
import 'package:osm_navigation/core/navigation/navigation.dart'; // Corrected case

class AppState extends ChangeNotifier {
  int selectedTabIndex = MainScreen.homeIndex;
  bool isDarkMode = false;

  // Method to change the selected tab
  void changeTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  // Method to toggle dark mode
  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
