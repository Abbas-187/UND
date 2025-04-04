// lib/core/exceptions/app_exception.dart
class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, {this.details});

  @override
  String toString() {
    return "AppException: $message ${details != null ? 'Details: $details' : ''}";
  }
}
