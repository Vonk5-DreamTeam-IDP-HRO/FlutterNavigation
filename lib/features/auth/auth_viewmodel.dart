import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/services/auth/auth_api_service.dart';
import 'package:osm_navigation/core/services/dio_factory.dart';

class AuthViewModel extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final AuthApiService _authService;
  bool _isInitialized = false;

  AuthViewModel({Dio? dio}) {
    _authService = AuthApiService(dio ?? Dio());
    debugPrint('🔧 AuthViewModel constructor called');

    // Set up the token provider for DioFactory
    DioFactory.setTokenProvider(() => _token);
  }

  bool get isInitialized => _isInitialized;
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('AuthViewModel.initialize() called');
    await _loadUserFromStorage();
    _isInitialized = true;
    debugPrint(
      'AuthViewModel initialization complete, notifying listeners (hashCode: $hashCode)',
    );
    notifyListeners();
    debugPrint('AuthViewModel: notifyListeners() called after initialization');
  }

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
  Future<void> _loadUserFromStorage() async {
    debugPrint('AuthViewModel._loadUserFromStorage() started');
    _token = await _secureStorage.read(key: _userTokenKey);
    _username = await _secureStorage.read(key: _userUsernameKey);
    _email = await _secureStorage.read(key: _userEmailKey);

    debugPrint(
      'AuthViewModel: Loaded from storage - token exists: ${_token != null}, isAuthenticated: $isAuthenticated',
    );
    debugPrint('AuthViewModel._loadUserFromStorage() completed');
  }

  Future<bool> login(String username, String password) async {
    try {
      _error = null;
      debugPrint('AuthViewModel: Starting login for username: $username');

      final token = await _authService.login(username, password);
      debugPrint(
        'AuthViewModel: Login successful, received token (${token.length} chars)',
      );

      // Save to storage first
      await Future.wait([
        _secureStorage.write(key: _userTokenKey, value: token),
        _secureStorage.write(key: _userUsernameKey, value: username),
      ]);

      // Then update in-memory state
      _token = token;
      _username = username;

      debugPrint('AuthViewModel: Setting token and notifying listeners');
      debugPrint(
        'AuthViewModel State: token exists=${_token != null}, isAuthenticated=$isAuthenticated',
      );

      // Notify listeners AFTER everything is saved and updated
      notifyListeners();
      debugPrint(
        'AuthViewModel: notifyListeners() called successfully after login',
      );
      return true;
    } on DioException catch (e) {
      debugPrint('AuthViewModel: DioException caught: ${e.message}');
      debugPrint(
        'AuthViewModel: Response status code: ${e.response?.statusCode}',
      );
      debugPrint('AuthViewModel: Response data: ${e.response?.data}');

      // Handle our API's custom error format
      if (e.message != null && e.message!.contains('Invalid username')) {
        _error = 'Invalid username or password';
      } else if (e.message != null && e.message!.contains('Login failed')) {
        _error = 'Login failed: ${e.message}';
      } else if (e.response?.statusCode == 401) {
        _error = 'Invalid username or password';
      } else {
        _error = 'Login failed: ${e.message ?? 'Unknown error'}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AuthViewModel: General exception caught: $e');
      _error = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Just check length for now since server handles complexity
    return password.length >= 8;
  }

  bool _isValidUsername(String username) {
    // At least 3 characters, alphanumeric
    return username.length >= 3 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      _error = null;

      // Client-side validation
      if (!_isValidUsername(username)) {
        _error =
            'Username must be at least 3 characters long and contain only letters and numbers';
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        notifyListeners();
        return false;
      }

      if (!_isValidPassword(password)) {
        _error =
            'Password must be at least 8 characters long and contain both letters and numbers';
        notifyListeners();
        return false;
      }

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
        _error =
            'Authentication failed. Please ensure you have permission to register.';
      } else if (e.response?.statusCode == 400) {
        _error =
            e.response?.data is Map
                ? e.response?.data['message'] ?? 'Invalid registration data'
                : e.response?.data?.toString() ?? 'Invalid registration data';
      } else if (e.response?.statusCode == 500) {
        // Extract error message from DioException
        final String baseError =
            e.message ?? 'An unexpected server error occurred';
        if (baseError.contains('This might be due to')) {
          _error = baseError; // Use the detailed error message we created
        } else {
          _error =
              'Server Error: The account could not be created. This might be due to:\n'
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
