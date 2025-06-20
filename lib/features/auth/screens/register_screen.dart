/// **RegisterScreen.dart**
///
/// **Purpose:**
/// Handles new user registration by providing a form interface for collecting
/// username, email, and password information. Includes client-side validation
/// and feedback mechanisms.
///
/// **Usage:**
/// This screen is accessed from the login screen when a user needs to create
/// a new account. After successful registration, it automatically logs the user
/// in and navigates to the settings screen.
///
/// **Key Features:**
/// - Form with username, email, and password inputs
/// - Password confirmation field with matching validation
/// - Client-side input validation for all fields
/// - Loading state management during registration
/// - Success/error feedback via snackbar
/// - Responsive layout with max width constraint
///
/// **Dependencies:**
/// - `AuthViewModel`: For handling registration logic
/// - `SettingScreen`: For post-registration navigation
/// - `Provider`: For accessing AuthViewModel
///
/// **workflow:**
/// ```
/// 1. User fills out registration form
/// 2. Form validates all inputs on submission
/// 4. Possible shows error messages for invalid inputs
/// 3. AuthViewModel processes registration request
/// 4. Shows loading indicator during request
/// 5. On success: Shows confirmation and redirects to settings
/// 6. On failure: Displays error message
/// ```
///
/// **Possible improvements:**
/// - Implement email verification process
/// - Add terms of service acceptance
/// - Consider adding registration with social accounts
///
library register_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_viewmodel.dart';
import 'package:osm_navigation/features/setting/setting_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authViewModel.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration Successful'),
              backgroundColor: Colors.green,
            ),
          );
          // Pop back to root and replace with settings screen
          Navigator.of(context)
              .pushNamedAndRemoveUntil(
                '/', // Go back to root/home
                (route) => false,
              )
              .then((_) {
                // After root is restored, navigate to settings
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                }
              });
        } else {
          final error =
              authViewModel.error ?? 'Registration Failed. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _register,
                          child: const Text('Register'),
                        ),
                      ),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.of(context).pop();
                            },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
