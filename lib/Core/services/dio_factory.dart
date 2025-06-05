import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioFactory {
  // Private constructor to prevent instantiation
  DioFactory._();
  static const int _connectTimeoutMs = 10000; // 10 seconds
  static const int _receiveTimeoutMs = 30000; // 30 seconds
  static const int _sendTimeoutMs = 15000; // 15 seconds

  // Static function to provide current auth token - will be set by AuthViewModel
  static String? Function()? _tokenProvider;

  /// Sets the token provider function that will be called to get the current auth token
  static void setTokenProvider(String? Function()? provider) {
    _tokenProvider = provider;
    debugPrint('DioFactory: Token provider set');
  }

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
