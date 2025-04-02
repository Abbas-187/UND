import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/auth_service.dart';

// Add a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final AuthService _authService = AuthService();

  // In the route access map, map UserRole enum values to route permissions
  static final Map<String, List<UserRole>> _routeAccess = {
    '/': [
      UserRole.admin,
      UserRole.warehouseManager,
      UserRole.sales,
      UserRole.logistics,
      UserRole.factory,
    ],
    '/login': [], // Everyone can access

    // Warehouse routes
    '/warehouse/dashboard': [
      UserRole.admin,
      UserRole.warehouseManager,
    ],
    '/warehouse/receive': [
      UserRole.admin,
      UserRole.warehouseManager,
    ],
    '/warehouse/issue': [
      UserRole.admin,
      UserRole.warehouseManager,
    ],
    '/warehouse/count': [
      UserRole.admin,
      UserRole.warehouseManager,
    ],
    '/warehouse/locations': [UserRole.admin, UserRole.warehouseManager],

    // Factory routes
    '/factory/dashboard': [
      UserRole.admin,
      UserRole.factory,
    ],
    '/factory/recipes': [UserRole.admin, UserRole.factory],
    '/factory/orders': [UserRole.admin, UserRole.factory],
    '/factory/requisition': [UserRole.admin, UserRole.factory],

    // Sales routes
    '/sales/dashboard': [UserRole.admin, UserRole.sales],
    '/sales/customers': [UserRole.admin, UserRole.sales],
    '/sales/new-order': [UserRole.admin, UserRole.sales],
    '/sales/orders': [UserRole.admin, UserRole.sales],
    '/sales/analytics': [UserRole.admin, UserRole.sales],

    // Logistics routes
    '/logistics/dashboard': [
      UserRole.admin,
      UserRole.logistics,
    ],
    '/logistics/vehicles': [UserRole.admin, UserRole.logistics],
    '/logistics/routes': [
      UserRole.admin,
      UserRole.logistics,
    ],
    '/logistics/tracking': [
      UserRole.admin,
      UserRole.logistics,
      UserRole.sales,
    ],
    '/logistics/history': [
      UserRole.admin,
      UserRole.logistics,
    ],

    // Settings routes
    '/admin/users': [UserRole.admin],
    '/admin/settings': [UserRole.admin],
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route name
    final String routeName = settings.name ?? '/';

    // Check if this is a public route (like login)
    if (_isPublicRoute(routeName)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => _getRouteWidget(routeName, settings.arguments),
      );
    }

    // For protected routes, wrap with authorization check
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => FutureBuilder<bool>(
        future: _hasAccess(routeName),
        builder: (context, snapshot) {
          // While checking permissions
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If user is not logged in
          if (snapshot.data == null) {
            return LoginScreen(redirectTo: routeName) as Widget;
          }

          // If user has access
          if (snapshot.data == true) {
            return _getRouteWidget(routeName, settings.arguments);
          }

          // If access denied
          return _buildUnauthorizedScreen(context);
        },
      ),
    );
  }

  // Temporary unauthorized screen
  static Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Denied'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red),
            SizedBox(height: 24),
            Text('You do not have permission to access this area.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }

  // Check if user has access to a specific route
  static Future<bool> _hasAccess(String routeName) async {
    // Get current user role
    final UserRole? userRole = await _authService.getCurrentUserRole();

    // If user is not logged in
    if (userRole == null) {
      return false;
    }

    // Check if route exists in our access map
    if (!_routeAccess.containsKey(routeName)) {
      return false;
    }

    // Public routes
    if (_routeAccess[routeName]!.isEmpty) {
      return true;
    }

    // Check if user role is allowed for this route
    return _routeAccess[routeName]!.contains(userRole);
  }

  // Check if route is public (accessible without login)
  static bool _isPublicRoute(String routeName) {
    return _routeAccess.containsKey(routeName) &&
        _routeAccess[routeName]!.isEmpty;
  }

  // Get the appropriate widget for a route
  static Widget _getRouteWidget(String routeName, dynamic arguments) {
    // For now, return a placeholder screen for all routes until the actual screens are implemented
    if (routeName == '/login') {
      if (arguments is String) {
        return LoginScreen(redirectTo: arguments) as Widget;
      }
      return const LoginScreen() as Widget;
    } else if (routeName == '/') {
      return const HomeScreen() as Widget;
    } else {
      // Placeholder for all screens that don't exist yet
      return Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Screen: $routeName'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('This screen is under development',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                Text('Route: $routeName',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  child: Text('Back to Home'),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
