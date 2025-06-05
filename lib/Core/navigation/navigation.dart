import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:osm_navigation/core/repositories/Route/route_repository.dart';
import 'package:osm_navigation/core/repositories/Location/location_repository.dart';
import 'package:osm_navigation/core/services/route/route_api_service.dart';
import 'package:osm_navigation/features/create_location/Services/Photon.dart';
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
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/services/location/location_api_service.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/features/setting/setting_viewmodel.dart';
import 'package:osm_navigation/features/create_location/create_location_screen.dart';
import 'package:osm_navigation/features/create_location/create_location_viewmodel.dart';
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
import 'package:osm_navigation/features/auth/screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const int homeIndex = 0;
  static const int saveIndex = 1;
  static const int createRouteIndex = 2;
  static const int mapIndex = 3;
  static const int settingsIndex = 4;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Provide the MapViewModel specifically to the MapScreen subtree.
// This creates a new MapViewModel instance when MainScreen builds.
class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final ValueNotifier<bool> _isDialOpen = ValueNotifier(false);

  @override
  void dispose() {
    _isDialOpen.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    // 0: Home Screen
    ChangeNotifierProvider(
      create: (_) => NewHomeViewModel(),
      child: const NewHomeScreen(),
    ), // 1: Saved Routes Screen
    ChangeNotifierProvider(
      create: (context) {
        final dio = context.read<Dio>();
        final routeApiService = RouteApiService(dio);
        final routeRepository = RouteRepository(routeApiService);
        return SavedRoutesViewModel(routeRepository: routeRepository);
      },
      child: const SavedRoutesScreen(),
    ),

    // 2: Empty placeholder for Create tab. When tapped, it opens the SpeedDial.
    // The user can choice to create a route or a location.
    const SizedBox.shrink(),

    // 3: Map Screen (3D Map)
    ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: const MapScreen(),
    ),

    // 4: Settings Screen
    Builder(
      builder: (context) => const SettingsScreen(),
    ),
  ];

  Future<void> _handleAuthenticatedAction(VoidCallback action) async {
    final authViewModel = context.read<AuthViewModel>();
    if (!authViewModel.isAuthenticated) {
      await LoginScreen.showAsDialog(context);
      if (!authViewModel.isAuthenticated) {
        _isDialOpen.value = false;
        return;
      }
    }
    action();
  }

  void _navigateToCreateRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: context.read<AppState>()),
                ChangeNotifierProvider(
                  create: (context) {
                    final dio = context.read<Dio>();
                    final authViewModel = context.read<AuthViewModel>();
                    final locationApiService = LocationApiService(dio);
                    final locationRepository = LocationRepository(
                      locationApiService,
                    );
                    final routeRepository = RouteRepository(
                      RouteApiService(dio),
                    );
                    return CreateRouteViewModel(
                      routeRepository,
                      locationRepository,
                    );
                  },
                ),
              ],
              child: const CreateRouteScreen(),
            ),
      ),
    );
    _isDialOpen.value = false;
  }

  void _navigateToCreateLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: context.read<AppState>()),
                ChangeNotifierProvider(
                  create: (context) {
                    final dio = context.read<Dio>();
                    final authViewModel = context.read<AuthViewModel>();
                    final locationApiService = LocationApiService(dio);
                    final locationRepository = LocationRepository(
                      locationApiService,
                    );
                    final photonService = context.read<PhotonService>();
                    return CreateLocationViewModel(
                      locationRepository: locationRepository,
                      photonService: photonService,
                    );
                  },
                ),
              ],
              child: const CreateLocationScreen(),
            ),
      ),
    );
    _isDialOpen.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentIndex = appState.selectedTabIndex;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: SpeedDial(
        openCloseDial: _isDialOpen,
        dialRoot: (ctx, open, toggleChildren) {
          // This custom dialRoot makes the main button effectively invisible
          // and non-interactive directly. The open/close state is controlled
          // by _isDialOpen, which is toggled by the BottomNavigationBar.
          // 'open' boolean indicates if SpeedDial children are currently visible.
          return const SizedBox.shrink();
        },
        visible: true,
        direction: SpeedDialDirection.up,
        switchLabelPosition: false,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => debugPrint('SPEED DIAL CHILDREN OPENED'),
        onClose: () => debugPrint('SPEED DIAL CHILDREN CLOSED'),
        tooltip: 'Create Options',
        heroTag: 'speed-dial-hero-tag',
        elevation: 0.0,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.route),
            backgroundColor: const Color(0xFF00811F), // Gemeente Rotterdam green
            foregroundColor: Colors.white,
            label: 'Create Route',
            labelStyle: const TextStyle(fontSize: 18.0),
            // Check authentication before pushing create route screen
            onTap: () => _handleAuthenticatedAction(_navigateToCreateRoute),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_location_alt_outlined),
            backgroundColor: const Color(0xFF00811F), // Gemeente Rotterdam green
            foregroundColor: Colors.white,
            label: 'Create Location',
            labelStyle: const TextStyle(fontSize: 18.0),
            // Check authentication before pushing create Location screen
            onTap: () => _handleAuthenticatedAction(_navigateToCreateLocation),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00811F), // Gemeente Rotterdam green
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == MainScreen.createRouteIndex) {
            _isDialOpen.value = !_isDialOpen.value;
          } else {
            if (_isDialOpen.value) {
              _isDialOpen.value = false;
            }
            context.read<AppState>().changeTab(index);
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
            label: 'Create',
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
