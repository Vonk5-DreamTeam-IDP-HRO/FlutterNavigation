import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:osm_navigation/core/config/app_config.dart';
import 'package:osm_navigation/Core/models/auth_dtos.dart';

class AuthApiService {
  final Dio _dio;
  static String get _primaryBaseApiUrl =>
      '${AppConfig.url}:${AppConfig.backendApiPort}';
  static String get _fallbackBaseApiUrl =>
      '${AppConfig.thijsApiUrl}:${AppConfig.backendApiPort}';

  const AuthApiService(this._dio);

  Future<String> login(String username, String password) async {
    try {
      // Try primary URL first
      try {
        final response = await _attemptLogin(
          _primaryBaseApiUrl,
          username,
          password,
        );
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

  Future<String> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      // Try primary URL first
      try {
        final response = await _attemptRegister(
          _primaryBaseApiUrl,
          username,
          email,
          password,
        );
        return response;
      } catch (e) {
        debugPrint('Primary register failed, trying fallback: $e');
      }

      // Try fallback URL
      return await _attemptRegister(
        _fallbackBaseApiUrl,
        username,
        email,
        password,
      );
    } catch (e) {
      debugPrint('Register failed on both URLs: $e');
      rethrow;
    }
  }

  Future<String> _attemptLogin(
    String baseUrl,
    String username,
    String password,
  ) async {
    try {
      debugPrint('\n=== LOGIN ATTEMPT ===');
      debugPrint('Server: $baseUrl');
      debugPrint('Endpoint: /api/User/login');
      debugPrint('Method: POST');

      final loginDto = LoginRequestDto(username: username, password: password);

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

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map) {
        final token = response.data['data'] as String?;
        if (token != null && token.isNotEmpty) {
          return token;
        }
        debugPrint(
          "Warning: Login response did not contain a valid token in the 'data' field: ${response.data}",
        );
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              "Login response did not contain a valid token in the 'data' field.",
        );
      }
      String errorMessage;
      if (response.statusCode == 401) {
        errorMessage = 'Invalid username or password';
        debugPrint(
          'Login failed: Received 401 Unauthorized - invalid credentials',
        );
      } else if (response.statusCode == 400 &&
          response.data is Map &&
          response.data['errors'] != null) {
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

  Future<String> _attemptRegister(
    String baseUrl,
    String username,
    String email,
    String password,
  ) async {
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
        options: Options(
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      debugPrint('Register response status: ${response.statusCode}');
      debugPrint('Register response headers: ${response.headers}');
      debugPrint('Register response data: ${response.data}');
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data != null &&
          response.data is Map) {
        final token = response.data['data'] as String?;
        if (token != null && token.isNotEmpty) {
          return token;
        }
        debugPrint(
          "Warning: Registration response did not contain a valid token in the 'data' field: ${response.data}",
        );
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              "Registration response did not contain a valid token in the 'data' field.",
        );
      }
      throw DioException(
        requestOptions: RequestOptions(path: '$baseUrl/api/User'),
        response: response,
        message:
            'Registration failed: ${response.statusCode}\nResponse: ${response.data}',
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
          final errorMessage =
              responseData is String
                  ? responseData
                  : responseData?['message'] ?? responseData?.toString();
          // Try to provide more specific error messages based on the response
          String detailedError =
              'Server error: $errorMessage\n\nPossible causes:\n';
          if (errorMessage.toLowerCase().contains('duplicate') ||
              errorMessage.toLowerCase().contains('already exists')) {
            detailedError += '- Username or email is already registered\n';
          } else if (errorMessage.toLowerCase().contains('password')) {
            detailedError +=
                '- Password does not meet requirements (min 8 chars, letters and numbers)\n';
          } else if (errorMessage.toLowerCase().contains('email')) {
            detailedError += '- Email format is invalid\n';
          } else if (errorMessage.toLowerCase().contains('database') ||
              errorMessage.toLowerCase().contains('connection')) {
            detailedError +=
                '- Database connection issues\n- Server might be temporarily unavailable\n';
          } else {
            detailedError +=
                '- Username/Email validation failed\n'
                '- Database connection issues\n'
                '- Server configuration error\n'
                '- Network connectivity problems';
          }

          throw DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            message: detailedError,
          );
        }
      }
      rethrow;
    }
  }
}
