library rotterdam_navigation_main;

import 'package:flutter/material.dart';
import 'package:osm_navigation/core/services/route/route_api_service.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/core/navigation/navigation.dart';
import 'package:osm_navigation/core/services/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/services/location/ILocationApiService.dart';
import 'package:osm_navigation/core/services/location/location_api_service.dart';
import 'package:osm_navigation/core/repositories/Location/i_location_repository.dart';
import 'package:osm_navigation/core/repositories/Location/location_repository.dart';
import 'package:osm_navigation/core/config/app_config.dart';
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
import 'package:osm_navigation/features/create_location/Services/Photon.dart';
import 'package:osm_navigation/features/create_location/create_location_viewmodel.dart';

/// **Rotterdam Navigation App**
///
/// A Flutter application for navigating through Rotterdam's points of interest,
/// built using the MVVM (Model-View-ViewModel) architectural pattern.
///
/// **Architecture:**
/// - Models: Data structures and business logic
/// - Views: UI components and screens
/// - ViewModels: State management and UI logic
///
/// **Key Features:**
/// - Dependency injection using Provider
/// - Centralized state management
/// - Clean architecture principles
/// - Error handling and recovery
///
/// **Core Dependencies:**
/// - Provider: For dependency injection and state management
/// - Dio: For HTTP communications
/// - WebView: For Cesium map integration
///
/// **References:**
/// - [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
/// - [Provider Documentation](https://pub.dev/packages/provider)
///

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load and validate environment configuration
    await AppConfig.load();
    AppConfig.validateConfig();

    // Create dependencies after config is validated
    final dio = DioFactory.createDio();
    final authViewModel = AuthViewModel(dio: dio);

    // Wait for AuthViewModel to fully initialize before creating the app
    debugPrint('Initializing AuthViewModel...');
    await authViewModel.initialize();
    debugPrint('AuthViewModel initialization complete');

    runApp(MyApp(dio: dio, authViewModel: authViewModel));
  } catch (e, stack) {
    debugPrint('Error initializing app: $e\n$stack');

    String errorMessage;
    if (e.toString().contains('Missing required environment variables')) {
      // For environment validation errors, show the full error with missing vars
      errorMessage = e.toString();
    } else if (e.toString().contains('.env')) {
      // For .env file related errors
      errorMessage =
          'Error loading .env file. Please ensure the file exists and has the correct format.';
    } else {
      // For other initialization errors
      errorMessage = 'Error initializing app: ${e.toString()}';
    }

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your environment configuration and restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Main application widget that sets up the dependency injection tree
/// and configures the application theme.
///
/// This widget is responsible for:
/// - Setting up Provider dependencies
/// - Configuring theme data
/// - Managing authentication state
/// - Initializing services and repositories
class MyApp extends StatelessWidget {
  final Dio _dio;
  final AuthViewModel _authViewModel;

  const MyApp({
    required Dio dio,
    required AuthViewModel authViewModel,
    super.key,
  }) : _dio = dio,
       _authViewModel = authViewModel;

  /// Builds the application widget tree with all required providers.
  ///
  /// Sets up the following providers:
  /// - AppState: Global application state
  /// - Dio: HTTP client with auth token management
  /// - AuthViewModel: Authentication state and token management
  /// - Services: LocationApi, RouteApi, etc.
  /// - Repositories: Location, Route management
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        Provider<Dio>.value(value: _dio),
        ChangeNotifierProvider.value(value: _authViewModel),
        Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            debugPrint('Consumer<AuthViewModel> rebuild triggered!');
            debugPrint('isAuthenticated: ${authViewModel.isAuthenticated}');
            debugPrint('token exists: ${authViewModel.token != null}');
            return child!;
          },
          child: Container(), // Empty widget for testing
        ),
        ProxyProvider<AuthViewModel, ILocationApiService>(
          lazy: false, // Force immediate creation
          updateShouldNotify: (_, __) => true, // Always notify on auth changes
          update: (context, authViewModel, previous) {
            debugPrint('PROXYPROVIDER CALLED!');
            debugPrint(
              'ProxyProvider update called: isAuthenticated=${authViewModel.isAuthenticated}, token=${authViewModel.token != null ? "EXISTS (${authViewModel.token?.substring(0, 10)}...)" : "NULL"}',
            );

            // Always use the same Dio instance with dynamic token resolution
            debugPrint(
              'Creating LocationApiService with dynamic Dio (token will be resolved dynamically)',
            );
            return LocationApiService(context.read<Dio>());
          },
        ),
        ProxyProvider<ILocationApiService, ILocationRepository>(
          update: (context, locationApiService, previous) {
            debugPrint(
              'Creating LocationRepository with updated LocationApiService',
            );
            return LocationRepository(locationApiService);
          },
        ),
        ProxyProvider<AuthViewModel, RouteApiService>(
          lazy: false, // Force immediate creation
          updateShouldNotify: (_, __) => true, // Always notify on auth changes
          update: (context, authViewModel, previous) {
            debugPrint(
              'Creating RouteApiService with dynamic Dio (token will be resolved dynamically)',
            );
            return RouteApiService(context.read<Dio>());
          },
        ),
        Provider<PhotonService>(create: (context) => PhotonService()),
        ProxyProvider2<
          ILocationRepository,
          PhotonService,
          CreateLocationViewModel
        >(
          update: (context, repository, photonService, previous) {
            debugPrint('Creating CreateLocationViewModel with dependencies');
            return CreateLocationViewModel(
              locationRepository: repository,
              photonService: photonService,
            );
          },
        ),
      ],
      child: Consumer<AppState>(
        builder:
            (context, appState, _) => MaterialApp(
              title: 'OSM Navigation',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF00811F),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF00811F),
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const MainScreen(),
            ),
      ),
    );
  }
}
