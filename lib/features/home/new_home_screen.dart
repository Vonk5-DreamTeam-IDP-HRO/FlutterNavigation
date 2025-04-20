import 'package:flutter/material.dart';

class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(Icons.home_filled, size: 100.0, color: Colors.grey),
      ),
    );
  }
}
