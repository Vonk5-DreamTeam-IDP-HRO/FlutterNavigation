import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
import 'package:osm_navigation/core/navigation/navigation.dart';
import 'package:osm_navigation/features/create_route/create_route_screen.dart';
import 'package:osm_navigation/features/create_location/create_location_screen.dart';
import 'package:osm_navigation/features/create_route/create_route_viewmodel.dart';
import 'package:osm_navigation/features/create_location/create_location_viewmodel.dart';
import 'package:osm_navigation/core/services/location/ILocationApiService.dart';
import 'package:osm_navigation/core/services/location/location_api_service.dart';
import 'package:osm_navigation/core/repositories/Location/i_location_repository.dart';
import 'package:osm_navigation/core/repositories/Location/location_repository.dart';
import 'package:osm_navigation/core/services/route/route_api_service.dart';
import 'package:osm_navigation/core/repositories/Route/route_repository.dart';
import 'package:osm_navigation/core/repositories/Route/IRouteRepository.dart';
import 'package:osm_navigation/features/create_location/Services/Photon.dart';

class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48.0),
            // Welcome Section
            Text(
              'Welcome to Rotterdam Navigation',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Discover and navigate through Rotterdam\'s landmarks',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32.0),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.route,
                    title: 'Create Route',
                    description: 'Plan a new route through Rotterdam',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider.value(
                                value: context.read<AppState>(),
                              ),
                              Provider<ILocationRepository>(
                                create: (context) {
                                  final dio = context.read<Dio>();
                                  final locationApiService = LocationApiService(dio);
                                  return LocationRepository(locationApiService);
                                },
                              ),
                              Provider<IRouteRepository>(
                                create: (context) {
                                  final dio = context.read<Dio>();
                                  final routeApiService = RouteApiService(dio);
                                  return RouteRepository(routeApiService);
                                },
                              ),
                              ChangeNotifierProvider(
                                create: (context) => CreateRouteViewModel(
                                  context.read<IRouteRepository>(),
                                  context.read<ILocationRepository>(),
                                ),
                              ),
                            ],
                            child: const CreateRouteScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.location_on,
                    title: 'Add Location',
                    description: 'Add a new point of interest',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider.value(
                                value: context.read<AppState>(),
                              ),
                              Provider<ILocationRepository>(
                                create: (context) {
                                  final locationApiService = LocationApiService(
                                    context.read<Dio>(),
                                  );
                                  return LocationRepository(locationApiService);
                                },
                              ),
                              ChangeNotifierProvider(
                                create: (context) => CreateLocationViewModel(
                                  locationRepository: context.read<ILocationRepository>(),
                                  photonService: PhotonService(),
                                ),
                              ),
                            ],
                            child: const CreateLocationScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),

            // Rotterdam Stats
            Text(
              'Rotterdam at a Glance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _StatItem(
                      icon: Icons.location_city,
                      title: 'City Area',
                      value: '324.14 km²',
                    ),
                    Divider(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    _StatItem(
                      icon: Icons.people,
                      title: 'Population',
                      value: '651,446',
                    ),
                    Divider(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    _StatItem(
                      icon: Icons.tour,
                      title: 'Tourist Attractions',
                      value: '100+',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon, 
                color: Theme.of(context).colorScheme.primary,
                size: 32.0
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4.0),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon, 
            color: Theme.of(context).colorScheme.primary
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
