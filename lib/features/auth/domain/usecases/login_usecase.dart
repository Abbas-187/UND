import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {

  LoginUseCase(this.repository);
  final AuthRepository repository;

  Future<User> execute(String email, String password) async {
    // Add any business logic here before login
    // For example, validation, logging, etc.
    return await repository.login(email, password);
  }
}
