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
        // Check if it's a duplicate user error
        if (e is DioException && e.response?.data != null) {
          final errorMessage = e.response!.data.toString().toLowerCase();
          if (errorMessage.contains('duplicate') || 
              errorMessage.contains('already exists') ||
              errorMessage.contains('in use')) {
            rethrow; // Don't try fallback if it's a duplicate error
          }
        }
        debugPrint('Primary register failed, trying fallback: $e');
      }
      
      // Try fallback URL
      return await _attemptRegister(_fallbackBaseApiUrl, username, email, password);
    } catch (e) {
      debugPrint('Register failed on both URLs: $e');
      
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.sendTimeout || 
            e.type == DioExceptionType.receiveTimeout) {
          throw DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            message: 'Registration failed. This could be because:\n' +
                    '1. The username or email is already registered\n' +
                    '2. The server is temporarily unavailable\n' +
                    '3. There are network connectivity issues'
          );
        } else if (e.response?.data != null) {
          final errorMessage = e.response!.data.toString().toLowerCase();
          if (errorMessage.contains('duplicate') || 
              errorMessage.contains('already exists') ||
              errorMessage.contains('in use')) {
            throw DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              message: 'This username or email is already registered. Please try a different one.'
            );
          }
        }
      }
      
      // If we get here, throw a generic error with the same format
      throw e is DioException ? DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: 'Registration failed. This could be because:\n' +
                '1. The username or email is already registered\n' +
                '2. The server is temporarily unavailable\n' +
                '3. There are network connectivity issues'
      ) : e;
    }
  }

  Future<String> _attemptLogin(String baseUrl, String username, String password) async {
    try {
      debugPrint('\n=== LOGIN ATTEMPT ===');
      debugPrint('Server: $baseUrl');
      debugPrint('Endpoint: /api/User/login');
      debugPrint('Method: POST');

      final loginDto = LoginRequestDto(
        username: username,
        password: password,
      );
      
      debugPrint('Request body: ${loginDto.toJson()}');
      debugPrint('Sending POST request for login...');
      final response = await _dio.post(
        '$baseUrl/api/User/login',
        data: loginDto.toJson(),
      );

      debugPrint('\n=== RESPONSE RECEIVED ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Data: ${response.data}');
      debugPrint('=========================\n');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          // Try both cases since C# might send 'Token' or 'token'
          final token = response.data['Token'] ?? response.data['token'];
          if (token != null) {
            return token.toString();
          }
          debugPrint('Warning: Response contained a Map but no token field: ${response.data}');
        }
        return response.data.toString(); // Fallback for direct token string
      }
      String errorMessage;
      if (response.statusCode == 401) {
        errorMessage = 'Invalid username or password';
        debugPrint('Login failed: Received 401 Unauthorized - invalid credentials');
      } else if (response.statusCode == 400 && response.data is Map && response.data['errors'] != null) {
        final errors = response.data['errors'] as Map;
        final errorList = errors.values.expand((e) => e as List).toList();
        errorMessage = 'Validation error: ${errorList.join(", ")}';
        debugPrint('Login failed: Validation errors - $errorMessage');
      } else {
        errorMessage = 'Login failed: ${response.statusCode}';
      }
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/api/User/login'),
        response: response,
        message: errorMessage,
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
      
      debugPrint('\n=== REGISTRATION ATTEMPT ===');
      debugPrint('Server: $baseUrl');
      debugPrint('Endpoint: /api/User');
      debugPrint('Registration payload: ${registerDto.toJson()}');
      
      // Clean up the data and ensure proper casing
      final data = registerDto.toJson();
      debugPrint('Registration data with proper casing: $data');
      
      final uri = Uri.parse('$baseUrl/api/User').toString();
      debugPrint('Constructed URI: $uri');

      // Send the POST request
      final response = await _dio.post(
        uri,
        data: data,
          options: Options(validateStatus: (status) => status != null && status < 600),
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

        // Check for various error status codes
        if (statusCode == 400 || statusCode == 500) {
          String errorMessage = responseData is String ? responseData : responseData?['message'] ?? responseData?.toString();
          errorMessage = errorMessage.toLowerCase();

          // Check for specific error patterns
          if (errorMessage.contains('username') && (errorMessage.contains('duplicate') || errorMessage.contains('exists') || errorMessage.contains('taken'))) {
            throw DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              message: 'This username is already taken. Please choose a different username.'
            );
          } else if (errorMessage.contains('email') && (errorMessage.contains('duplicate') || errorMessage.contains('exists'))) {
            throw DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              message: 'This email address is already registered. Please use a different email or try logging in.'
            );
          } else if (errorMessage.contains('duplicate') || errorMessage.contains('already exists')) {
            throw DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              message: 'This username or email is already registered. Please try different credentials.'
            );
          } else if (errorMessage.contains('unexpected error')) {
            // This is specifically for the case you showed in the logs
            throw DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              message: 'Registration failed. Please verify your information and try again.\n\n' +
                      'This could be because:\n' +
                      '1. The username or email is already registered\n' +
                      '2. The server is temporarily unavailable\n' +
                      '3. There are network connectivity issues'
            );
          }
        }
      }
      rethrow;
    }
  }
}
