import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/user.dart';
import '../../data/datasources/mock_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_repository.g.dart';

/// Interface for the authentication repository
abstract class AuthRepository {
  /// Signs in a user with email and password
  Future<User> login(String email, String password);

  /// Registers a new user
  Future<User> register(String email, String password, String name);

  /// Signs out the current user
  Future<void> logout();

  /// Gets the current authenticated user
  Future<User?> getCurrentUser();

  /// Sends a password reset email
  Future<void> resetPassword(String email);

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}

/// Provider for the auth repository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
}
