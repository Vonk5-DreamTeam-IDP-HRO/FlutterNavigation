import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/config/app_config.dart';
import '../dio_factory.dart';

class AuthApiService {
  late final Dio _dio;
  
  static final String _primaryBaseApiUrl = '${AppConfig.url}:${AppConfig.backendApiPort}';
  static final String _fallbackBaseApiUrl = '${AppConfig.thijsApiUrl}:${AppConfig.localhostPort}';
  
  AuthApiService() {
    _dio = DioFactory.createDio();
  }
  
  Future<String> login(String email, String password) async {
    try {
      // Try primary URL first
      try {
        final response = await _attemptLogin(_primaryBaseApiUrl, email, password);
        return response;
      } catch (e) {
        debugPrint('Primary login failed, trying fallback: $e');
      }
      
      // Try fallback URL
      return await _attemptLogin(_fallbackBaseApiUrl, email, password);
    } catch (e) {
      debugPrint('Login failed on both URLs: $e');
      rethrow;
    }
  }

  Future<String> register(String email, String password) async {
    try {
      // Try primary URL first
      try {
        final response = await _attemptRegister(_primaryBaseApiUrl, email, password);
        return response;
      } catch (e) {
        debugPrint('Primary register failed, trying fallback: $e');
      }
      
      // Try fallback URL
      return await _attemptRegister(_fallbackBaseApiUrl, email, password);
    } catch (e) {
      debugPrint('Register failed on both URLs: $e');
      rethrow;
    }
  }

  Future<String> _attemptLogin(String baseUrl, String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/Login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['token'];
      }
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/Login'),
        response: response,
        message: 'Login failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Login attempt failed: $e');
      rethrow;
    }
  }

  Future<String> _attemptRegister(String baseUrl, String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/CreateUser',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        return response.data['token'];
      }
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/CreateUser'),
        response: response,
        message: 'Registration failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Registration attempt failed: $e');
      rethrow;
    }
  }
}
