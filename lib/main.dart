import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/core/navigation/navigation.dart'; // Assuming MainScreen is here
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
// No need to import LoginScreen here for the home widget directly

/// This application is build according the MVVM architectural pattern
/// https://docs.flutter.dev/app-architecture/guide
///

Future<void> main() async {
  // Ensure Flutter bindings are initialized before using plugins or async operations.
  // This is especially important when using plugins that must be loaded before the app starts.
  // For example, if you are using plugins that require native code. Kotlin or Swift.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'OSM Navigation',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const MainScreen(), // Always start with MainScreen
        // routes: {
        //   // Define routes if you use named navigation for login/register
        //   // '/login': (context) => const LoginScreen(),
        //   // '/register': (context) => const RegisterScreen(),
        // },
      ),
    );
  }
}
