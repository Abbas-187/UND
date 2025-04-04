// lib/core/exceptions/failure.dart
abstract class Failure {
  final String message;
  final String? details;

  const Failure(this.message, {this.details});

  @override
  String toString() =>
      "Failure: $message ${details != null ? 'Details: $details' : ''}";
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {String? details})
      : super(message, details: details);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? details})
      : super(message, details: details);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? details})
      : super(message, details: details);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? details})
      : super(message, details: details);
}

class AuthFailure extends Failure {
  const AuthFailure(String message, {String? details})
      : super(message, details: details);
}
