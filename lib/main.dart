import 'package:flutter/material.dart';
import 'package:osm_navigation/screens/save_screen.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/screens/home_screen.dart';
import 'package:osm_navigation/screens/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'OSM Navigation',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MainScreen.instance(),
      ),
    );
  }
}

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
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Private static key to avoid exposing private type in public API
  static final GlobalKey<_MainScreenState> _mainScreenKey =
      GlobalKey<_MainScreenState>();

  // Static method to get the widget instance with the correct key
  static MainScreen instance() {
    return MainScreen(key: _mainScreenKey);
  }

  // Static method to navigate to the map tab from anywhere
  static void navigateToMapTab(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.showRouteOnMap();

    _mainScreenKey.currentState?.navigateToTab(3);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
        const HomeScreen(),
        const CesiumViewer(), // Placeholder
        const Scaffold(
            body: Center(child: Text('Create Route Screen'))), // Placeholder
        const MapScreen(),
        const Scaffold(
            body: Center(child: Text('Settings Screen'))), // Placeholder
      ];

  void navigateToTab(int index, {bool showRoute = false}) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Save',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.plus_one_rounded),
            label: 'Create Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'settings')
        ],
      ),
    );
  }
}
