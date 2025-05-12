import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Base class for all API service-related exceptions.
class ApiException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  final Object? originalException; // The original exception that was caught

  ApiException(this.message, {this.stackTrace, this.originalException});

  @override
  String toString() {
    String output = 'ApiException: $message';
    if (originalException != null) {
      output += '\nOriginal exception: ${originalException.toString()}';
    }
    // StackTrace is intentionally omitted from default toString for brevity
    return output;
  }
}

/// Exception for network-related errors during API calls.
class ApiNetworkException extends ApiException {
  final int? statusCode;
  final String? statusMessage;
  final Uri? uri;

  ApiNetworkException(
    String message, {
    this.statusCode,
    this.statusMessage,
    this.uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         stackTrace: stackTrace,
         originalException: originalException,
       );

  @override
  String toString() {
    String output =
        'ApiNetworkException: $message (StatusCode: $statusCode, StatusMessage: $statusMessage, URI: $uri)';
    if (originalException != null) {
      output += '\nOriginal exception: ${originalException.toString()}';
    }
    return output;
  }
}

/// Exception for when the API returns a 400 Bad Request error.
class ApiBadRequestException extends ApiNetworkException {
  ApiBadRequestException(
    String message, {
    int? statusCode = 400,
    String? statusMessage = "Bad Request",
    Uri? uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         statusCode: statusCode,
         statusMessage: statusMessage,
         uri: uri,
         stackTrace: stackTrace,
         originalException: originalException,
       );
}

/// Exception for when the API returns a 401 Unauthorized error.
class ApiUnauthorizedException extends ApiNetworkException {
  ApiUnauthorizedException(
    String message, {
    int? statusCode = 401,
    String? statusMessage = "Unauthorized",
    Uri? uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         statusCode: statusCode,
         statusMessage: statusMessage,
         uri: uri,
         stackTrace: stackTrace,
         originalException: originalException,
       );
}

/// Exception for when the API returns a 403 Forbidden error.
class ApiForbiddenException extends ApiNetworkException {
  ApiForbiddenException(
    String message, {
    int? statusCode = 403,
    String? statusMessage = "Forbidden",
    Uri? uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         statusCode: statusCode,
         statusMessage: statusMessage,
         uri: uri,
         stackTrace: stackTrace,
         originalException: originalException,
       );
}

/// Exception for when the API returns a 500 Internal Server Error.
class ApiInternalServerErrorException extends ApiNetworkException {
  ApiInternalServerErrorException(
    String message, {
    int? statusCode = 500,
    String? statusMessage = "Internal Server Error",
    Uri? uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         statusCode: statusCode,
         statusMessage: statusMessage,
         uri: uri,
         stackTrace: stackTrace,
         originalException: originalException,
       );
}

/// Exception for when the API returns a 503 Service Unavailable error.
class ApiServiceUnavailableException extends ApiNetworkException {
  ApiServiceUnavailableException(
    String message, {
    int? statusCode = 503,
    String? statusMessage = "Service Unavailable",
    Uri? uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         statusCode: statusCode,
         statusMessage: statusMessage,
         uri: uri,
         stackTrace: stackTrace,
         originalException: originalException,
       );
}

/// Exception for when an API request times out.
class ApiTimeoutException extends ApiNetworkException {
  ApiTimeoutException(
    String message, {
    Uri? uri,

    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         uri: uri,
         stackTrace: stackTrace,
         originalException: originalException,
       );
}

/// Exception for when there's a connection error (e.g., no internet).
class ApiConnectionException extends ApiNetworkException {
  ApiConnectionException(
    String message, {
    Uri? uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         uri: uri, // statusCode and statusMessage might not be relevant
         stackTrace: stackTrace,
         originalException: originalException,
       );
}

/// Exception for when an API resource is not found (e.g., 404).
class ApiNotFoundException extends ApiException {
  final Uri? uri;

  ApiNotFoundException(
    String message, {
    this.uri,
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         stackTrace: stackTrace,
         originalException: originalException,
       );

  @override
  String toString() {
    String output = 'ApiNotFoundException: $message (URI: $uri)';

    if (originalException != null) {
      output += '\nOriginal exception: ${originalException.toString()}';
    }
    return output;
  }
}

/// Exception for errors during parsing of API responses.
class ApiParseException extends ApiException {
  ApiParseException(
    String message, {
    StackTrace? stackTrace,
    Object? originalException,
  }) : super(
         message,
         stackTrace: stackTrace,
         originalException: originalException,
       );

  @override
  String toString() {
    String output = 'ApiParseException: $message';

    if (originalException != null) {
      output += '\nOriginal exception: ${originalException.toString()}';
    }
    return output;
  }
}
