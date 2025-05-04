import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Map<String, List<String>> categorizedPOIs = {
    'Museums': [],
    'Parks': [],
    'Monuments': [],
    'Restaurants': [],
    'Shops': [],
    'Libraries': [],
  };
  Set<String> seenPOIs = {};
  Set<String> selectedPOIs = {};

  @override
  void initState() {
    super.initState();
    fetchPOIs();
  }

  Future<void> fetchPOIs() async {
    const query = '''
      [out:json][timeout:20];
      area[name="Rotterdam"]->.a;
      (
        node["tourism"~"museum|gallery|attraction|viewpoint"](area.a);
        node["leisure"~"park|stadium"](area.a);
        node["historic"="monument"](area.a);
        node["amenity"~"place_of_worship|restaurant|cafe|library|theatre"](area.a);
        node["shop"](area.a);
      );
      out body;
    ''';

    final response = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      body: {'data': query},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List elements = data['elements'];

      for (var element in elements) {
        final tags = element['tags'] ?? {};
        final name = tags['name'] ?? '';
        if (name.isEmpty || seenPOIs.contains(name)) continue;

        seenPOIs.add(name);

        if (tags['tourism'] == 'museum' || tags['tourism'] == 'gallery') {
          categorizedPOIs['Museums']!.add(name);
        }
        if (tags['leisure'] == 'park') {
          categorizedPOIs['Parks']!.add(name);
        }
        if (tags['historic'] == 'monument') {
          categorizedPOIs['Monuments']!.add(name);
        }
        if (tags['amenity'] == 'restaurant' || tags['amenity'] == 'cafe') {
          categorizedPOIs['Restaurants']!.add(name);
        }
        if (tags['shop'] != null) {
          categorizedPOIs['Shops']!.add(name);
        }
        if (tags['amenity'] == 'library') {
          categorizedPOIs['Libraries']!.add(name);
        }
      }

      setState(() {});
    }
  }

  List<Widget> buildAccordions() {
    final searchTerm = _searchController.text.toLowerCase();
    return categorizedPOIs.entries.map((entry) {
      final filtered = entry.value
          .where((item) => item.toLowerCase().contains(searchTerm))
          .toList();
      if (filtered.isEmpty) return const SizedBox.shrink();
      return ExpansionTile(
        title: Text(entry.key),
        children: filtered.map((e) {
          final isSelected = selectedPOIs.contains(e);
          return ListTile(
            title: Text(e),
            trailing: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.green : null,
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedPOIs.remove(e);
                } else {
                  selectedPOIs.add(e);
                }
              });
            },
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Route')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Route Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _startController,
              decoration: const InputDecoration(
                labelText: 'Start Point',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _endController,
              decoration: const InputDecoration(
                labelText: 'End Point',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search POIs...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (selectedPOIs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    children: selectedPOIs.map((poi) {
                      return Chip(
                        label: Text(poi),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            selectedPOIs.remove(poi);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedPOIs.clear();
                        });
                      },
                      child: const Text("Clear All"),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children: buildAccordions(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: handle "Go" logic later
              },
              child: const Text("Go"),
            ),
          ),
        ],
      ),
    );
  }
}
