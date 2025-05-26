import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/Core/config/app_config.dart';
import 'package:osm_navigation/Core/models/auth_dtos.dart';
import '../dio_factory.dart';

class AuthApiService {
  late final Dio _dio;
  
  static final String _primaryBaseApiUrl = '${AppConfig.url}:${AppConfig.backendApiPort}';
  static final String _fallbackBaseApiUrl = '${AppConfig.thijsApiUrl}:${AppConfig.localhostPort}';
  
  AuthApiService() {
    _dio = DioFactory.createDio();
  }
  
  Future<String> login(String username, String password) async {
    try {
      // Try primary URL first
      try {
        final response = await _attemptLogin(_primaryBaseApiUrl, username, password);
        return response;
      } catch (e) {
        debugPrint('Primary login failed, trying fallback: $e');
      }
      
      // Try fallback URL
      return await _attemptLogin(_fallbackBaseApiUrl, username, password);
    } catch (e) {
      debugPrint('Login failed on both URLs: $e');
      rethrow;
    }
  }

  Future<String> register(String username, String email, String password) async {
    try {
      // Try primary URL first
      try {
        final response = await _attemptRegister(_primaryBaseApiUrl, username, email, password);
        return response;
      } catch (e) {
        debugPrint('Primary register failed, trying fallback: $e');
      }
      
      // Try fallback URL
      return await _attemptRegister(_fallbackBaseApiUrl, username, email, password);
    } catch (e) {
      debugPrint('Register failed on both URLs: $e');
      rethrow;
    }
  }

  Future<String> _attemptLogin(String baseUrl, String username, String password) async {
    try {
      final loginDto = LoginRequestDto(username: username, password: password);
      final response = await _dio.post(
        '$baseUrl/api/User/Login',
        data: loginDto.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponseDto.fromJson(response.data);
        return authResponse.token;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/api/User/Login'),
        response: response,
        message: 'Login failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Login attempt failed: $e');
      rethrow;
    }
  }

  Future<String> _attemptRegister(String baseUrl, String username, String email, String password) async {
    try {
      final registerDto = RegisterRequestDto(
        username: username,
        email: email,
        password: password,
      );
      
      // Create new Dio instance with specific headers for registration
      final registrationDio = DioFactory.createDio();
      registrationDio.options.headers.addAll({
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'application/json',
      });

      debugPrint('Attempting registration at: $baseUrl/api/User');
      debugPrint('Registration payload: ${registerDto.toJson()}');
      
      // Clean up the data and ensure proper casing
      final data = registerDto.toJson();
      debugPrint('Registration data with proper casing: $data');
      
      final response = await registrationDio.post(
        '$baseUrl/api/User',
        data: data,
      );

      debugPrint('Register response status: ${response.statusCode}');
      debugPrint('Register response headers: ${response.headers}');
      debugPrint('Register response data: ${response.data}');
      if ((response.statusCode == 201 || response.statusCode == 200) && response.data != null) {
        // Some APIs return 200 instead of 201 for successful creation
        if (response.data is String) {
          // If the response is directly a token string
          return response.data;
        } else {
          // If the response is a JSON object containing the token
          final authResponse = AuthResponseDto.fromJson(response.data);
          return authResponse.token;
        }
      }
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/api/User'),
        response: response,
        message: 'Registration failed: ${response.statusCode}\nResponse: ${response.data}',
      );
    } catch (e) {
      debugPrint('Registration attempt failed: $e');
      if (e is DioException && e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        debugPrint('Response status: $statusCode');
        debugPrint('Response headers: ${e.response?.headers}');
        debugPrint('Response data: $responseData');

        if (statusCode == 500) {
          // Try to extract more detailed error message if available
          final errorMessage = responseData is String ? responseData : responseData?['message'] ?? responseData?.toString();
          throw DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            message: 'Server error: $errorMessage\nThis might be due to:\n'
                    '1. Username/Email already exists\n'
                    '2. Database connection issues\n'
                    '3. Server configuration error',
          );
        }
      }
      rethrow;
    }
  }
}
