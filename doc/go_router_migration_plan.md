# GoRouter Migration Plan

**Last updated:** April 30, 2025

## 1. Inventory All Screens and Routes
- **List all screen widgets:**
  - Search for all Dart files in `lib/features/**/screens/`, `lib/screens/`, and any custom screen directories.
  - Identify all classes ending with `Screen`, `Page`, or `View`.
  - Note screens that require parameters (e.g., detail screens with IDs).
- **Collect all route strings:**
  - From `AppRoutes`, `app_modules.dart`, NavigationRail, Drawer, and direct `Navigator` usage.
  - Document all unique route paths and their intended screens.
- **Map route parameters:**
  - For each screen that requires parameters, specify the parameter name and type (e.g., `/inventory/item/:id`).

## 2. Add go_router to Project (if not already present)
- Ensure `go_router` is in `pubspec.yaml` under dependencies.
- Run `flutter pub get` to install the package.
- Review the [go_router documentation](https://pub.dev/packages/go_router) for advanced features.

## 3. Create Central Routing File
- Create `lib/core/routes/app_go_router.dart`.
- **Define all routes using GoRoute:**
  - Use a flat or nested structure as needed.
  - For each route, specify:
    - `path`: The route path (e.g., `/inventory`, `/factory/production/list`)
    - `builder`: The widget to display
    - `routes`: For nested routes (e.g., detail screens under a list)
  - Use path parameters for detail screens (e.g., `/inventory/item/:id`).
- **Example:**
  ```dart
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => DairyInventoryScreen(),
        routes: [
          GoRoute(
            path: 'item/:id',
            builder: (context, state) => InventoryItemDetailScreen(
              id: state.params['id']!,
            ),
          ),
        ],
      ),
      // ...add all other routes
    ],
  );
  ```
- **Document all routes in a table:**
  | Route Path | Screen Widget | Parameters | Notes |
  |------------|--------------|------------|-------|
  | `/` | HomeScreen |  |  |
  | `/inventory` | DairyInventoryScreen |  |  |
  | `/inventory/item/:id` | InventoryItemDetailScreen | id (String) |  |
  | ... | ... | ... | ... |

## 4. Update main.dart
- Replace `MaterialApp` with `MaterialApp.router`.
- Use the GoRouter instance for routing:
  ```dart
  MaterialApp.router(
    routerConfig: router,
    // ...other properties
  )
  ```
- Remove or refactor any old router logic (e.g., AppRouter, onGenerateRoute).

## 5. Update Navigation Calls
- Replace all `Navigator.pushNamed`, `Navigator.of(context).pushNamed`, and similar calls with `context.go()` or `context.push()`.
  - Use `context.go('/route')` for navigation that replaces the current route.
  - Use `context.push('/route')` for navigation that adds to the stack.
  - For parameterized routes, use string interpolation or GoRouter's helpers:
    ```dart
    context.go('/inventory/item/${item.id}');
    ```
- Update NavigationRail, Drawer, quick action buttons, and any other navigation triggers.
- Refactor any custom navigation helpers to use GoRouter.

## 6. Handle Route Guards and Redirects (Optional)
- Use GoRouter's `redirect` and `GoRoute` `redirect`/`canActivate` features for:
  - Authentication (e.g., redirect to login if not signed in)
  - Role-based access (e.g., restrict certain routes to admins)
  - Onboarding or setup flows
- Example:
  ```dart
  GoRoute(
    path: '/admin',
    builder: (context, state) => AdminScreen(),
    redirect: (context, state) {
      if (!isAdmin) return '/login';
      return null;
    },
  )
  ```

## 7. Test All Navigation Paths
- **Manual testing:**
  - Ensure every screen is accessible from the UI and via direct URL (for web).
  - Test parameterized routes, deep links, and error handling.
- **Automated testing:**
  - Add widget tests for navigation flows, especially for guarded/redirected routes.
- **Edge cases:**
  - Test unknown routes, missing parameters, and unauthorized access.

## 8. Remove Old Routing Code
- Delete or comment out AppRouter, AppRoutes, and any old navigation helpers.
- Remove unused imports and references to the old router.
- Update documentation to reference GoRouter usage only.

## 9. Document New Navigation Patterns
- Add a section to your developer documentation explaining:
  - How to add new routes to GoRouter
  - How to navigate using `context.go` and `context.push`
  - How to handle parameters and guards
- Provide code samples for common navigation scenarios.

## 10. Migration Progress Tracking
- Use `doc/go_router_progress.md` to track each migration step.
- Check off each item as it is completed.
- Add notes, blockers, and decisions for team visibility.

---

*This comprehensive plan ensures a smooth, maintainable migration to go_router, supporting all current and future screens, parameters, and navigation patterns in your Flutter app.*
