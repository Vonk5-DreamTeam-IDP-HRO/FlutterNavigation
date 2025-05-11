import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:osm_navigation/core/config/app_config.dart'; // Added import for AppConfig
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/core/navigation/navigation.dart';

/// This application is build according the MVVM architectural pattern
/// https://docs.flutter.dev/app-architecture/guide
///

Future<void> main() async {
  // Ensure Flutter bindings are initialized before using plugins or async operations.
  // This is especially important when using plugins that must be loaded before the app starts.
  // For example, if you are using plugins that require native code. Kotlin or Swift.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file and initialize AppConfig
  // AppConfig.load() will internally call dotenv.load()
  await AppConfig.load();
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
        home: const MainScreen(),
      ),
    );
  }
}
