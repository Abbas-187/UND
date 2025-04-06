import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../auth/models/app_user.dart';

/// Provider for the local database service
final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  return LocalDatabaseService();
});

/// Service for managing local database operations
class LocalDatabaseService {
  static const String _userPrefsKey = 'currentUser';
  static const String _lastSyncTimeKey = 'lastSyncTime';

  Database? _database;
  SharedPreferences? _prefs;

  /// Initialize the database and shared preferences
  Future<void> initialize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'und_app.db');

    // Initialize database
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create tables
        await db.execute(
          'CREATE TABLE inventory (id TEXT PRIMARY KEY, data TEXT)',
        );
        await db.execute(
          'CREATE TABLE suppliers (id TEXT PRIMARY KEY, data TEXT)',
        );
        await db.execute(
          'CREATE TABLE sales (id TEXT PRIMARY KEY, data TEXT)',
        );
        await db.execute(
          'CREATE TABLE forecasting (id TEXT PRIMARY KEY, data TEXT)',
        );
        await db.execute(
          'CREATE TABLE sync_queue (key INTEGER PRIMARY KEY AUTOINCREMENT, id TEXT, operation TEXT, collection TEXT, data TEXT, timestamp TEXT)',
        );
      },
    );

    // Initialize shared preferences
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save the current user to local storage
  Future<void> saveCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPrefsKey, jsonEncode(user.toJson()));
  }

  /// Get the current user from local storage
  AppUser? getCurrentUser() {
    final prefs = _prefs;
    if (prefs == null) return null;

    final userJson = prefs.getString(_userPrefsKey);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userData = jsonDecode(userJson);
      return AppUser.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Save data to a specific collection
  Future<void> saveData(
      String collection, String id, Map<String, dynamic> data) async {
    final db = _database;
    if (db == null) return;

    await db.insert(
      collection,
      {
        'id': id,
        'data': jsonEncode(data),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get data from a specific collection by ID
  Map<String, dynamic>? getData(String collection, String id) {
    final db = _database;
    if (db == null) return null;

    try {
      final List<Map<String, dynamic>> result = db.query(
        collection,
        where: 'id = ?',
        whereArgs: [id],
      ) as List<Map<String, dynamic>>;

      if (result.isEmpty) return null;

      final data = result.first['data'] as String?;
      if (data == null) return null;

      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Get all data from a specific collection
  List<Map<String, dynamic>> getAllData(String collection) {
    final db = _database;
    if (db == null) return [];

    final result = <Map<String, dynamic>>[];

    try {
      final List<Map<String, dynamic>> rows =
          db.query(collection) as List<Map<String, dynamic>>;

      for (final row in rows) {
        final data = row['data'] as String?;
        if (data != null) {
          try {
            final decodedData = jsonDecode(data);
            if (decodedData is Map<String, dynamic>) {
              result.add(decodedData);
            }
          } catch (_) {
            // Ignore invalid data
          }
        }
      }
    } catch (e) {
      // Return empty list on error
    }

    return result;
  }

  /// Delete data from a specific collection by ID
  Future<void> deleteData(String collection, String id) async {
    final db = _database;
    if (db == null) return;

    await db.delete(
      collection,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all data from a specific collection
  Future<void> clearCollection(String collection) async {
    final db = _database;
    if (db == null) return;

    await db.delete(collection);
  }

  /// Add an item to the sync queue for later synchronization
  Future<void> addToSyncQueue(String operation, String collection, String id,
      Map<String, dynamic>? data) async {
    final db = _database;
    if (db == null) return;

    await db.insert(
      'sync_queue',
      {
        'id': id,
        'operation': operation,
        'collection': collection,
        'data': data != null ? jsonEncode(data) : null,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get all items in the sync queue
  List<Map<String, dynamic>> getSyncQueue() {
    final db = _database;
    if (db == null) return [];

    final result = <Map<String, dynamic>>[];

    try {
      final List<Map<String, dynamic>> rows = db.query(
        'sync_queue',
        orderBy: 'timestamp ASC',
      ) as List<Map<String, dynamic>>;

      for (final row in rows) {
        final syncItem = <String, dynamic>{
          'key': row['key'],
          'id': row['id'],
          'operation': row['operation'],
          'collection': row['collection'],
          'timestamp': row['timestamp'],
        };

        final dataStr = row['data'] as String?;
        if (dataStr != null) {
          try {
            syncItem['data'] = jsonDecode(dataStr);
          } catch (_) {
            syncItem['data'] = null;
          }
        } else {
          syncItem['data'] = null;
        }

        result.add(syncItem);
      }
    } catch (e) {
      // Return empty list on error
    }

    return result;
  }

  /// Remove an item from the sync queue
  Future<void> removeFromSyncQueue(dynamic key) async {
    final db = _database;
    if (db == null) return;

    await db.delete(
      'sync_queue',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Clear the entire sync queue
  Future<void> clearSyncQueue() async {
    final db = _database;
    if (db == null) return;

    await db.delete('sync_queue');
  }

  /// Save the last synchronization time
  Future<void> saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncTimeKey, time.toIso8601String());
  }

  /// Get the last synchronization time
  DateTime? getLastSyncTime() {
    final prefs = _prefs;
    if (prefs == null) return null;

    final timeString = prefs.getString(_lastSyncTimeKey);
    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  /// Close the database
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
