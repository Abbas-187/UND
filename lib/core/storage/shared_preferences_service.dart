import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/app_providers.dart';
import 'storage_service.dart';

/// SharedPreferences implementation of the StorageService
class SharedPreferencesService implements StorageService {
  final SharedPreferences _preferences;

  SharedPreferencesService(this._preferences);

  @override
  Future<bool> setString(String key, String value) async {
    return _preferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _preferences.getString(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return _preferences.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _preferences.getInt(key);
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    return _preferences.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _preferences.getDouble(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return _preferences.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _preferences.getBool(key);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    return _preferences.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _preferences.getStringList(key);
  }

  @override
  Future<bool> setObject<T>(String key, T value,
      {Object? Function(T)? toJson}) async {
    if (value == null) {
      return _preferences.remove(key);
    }

    try {
      final jsonData = toJson != null
          ? toJson(value)
          : (value is Map || value is List)
              ? value
              : (value as dynamic).toJson();

      return _preferences.setString(key, jsonEncode(jsonData));
    } catch (e) {
      throw Exception('Failed to serialize object of type ${T.toString()}: $e');
    }
  }

  @override
  Future<T?> getObject<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    final jsonString = _preferences.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString);
      if (json is Map<String, dynamic>) {
        return fromJson(json);
      }
      throw Exception('Stored JSON is not a Map<String, dynamic>');
    } catch (e) {
      throw Exception(
          'Failed to deserialize object of type ${T.toString()}: $e');
    }
  }

  @override
  Future<bool> remove(String key) async {
    return _preferences.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _preferences.containsKey(key);
  }

  @override
  Future<bool> clear() async {
    return _preferences.clear();
  }

  @override
  Future<Set<String>> getKeys() async {
    return _preferences.getKeys();
  }
}

/// Provider for the StorageService using SharedPreferences
final storageServiceProvider = Provider<StorageService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesService(sharedPreferences);
});
