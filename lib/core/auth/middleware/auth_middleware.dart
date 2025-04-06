import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_router.dart';
import '../models/permission.dart';
import '../services/auth_service.dart';

/// Middleware to check if a user is authenticated before accessing a route
class AuthMiddleware {
  static Route<dynamic> handleAuthCheck(
    BuildContext context,
    Widget destination,
    String routeName,
    WidgetRef ref,
  ) {
    final userState = ref.read(currentUserProvider);

    return userState.when(
      data: (user) {
        if (user == null) {
          // User is not authenticated, redirect to login
          return MaterialPageRoute(
            settings: RouteSettings(name: AppRoutes.login),
            builder: (_) => const _AuthRedirect(destination: AppRoutes.login),
          );
        }

        // User is authenticated, proceed
        return MaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: (_) => destination,
        );
      },
      loading: () => MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (_) => const _LoadingScreen(),
      ),
      error: (_, __) => MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.login),
        builder: (_) => const _AuthRedirect(destination: AppRoutes.login),
      ),
    );
  }

  /// Check if a user has the required permission before accessing a route
  static Route<dynamic> handlePermissionCheck(
    BuildContext context,
    Widget destination,
    String routeName,
    WidgetRef ref,
    Permission requiredPermission,
  ) {
    final userState = ref.read(currentUserProvider);

    return userState.when(
      data: (user) {
        if (user == null) {
          // User is not authenticated, redirect to login
          return MaterialPageRoute(
            settings: RouteSettings(name: AppRoutes.login),
            builder: (_) => const _AuthRedirect(destination: AppRoutes.login),
          );
        }

        if (!user.hasPermission(requiredPermission)) {
          // User doesn't have the required permission, redirect to unauthorized
          return MaterialPageRoute(
            settings: RouteSettings(name: AppRoutes.unauthorized),
            builder: (_) =>
                const _AuthRedirect(destination: AppRoutes.unauthorized),
          );
        }

        // User has the required permission, proceed
        return MaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: (_) => destination,
        );
      },
      loading: () => MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (_) => const _LoadingScreen(),
      ),
      error: (_, __) => MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.login),
        builder: (_) => const _AuthRedirect(destination: AppRoutes.login),
      ),
    );
  }
}

/// Helper widget to handle redirects
class _AuthRedirect extends ConsumerWidget {

  const _AuthRedirect({required this.destination});
  final String destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a post-frame callback to avoid navigation during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(destination);
    });

    // Return an empty container as placeholder during redirect
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Loading screen shown during authentication check
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
