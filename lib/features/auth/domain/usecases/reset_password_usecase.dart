import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {

  ResetPasswordUseCase(this.repository);
  final AuthRepository repository;
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // Rate limiting: store last reset attempt time per email
  final Map<String, DateTime> _lastResetAttempts = {};
  static const _resetCooldown = Duration(minutes: 5);

  Future<void> execute(String email) async {
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

    // Rate limiting check
    final lastAttempt = _lastResetAttempts[trimmedEmail];
    if (lastAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
      if (timeSinceLastAttempt < _resetCooldown) {
        final remainingTime = _resetCooldown - timeSinceLastAttempt;
        final minutes = remainingTime.inMinutes + 1;
        throw Exception(
          'Please wait $minutes minutes before requesting another password reset',
        );
      }
    }

    // Update last attempt time before making the request
    _lastResetAttempts[trimmedEmail] = DateTime.now();

    try {
      await repository.resetPassword(trimmedEmail);
    } catch (e) {
      // Remove the timestamp if the request failed
      _lastResetAttempts.remove(trimmedEmail);
      rethrow;
    }
  }

  // Method to clear rate limiting data (useful for testing or manual override)
  void clearRateLimiting() {
    _lastResetAttempts.clear();
  }
}
