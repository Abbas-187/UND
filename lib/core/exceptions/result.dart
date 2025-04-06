import 'failure.dart';

/// A class that represents either a successful result with data or a failure.
class Result<T> {

  const Result._({T? data, Failure? failure})
      : _data = data,
        _failure = failure;

  /// Creates a successful result with the given data
  factory Result.success(T data) => Result._(data: data);

  /// Creates a failure result with the given failure
  factory Result.failure(Failure failure) => Result._(failure: failure);
  final T? _data;
  final Failure? _failure;

  /// Returns true if the result was a success
  bool get isSuccess => _failure == null;

  /// Returns true if the result was a failure
  bool get isFailure => _failure != null;

  /// If the result is a success, returns the data
  /// If the result is a failure, throws an exception
  T get getOrThrow {
    if (isSuccess) {
      return _data as T;
    } else {
      throw Exception(_failure.toString());
    }
  }

  /// Returns the data if successful, or null if failure
  T? get data => _data;

  /// Returns the failure if failed, or null if successful
  Failure? get failure => _failure;

  /// Transforms the result using the given function
  Result<R> map<R>(R Function(T) transform) {
    if (isSuccess) {
      return Result.success(transform(_data as T));
    } else {
      return Result.failure(_failure!);
    }
  }

  /// Executes one of the provided functions depending on the result state
  R fold<R>(
    R Function(T) onSuccess,
    R Function(Failure) onFailure,
  ) {
    if (isSuccess) {
      return onSuccess(_data as T);
    } else {
      return onFailure(_failure!);
    }
  }
}
