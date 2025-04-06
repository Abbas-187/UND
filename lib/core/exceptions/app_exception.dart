// lib/core/exceptions/app_exception.dart
class AppException implements Exception {

  AppException(this.message, {this.details});
  final String message;
  final String? details;

  @override
  String toString() {
    return "AppException: $message ${details != null ? 'Details: $details' : ''}";
  }
}
