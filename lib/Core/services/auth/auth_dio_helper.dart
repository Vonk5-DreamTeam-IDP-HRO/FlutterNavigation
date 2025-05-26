import 'package:dio/dio.dart';
import '../dio_factory.dart';

class AuthDioHelper {
  static Dio getDioWithAuth(String token) {
    return DioFactory.createDio(authToken: token);
  }
}
