import 'package:flutter/material.dart';
import 'package:osm_navigation/core/navigation/navigation.dart'; // Corrected case

class AppState extends ChangeNotifier {
  int selectedTabIndex = MainScreen.homeIndex;

  // State for triggering route display on map
  bool _shouldShowRouteOnMap = false;
  bool get shouldShowRouteOnMap => _shouldShowRouteOnMap;

  void showRouteOnMap() {
    _shouldShowRouteOnMap = true;
    notifyListeners();
  }

  void routeShown() {
    _shouldShowRouteOnMap = false;
    // No need to notify listeners here if only the flag is reset internally
    // notifyListeners(); // Consider if this is needed
  }

  // Method to change the selected tab
  void changeTab(int index) {
    selectedTabIndex = index;
    notifyListeners(); // Notify listeners to rebuild UI based on the new index
  }
}
