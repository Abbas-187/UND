import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data/unified_data_manager.dart';

/// Error types for categorization
enum ErrorType {
  network,
  database,
  validation,
  permission,
  calculation,
  ui,
  unknown,
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Application error with context
class AppError {
  const AppError({
    required this.message,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.stackTrace,
    this.context,
    this.userId,
    this.sessionId,
    this.additionalData,
  });

  final String message;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final String? context;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic>? additionalData;

  Map<String, dynamic> toJson() => {
        'message': message,
        'type': type.toString(),
        'severity': severity.toString(),
        'timestamp': timestamp.toIso8601String(),
        'stackTrace': stackTrace?.toString(),
        'context': context,
        'userId': userId,
        'sessionId': sessionId,
        'additionalData': additionalData,
      };
}

/// Error analytics and monitoring
class ErrorAnalytics {
  static final Logger _logger = Logger();
  static final List<AppError> _errorHistory = [];
  static const int _maxHistorySize = 1000;

  /// Track an error
  static void trackError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    ErrorType? type,
    ErrorSeverity? severity,
    Map<String, dynamic>? additionalData,
  }) {
    final appError = AppError(
      message: error.toString(),
      type: type ?? _categorizeError(error),
      severity: severity ?? _determineSeverity(error),
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
      context: context,
      additionalData: additionalData,
    );

    _addToHistory(appError);
    _logError(appError);
    _reportCriticalErrors(appError);
  }

  /// Categorize error type
  static ErrorType _categorizeError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return ErrorType.network;
    }

    if (errorString.contains('firestore') ||
        errorString.contains('database') ||
        errorString.contains('sql')) {
      return ErrorType.database;
    }

    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return ErrorType.validation;
    }

    if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return ErrorType.permission;
    }

    if (errorString.contains('calculation') ||
        errorString.contains('arithmetic')) {
      return ErrorType.calculation;
    }

    return ErrorType.unknown;
  }

  /// Determine error severity
  static ErrorSeverity _determineSeverity(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('critical') ||
        errorString.contains('fatal') ||
        errorString.contains('crash')) {
      return ErrorSeverity.critical;
    }

    if (errorString.contains('error') || errorString.contains('exception')) {
      return ErrorSeverity.high;
    }

    if (errorString.contains('warning') || errorString.contains('deprecated')) {
      return ErrorSeverity.medium;
    }

    return ErrorSeverity.low;
  }

  /// Add error to history
  static void _addToHistory(AppError error) {
    _errorHistory.add(error);

    // Maintain history size
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }
  }

  /// Log error with appropriate level
  static void _logError(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.critical:
        _logger.f('CRITICAL: ${error.message}');
        if (error.stackTrace != null) {
          _logger.f('Stack trace: ${error.stackTrace}');
        }
        break;
      case ErrorSeverity.high:
        _logger.e('ERROR: ${error.message}');
        if (error.stackTrace != null) {
          _logger.e('Stack trace: ${error.stackTrace}');
        }
        break;
      case ErrorSeverity.medium:
        _logger.w('WARNING: ${error.message}');
        break;
      case ErrorSeverity.low:
        _logger.i('INFO: ${error.message}');
        break;
    }
  }

  /// Report critical errors
  static void _reportCriticalErrors(AppError error) {
    if (error.severity == ErrorSeverity.critical) {
      // In production, send to crash reporting service
      _logger.f('CRITICAL ERROR REPORTED: ${error.toJson()}');
    }
  }

  /// Get error statistics
  static Map<String, dynamic> getErrorStats() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastHour = now.subtract(const Duration(hours: 1));

    final recent24h =
        _errorHistory.where((e) => e.timestamp.isAfter(last24Hours));
    final recent1h = _errorHistory.where((e) => e.timestamp.isAfter(lastHour));

    return {
      'totalErrors': _errorHistory.length,
      'errorsLast24h': recent24h.length,
      'errorsLastHour': recent1h.length,
      'criticalErrors': _errorHistory
          .where((e) => e.severity == ErrorSeverity.critical)
          .length,
      'errorsByType': _groupErrorsByType(),
      'errorsBySeverity': _groupErrorsBySeverity(),
    };
  }

  static Map<String, int> _groupErrorsByType() {
    final groups = <String, int>{};
    for (final error in _errorHistory) {
      final type = error.type.toString();
      groups[type] = (groups[type] ?? 0) + 1;
    }
    return groups;
  }

  static Map<String, int> _groupErrorsBySeverity() {
    final groups = <String, int>{};
    for (final error in _errorHistory) {
      final severity = error.severity.toString();
      groups[severity] = (groups[severity] ?? 0) + 1;
    }
    return groups;
  }

  /// Clear error history
  static void clearHistory() {
    _errorHistory.clear();
  }
}

/// Error state for providers
@immutable
class ErrorState {
  const ErrorState({
    this.error,
    this.stackTrace,
    this.canRetry = true,
    this.retryCount = 0,
    this.maxRetries = 3,
  });

  final Object? error;
  final StackTrace? stackTrace;
  final bool canRetry;
  final int retryCount;
  final int maxRetries;

