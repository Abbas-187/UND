import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_remote_datasource.dart';

/// Provider for the Firebase Auth datasource (always uses real Firebase)
final firebaseAuthDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
  );
});
