import 'package:flutter/material.dart';
import 'package:osm_navigation/core/navigation/navigation.dart'; // Corrected case

class AppState extends ChangeNotifier {
  int selectedTabIndex = MainScreen.homeIndex;

  // Method to change the selected tab
  void changeTab(int index) {
    selectedTabIndex = index;
    notifyListeners(); // Notify listeners to rebuild UI based on the new index
  }
}
