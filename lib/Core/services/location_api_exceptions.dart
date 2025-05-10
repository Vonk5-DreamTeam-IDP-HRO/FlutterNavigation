import 'package:dio/dio.dart'; // Ensure Dio is imported

// --- Custom Exceptions ---
class LocationApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData; // To store response body on error, if any
  final StackTrace? stackTrace;
  final dynamic originalException;

  LocationApiException(
    this.message, {
    this.statusCode,
    this.errorData,
    this.stackTrace,
    this.originalException,
  });

  factory LocationApiException.fromDioError(DioException dioError) {
    String errorMessage = 'A network error occurred.';
    dynamic errorDataContent;
    final int? httpStatusCode = dioError.response?.statusCode;

    if (dioError.response != null) {
      errorMessage = 'API Error: ${dioError.response?.statusCode}';
      if (dioError.response?.data != null) {
        errorDataContent = dioError.response?.data;
        if (errorDataContent is Map && errorDataContent.containsKey('title')) {
          errorMessage = errorDataContent['title'];
        } else if (errorDataContent is Map &&
            errorDataContent.containsKey('message')) {
          errorMessage = errorDataContent['message'];
        } else if (errorDataContent is String && errorDataContent.isNotEmpty) {
          errorMessage = errorDataContent;
        }
      }
    } else {
      errorMessage = dioError.message ?? 'Network request failed';
    }

    // Check for specific DioException types for more tailored messages
    if (dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.sendTimeout ||
        dioError.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Request timed out.';
      // For network exceptions, we might not have a specific API status code from the response
      // but we can use the LocationApiNetworkException structure if desired.
      // For simplicity here, we'll use the generic LocationApiException.
    }

    if (httpStatusCode == 404) {
      return LocationNotFoundException(
        dioError.requestOptions.path.contains('/')
            ? 'Resource at ${dioError.requestOptions.path.substring(dioError.requestOptions.path.lastIndexOf('/') + 1)} not found.'
            : 'Resource not found.', // Generic 404 if path parsing is tricky
        errorData: errorDataContent,
        originalException: dioError,
        stackTrace: dioError.stackTrace,
      );
    }

    return LocationApiException(
      errorMessage,
      statusCode: httpStatusCode,
      errorData: errorDataContent,
      originalException: dioError,
      stackTrace: dioError.stackTrace,
    );
  }

  @override
  String toString() {
    String output = 'LocationApiException: $message (Status Code: $statusCode)';
    if (errorData != null) {
      output += '\nError Data: $errorData';
    }
    if (originalException != null) {
      output += '\nOriginal Exception: ${originalException.toString()}';
    }
    return output;
  }
}

class LocationNotFoundException extends LocationApiException {
  LocationNotFoundException(
    super.message, {
    super.errorData,
    super.stackTrace,
    super.originalException,
  }) : super(statusCode: 404);
}

class LocationApiNetworkException extends LocationApiException {
  final Uri? uri;

  LocationApiNetworkException(
    super.message, {
    super.statusCode, // statusCode from LocationApiException is used
    String? statusMessage, // Can be part of message or errorData
    this.uri,
    dynamic errorData,
    super.stackTrace,
    super.originalException,
  }) : super(errorData: errorData ?? statusMessage);

  @override
  String toString() {
    String output = super.toString(); // Includes message and statusCode
    if (uri != null) output += '\nRequest URI: $uri';
    // errorData (which might contain statusMessage) is already handled by super.toString()
    return output;
  }
}

class LocationApiParseException extends LocationApiException {
  LocationApiParseException(
    String message, {
    dynamic errorData,
    StackTrace? stackTrace,
    dynamic originalException,
  }) : super(
         'Failed to parse API response: $message',
         errorData: errorData,
         stackTrace: stackTrace,
         originalException: originalException,
       );
}
