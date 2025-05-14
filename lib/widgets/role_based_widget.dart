import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class RoleBasedWidget extends StatelessWidget {
  RoleBasedWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole?>(
      stream: _authService.userRoleStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Or a placeholder/shimmer
        }

        final userRole = snapshot.data;
        final String? roleName = userRole?.toString().split('.').last;

        if (roleName != null && allowedRoles.contains(roleName)) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
