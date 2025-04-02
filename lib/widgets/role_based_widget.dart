import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class RoleBasedWidget extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final AuthService _authService = AuthService();

  RoleBasedWidget({
    Key? key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  }) : super(key: key);

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
