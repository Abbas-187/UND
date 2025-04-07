import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/firebase/firebase_interface.dart';
import '../../../../core/firebase/firebase_module.dart';
import '../../domain/entities/user.dart';
import 'auth_remote_datasource.dart';

part 'mock_auth_datasource.g.dart';

/// Provider for auth data source that can switch between real and mock implementation
@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  final authInterface = ref.watch(authInterfaceProvider);
  return AuthRemoteDataSourceImpl(authInterface: authInterface);
}

/// Implementation of AuthRemoteDataSource that uses AuthInterface
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthInterface _authInterface;

  AuthRemoteDataSourceImpl({required AuthInterface authInterface})
      : _authInterface = authInterface;

  @override
  Future<User> login(String email, String password) async {
    final credential = await _authInterface.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapFirebaseUserToUser(credential.user!);
  }

  @override
  Future<User> register(String email, String password, String name) async {
    final credential = await _authInterface.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await credential.user?.updateDisplayName(name);

    return _mapFirebaseUserToUser(credential.user!);
  }

  @override
  Future<void> logout() async {
    await _authInterface.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _authInterface.currentUser;
    if (firebaseUser == null) return null;
    return _mapFirebaseUserToUser(firebaseUser);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _authInterface.sendPasswordResetEmail(email: email);
  }

  @override
  Stream<User?> get authStateChanges {
    return _authInterface.authStateChanges().map((firebaseUser) {
      return firebaseUser == null ? null : _mapFirebaseUserToUser(firebaseUser);
    });
  }

  User _mapFirebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      role: 'user', // Default role, can be overridden
      lastLogin: firebaseUser.metadata.lastSignInTime,
    );
  }
}
