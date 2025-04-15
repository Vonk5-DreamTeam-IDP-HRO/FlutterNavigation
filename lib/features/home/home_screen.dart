import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/providers/app_state.dart'; // Add correct import for AppState
import 'package:osm_navigation/navigation/navigation.dart'; // Add correct import for MainScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.route),
              title: Text('Route_1'),
              subtitle: Text('Along best places in R"dam'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: const Text('Edit'),
                ),
                TextButton(
                    onPressed: () {
                      final appState =
                          Provider.of<AppState>(context, listen: false);
                      appState.showRouteOnMap();

                      // Use the static method to navigate to map tab
                      MainScreen.navigateToMapTab(context);
                    },
                    child: const Text('View route'))
              ],
            )
          ],
        )),
      ),
    );
  }
}
