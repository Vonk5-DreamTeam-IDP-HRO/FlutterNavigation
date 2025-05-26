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
