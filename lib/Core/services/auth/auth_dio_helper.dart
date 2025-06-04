import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../dio_factory.dart';

class AuthDioHelper {
  static Dio getDioWithAuth(String token) {
    debugPrint('AuthDioHelper.getDioWithAuth called');
    debugPrint('Token length: ${token.length}');
    debugPrint('Token prefix: ${token.substring(0, 20)}...');

    // Create Dio instance with auth token
    final dio = DioFactory.createDio(authToken: token);

    // Add an auth-enforcing interceptor that always ensures the token is present
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('AuthDioHelper interceptor: Adding Authorization header');
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('Final headers: ${options.headers}');
          handler.next(options);
        },
      ),
    );

    debugPrint('🔐 AuthDioHelper: Created authenticated Dio instance');
    return dio;
  }
}