  bool get hasError => error != null;
  bool get canRetryAgain => canRetry && retryCount < maxRetries;

  ErrorState copyWith({
    Object? error,
    StackTrace? stackTrace,
    bool? canRetry,
    int? retryCount,
    int? maxRetries,
  }) {
    return ErrorState(
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      canRetry: canRetry ?? this.canRetry,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }
}

/// Error boundary provider
final errorBoundaryProvider =
    StateNotifierProvider<ErrorBoundaryNotifier, ErrorState>((ref) {
  return ErrorBoundaryNotifier();
});

/// Error boundary state notifier
class ErrorBoundaryNotifier extends StateNotifier<ErrorState> {
  ErrorBoundaryNotifier() : super(const ErrorState());

  /// Handle error with automatic retry logic
  Future<void> handleError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    bool canRetry = true,
  }) async {
    // Track error
    ErrorAnalytics.trackError(
      error,
      stackTrace,
      context: context,
    );

    // Update state
    state = state.copyWith(
      error: error,
      stackTrace: stackTrace,
      canRetry: canRetry,
    );

    // Auto-retry for certain error types
    if (canRetry && _shouldAutoRetry(error)) {
      await Future.delayed(Duration(seconds: 2 * (state.retryCount + 1)));
      await retry();
    }
  }

  /// Retry the failed operation
  Future<void> retry() async {
    if (!state.canRetryAgain) return;

    state = state.copyWith(
      retryCount: state.retryCount + 1,
    );

    // Clear error to trigger retry
    clearError();
  }

  /// Clear error state
  void clearError() {
    state = const ErrorState();
  }

  /// Check if error should auto-retry
  bool _shouldAutoRetry(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection');
  }
}

/// Error boundary widget
class ErrorBoundary extends ConsumerWidget {
  const ErrorBoundary({
    required this.child,
    this.onError,
    this.errorBuilder,
    super.key,
  });

  final Widget child;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final Widget Function(
      Object error, StackTrace? stackTrace, VoidCallback retry)? errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorState = ref.watch(errorBoundaryProvider);

    if (errorState.hasError) {
      return errorBuilder?.call(
            errorState.error!,
            errorState.stackTrace,
            () => ref.read(errorBoundaryProvider.notifier).retry(),
          ) ??
          _DefaultErrorWidget(
            error: errorState.error!,
            stackTrace: errorState.stackTrace,
            canRetry: errorState.canRetryAgain,
            onRetry: () => ref.read(errorBoundaryProvider.notifier).retry(),
            onDismiss: () =>
                ref.read(errorBoundaryProvider.notifier).clearError(),
          );
    }

    return child;
  }
}

/// Default error widget
class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({
    required this.error,
    required this.stackTrace,
    required this.canRetry,
    required this.onRetry,
    required this.onDismiss,
  });

  final Object error;
  final StackTrace? stackTrace;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (canRetry) ...[
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(width: 16),
                  ],
                  OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Async error boundary for handling Future errors
class AsyncErrorBoundary<T> extends ConsumerWidget {
  const AsyncErrorBoundary({
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });

  final Future<T> future;
  final Widget Function(T data) builder;
  final Widget Function(
      Object error, StackTrace? stackTrace, VoidCallback retry)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call() ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }

        if (snapshot.hasError) {
          // Track error
          ErrorAnalytics.trackError(
            snapshot.error!,
            snapshot.stackTrace,
            context: 'AsyncErrorBoundary',
          );

          return errorBuilder?.call(
                snapshot.error!,
                snapshot.stackTrace,
                () {
                  // Trigger rebuild by calling setState on parent
                },
              ) ??
              _DefaultErrorWidget(
                error: snapshot.error!,
                stackTrace: snapshot.stackTrace,
                canRetry: true,
                onRetry: () {
                  // Trigger rebuild
                },
                onDismiss: () {
                  Navigator.of(context).pop();
                },
              );
        }

        if (snapshot.hasData) {
          return builder(snapshot.data as T);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Performance monitoring widget
class PerformanceMonitorWidget extends StatefulWidget {
  const PerformanceMonitorWidget({
    required this.child,
    this.monitoringEnabled = true,
    super.key,
  });

  final Widget child;
  final bool monitoringEnabled;

  @override
  State<PerformanceMonitorWidget> createState() =>
      _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  late final Stopwatch _stopwatch;
  static const Duration _slowRenderThreshold = Duration(milliseconds: 16);

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();

    if (widget.monitoringEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stopwatch.start();
      });
    }
  }

  @override
  void dispose() {
    if (widget.monitoringEnabled && _stopwatch.isRunning) {
      _stopwatch.stop();
      final renderTime = _stopwatch.elapsed;

      if (renderTime > _slowRenderThreshold) {
        ErrorAnalytics.trackError(
          'Slow render detected: ${renderTime.inMilliseconds}ms',
          null,
          context: 'PerformanceMonitor',
          type: ErrorType.ui,
          severity: ErrorSeverity.medium,
          additionalData: {
            'renderTimeMs': renderTime.inMilliseconds,
            'threshold': _slowRenderThreshold.inMilliseconds,
          },
        );
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
