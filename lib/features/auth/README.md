# Authentication and Authorization System

This module implements a comprehensive authentication and authorization system for the UND Inventory Application, featuring role-based access control and support for offline functionality.

## Features

### User Authentication
- Email and password authentication using Firebase Auth
- Secure storage of user credentials
- Session management with automatic token refresh
- Password reset functionality
- User profile management

### Role-Based Access Control (RBAC)
The system defines a set of user roles with different permission levels:

- **Administrator**: Full access to all features and system administration
- **Manager**: High-level access to most features, except user management
- **Warehouse Staff**: Focused access to inventory operations
- **Sales Staff**: Focused access to sales operations
- **Accounting Staff**: Focused access to financial operations
- **Viewer**: Limited read-only access to basic features

### Granular Permissions
Each role is assigned specific permissions across different functional areas:

- **Inventory Management**: View, create, edit, delete inventory items
- **Supplier Management**: View, create, edit, delete suppliers
- **Sales Management**: View, create, edit, delete sales
- **Analytics**: View reports, access dashboards, export data
- **Forecasting**: View, create, and edit forecasts
- **User Management**: View, create, edit, delete users and manage roles
- **Settings**: View and edit application settings

### Security Features
- Secure token storage
- Protection against common auth vulnerabilities
- Session timeout handling
- Access control at API and UI levels

### Offline Support
- Local storage of authentication state
- Caching of user profile and permissions
- Synchronization when connectivity is restored

## Architecture

### Core Components

1. **Models**:
   - `AppUser`: User data model with profile information and role
   - `UserRole`: Enum defining the available roles in the system
   - `Permission`: Enum defining granular permissions

2. **Services**:
   - `AuthService`: Handles authentication operations with Firebase
   - `LocalDatabaseService`: Manages local storage for offline support
   - `SyncService`: Handles data synchronization between local and remote

3. **Middleware**:
   - `AuthMiddleware`: Route protection based on authentication state
   - `PermissionWrapper`: UI wrapper to restrict access based on permissions

4. **Screens**:
   - `LoginScreen`: User authentication screen
   - `UserProfileScreen`: User profile management
   - `UserManagementScreen`: Admin interface for user management
   - `UnauthorizedScreen`: Displayed when access is denied

## Usage

### Checking Permissions

```dart
// Using the permission wrapper
Widget build(BuildContext context) {
  return PermissionWrapper(
    requiredPermission: Permission.inventoryEdit,
    child: YourWidget(),
  );
}

// Using the permission provider
final hasPermission = ref.watch(hasPermissionProvider(Permission.inventoryEdit));
if (hasPermission) {
  // Perform action
}
```

### Protecting Routes

Routes can be protected using the AuthMiddleware:

```dart
// In your router
Route<dynamic> generateRoute(RouteSettings settings) {
  // For authenticated routes only
  return AuthMiddleware.handleAuthCheck(
    context, 
    destination,
    routeName,
    ref,
  );
  
  // For permission-based routes
  return AuthMiddleware.handlePermissionCheck(
    context, 
    destination,
    routeName,
    ref,
    Permission.userManage,
  );
}
```

## Implementation Notes

1. The authentication state is tracked using Riverpod providers.
2. User roles and permissions are enforced at both the UI and service levels.
3. Offline support uses Hive for local storage with sync queuing.
4. All sensitive operations are properly error-handled for user feedback. 