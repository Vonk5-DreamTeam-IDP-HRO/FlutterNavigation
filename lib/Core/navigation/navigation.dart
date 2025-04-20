import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/features/home/new_home_screen.dart';
import 'package:osm_navigation/features/saved_routes/saved_routes_screen.dart';
import 'package:osm_navigation/features/create_route/create_route_screen.dart';
import 'package:osm_navigation/features/map/map_screen.dart';
import 'package:osm_navigation/features/map/map_viewmodel.dart';
import 'package:osm_navigation/features/setting/setting_screen.dart';
import 'package:osm_navigation/features/home/new_home_viewmodel.dart';
import 'package:osm_navigation/features/saved_routes/saved_routes_viewmodel.dart';
import 'package:osm_navigation/features/saved_routes/services/route_api_service.dart'; // Import the service
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/features/setting/setting_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Define constants here for static access if needed elsewhere,
  // otherwise they can be moved or removed if only used locally.
  static const int homeIndex = 0;
  static const int saveIndex = 1;
  static const int createRouteIndex = 2;
  static const int mapIndex = 3;
  static const int settingsIndex = 4;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// Provide the MapViewModel specifically to the MapScreen subtree.
/// This creates a new MapViewModel instance when MainScreen builds.
class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    // 0: Home Screen
    ChangeNotifierProvider(
      create: (_) => NewHomeViewModel(),
      child: const NewHomeScreen(),
    ),

    // 1: Saved Routes Screen
    ChangeNotifierProvider(
      // Create the ApiService and pass it to the ViewModel
      // Instantiate the service here to ensure it's available for the ViewModel
      create: (_) => SavedRoutesViewModel(
        apiService: RouteApiService(), 
      ),
      child: const SavedRoutesScreen(),
    ),

    // 2: Create Route Screen
    ChangeNotifierProvider(
      create: (_) => CreateRouteViewModel(),
      child: const CreateRouteScreen(),
    ),

    // 3: Map Screen (2D Map)
    ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: const MapScreen(),
    ),

    // 4: Settings Screen
    ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const SettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch AppState to rebuild when selectedTabIndex changes
    final appState = context.watch<AppState>();
    final currentIndex = appState.selectedTabIndex;

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
          // 0: Home
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          // 1: Save routes
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt_outlined),
            label: 'Save routes',
          ), // Changed icon and label
          // 2: Create Route
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outline,
            ), // Using a standard add icon for now
            label: 'Create Route',
          ),
          // 3: Show Map
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Show Map',
          ), // Changed label, adjusted icon
          // 4: Settings
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
