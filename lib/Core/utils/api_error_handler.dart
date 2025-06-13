library api_error_handler;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:osm_navigation/Core/services/api_exceptions.dart';

/// **API Error Handler**
///
/// Provides standardized error handling for Dio-based API operations by converting
/// Dio exceptions into application-specific exception types.
///
/// **Purpose:**
/// Centralizes error handling logic and provides consistent error responses
/// across all API operations in the application.
///
/// **Key Features:**
/// - Converts DioExceptions to typed ApiExceptions
/// - Handles network timeouts and connection errors
/// - Provides detailed error messages with context
/// - Preserves stack traces for debugging
///
/// **Usage:**
/// ```dart
/// try {
///   await dio.get('/users');
/// } on DioException catch (e) {
///   final apiError = handleDioError(e, 'fetching users', '/api/users');
///   // Handle the typed exception
/// }
/// ```
///
/// **Parameters:**
/// - [e]: The DioException that occurred during the API call
/// - [operation]: Description of the attempted operation
/// - [urlAttempted]: The endpoint URL that was being accessed
///
/// **Returns:**
/// An [ApiException] or its subtype ([ApiNetworkException], [ApiNotFoundException])
/// that represents the error in a standardized format.
///
/// **References:**
/// - [Dio Documentation](https://pub.dev/packages/dio)
/// - [Error Handling Best Practices](https://medium.com/@mohammadjoumani/error-handling-in-flutter-a1dfe81a2e0)
///

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
