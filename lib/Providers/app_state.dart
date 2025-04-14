import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // Add any app-wide state here if needed
  bool _shouldShowRouteOnMap = false;

  bool get shouldShowRouteOnMap => _shouldShowRouteOnMap;

  void showRouteOnMap() {
    _shouldShowRouteOnMap = true;
    notifyListeners();
  }

  void routeShown() {
    _shouldShowRouteOnMap = false;
    notifyListeners();
  }
}
