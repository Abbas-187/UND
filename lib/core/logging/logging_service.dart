import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Custom logger service for consistent logging across the app
class LoggingService {

  LoggingService(this._logger, this._appConfig);
  final Logger _logger;
  final AppConfig _appConfig;

  /// Log a debug message
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_appConfig.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an info message
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_appConfig.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a warning message
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_appConfig.enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an error message
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_appConfig.enableLogging) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a fatal error message
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_appConfig.enableLogging) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }
}

/// Provider for the LoggingService
final loggingServiceProvider = Provider<LoggingService>((ref) {
  final appConfig = AppConfig();

  // Create a custom logger configuration
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: appConfig.enableLogging ? Level.debug : Level.nothing,
  );

  return LoggingService(logger, appConfig);
});
