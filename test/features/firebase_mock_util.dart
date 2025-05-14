import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // No-op for now, as we only need to prevent real Firebase init
}
