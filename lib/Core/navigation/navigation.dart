import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/features/home/home_screen.dart';
import 'package:osm_navigation/features/map/map_screen.dart';
import 'package:osm_navigation/features/map/cesium_map_screen.dart'; // Updated import path
import 'package:osm_navigation/features/setting/setting_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Define constants here for static access if needed elsewhere,
  // otherwise they can be moved or removed if only used locally.
  static const int homeIndex = 0;
  static const int saveIndex = 1;
  static const int createRouteIndex = 2; // Placeholder index
  static const int mapIndex = 3;
  static const int settingsIndex = 4;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const CesiumMapScreen(), // Updated class name
    const Scaffold(
      body: Center(child: Text('Create Route Screen')),
    ), // Placeholder
    const MapScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch AppState to rebuild when selectedTabIndex changes
    final appState = context.watch<AppState>();
    final currentIndex = appState.selectedTabIndex; // Use correct variable name


    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          // Call AppState method to change tab
          context.read<AppState>().changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: '3D Map'), // Updated label and icon
          BottomNavigationBarItem(
            icon: Icon(Icons.add_road),
            label: 'Create Route',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
