// lib/core/repositories/repository_exception.dart
class RepositoryException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  RepositoryException(this.message, {this.originalException, this.stackTrace});

  @override
  String toString() {
    return 'RepositoryException: $message ${originalException != null ? "(Original: $originalException)" : ""}';
  }
}

class DataNotFoundRepositoryException extends RepositoryException {
  DataNotFoundRepositoryException(
    String message, {
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message,
         originalException: originalException,
         stackTrace: stackTrace,
       );
}
