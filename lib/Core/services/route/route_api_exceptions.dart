/// Base class for exceptions specific to the RouteApiService.
class RouteApiException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;
  final Uri? uri;
  final int? statusCode;

  RouteApiException(
    this.message, {
    this.originalException,
    this.stackTrace,
    this.uri,
    this.statusCode,
  });

  @override
  String toString() {
    return 'RouteApiException: $message (StatusCode: $statusCode, URI: $uri, OriginalException: $originalException)';
  }
}

/// Exception for network-related errors during Route API calls.
class RouteApiNetworkException extends RouteApiException {
  RouteApiNetworkException(
    String message, {
    super.originalException,
    super.stackTrace,
    super.uri,
    super.statusCode,
    String? statusMessage,
  }) : super('$message (Status: $statusCode - $statusMessage)');
}

/// Exception for when a route or its related data is not found.
class RouteNotFoundException extends RouteApiException {
  RouteNotFoundException(
    super.message, {
    super.originalException,
    super.stackTrace,
    super.uri,
  }) : super(statusCode: 404);
}

/// Exception for errors during parsing of Route API response data.
class RouteApiParseException extends RouteApiException {
  RouteApiParseException(
    super.message, {
    super.originalException,
    super.stackTrace,
    super.uri,
  });
}
