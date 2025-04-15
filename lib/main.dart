import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/core/navigation/navigation.dart';

/// This application is build according the MVVM architectural pattern
/// https://docs.flutter.dev/app-architecture/guide
/// 
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
        home: MainScreen.instance(),
      ),
    );
  }
}
