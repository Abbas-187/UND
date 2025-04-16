import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared global providers
final loggerProvider = Provider<Logger>((ref) => Logger());
final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final sharedPreferencesProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('Initialize in main.dart'));

// Other providers will be imported from their respective feature modules
