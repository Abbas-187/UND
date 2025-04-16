// lib/core/exceptions/app_exception.dart

// Application exception types
enum AppExceptionType {
  // Client errors
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,

  // Server errors
  serverError,

  // Network errors
  network,
  timeout,

  // Other errors
  unknown,
  validation
}

/// Standard application exception class for handling errors consistently
class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;
  final dynamic data;
  final AppExceptionType type;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.details,
    this.statusCode,
    this.data,
    this.type = AppExceptionType.unknown,
    this.stackTrace,
  });

  @override
  String toString() {
    return "AppException: $message${details != null ? ' Details: $details' : ''}${statusCode != null ? ' Status code: $statusCode' : ''}";
  }
}
