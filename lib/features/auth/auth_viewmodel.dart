import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/services/auth/auth_api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AuthApiService _authService = AuthApiService();

  // Keys for secure storage
  static const String _userTokenKey = 'user_token';
  static const String _userUsernameKey = 'user_username';
  static const String _userEmailKey = 'user_email';

  String? _token;
  String? _username;
  String? _email;
  String? _error;

  String? get token => _token;
  String? get username => _username;
  String? get email => _email;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  AuthViewModel() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _token = await _secureStorage.read(key: _userTokenKey);
    _username = await _secureStorage.read(key: _userUsernameKey);
    _email = await _secureStorage.read(key: _userEmailKey);
  }

  Future<bool> login(String username, String password) async {
    try {
      _error = null;
      final token = await _authService.login(username, password);
      
      _token = token;
      _username = username;
      await _secureStorage.write(key: _userTokenKey, value: token);
      await _secureStorage.write(key: _userUsernameKey, value: username);
      
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _error = 'Invalid username or password';
      } else {
        _error = 'Login failed: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      _error = null;
      final token = await _authService.register(username, email, password);
      
      _token = token;
      _username = username;
      _email = email;
      await _secureStorage.write(key: _userTokenKey, value: token);
      await _secureStorage.write(key: _userUsernameKey, value: username);
      await _secureStorage.write(key: _userEmailKey, value: email);
      
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _error = 'Authentication failed. Please ensure you have permission to register.';
      } else if (e.response?.statusCode == 400) {
        _error = e.response?.data is Map ? 
                e.response?.data['message'] ?? 'Invalid registration data' :
                e.response?.data?.toString() ?? 'Invalid registration data';
      } else if (e.response?.statusCode == 500) {
        // Extract error message from DioException
        String baseError = e.message ?? 'An unexpected server error occurred';
        if (baseError.contains('This might be due to')) {
          _error = baseError; // Use the detailed error message we created
        } else {
          _error = 'Server Error: The account could not be created. This might be due to:\n'
                  '1. Username or email is already in use\n'
                  '2. Invalid input format\n'
                  'Please try again or contact support if the issue persists.';
        }
      } else {
        _error = 'Registration failed: ${e.response?.data ?? e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _email = null;
    await _secureStorage.delete(key: _userTokenKey);
    await _secureStorage.delete(key: _userUsernameKey);
    await _secureStorage.delete(key: _userEmailKey);
    notifyListeners();
  }
}
