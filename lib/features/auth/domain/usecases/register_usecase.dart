import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');

  RegisterUseCase(this.repository);

  Future<User> execute(String email, String password, String name) async {
    // Name validation
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    if (trimmedName.length < 2) {
      throw Exception('Name must be at least 2 characters long');
    }
    if (trimmedName.length > 50) {
      throw Exception('Name cannot be longer than 50 characters');
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmedName)) {
      throw Exception('Name can only contain letters and spaces');
    }

    // Email validation
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      throw Exception('Invalid email format');
    }
    if (trimmedEmail.length > 100) {
      throw Exception('Email cannot be longer than 100 characters');
    }

    // Password validation
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters long');
    }
    if (password.length > 100) {
      throw Exception('Password cannot be longer than 100 characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw Exception('Password must contain at least one uppercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw Exception('Password must contain at least one number');
    }
    if (!password.contains(RegExp(r'[!@#\$&*~]'))) {
      throw Exception(
          'Password must contain at least one special character (!@#\$&*~)');
    }
    if (password.contains(' ')) {
      throw Exception('Password cannot contain spaces');
    }

    // Check if password contains parts of the email or name
    final emailParts = trimmedEmail.split('@')[0].toLowerCase();
    if (password.toLowerCase().contains(emailParts) && emailParts.length > 3) {
      throw Exception('Password cannot contain parts of your email');
    }
    if (trimmedName.split(' ').any((part) =>
        part.length > 3 &&
        password.toLowerCase().contains(part.toLowerCase()))) {
      throw Exception('Password cannot contain parts of your name');
    }

    return await repository.register(trimmedEmail, password, trimmedName);
  }
}
