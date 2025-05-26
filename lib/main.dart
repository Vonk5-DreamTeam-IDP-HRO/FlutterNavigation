import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/Core/providers/app_state.dart';
import 'package:osm_navigation/Core/navigation/navigation.dart';
import 'package:osm_navigation/Core/services/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/services/location/ILocationApiService.dart';
import 'package:osm_navigation/Core/services/location/location_api_service.dart';
import 'package:osm_navigation/Core/repositories/location/i_location_repository.dart';
import 'package:osm_navigation/Core/repositories/location/location_repository.dart';
import 'package:osm_navigation/Core/config/app_config.dart';
import 'package:osm_navigation/features/create_location/Services/Photon.dart';

/// This application is build according the MVVM architectural pattern
/// https://docs.flutter.dev/app-architecture/guide
///

Future<void> main() async {
  // Ensure Flutter bindings are initialized before using plugins or async operations.
  // This is especially important when using plugins that must be loaded before the app starts.
  // For example, if you are using plugins that require native code. Kotlin or Swift.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize environment variables first
    await dotenv.load(fileName: '.env');
    // Then initialize AppConfig with loaded environment variables.
    await AppConfig.load();

    print('Environment loaded successfully');
    print('URL: ${AppConfig.url}');
  } catch (e) {
    print('Error loading environment: $e');
    // Still run the app, but with potential issues
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a single Dio instance for the app.
    // This instance can be shared across the app, ensuring consistent configuration.
    // It is used for making network requests and catch expections to show to the user.
    final dio = DioFactory.createDio();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        Provider<Dio>(create: (context) => dio),
        Provider<ILocationApiService>(
          create: (context) => LocationApiService(context.read<Dio>()),
        ),
        Provider<ILocationRepository>(
          create:
              (context) =>
                  LocationRepository(context.read<ILocationApiService>()),
        ),
        Provider<PhotonService>(create: (context) => PhotonService()),
      ],
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
