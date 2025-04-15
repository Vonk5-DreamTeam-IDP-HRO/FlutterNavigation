import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Corrected import path for AppState
import 'package:osm_navigation/providers/app_state.dart';
// Import for the moved MainScreen
import 'package:osm_navigation/navigation/navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AppState is provided
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'OSM Navigation',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        // MainScreen will be defined in navigation/main_screen.dart
        home: MainScreen.instance(),
      ),
    );
  }
}

// AppState class has been moved to lib/providers/app_state.dart
// MainScreen and _MainScreenState classes will be moved to lib/navigation/main_screen.dart
