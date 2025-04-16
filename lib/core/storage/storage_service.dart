import 'dart:convert';

/// Abstract interface for local storage operations
abstract class StorageService {
  /// Saves a string value to local storage
  Future<bool> setString(String key, String value);

  /// Retrieves a string value from local storage
  Future<String?> getString(String key);

  /// Saves an integer value to local storage
  Future<bool> setInt(String key, int value);

  /// Retrieves an integer value from local storage
  Future<int?> getInt(String key);

  /// Saves a double value to local storage
  Future<bool> setDouble(String key, double value);

  /// Retrieves a double value from local storage
  Future<double?> getDouble(String key);

  /// Saves a boolean value to local storage
  Future<bool> setBool(String key, bool value);

  /// Retrieves a boolean value from local storage
  Future<bool?> getBool(String key);

  /// Saves a list of strings to local storage
  Future<bool> setStringList(String key, List<String> value);

  /// Retrieves a list of strings from local storage
  Future<List<String>?> getStringList(String key);

  /// Saves an object to local storage by serializing it to JSON
  Future<bool> setObject<T>(String key, T value, {Object? Function(T)? toJson});

  /// Retrieves an object from local storage and deserializes it from JSON
  Future<T?> getObject<T>(
      String key, T Function(Map<String, dynamic>) fromJson);

  /// Removes a value from local storage
  Future<bool> remove(String key);

  /// Checks if a key exists in local storage
  Future<bool> containsKey(String key);

  /// Clears all values from local storage
  Future<bool> clear();

  /// Gets all keys from local storage
  Future<Set<String>> getKeys();
}
