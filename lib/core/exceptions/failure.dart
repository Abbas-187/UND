// lib/core/exceptions/failure.dart

import 'app_exception.dart';

/// Base Failure class for domain layer error handling
abstract class Failure {
  const Failure(this.message, {this.details, this.statusCode, this.stackTrace});

  final String message;
  final String? details;
  final int? statusCode;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      "Failure: $message ${details != null ? ' Details: $details' : ''}${statusCode != null ? ' Status code: $statusCode' : ''}";
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Resource not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Input validation failures
class ValidationFailure extends Failure {
  final Map<String, List<String>>? validationErrors;

  const ValidationFailure(
    super.message, {
    super.details,
    super.statusCode,
    super.stackTrace,
    this.validationErrors,
  });
}

/// Unknown or unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Cache or local storage failures
class CacheFailure extends Failure {
  const CacheFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Business logic or domain rule failures
class BusinessFailure extends Failure {
  const BusinessFailure(super.message,
      {super.details, super.statusCode, super.stackTrace});
}

/// Extension to convert AppException to Failure
extension AppExceptionToFailure on AppException {
  Failure toFailure() {
    switch (type) {
      case AppExceptionType.serverError:
        return ServerFailure(message,
            details: details, statusCode: statusCode, stackTrace: stackTrace);
      case AppExceptionType.notFound:
        return NotFoundFailure(message,
            details: details, statusCode: statusCode, stackTrace: stackTrace);
      case AppExceptionType.validation:
        return ValidationFailure(message,
            details: details, statusCode: statusCode, stackTrace: stackTrace);
      case AppExceptionType.unauthorized:
      case AppExceptionType.forbidden:
        return AuthFailure(message,
            details: details, statusCode: statusCode, stackTrace: stackTrace);
      case AppExceptionType.network:
      case AppExceptionType.timeout:
        return NetworkFailure(message,
            details: details, statusCode: statusCode, stackTrace: stackTrace);
      default:
        return UnknownFailure(message,
            details: details, statusCode: statusCode, stackTrace: stackTrace);
    }
  }
}
