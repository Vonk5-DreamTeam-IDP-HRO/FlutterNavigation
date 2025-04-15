import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:osm_navigation/core/providers/app_state.dart'; // Updated path
import 'package:osm_navigation/features/home/home_screen.dart';
import 'package:osm_navigation/features/map/map_screen.dart';
import 'package:osm_navigation/features/save/save_screen.dart';
import 'package:osm_navigation/features/setting/setting_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Private static key to avoid exposing private type in public API
  static final GlobalKey<_MainScreenState> _mainScreenKey =
      GlobalKey<_MainScreenState>();

  // Define constants here for static access
  static const int homeIndex = 0;
  static const int saveIndex = 1;
  static const int createRouteIndex = 2; // Placeholder index
  static const int mapIndex = 3;
  static const int settingsIndex = 4;

  // Static method to get the widget instance with the correct key
  static MainScreen instance() {
    return MainScreen(key: _mainScreenKey);
  }

  // Static method to navigate to the map tab from anywhere
  static void navigateToMapTab(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.showRouteOnMap();

    // Use the defined constant for clarity
    _mainScreenKey.currentState?.navigateToTab(mapIndex);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Use the constants defined in the parent widget
  int _selectedIndex = MainScreen.homeIndex;

  // Constants are defined in the MainScreen class above

  List<Widget> get _screens => [
        const HomeScreen(),
        const SaveScreen(),
        const Scaffold(
            body: Center(child: Text('Create Route Screen'))), // Placeholder
        const MapScreen(),
        const SettingsScreen(),
      ];

  void navigateToTab(int index) {
    // Add bounds check if necessary
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to show the route immediately after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      // Access constants via MainScreen class
      if (appState.shouldShowRouteOnMap &&
          _selectedIndex == MainScreen.mapIndex) {
        // Potentially trigger something in MapScreen or handle state differently
        print('Navigated to Map tab, should show route flag is set.');
        appState.routeShown(); // Reset the flag after checking
      }
    });

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Use the navigateToTab method for consistency
          navigateToTab(index);
        },
        items: const [
          // Use constants for labels/icons if desired later
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Save',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_road), // Changed icon
            label: 'Create Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings' // Corrected label casing
              )
        ],
      ),
    );
  }
}
