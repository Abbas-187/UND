import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global navigator key for accessing navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// A service that encapsulates the navigation logic for the app
// DEPRECATED: This service is no longer used. Navigation is now handled by GoRouter.
// All methods below are obsolete and should not be used.
class NavigationService {
  NavigationService(this.navigatorKey);
  final GlobalKey<NavigatorState> navigatorKey;

  // Get the current navigation context
  BuildContext? get context => navigatorKey.currentContext;

  // Get the current navigation state
  NavigatorState? get navigator => navigatorKey.currentState;

  // Navigate to a named route
  Future<dynamic> navigateTo(String routeName,
      {Map<String, dynamic>? arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  // Replace the current route with a new one
  Future<dynamic> replaceTo(String routeName,
      {Map<String, dynamic>? arguments}) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Navigate to a route and remove all previous routes
  Future<dynamic> navigateToReplaceAll(String routeName,
      {Map<String, dynamic>? arguments}) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Go back to the previous route
  void goBack([dynamic result]) {
    return navigator!.pop(result);
  }

  // Check if can go back
  bool canGoBack() => navigator!.canPop();

  // Go back until a certain route
  void goBackUntil(String routeName) {
    return navigator!.popUntil(ModalRoute.withName(routeName));
  }
}

// Provider for the navigation service
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(navigatorKey);
});
