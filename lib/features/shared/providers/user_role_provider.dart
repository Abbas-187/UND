import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRoleNotifier extends StateNotifier<UserRole> {
  static const String _rolePrefsKey = 'current_user_role';

  UserRoleNotifier() : super(UserRoles.admin);

  /// Change the current user role
  Future<void> setRole(UserRole role) async {
    state = role;

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rolePrefsKey, role.id);
  }

  /// Load the saved role from preferences
  Future<void> loadSavedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRoleId = prefs.getString(_rolePrefsKey);

      if (savedRoleId != null) {
        final savedRole = UserRoles.allRoles.firstWhere(
          (role) => role.id == savedRoleId,
          orElse: () => UserRoles.admin,
        );
        state = savedRole;
      }
    } catch (e) {
      // If there's an error, keep the default role
    }
  }

  /// Check if a module is allowed for the current role
  bool canAccessModule(String moduleId) {
    return state.allowedModules.contains(moduleId);
  }
}

/// Provider for accessing and managing the user role
final userRoleProvider =
    StateNotifierProvider<UserRoleNotifier, UserRole>((ref) {
  final notifier = UserRoleNotifier();
  // Load saved role on initialization
  notifier.loadSavedRole();
  return notifier;
});
