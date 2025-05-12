// --- Custom Exceptions for Route Service ---
// Aligned to better support wrapping generic ApiExceptions

/// Base class for exceptions specific to the RouteApiService.
class RouteApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData;
  final StackTrace? stackTrace;
  final dynamic originalException;

  RouteApiException(
    this.message, {
    this.statusCode,
    this.errorData,
    this.stackTrace,
    this.originalException,
  });

  @override
  String toString() {
    String output = 'RouteApiException: $message (Status Code: $statusCode)';
    if (errorData != null) {
      output += '\nError Data: $errorData';
    }
    if (originalException != null) {
      output += '\nOriginal Exception: ${originalException.toString()}';
    }
    return output;
  }
}

/// Exception for network-related errors during Route API calls.
class RouteApiNetworkException extends RouteApiException {
  final Uri? uri;
  final String? statusMessage; // Optional: if distinct from the main message

  RouteApiNetworkException(
    super.message, {
    super.statusCode,
    this.statusMessage,
    this.uri,
    super.errorData,
    super.stackTrace,
    super.originalException,
  });

  @override
  String toString() {
    String output = super.toString();
    if (uri != null) output += '\nRequest URI: $uri';
    if (statusMessage != null &&
        (errorData is! String || errorData != statusMessage)) {
      // Avoid duplicating statusMessage if it's already in errorData and is a string
      output += '\nStatus Message: $statusMessage';
    }
    return output;
  }
}

/// Exception for when a route or its related data is not found.
class RouteNotFoundException extends RouteApiException {
  final Uri? uri; // Optional: URI of the resource that was not found

  RouteNotFoundException(
    super.message, {
    this.uri,
    super.errorData,
    super.stackTrace,
    super.originalException,
  }) : super(statusCode: 404); // Sets statusCode to 404

  @override
  String toString() {
    String output = super.toString();
    if (uri != null) output += '\nRequest URI: $uri';
    return output;
  }
}

/// Exception for errors during parsing of Route API response data.
class RouteApiParseException extends RouteApiException {
  RouteApiParseException(
    String message, {
    super.errorData,
    super.stackTrace,
    super.originalException, // The actual parsing error
  }) : super('Failed to parse Route API response: $message');
}
