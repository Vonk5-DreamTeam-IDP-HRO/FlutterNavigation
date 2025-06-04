import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/io.dart';

class DioFactory {
  // Private constructor to prevent instantiation
  DioFactory._();
  static const int _connectTimeoutMs = 10000; // 10 seconds
  static const int _receiveTimeoutMs = 30000; // 30 seconds
  static const int _sendTimeoutMs = 15000; // 15 seconds
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

          // Add auth token if available
          if (authToken != null) {
            debugPrint('Adding Authorization header with token');
            options.headers['Authorization'] = 'Bearer $authToken';
          }

          debugPrint('Final request headers: ${options.headers}');
          handler.next(options);
        },
      ),

      // 2. Debug logging interceptor
      if (kDebugMode)
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint('DIO LOG: $object'),
        ),

      // 3. Response/Error handling interceptor
      InterceptorsWrapper(
        onResponse: (response, handler) {
          debugPrint('RESPONSE [${response.statusCode}] => PATH: ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('ERROR [${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          debugPrint('Error details: ${error.message}');
          handler.next(error);
        },
      ),
    ]);

    return dio;
  }
}
