import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'create_location_viewmodel.dart';
import 'Services/Photon.dart';

class CreateLocationScreen extends StatefulWidget {
  const CreateLocationScreen({super.key});

  @override
  State<CreateLocationScreen> createState() => _CreateLocationScreenState();
}

class _CreateLocationScreenState extends State<CreateLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _category;

  @override
  void initState() {
    super.initState();
    // Fetch categories when the screen initializes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CreateLocationViewModel>(
        context,
        listen: false,
      ).fetchCategories();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<CreateLocationViewModel>(
        context,
        listen: false,
      );
      viewModel.clearMessages();

      final success = await viewModel.submitLocation(
        name: _nameController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        category: _category!,
      );

      if (success) {
        // Clear form fields
        _formKey.currentState?.reset();
        _addressController.clear();
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _category = null;
        });
        // Show success message from ViewModel
        if (mounted && viewModel.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error message from ViewModel
        if (mounted && viewModel.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the ViewModel
    final viewModel = Provider.of<CreateLocationViewModel>(context);
    final photonService = Provider.of<PhotonService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Location')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -- Address field with typeahead that gives suggestions -- //
              // Created by Cline using Gemini 2.5 PRO
              TypeAheadField<PhotonResultExtension>(
                controller: _addressController,
                builder: (context, controller, focusNode) {
                  return TextFormField(
                    controller: _addressController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Start typing an address (min 3 characters)',
                    ),
                    validator: (value) {
                      // When a suggestion is selected, _addressController is updated.
                      // The text field's controller (from builder) will also have the text.
                      // Validate based on _addressController as it's used for submission.
                      if (_addressController.text.isEmpty) {
                        if (value != null && value.isNotEmpty) {
                          // If user typed something but didn't select, and _addressController is empty
                          return 'Please select a valid address from suggestions.';
                        }
                        return 'Please enter an address';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // If user clears the field or types manually after selecting,
                      // clear our stored _addressController to ensure validation catches it
                      if (text.isEmpty) {
                        _addressController.clear();
                      }
                    },
                  );
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 3) return [];
                  try {
                    final results = await photonService.searchAddresses(
                      pattern,
                    );
                    // The cast might be redundant if searchAddresses already returns List<PhotonResultExtension>
                    // but it's safer to keep if Photon.dart's searchAddresses returns List<dynamic> or List<PhotonFeature>
                    // and relies on the cast here. Given Photon.dart now maps to PhotonResultExtension,
                    // this cast should be fine.
                    return results; // No cast needed if searchAddresses is correctly typed
                  } catch (e) {
                    print('Error getting address suggestions: $e');
                    return [];
                  }
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(
                      suggestion.name ??
                          suggestion
                              .formattedAddress, // Using .name from PhotonResultExtension
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      suggestion.formattedAddress,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                onSelected: (suggestion) {
                  final List<String> parts = [];
                  if (suggestion.name != null && suggestion.name!.isNotEmpty) {
                    parts.add(suggestion.name!);
                  }
                  if (suggestion.postcode != null &&
                      suggestion.postcode!.isNotEmpty) {
                    parts.add(suggestion.postcode!);
                  }
                  if (suggestion.city != null && suggestion.city!.isNotEmpty) {
                    parts.add(suggestion.city!);
                  }
                  _addressController.text = parts.join(', ');

                  viewModel.setSelectedCoordinates(
                    suggestion.latitude,
                    suggestion.longitude,
                  );
                  // Optionally, trigger re-validation of the form field
                  // _formKey.currentState?.validate();
                },
                emptyBuilder: // Renamed from noItemsFoundBuilder
                    (context) => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No addresses found. Try a different search term.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                loadingBuilder:
                    (context) => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Searching addresses...'),
                        ],
                      ),
                    ),
              ),

              // -- Name text field -- //
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              //  -- Description text field -- //
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              // -- Category dropdown -- //
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _category,
                hint:
                    viewModel.isLoadingCategories
                        ? const Text('Loading categories...')
                        : viewModel.categoriesErrorMessage != null
                        ? const Text(
                          'Error loading categories',
                          style: TextStyle(color: Colors.red),
                        )
                        : viewModel.categories.isEmpty
                        ? const Text('No categories available')
                        : null,
                disabledHint:
                    viewModel.isLoadingCategories
                        ? const Text('Loading...')
                        : null,
                items:
                    viewModel.isLoadingCategories ||
                            viewModel.categoriesErrorMessage != null
                        ? []
                        : viewModel.categories.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                onChanged:
                    viewModel.isLoadingCategories ||
                            viewModel.categoriesErrorMessage != null
                        ? null
                        : (value) {
                          setState(() {
                            _category = value;
                          });
                        },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),

              // Error message for categories
              if (viewModel.categoriesErrorMessage != null &&
                  !viewModel.isLoadingCategories)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Error details: ${viewModel.categoriesErrorMessage}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              // -- Submit button -- //
              const SizedBox(height: 32),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () => _submitForm(context),
                  child: const Text('Create Location'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
