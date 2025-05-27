import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioFactory {
  // Private constructor to prevent instantiation
  DioFactory._();

  static const int _connectTimeoutMs = 5000; // 5 seconds
  static const int _receiveTimeoutMs = 1000; // 10 seconds
  static const int _sendTimeoutMs = 15000; // 15 seconds

  static Dio createDio({String? authToken}) {
    final dio = Dio();

    final headers = {'Content-Type': 'application/json; charset=UTF-8'};

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    dio.options = BaseOptions(
      connectTimeout: const Duration(milliseconds: _connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: _receiveTimeoutMs),
      sendTimeout: const Duration(milliseconds: _sendTimeoutMs),
      headers: headers,
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    return dio;
  }
}
