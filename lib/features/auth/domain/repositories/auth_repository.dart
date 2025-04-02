import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
}
