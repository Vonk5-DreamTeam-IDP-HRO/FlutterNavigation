import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthViewModel extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keys for secure storage
  static const String _userTokenKey = 'user_token';
  static const String _userEmailKey = 'user_email';

  String? _token;
  String? _email;

  String? get token => _token;
  String? get email => _email;
  bool get isAuthenticated => _token != null;

  AuthViewModel() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _token = await _secureStorage.read(key: _userTokenKey);
    _email = await _secureStorage.read(key: _userEmailKey);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you would call your backend API here
    // For now, let's assume login is successful if password is "password"
    if (password == "password") {
      _token = "fake_jwt_token"; // Replace with actual token from backend
      _email = email;
      await _secureStorage.write(key: _userTokenKey, value: _token);
      await _secureStorage.write(key: _userEmailKey, value: _email);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you would call your backend API here
    // For now, let's assume registration is successful
    _token = "fake_jwt_token_after_register"; // Replace with actual token
    _email = email;
    await _secureStorage.write(key: _userTokenKey, value: _token);
    await _secureStorage.write(key: _userEmailKey, value: _email);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    await _secureStorage.delete(key: _userTokenKey);
    await _secureStorage.delete(key: _userEmailKey);
    notifyListeners();
  }
}
