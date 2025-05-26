import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:osm_navigation/Core/services/api_exceptions.dart';

/// Handles Dio errors and converts them to generic [ApiException] types.
///
/// This utility function can be used by any API service that uses Dio
/// to ensure consistent error handling.
///
/// - [e]: The [DioException] that occurred.
/// - [operation]: A descriptive string of the operation being attempted
///   (e.g., "fetching user data", "creating new item").
/// - [urlAttempted]: The URL that was being accessed when the error occurred.
///
/// Returns an [ApiException] (or a subtype like [ApiNetworkException])
/// representing the error.
/// Some of the information can be found on https://pub.dev/packages/dio Also https://medium.com/@mohammadjoumani/error-handling-in-flutter-a1dfe81a2e0
/// and
ApiException handleDioError(
  DioException e,
  String operation,
  String
  urlAttempted, // Optional: could also get from e.requestOptions.uri.toString()
) {
  // It's good practice to log the error.
  // Using debugPrint for simplicity, but a proper logging solution is better for production.
  debugPrint(
    '[ApiErrorHandler] DioError during $operation at $urlAttempted: ${e.message}, Type: ${e.type}',
  );

  if (e.response != null) {
    // Error with a response from the server (e.g., 4xx, 5xx)
    // We can check e.response.statusCode here for more specific errors if needed.
    // For example, a 404 could be mapped to ApiNotFoundException.
    if (e.response?.statusCode == 404) {
      return ApiNotFoundException(
        'Resource not found during $operation at $urlAttempted (404)',
        uri: e.requestOptions.uri,
        stackTrace: e.stackTrace,
        originalException: e,
      );
    }
    return ApiNetworkException(
      'Network error during $operation: ${e.response?.statusCode}',
      statusCode: e.response?.statusCode,
      statusMessage: e.response?.statusMessage,
      uri: e.requestOptions.uri,
      originalException: e,
      stackTrace: e.stackTrace,
    );
  } else if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    // Timeout errors
    return ApiNetworkException(
      'Request timed out during $operation at $urlAttempted',
      uri: e.requestOptions.uri,
      originalException: e,
      stackTrace: e.stackTrace,
    );
  } else if (e.type == DioExceptionType.cancel) {
    // Request was cancelled
    return ApiException(
      'Request was cancelled during $operation at $urlAttempted',
      stackTrace: e.stackTrace,
      originalException: e,
    );
  } else if (e.type == DioExceptionType.connectionError) {
    // Connection errors (e.g. DNS issue, host unreachable)
    return ApiNetworkException(
      'Connection error during $operation at $urlAttempted: ${e.message}',
      uri: e.requestOptions.uri,
      originalException: e,
      stackTrace: e.stackTrace,
    );
  }
  // For other DioException types or if e.response is null (e.g., setup errors)
  return ApiException(
    'Failed $operation at $urlAttempted: ${e.message}',
    stackTrace: e.stackTrace,
    originalException: e,
  );
}
