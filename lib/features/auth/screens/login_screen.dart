/// **LoginScreen.dart**
///
/// **Purpose:**
/// Provides the user interface for authentication. Can be shown either as
/// a full screen or as a modal dialog, handling user login with username and password
/// input validation.
///
/// **Usage:**
/// This screen is used whenever user authentication is required. It can be
/// displayed in two ways:
/// - As a full screen using normal navigation
/// - As a modal dialog
///
/// **Key Features:**
/// - Form with username and password inputs
/// - Input validation before submission
/// - Loading state handling during login
/// - Error feedback via snackbar
/// - Navigation to registration screen
/// - Responsive layout with max width constraint
///
/// **Dependencies:**
/// - `AuthViewModel`: For handling login logic
/// - `RegisterScreen`: For new user registration
/// - `Provider`: For accessing AuthViewModel
///
/// **workflow:**
/// ```
/// 1. User enters credentials
/// 2. Form validates input on submission
/// 3. AuthViewModel handles login request
/// 4. Shows loading indicator during request
/// 5. Displays error message or redirects on completion
/// ```
///
/// **Possible improvements:**
/// - Add "Remember me" functionality to persist login state
/// - Implement "Forgot password" feature
/// - Add social login options
///
library login_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_viewmodel.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final bool isDialog;
  const LoginScreen({super.key, this.onLoginSuccess, this.isDialog = false});

  static Future<void> showAsDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder:
          (context) => LoginScreen(
            isDialog: true,
            onLoginSuccess: () {
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authViewModel.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (success) {
          if (widget.isDialog) {
            widget.onLoginSuccess?.call();
          } else {
            // Navigate back to settings screen
            Navigator.of(context).pop();
          }
        } else {
          final error =
              authViewModel.error ?? 'Login Failed. Please try again.';
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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget loginForm = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Login Required',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
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
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),
          TextButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
            child: const Text('Don\'t have an account? Register'),
          ),
        ],
      ),
    );

    if (widget.isDialog) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: loginForm,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: loginForm,
          ),
        ),
      ),
    );
  }
}
