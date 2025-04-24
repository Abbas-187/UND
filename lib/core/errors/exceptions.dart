// Specialized exceptions for API operations
import '../exceptions/app_exception.dart';

/// Exception for network connectivity issues
class NetworkException extends AppException {
  NetworkException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.network,
          data: data,
        );
}

/// Exception for unauthorized access (401)
class UnauthorizedException extends AppException {
  UnauthorizedException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.unauthorized,
          statusCode: 401,
          data: data,
        );
}

/// Exception for forbidden access (403)
class ForbiddenException extends AppException {
  ForbiddenException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.forbidden,
          statusCode: 403,
          data: data,
        );
}

/// Exception for resource not found (404)
class NotFoundException extends AppException {
  NotFoundException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.notFound,
          statusCode: 404,
          data: data,
        );
}

/// Exception for validation errors (400)
class ValidationException extends AppException {
  ValidationException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.validation,
          statusCode: 400,
          data: data,
        );
}

/// Exception for conflict errors (409)
class ConflictException extends AppException {
  ConflictException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.conflict,
          statusCode: 409,
          data: data,
        );
}

/// Exception for API errors
class ApiException extends AppException {
  ApiException(String message, {int? statusCode, dynamic data})
      : super(
          message: message,
          type: AppExceptionType.serverError,
          statusCode: statusCode ?? 500,
          data: data,
        );
}

/// Exception for data parsing errors
class DataParsingException extends AppException {
  DataParsingException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.unknown,
          data: data,
        );
}

/// Exception for service-level errors
class ServiceException extends AppException {
  ServiceException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.unknown,
          data: data,
        );
}

/// Exception for request timeouts
class RequestTimeoutException extends AppException {
  RequestTimeoutException(String message, {dynamic data})
      : super(
          message: message,
          type: AppExceptionType.timeout,
          data: data,
        );
}
