import 'dart:async';

import '../../../../core/core.dart';
import '../../../../models/user_model.dart';

/// Authentication service that handles user authentication operations
class AuthService {
  /// Stream for user role changes
  Stream<UserRole?> get userRoleStream {
    // Return an empty stream for now
    return Stream.value(null);
  }

  /// Get current user role as UserRole
  Future<UserRole?> getCurrentUserRole() async {
    // Return null for now
    return null;
  }

  /// Sign out
  Future<void> signOut() async {
    // Do nothing for now
  }
}
