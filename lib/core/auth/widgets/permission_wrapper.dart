import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_go_router.dart';
import '../models/permission.dart';
import '../services/auth_service.dart';

/// A widget that checks if the current user has the required permission to view the content
/// If not, it shows either a custom unauthorized widget or redirects to the unauthorized screen
class PermissionWrapper extends ConsumerWidget {
  /// Constructor
  const PermissionWrapper({
    super.key,
    required this.child,
    required this.requiredPermission,
    this.unauthorizedWidget,
    this.redirectWhenUnauthorized = true,
  });

  /// The child widget to display if the user has permission
  final Widget child;

  /// The permission required to view the content
  final Permission requiredPermission;

  /// Custom widget to show when unauthorized (optional)
  final Widget? unauthorizedWidget;

  /// Whether to redirect to the unauthorized screen when unauthorized
  final bool redirectWhenUnauthorized;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);

    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          // Not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.login);
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final hasPermission = user.hasPermission(requiredPermission);
        if (hasPermission) {
          return child;
        }

        if (redirectWhenUnauthorized) {
          // Redirect to the unauthorized screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.unauthorized);
          });

          // Return a loading widget temporarily
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show custom unauthorized widget or default message
        return unauthorizedWidget ?? _buildDefaultUnauthorizedWidget();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const Scaffold(
        body: Center(
          child: Text('Authentication error'),
        ),
      ),
    );
  }

  Widget _buildDefaultUnauthorizedWidget() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You do not have permission to access this feature.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that checks if the user is logged in
/// If not, it redirects to the login screen
class AuthenticationWrapper extends ConsumerWidget {
  /// Constructor
  const AuthenticationWrapper({
    super.key,
    required this.child,
  });

  /// The child widget to display if the user is authenticated
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);

    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          // Redirect to login screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.login);
          });

          // Return a loading widget temporarily
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return child;
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) {
        // Redirect to login screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRoutes.login);
        });

        // Return a loading widget temporarily
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
