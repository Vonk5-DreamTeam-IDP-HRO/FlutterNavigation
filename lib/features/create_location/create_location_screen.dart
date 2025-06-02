import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
import 'package:osm_navigation/features/auth/screens/login_screen.dart';
import 'package:osm_navigation/core/providers/app_state.dart';
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
  bool _isLoginDialogShown = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use listen: false for initial checks to avoid rebuild cycles
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Check initial state
    final bool shouldShowDialog =
        !authViewModel.isAuthenticated && !_isLoginDialogShown;

    if (shouldShowDialog) {
      // Use Future.microtask to avoid build-time setState
      Future.microtask(() {
        if (mounted && !_isLoginDialogShown) {
          _showLoginDialog(context);
          if (mounted) {
            setState(() {
              _isLoginDialogShown = true;
            });
          }
        }
      });
    }

    // Listen for changes
    final authChanges = Provider.of<AuthViewModel>(context);
    if (authChanges.isAuthenticated && _isLoginDialogShown) {
      if (mounted) {
        setState(() {
          _isLoginDialogShown = false;
        });
      }
    }
  }

  void _showLoginDialog(BuildContext dialogContext) {
    if (!mounted) return;

    // Create a new context using Builder to ensure we have access to all providers
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder:
          (BuildContext alertContext) => Builder(
            builder:
                (builderContext) => AlertDialog(
                  title: const Text('Login Required'),
                  content: const Text(
                    'You need to log in or register to create a location.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(alertContext).pop();
                        if (mounted) {
                          setState(() {
                            _isLoginDialogShown = false;
                          });
                          Navigator.of(
                            context,
                          ).pop(); // Go back to previous screen
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Login / Register'),
                      onPressed: () {
                        Navigator.of(alertContext).pop();
                        if (mounted) {
                          setState(() {
                            _isLoginDialogShown = false;
                          });
                        }
                        Navigator.of(builderContext).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
          ),
    ).then((_) {
      if (!mounted) return;

      final auth = Provider.of<AuthViewModel>(context, listen: false);

      if (auth.isAuthenticated) {
        setState(() {
          _isLoginDialogShown = false;
        });
      }
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
    final viewModel = Provider.of<CreateLocationViewModel>(context);
    final photonService = Provider.of<PhotonService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Location')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TypeAheadField<PhotonResultExtension>(
                    builder:
                        (context, controller, focusNode) => TextFormField(
                          controller: _addressController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            hintText:
                                'Start typing an address (min 3 characters)',
                          ),
                          validator: (value) {
                            if (_addressController.text.isEmpty) {
                              if (value != null && value.isNotEmpty) {
                                return 'Please select a valid address from suggestions';
                              }
                              return 'Please enter an address';
                            }
                            return null;
                          },
                        ),
                    suggestionsCallback: (pattern) async {
                      if (pattern.length < 3) return [];
                      try {
                        return await photonService.searchAddresses(pattern);
                      } catch (e) {
                        print('Error getting address suggestions: $e');
                        return [];
                      }
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(
                          suggestion.name ?? suggestion.formattedAddress,
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
                      if (suggestion.name != null &&
                          suggestion.name!.isNotEmpty) {
                        parts.add(suggestion.name!);
                      }
                      if (suggestion.postcode != null &&
                          suggestion.postcode!.isNotEmpty) {
                        parts.add(suggestion.postcode!);
                      }
                      if (suggestion.city != null &&
                          suggestion.city!.isNotEmpty) {
                        parts.add(suggestion.city!);
                      }
                      _addressController.text = parts.join(', ');
                      viewModel.setSelectedCoordinates(
                        suggestion.latitude,
                        suggestion.longitude,
                      );
                    },
                    emptyBuilder:
                        (context) => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No addresses found. Try a different search term.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
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
                            : null,
                    items:
                        viewModel.isLoadingCategories ||
                                viewModel.categoriesErrorMessage != null
                            ? []
                            : viewModel.categories
                                .map(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
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
          if (!Provider.of<AuthViewModel>(context).isAuthenticated)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }
}
