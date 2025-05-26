import 'package:flutter/material.dart';
import 'package:osm_navigation/core/models/location_details.dart'; // Assuming LocationDetails is needed for context or return type

class AddLocationDetailsScreen extends StatefulWidget {
  final LocationDetails? initialDetails; // Optional: to pre-fill if editing

  const AddLocationDetailsScreen({super.key, this.initialDetails});

  @override
  State<AddLocationDetailsScreen> createState() => _AddLocationDetailsScreenState();
}

class _AddLocationDetailsScreenState extends State<AddLocationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _zipCodeController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _websiteController;
  late TextEditingController _accessibilityController;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initialDetails?.city);
    _countryController = TextEditingController(text: widget.initialDetails?.country);
    _zipCodeController = TextEditingController(text: widget.initialDetails?.zipCode);
    _phoneNumberController = TextEditingController(text: widget.initialDetails?.phoneNumber);
    _websiteController = TextEditingController(text: widget.initialDetails?.website);
    _accessibilityController = TextEditingController(text: widget.initialDetails?.accessibility);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _phoneNumberController.dispose();
    _websiteController.dispose();
    _accessibilityController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      final details = {
        'city': _cityController.text,
        'country': _countryController.text,
        'zipCode': _zipCodeController.text,
        'phoneNumber': _phoneNumberController.text,
        'website': _websiteController.text,
        'accessibility': _accessibilityController.text,
      };
      Navigator.of(context).pop(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Additional Location Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(
                  labelText: 'Zip Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accessibilityController,
                decoration: const InputDecoration(
                  labelText: 'Accessibility Information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveDetails,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Save Additional Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
