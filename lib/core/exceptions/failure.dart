// lib/core/exceptions/failure.dart
abstract class Failure {

  const Failure(this.message, {this.details});
  final String message;
  final String? details;

  @override
  String toString() =>
      "Failure: $message ${details != null ? 'Details: $details' : ''}";
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.details});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.details});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.details});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.details});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.details});
}
