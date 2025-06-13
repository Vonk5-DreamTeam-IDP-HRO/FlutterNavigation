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
    super.message, {
    this.statusCode,
    this.statusMessage,
    this.uri,
    super.stackTrace,
    super.originalException,
  });

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
    super.message, {
    super.statusCode = 400,
    super.statusMessage = 'Bad Request',
    super.uri,
    super.stackTrace,
    super.originalException,
  });
}

/// Exception for when the API returns a 401 Unauthorized error.
class ApiUnauthorizedException extends ApiNetworkException {
  ApiUnauthorizedException(
    super.message, {
    super.statusCode = 401,
    super.statusMessage = 'Unauthorized',
    super.uri,
    super.stackTrace,
    super.originalException,
  });
}

/// Exception for when the API returns a 403 Forbidden error.
class ApiForbiddenException extends ApiNetworkException {
  ApiForbiddenException(
    super.message, {
    super.statusCode = 403,
    super.statusMessage = 'Forbidden',
    super.uri,
    super.stackTrace,
    super.originalException,
  });
}

/// Exception for when the API returns a 500 Internal Server Error.
class ApiInternalServerErrorException extends ApiNetworkException {
  ApiInternalServerErrorException(
    super.message, {
    super.statusCode = 500,
    super.statusMessage = 'Internal Server Error',
    super.uri,
    super.stackTrace,
    super.originalException,
  });
}

/// Exception for when the API returns a 503 Service Unavailable error.
class ApiServiceUnavailableException extends ApiNetworkException {
  ApiServiceUnavailableException(
    super.message, {
    super.statusCode = 503,
    super.statusMessage = 'Service Unavailable',
    super.uri,
    super.stackTrace,
    super.originalException,
  });
}

/// Exception for when an API request times out.
class ApiTimeoutException extends ApiNetworkException {
  ApiTimeoutException(
    super.message, {
    super.uri,

    super.stackTrace,
    super.originalException,
  });
}

/// Exception for when there's a connection error (e.g., no internet).
class ApiConnectionException extends ApiNetworkException {
  ApiConnectionException(
    super.message, {
    super.uri,
    super.stackTrace,
    super.originalException,
  });
}

/// Exception for when an API resource is not found (e.g., 404).
class ApiNotFoundException extends ApiException {
  final Uri? uri;

  ApiNotFoundException(
    super.message, {
    this.uri,
    super.stackTrace,
    super.originalException,
  });

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
  ApiParseException(super.message, {super.stackTrace, super.originalException});

  @override
  String toString() {
    String output = 'ApiParseException: $message';

    if (originalException != null) {
      output += '\nOriginal exception: ${originalException.toString()}';
    }
    return output;
  }
}
