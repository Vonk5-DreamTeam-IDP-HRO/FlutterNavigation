import 'package:flutter/material.dart';

class CreateLocationScreen extends StatelessWidget {
  const CreateLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final viewModel = context.watch<CreateLocationViewModel>(); // Uncomment when ViewModel is used

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Location')),
      body: const Center(child: Text('Create Location Screen - Placeholder')),
    );
  }
}
