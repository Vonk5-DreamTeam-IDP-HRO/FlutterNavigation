/// **DioFactory**
///
/// A factory class that creates and configures Dio HTTP client instances with
/// standardized settings and interceptors for the application.
///
/// **Purpose:**
/// Provides a centralized way to create pre-configured Dio instances with:
/// - Authentication token management
/// - Consistent timeout settings
/// - Standard headers
/// - Logging and error handling
///
/// **Key Features:**
/// - Dynamic token management via provider pattern
/// - Configurable timeout settings
/// - Debug logging in development
/// - Standardized error handling
/// - Request/response interceptors
///
/// **Usage:**
/// ```dart
/// // Create a Dio instance with optional auth token
/// final dio = DioFactory.createDio();
///
/// // Set a token provider for dynamic token management
/// DioFactory.setTokenProvider(() => authService.currentToken);
/// ```
///
/// **Configuration:**
/// - Connect timeout: 10 seconds
/// - Receive timeout: 30 seconds
/// - Send timeout: 15 seconds
///
library dio_factory;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Factory for creating configured Dio instances.
///
/// This class cannot be instantiated and provides static methods for creating
/// and configuring Dio instances with standardized settings.
class DioFactory {
  // --- Private Constructor ---
  DioFactory._();
  // --- Constants ---
  static const int _connectTimeoutMs = 10000; // 10 seconds
  static const int _receiveTimeoutMs = 30000; // 30 seconds
  static const int _sendTimeoutMs = 15000; // 15 seconds

  // --- State ---
  static String? Function()? _tokenProvider; // Provides current auth token

  // --- Public Methods ---
  /// Sets the function that provides the current authentication token.
  ///
  /// The provider function should return the current token as a String, or null
  /// if no token is available. This is typically set by the AuthViewModel.
  static void setTokenProvider(String? Function()? provider) {
    _tokenProvider = provider;
    debugPrint('DioFactory: Token provider set');
  }

  /// Creates a new Dio instance with standardized configuration and interceptors.
  ///
  /// The created instance includes:
  /// - Standard timeout configurations
  /// - Default headers for JSON communication
  /// - Token-based authentication handling
  /// - Debug logging (in debug mode)
  /// - Error handling interceptors
  ///
  /// Parameters:
  ///   - [authToken]: Optional static auth token. If not provided, the token
  ///     provider will be used instead.
  ///
  /// Returns:
  ///   A configured [Dio] instance ready for use.
  ///
  /// Example:
  /// ```dart
  /// final dio = DioFactory.createDio(authToken: 'myStaticToken');
  /// // or
  /// final dio = DioFactory.createDio(); // Uses token provider
  /// ```
  static Dio createDio({String? authToken}) {
    debugPrint(
      'DioFactory.createDio called with authToken: ${authToken != null ? "EXISTS (${authToken.length} chars)" : "NULL"}',
    );
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    debugPrint('DioFactory: Creating Dio instance');

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: _connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: _receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: _sendTimeoutMs),
        headers: defaultHeaders,
        validateStatus: (status) => status != null && status < 600,
        followRedirects: false,
        maxRedirects: 0,
      ),
    );

    dio.interceptors.addAll([
      // --- Interceptors ---
      // 1. Header management interceptor (first, to ensure headers are set)
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('REQUEST INTERCEPTOR - Setting headers');
          // Always set base headers
          options.headers.addAll(defaultHeaders);

          // Determine which token to use: explicit authToken or dynamic token from provider
          String? tokenToUse = authToken;
          if (tokenToUse == null && _tokenProvider != null) {
            tokenToUse = _tokenProvider!();
            debugPrint(
              'Retrieved token from provider: ${tokenToUse != null ? "EXISTS (${tokenToUse.length} chars)" : "NULL"}',
            );
          }

          // Add auth token if available
          if (tokenToUse != null) {
            debugPrint('Adding Authorization header with token');
            options.headers['Authorization'] = 'Bearer $tokenToUse';
          } else {
            debugPrint(
              'No auth token available - proceeding without Authorization header',
            );
          }

          debugPrint('Final request headers: ${options.headers}');
          handler.next(options);
        },
      ),

      // 2. Debug logging interceptor
      if (kDebugMode)
        LogInterceptor(
          request: false,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) {
            if (object.toString().startsWith('DioException')) {
              debugPrint('DIO ERROR: $object');
            } else {
              debugPrint('DIO: $object');
            }
          },
        ),

      // 3. Error handling interceptor
      InterceptorsWrapper(
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) => handler.next(error),
      ),
    ]);

    return dio;
  }
}
