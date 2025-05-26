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

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    dio.options = BaseOptions(
      connectTimeout: const Duration(milliseconds: _connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: _receiveTimeoutMs),
      sendTimeout: const Duration(milliseconds: _sendTimeoutMs),
      headers: headers,
      validateStatus: (status) {
        return status != null && status < 500;
      },
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          debugPrint('Response Status Code: ${response.statusCode}');
          debugPrint('Response Headers: ${response.headers}');
          debugPrint('Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('Error Status Code: ${error.response?.statusCode}');
          debugPrint('Error Headers: ${error.response?.headers}');
          debugPrint('Error Data: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
