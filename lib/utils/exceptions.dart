/// Base exception class for database operations
class DatabaseException implements Exception {
  DatabaseException(this.message);
  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception thrown when a requested document is not found
class NotFoundException implements Exception {
  NotFoundException(this.message);
  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when user doesn't have sufficient permissions
class PermissionException implements Exception {
  PermissionException(this.message);
  final String message;

  @override
  String toString() => 'PermissionException: $message';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when input validation fails
class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
