import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:osm_navigation/Core/repositories/Route/route_repository.dart';
import 'package:osm_navigation/Core/repositories/location/location_repository.dart';
import 'package:osm_navigation/Core/services/route/route_api_service.dart';
import 'package:osm_navigation/features/create_location/Services/Photon.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/Core/providers/app_state.dart';
import 'package:osm_navigation/features/home/new_home_screen.dart';
import 'package:osm_navigation/features/saved_routes/saved_routes_screen.dart';
import 'package:osm_navigation/features/create_route/create_route_screen.dart';
import 'package:osm_navigation/features/map/map_screen.dart';
import 'package:osm_navigation/features/map/map_viewmodel.dart';
import 'package:osm_navigation/features/setting/setting_screen.dart';
import 'package:osm_navigation/features/home/new_home_viewmodel.dart';
import 'package:osm_navigation/features/saved_routes/saved_routes_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/services/location/location_api_service.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/features/setting/setting_viewmodel.dart';
import 'package:osm_navigation/features/create_location/create_location_screen.dart';
import 'package:osm_navigation/features/create_location/create_location_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Define constants here for static access if needed elsewhere,
  // otherwise they can be moved or removed if only used locally.
  static const int homeIndex = 0;
  static const int saveIndex = 1;
  static const int createRouteIndex =
      2; // This tab will now activate the SpeedDial
  static const int mapIndex = 3;
  static const int settingsIndex = 4;
  // static const int createLocationIndex = 5; // Not directly navigable via BottomNavBar

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Provide the MapViewModel specifically to the MapScreen subtree.
// This creates a new MapViewModel instance when MainScreen builds.
class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  // Added TickerProviderStateMixin
  final ValueNotifier<bool> _isDialOpen = ValueNotifier(false);

  @override
  void dispose() {
    _isDialOpen.dispose();
    super.dispose();
  }

  // The CreateLocationScreen is added here to be available in the IndexedStack,
  // but it will be navigated to programmatically, not via direct BottomNavBar tap.
  final List<Widget> _screens = [
    // 0: Home Screen
    ChangeNotifierProvider(
      create: (_) => NewHomeViewModel(),
      child: const NewHomeScreen(),
    ),

    // 1: Saved Routes Screen
    ChangeNotifierProvider(
      create: (context) {
        final dio =
            context.read<Dio>(); // Get the Dio instance from the context
        final routeApiService = RouteApiService(
          dio,
        ); // Create the RouteApiService and pass on the Dio instance
        final routeRepository = RouteRepository(routeApiService);
        return SavedRoutesViewModel(routeRepository: routeRepository);
      },
      child: const SavedRoutesScreen(),
    ), // 2: Create Route Screen (This is one of the SpeedDial targets)
    ChangeNotifierProvider(
      create: (context) {
        final locationApiService = LocationApiService(context.read<Dio>());
        final locationRepository = LocationRepository(locationApiService);
        return CreateRouteViewModel(locationRepository);
      },
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
    ),    // 5: Create Location Screen (This is another SpeedDial target)
    // This screen is part of the stack but not directly mapped to a BottomNavBar item.
    ChangeNotifierProvider(
      create: (context) {
        final locationApiService = LocationApiService(context.read<Dio>());
        final locationRepository = LocationRepository(locationApiService);
        return CreateLocationViewModel(
          locationRepository: locationRepository,
          photonService: context.read<PhotonService>(),
        );
      },
      child: const CreateLocationScreen(),
    ),
  ];

  // Removed _navigateToScreen as logic is now inline or handled by direct navigation
  // _showCreateMenu method removed

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentIndex = appState.selectedTabIndex;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      floatingActionButtonLocation:
          FloatingActionButtonLocation
              .miniEndFloat, // Center the FAB (SpeedDial base)
      floatingActionButton: SpeedDial(
        // SpeedDial is now always in the widget tree
        // icon: Icons.add, // Removed to make main button invisible
        // activeIcon: Icons.close, // Removed
        openCloseDial: _isDialOpen,
        // backgroundColor: Colors.transparent, // Make background transparent
        // foregroundColor: Colors.transparent,
        // activeBackgroundColor: Colors.transparent,
        // activeForegroundColor: Colors.transparent,
        dialRoot: (ctx, open, toggleChildren) {
          // This custom dialRoot makes the main button effectively invisible
          // and non-interactive directly. The open/close state is controlled
          // by _isDialOpen, which is toggled by the BottomNavigationBar.
          // 'open' boolean indicates if SpeedDial children are currently visible.
          // 'toggleChildren' can be called to programmatically toggle, but we use _isDialOpen.
          return const SizedBox.shrink(); // Invisible and takes no space
        },
        visible:
            true, // The SpeedDial widget itself needs to be in the tree to manage children
        direction: SpeedDialDirection.up,
        switchLabelPosition: false,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => debugPrint('SPEED DIAL CHILDREN OPENED'),
        onClose: () => debugPrint('SPEED DIAL CHILDREN CLOSED'),
        tooltip: 'Create Options',
        heroTag:
            'speed-dial-hero-tag', // Still good for animations if any part animates
        elevation: 0.0, // No elevation for the (now invisible) main button
        // shape: const CircleBorder(), // Shape of invisible button doesn't matter
        // The children will only be visible if _isDialOpen is true,
        // which is controlled by tapping the "Create" BottomNavigationBarItem.
        children: [
          SpeedDialChild(
            child: const Icon(Icons.route),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'Create Route',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChangeNotifierProvider(
                        create: (context) {
                          // Logic to create CreateRouteViewModel, similar to _screens setup
                          final dio = context.read<Dio>();
                          final locationApiService = LocationApiService(dio);
                          final locationRepository = LocationRepository(
                            locationApiService,
                          );
                          return CreateRouteViewModel(locationRepository);
                        },
                        child: const CreateRouteScreen(),
                      ),
                ),
              );
              _isDialOpen.value = false; // Close dial
              debugPrint('Create Route tapped - Pushed as new route');
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_location_alt_outlined),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: 'Create Location',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChangeNotifierProvider(
                        create: (context) {
                          final locationApiService = LocationApiService(
                            context.read<Dio>(),
                          );
                          final locationRepository = LocationRepository(
                            locationApiService,
                          );
                          return CreateLocationViewModel(
                            locationRepository: locationRepository,
                            photonService: PhotonService(),
                          );
                        },
                        child: const CreateLocationScreen(),
                      ),
                ),
              );
              _isDialOpen.value = false; // Close dial
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == MainScreen.createRouteIndex) {
            // Tapped on the "Create" button - ONLY toggle dial visibility
            _isDialOpen.value = !_isDialOpen.value;
          } else {
            // Tapped on any other button
            if (_isDialOpen.value) {
              _isDialOpen.value = false; // Close dial children if open
            }
            context.read<AppState>().changeTab(
              index,
            ); // Switch to the tapped tab
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt_outlined),
            label: 'Save routes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create', // Changed label to be more generic for Speed Dial
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Show Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
