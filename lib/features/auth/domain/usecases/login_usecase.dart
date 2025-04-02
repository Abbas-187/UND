import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String email, String password) async {
    // Add any business logic here before login
    // For example, validation, logging, etc.
    return await repository.login(email, password);
  }
}
