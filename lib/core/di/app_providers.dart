import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared global providers
final loggerProvider = Provider<Logger>((ref) => Logger());
final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final sharedPreferencesProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('Initialize in main.dart'));
final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final networkInfoProvider = Provider<Connectivity>((ref) => Connectivity());
final cacheManagerProvider =
    Provider<BaseCacheManager>((ref) => DefaultCacheManager());

// Other providers will be imported from their respective feature modules
