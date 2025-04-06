import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl(this.remoteDataSource);
  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<User> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<User> register(String email, String password, String name) async {
    try {
      final user = await remoteDataSource.register(email, password, name);
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  Exception _handleError(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('Email is already registered.');
        default:
          return Exception(error.message ?? 'Authentication error occurred.');
      }
    }
    return Exception('An unexpected error occurred.');
  }
}
