import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/services/auth/auth_api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AuthApiService _authService = AuthApiService();

  // Keys for secure storage
  static const String _userTokenKey = 'user_token';
  static const String _userEmailKey = 'user_email';

  String? _token;
  String? _email;
  String? _error;

  String? get token => _token;
  String? get email => _email;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  AuthViewModel() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _token = await _secureStorage.read(key: _userTokenKey);
    _email = await _secureStorage.read(key: _userEmailKey);
    // Don't notify listeners at startup to avoid triggering any auth UI
  }

  Future<bool> login(String email, String password) async {
    try {
      _error = null;
      final token = await _authService.login(email, password);
      
      _token = token;
      _email = email;
      await _secureStorage.write(key: _userTokenKey, value: token);
      await _secureStorage.write(key: _userEmailKey, value: email);
      
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _error = 'Invalid email or password';
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

  Future<bool> register(String email, String password) async {
    try {
      _error = null;
      final token = await _authService.register(email, password);
      
      _token = token;
      _email = email;
      await _secureStorage.write(key: _userTokenKey, value: token);
      await _secureStorage.write(key: _userEmailKey, value: email);
      
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        _error = e.response?.data['message'] ?? 'Invalid registration data';
      } else {
        _error = 'Registration failed: ${e.message}';
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
    _email = null;
    await _secureStorage.delete(key: _userTokenKey);
    await _secureStorage.delete(key: _userEmailKey);
    notifyListeners();
  }
}
