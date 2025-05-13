import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_location_viewmodel.dart';

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
    // Use addPostFrameCallback to ensure that the context is fully available
    // and that the ViewModel provider has been initialized.
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
        // Optionally, show success message from ViewModel or navigate away
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

    return Scaffold(
      appBar: AppBar(title: const Text('Create Location')),
      body: SingleChildScrollView(
        // Added SingleChildScrollView for smaller screens
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
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
                        : null, // Default hint if categories are loaded but none selected
                disabledHint:
                    viewModel.isLoadingCategories
                        ? const Text('Loading...')
                        : null,
                items:
                    viewModel.isLoadingCategories ||
                            viewModel.categoriesErrorMessage != null
                        ? [] // Show no items if loading or error
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
                        ? null // Disable dropdown if loading or error
                        : (value) {
                          // When a category is selected, ensure _category is updated
                          // and if there was a previous error, it might be good to clear it
                          // or allow re-fetch, though current logic doesn't do that on change.
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
              if (viewModel.categoriesErrorMessage != null &&
                  !viewModel.isLoadingCategories)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Error details: ${viewModel.categoriesErrorMessage}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
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
