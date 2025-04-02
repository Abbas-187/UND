# PowerShell script to create Flutter UND warehouse management app folder structure

# Define the base directory (current directory)
$baseDir = Get-Location

# Create the lib directory if it doesn't exist
$libDir = Join-Path $baseDir "lib"
if (-not (Test-Path $libDir)) {
    New-Item -Path $libDir -ItemType Directory
    Write-Host "Created 'lib' directory" -ForegroundColor Green
}

# Create main.dart file
$mainDartPath = Join-Path $libDir "main.dart"
$mainDartContent = @'
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_router.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize auth service
  final authService = AuthService();
  await authService.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UND Warehouse Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
'@
Set-Content -Path $mainDartPath -Value $mainDartContent
Write-Host "Created 'main.dart'" -ForegroundColor Green

# Create subdirectories
$directories = @(
    "models",
    "screens",
    "screens/auth",
    "screens/home",
    "screens/warehouse",
    "screens/factory",
    "screens/sales",
    "screens/logistics",
    "screens/admin",
    "services",
    "utils",
    "widgets",
    "widgets/common"
)

foreach ($dir in $directories) {
    $newDir = Join-Path $libDir $dir
    if (-not (Test-Path $newDir)) {
        New-Item -Path $newDir -ItemType Directory
        Write-Host "Created '$dir' directory" -ForegroundColor Green
    }
}

# Create model files
$userModelPath = Join-Path $libDir "models/user_model.dart"
$userModelContent = @'
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String? warehouseId;
  final bool isEmailVerified;
  
  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    this.warehouseId,
    required this.isEmailVerified,
  });
  
  factory UserModel.fromFirebase(User firebaseUser, Map<String, dynamic>? claims) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      role: UserRole.fromClaims(claims),
      warehouseId: claims?['warehouseId'],
      isEmailVerified: firebaseUser.emailVerified,
    );
  }
}
'@
Set-Content -Path $userModelPath -Value $userModelContent
Write-Host "Created 'models/user_model.dart'" -ForegroundColor Green

$userRolePath = Join-Path $libDir "models/user_role.dart"
$userRoleContent = @'
class UserRole {
  final String role;
  final List<String> permissions;
  
  UserRole({
    required this.role,
    required this.permissions,
  });
  
  factory UserRole.fromClaims(Map<String, dynamic>? claims) {
    final roleString = claims?['role'] as String? ?? 'guest';
    return UserRole(
      role: roleString,
      permissions: _getPermissionsForRole(roleString),
    );
  }
  
  static List<String> _getPermissionsForRole(String role) {
    // Define permissions for each role
    switch (role) {
      case 'system_admin':
        return [
          'user_management',
          'warehouse_management',
          'inventory_management',
          'production_management',
          'sales_management',
          'logistics_management',
          'system_configuration',
        ];
      case 'warehouse_admin':
        return [
          'warehouse_management',
          'inventory_management',
        ];
      case 'inventory_operator':
        return [
          'view_inventory',
          'receive_goods',
          'issue_goods',
          'count_inventory',
        ];
      case 'factory_admin':
        return [
          'production_management',
          'recipe_management',
        ];
      case 'production_operator':
        return [
          'view_production',
          'execute_production',
          'requisition_materials',
        ];
      case 'sales_admin':
        return [
          'sales_management',
          'customer_management',
          'sales_reporting',
        ];
      case 'sales_operator':
        return [
          'view_customers',
          'create_orders',
          'view_orders',
        ];
      case 'logistics_admin':
        return [
          'logistics_management',
          'vehicle_management',
          'route_management',
        ];
      case 'delivery_operator':
        return [
          'view_routes',
          'execute_deliveries',
          'update_tracking',
        ];
      default:
        return [];
    }
  }
  
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
  
  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions.any((permission) => hasPermission(permission));
  }
  
  bool hasAllPermissions(List<String> requiredPermissions) {
    return requiredPermissions.every((permission) => hasPermission(permission));
  }
}
'@
Set-Content -Path $userRolePath -Value $userRoleContent
Write-Host "Created 'models/user_role.dart'" -ForegroundColor Green

$navigationItemPath = Join-Path $libDir "models/navigation_item.dart"
$navigationItemContent = @'
import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<String> allowedRoles;
  final List<NavigationItem>? children;
  
  NavigationItem({
    required this.title,
    required this.icon,
    this.route,
    required this.allowedRoles,
    this.children,
  });
}
'@
Set-Content -Path $navigationItemPath -Value $navigationItemContent
Write-Host "Created 'models/navigation_item.dart'" -ForegroundColor Green

# Create services files
$authServicePath = Join-Path $libDir "services/auth_service.dart"
$authServiceContent = @'
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  // Stream controllers for user data
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  final StreamController<UserRole> _userRoleController = StreamController<UserRole>.broadcast();
  
  // Stream getters
  Stream<UserModel?> get userStream => _userController.stream;
  Stream<UserRole> get userRoleStream => _userRoleController.stream;
  
  // Initialize the service
  Future<void> init() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
    
    // Also listen to id token changes to catch role updates
    _auth.idTokenChanges().listen(_onIdTokenChanged);
  }
  
  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // User signed out, emit null
      _userController.add(null);
      _userRoleController.add(UserRole.fromClaims(null));
      return;
    }
    
    // Get user's custom claims (role info)
    final idTokenResult = await firebaseUser.getIdTokenResult(true);
    final claims = idTokenResult.claims;
    
    // Create and emit the user model
    final userModel = UserModel.fromFirebase(firebaseUser, claims);
    _userController.add(userModel);
    
    // Emit the user role separately
    _userRoleController.add(userModel.role);
    
    // Update user's last login in Firestore
    await _updateUserLastLogin(firebaseUser.uid);
  }
  
  // Handle ID token changes (for role updates)
  Future<void> _onIdTokenChanged(User? firebaseUser) async {
    if (firebaseUser == null) return;
    
    // Get user's custom claims (role info)
    final idTokenResult = await firebaseUser.getIdTokenResult(true);
    final claims = idTokenResult.claims;
    
    // Emit the updated user role
    _userRoleController.add(UserRole.fromClaims(claims));
  }
  
  // Update user's last login timestamp
  Future<void> _updateUserLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating last login: $e');
    }
  }
  
  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) return null;
      
      // Get user's custom claims
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      
      return UserModel.fromFirebase(user, claims);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Create user with email and password (for admin use)
  Future<UserModel?> createUserWithEmailAndPassword(
    String email, 
    String password,
    String displayName,
    String initialRole,
    String? warehouseId,
  ) async {
    try {
      // First, create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) return null;
      
      // Update display name
      await user.updateDisplayName(displayName);
      
      // Set user's initial role using Cloud Function
      await _setUserRole(user.uid, initialRole, warehouseId);
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': displayName,
        'role': initialRole,
        'warehouseId': warehouseId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      // Get updated token with custom claims
      await user.getIdToken(true);
      final idTokenResult = await user.getIdTokenResult();
      
      return UserModel.fromFirebase(user, idTokenResult.claims);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Set or update user role (admin function)
  Future<void> setUserRole(String uid, String role, String? warehouseId) async {
    await _setUserRole(uid, role, warehouseId);
  }
  
  // Internal helper to call the Cloud Function
  Future<void> _setUserRole(String uid, String role, String? warehouseId) async {
    try {
      final callable = _functions.httpsCallable('setUserRole');
      await callable.call({
        'uid': uid,
        'role': role,
        'warehouseId': warehouseId,
      });
    } catch (e) {
      print('Error setting user role: $e');
      throw Exception('Failed to set user role. Please try again later.');
    }
  }
  
  // Get current user's role directly
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    
    final idTokenResult = await user.getIdTokenResult(true);
    return idTokenResult.claims?['role'] as String?;
  }
  
  // Check if current user has a specific permission
  Future<bool> hasPermission(String permission) async {
    final role = await getCurrentUserRole();
    if (role == null) return false;
    
    final userRole = UserRole.fromClaims({'role': role});
    return userRole.hasPermission(permission);
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // Get current user synchronously (may be null)
  User? get currentUser => _auth.currentUser;
  
  // Helper to handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return Exception('The email address is already in use.');
      case 'weak-password':
        return Exception('The password is too weak. Please choose a stronger password.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many login attempts. Please try again later.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
  
  // Dispose resources
  void dispose() {
    _userController.close();
    _userRoleController.close();
  }
}
'@
Set-Content -Path $authServicePath -Value $authServiceContent
Write-Host "Created 'services/auth_service.dart'" -ForegroundColor Green

$featureFlagServicePath = Join-Path $libDir "services/feature_flag_service.dart"
$featureFlagServiceContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FeatureFlag {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final List<String> allowedRoles;
  final List<String> requiredPermissions;
  
  FeatureFlag({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.allowedRoles,
    required this.requiredPermissions,
  });
  
  factory FeatureFlag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeatureFlag(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      isEnabled: data['isEnabled'] ?? false,
      allowedRoles: List<String>.from(data['allowedRoles'] ?? []),
      requiredPermissions: List<String>.from(data['requiredPermissions'] ?? []),
    );
  }
}

class FeatureFlagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  // Cache for feature flags
  final Map<String, FeatureFlag> _featureFlags = {};
  
  // Stream of feature flags
  Stream<List<FeatureFlag>> getFeatureFlags() {
    return _firestore
        .collection('settings')
        .doc('feature_flags')
        .collection('flags')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FeatureFlag.fromFirestore(doc))
              .toList();
        });
  }
  
  // Check if a feature is enabled for the current user
  Future<bool> isFeatureEnabled(String featureId) async {
    // If we haven't cached this feature flag, fetch it
    if (!_featureFlags.containsKey(featureId)) {
      final doc = await _firestore
          .collection('settings')
          .doc('feature_flags')
          .collection('flags')
          .doc(featureId)
          .get();
      
      if (!doc.exists) {
        return false; // Feature doesn't exist
      }
      
      _featureFlags[featureId] = FeatureFlag.fromFirestore(doc);
    }
    
    final feature = _featureFlags[featureId]!;
    
    // If feature is globally disabled, no need to check role
    if (!feature.isEnabled) {
      return false;
    }
    
    // Get current user role
    final userRole = await _authService.getCurrentUserRole();
    if (userRole == null) {
      return false; // Not authenticated
    }
    
    // Check if user's role is allowed
    if (!feature.allowedRoles.contains(userRole) && 
        !feature.allowedRoles.contains('*')) {
      return false;
    }
    
    // Check if user has all required permissions
    final userRoleObj = UserRole.fromClaims({'role': userRole});
    if (!userRoleObj.hasAllPermissions(feature.requiredPermissions)) {
      return false;
    }
    
    return true;
  }
  
  // Toggle a feature flag (admin only)
  Future<void> toggleFeature(String featureId, bool enabled) async {
    await _firestore
        .collection('settings')
        .doc('feature_flags')
        .collection('flags')
        .doc(featureId)
        .update({
          'isEnabled': enabled,
          'updatedAt': FieldValue.serverTimestamp(),
        });
    
    // Clear cache for this feature
    _featureFlags.remove(featureId);
  }
  
  // Create a new feature flag
  Future<void> createFeature({
    required String id,
    required String name,
    required String description,
    required bool isEnabled,
    required List<String> allowedRoles,
    required List<String> requiredPermissions,
  }) async {
    await _firestore
        .collection('settings')
        .doc('feature_flags')
        .collection('flags')
        .doc(id)
        .set({
          'name': name,
          'description': description,
          'isEnabled': isEnabled,
          'allowedRoles': allowedRoles,
          'requiredPermissions': requiredPermissions,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
'@
Set-Content -Path $featureFlagServicePath -Value $featureFlagServiceContent
Write-Host "Created 'services/feature_flag_service.dart'" -ForegroundColor Green

$auditLogServicePath = Join-Path $libDir "services/audit_log_service.dart"
$auditLogServiceContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class AuditLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  // Log an action
  Future<void> logAction({
    required String action,
    required String module,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? details,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      return; // Cannot log without a user
    }
    
    final idTokenResult = await user.getIdTokenResult();
    final userRole = idTokenResult.claims?['role'] as String? ?? 'unknown';
    
    await _firestore.collection('audit_logs').add({
      'action': action,
      'module': module,
      'userId': user.uid,
      'userEmail': user.email,
      'userRole': userRole,
      'targetId': targetId,
      'targetType': targetType,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
      'ipAddress': null, // Would be captured by a Cloud Function
      'userAgent': null, // Would be captured by a Cloud Function
    });
  }
  
  // Get audit logs for admin view
  Stream<QuerySnapshot> getAuditLogs({
    String? userId,
    String? module,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    Query query = _firestore.collection('audit_logs')
        .orderBy('timestamp', descending: true);
    
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    
    if (module != null) {
      query = query.where('module', isEqualTo: module);
    }
    
    if (action != null) {
      query = query.where('action', isEqualTo: action);
    }
    
    if (startDate != null) {
      query = query.where('timestamp', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    
    if (endDate != null) {
      query = query.where('timestamp', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.limit(limit).snapshots();
  }
}
'@
Set-Content -Path $auditLogServicePath -Value $auditLogServiceContent
Write-Host "Created 'services/audit_log_service.dart'" -ForegroundColor Green

# Create utils files
$appRouterPath = Join-Path $libDir "utils/app_router.dart"
$appRouterContent = @'
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/unauthorized_screen.dart';
import '../screens/home/home_screen.dart';
// Import all your screens
import '../services/auth_service.dart';

class AppRouter {
  static final AuthService _authService = AuthService();
  
  // Route access definitions
  static final Map<String, List<String>> _routeAccess = {
    '/': ['system_admin', 'warehouse_admin', 'factory_admin', 'sales_admin', 'logistics_admin', 'inventory_operator', 'production_operator', 'sales_operator', 'delivery_operator'],
    '/login': ['*'], // Everyone can access
    
    // Warehouse routes
    '/warehouse/dashboard': ['system_admin', 'warehouse_admin', 'inventory_operator'],
    '/warehouse/receive': ['system_admin', 'warehouse_admin', 'inventory_operator'],
    '/warehouse/issue': ['system_admin', 'warehouse_admin', 'inventory_operator'],
    '/warehouse/count': ['system_admin', 'warehouse_admin', 'inventory_operator'],
    '/warehouse/locations': ['system_admin', 'warehouse_admin'],
    
    // Factory routes
    '/factory/dashboard': ['system_admin', 'factory_admin', 'production_operator'],
    '/factory/recipes': ['system_admin', 'factory_admin'],
    '/factory/orders': ['system_admin', 'factory_admin', 'production_operator'],
    '/factory/requisition': ['system_admin', 'factory_admin', 'production_operator'],
    
    // Sales routes
    '/sales/dashboard': ['system_admin', 'sales_admin', 'sales_operator'],
    '/sales/customers': ['system_admin', 'sales_admin', 'sales_operator'],
    '/sales/new-order': ['system_admin', 'sales_admin', 'sales_operator'],
    '/sales/orders': ['system_admin', 'sales_admin', 'sales_operator'],
    '/sales/analytics': ['system_admin', 'sales_admin'],
    
    // Logistics routes
    '/logistics/dashboard': ['system_admin', 'logistics_admin', 'delivery_operator'],
    '/logistics/vehicles': ['system_admin', 'logistics_admin'],
    '/logistics/routes': ['system_admin', 'logistics_admin', 'delivery_operator'],
    '/logistics/tracking': ['system_admin', 'logistics_admin', 'delivery_operator', 'sales_admin', 'sales_operator'],
    '/logistics/history': ['system_admin', 'logistics_admin', 'delivery_operator'],
    
    // Settings routes
    '/admin/users': ['system_admin'],
    '/admin/settings': ['system_admin'],
  };
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route name
    final String routeName = settings.name ?? '/';
    
    // Check if this is a public route (like login)
    if (_isPublicRoute(routeName)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => _getRouteWidget(routeName, settings.arguments),
      );
    }
    
    // For protected routes, wrap with authorization check
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => FutureBuilder<bool>(
        future: _hasAccess(routeName),
        builder: (context, snapshot) {
          // While checking permissions
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // If user is not logged in
          if (snapshot.data == null) {
            return LoginScreen(redirectTo: routeName);
          }
          
          // If user has access
          if (snapshot.data == true) {
            return _getRouteWidget(routeName, settings.arguments);
          }
          
          // If access denied
          return UnauthorizedScreen();
        },
      ),
    );
  }
  
  // Check if user has access to a specific route
  static Future<bool> _hasAccess(String routeName) async {
    // Get current user role
    final String? userRole = await _authService.getCurrentUserRole();
    
    // If user is not logged in
    if (userRole == null) {
      return false;
    }
    
    // Check if route exists in our access map
    if (!_routeAccess.containsKey(routeName)) {
      return false;
    }
    
    // Check if user role is allowed for this route
    return _routeAccess[routeName]!.contains(userRole) || 
           _routeAccess[routeName]!.contains('*');
  }
  
  // Check if route is public (accessible without login)
  static bool _isPublicRoute(String routeName) {
    return _routeAccess.containsKey(routeName) && 
           _routeAccess[routeName]!.contains('*');
  }
  
  // Get the appropriate widget for a route
  static Widget _getRouteWidget(String routeName, dynamic arguments) {
    switch (routeName) {
      case '/':
        return HomeScreen();
      case '/login':
        return LoginScreen();
      
      // Warehouse routes
      case '/warehouse/dashboard':
        return WarehouseDashboardScreen();
      case '/warehouse/receive':
        return GoodsReceiptScreen();
      case '/warehouse/issue':
        return GoodsIssueScreen();
      case '/warehouse/count':
        return InventoryCountScreen();
      case '/warehouse/locations':
        return LocationManagementScreen();
      
      // Factory routes 
      case '/factory/dashboard':
        return FactoryDashboardScreen();
      case '/factory/recipes':
        return RecipeManagementScreen();
      case '/factory/orders':
        return ProductionOrdersScreen();
      case '/factory/requisition':
        return MaterialRequisitionScreen();
      
      // Sales routes
      case '/sales/dashboard':
        return SalesDashboardScreen();
      case '/sales/customers':
        return CustomerManagementScreen();
      case '/sales/new-order':
        return NewSalesOrderScreen();
      case '/sales/orders':
        return SalesOrderListScreen();
      case '/sales/analytics':
        return SalesAnalyticsScreen();
      
      // Logistics routes
      case '/logistics/dashboard':
        return LogisticsDashboardScreen();
      case '/logistics/vehicles':
        return VehicleManagementScreen();
      case '/logistics/routes':
        return RouteManagementScreen();
      case '/logistics/tracking':
        return LiveTrackingScreen();
      case '/logistics/history':
        return DeliveryHistoryScreen();
      
      // Admin routes
      case '/admin/users':
        return UserManagementScreen();
      case '/admin/settings':
        return SystemSettingsScreen();
      
      // Default case
      default:
        return Scaffold(
          body: Center(
            child: Text('Route not found: $routeName'),
          ),
        );
    }
  }
}
'@
Set-Content -Path $appRouterPath -Value $appRouterContent
Write-Host "Created 'utils/app_router.dart'" -ForegroundColor Green

$auditMiddlewarePath = Join-Path $libDir "utils/audit_middleware.dart"
$auditMiddlewareContent = @'
import '../services/audit_log_service.dart';

typedef Future<T> AsyncOperation<T>();

Future<T> withAuditLog<T>({
  required AsyncOperation<T> operation,
  required String action,
  required String module,
  String? targetId,
  String? targetType,
  Mapfailed",
      module: module,
      targetId: targetId,
      targetType: targetType,
      details: {
        ...?details,
        'error': error.toString(),
      },
    );
    
    // Rethrow the original error
    rethrow;
  }
}
'@
Set-Content -Path $auditMiddlewarePath -Value $auditMiddlewareContent
Write-Host "Created 'utils/audit_middleware.dart'" -ForegroundColor Green

# Create widgets
$roleBasedWidgetPath = Join-Path $libDir "widgets/role_based_widget.dart"
$roleBasedWidgetContent = @'
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RoleBasedWidget extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;
  
  const RoleBasedWidget({
    Key? key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      stream: AuthService().userRoleStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Or a placeholder/shimmer
        }
        
        final userRole = snapshot.data?.role;
        
        if (userRole != null && allowedRoles.contains(userRole)) {
          return child;
        }
        
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
'@
Set-Content -Path $roleBasedWidgetPath -Value $roleBasedWidgetContent
Write-Host "Created 'widgets/role_based_widget.dart'" -ForegroundColor Green

$permissionWidgetPath = Join-Path $libDir "widgets/permission_widget.dart"
$permissionWidgetContent = @'
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum PermissionCheckType {
  any,  // User needs at least one of the permissions
  all   // User needs all of the permissions
}

class PermissionWidget extends StatefulWidget {
  final List<String> permissions;
  final PermissionCheckType checkType;
  final Widget child;
  final Widget? fallback;
  final bool hideIfNoPermission;
  
  const PermissionWidget({
    Key? key,
    required this.permissions,
    this.checkType = PermissionCheckType.any,
    required this.child,
    this.fallback,
    this.hideIfNoPermission = true,
  }) : super(key: key);
  
  @override
  _PermissionWidgetState createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  final AuthService _authService = AuthService();
  bool? _hasPermission;
  
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }
  
  @override
  void didUpdateWidget(PermissionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permissions != widget.permissions ||
        oldWidget.checkType != widget.checkType) {
      _checkPermission();
    }
  }
  
  Future<void> _checkPermission() async {
    final currentRole = await _authService.getCurrentUserRole();
    if (currentRole == null) {
      setState(() => _hasPermission = false);
      return;
    }
    
    final userRole = UserRole.fromClaims({'role': currentRole});
    
    final bool hasPermission = widget.checkType == PermissionCheckType.all
        ? userRole.hasAllPermissions(widget.permissions)
        : userRole.hasAnyPermission(widget.permissions);
    
    setState(() => _hasPermission = hasPermission);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasPermission == null) {
      return SizedBox.shrink(); // Still checking permissions
    }
    
    if (_hasPermission!) {
      return widget.child;
    }
    
    if (widget.hideIfNoPermission) {
      return SizedBox.shrink();
    }
    
    return widget.fallback ?? SizedBox.shrink();
  }
}
'@
Set-Content -Path $permissionWidgetPath -Value $permissionWidgetContent
Write-Host "Created 'widgets/permission_widget.dart'" -ForegroundColor Green

$featureFlagWidgetPath = Join-Path $libDir "widgets/feature_flag_widget.dart"
$featureFlagWidgetContent = @'
import 'package:flutter/material.dart';
import '../services/feature_flag_service.dart';

class FeatureFlagWidget extends StatefulWidget {
  final String featureId;
  final Widget child;
  final Widget? fallback;
  final bool hideIfDisabled;
  
  const FeatureFlagWidget({
    Key? key,
    required this.featureId,
    required this.child,
    this.fallback,
    this.hideIfDisabled = true,
  }) : super(key: key);
  
  @override
  _FeatureFlagWidgetState createState() => _FeatureFlagWidgetState();
}

class _FeatureFlagWidgetState extends State<FeatureFlagWidget> {
  final FeatureFlagService _featureFlagService = FeatureFlagService();
  bool? _isEnabled;
  
  @override
  void initState() {
    super.initState();
    _checkFeature();
  }
  
  @override
  void didUpdateWidget(FeatureFlagWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.featureId != widget.featureId) {
      _checkFeature();
    }
  }
  
  Future<void> _checkFeature() async {
    final isEnabled = await _featureFlagService.isFeatureEnabled(widget.featureId);
    setState(() => _isEnabled = isEnabled);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isEnabled == null) {
      return SizedBox.shrink(); // Still checking
    }
    
    if (_isEnabled!) {
      return widget.child;
    }
    
    if (widget.hideIfDisabled) {
      return SizedBox.shrink();
    }
    
    return widget.fallback ?? SizedBox.shrink();
  }
}
'@
Set-Content -Path $featureFlagWidgetPath -Value $featureFlagWidgetContent
Write-Host "Created 'widgets/feature_flag_widget.dart'" -ForegroundColor Green

$roleBasedDrawerPath = Join-Path $libDir "widgets/role_based_drawer.dart"
$roleBasedDrawerContent = @'
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/navigation_item.dart';

class RoleBasedDrawer extends StatelessWidget {
  RoleBasedDrawer({Key? key}) : super(key: key);
  
  final List<NavigationItem> _navigationItems = [
    // Warehouse Section
    NavigationItem(
      title: 'Warehouse',
      icon: Icons.warehouse,
      allowedRoles: ['system_admin', 'warehouse_admin', 'inventory_operator'],
      children: [
        NavigationItem(
          title: 'Dashboard',
          route: '/warehouse/dashboard',
          icon: Icons.dashboard,
          allowedRoles: ['system_admin', 'warehouse_admin', 'inventory_operator'],
        ),
        NavigationItem(
          title: 'Receive Goods',
          route: '/warehouse/receive',
          icon: Icons.input,
          allowedRoles: ['system_admin', 'warehouse_admin', 'inventory_operator'],
        ),
        NavigationItem(
          title: 'Issue Goods',
          route: '/warehouse/issue',
          icon: Icons.output,
          allowedRoles: ['system_admin', 'warehouse_admin', 'inventory_operator'],
        ),
        NavigationItem(
          title: 'Stock Count',
          route: '/warehouse/count',
          icon: Icons.inventory_2,
          allowedRoles: ['system_admin', 'warehouse_admin', 'inventory_operator'],
        ),
        NavigationItem(
          title: 'Locations',
          route: '/warehouse/locations',
          icon: Icons.grid_on,
          allowedRoles: ['system_admin', 'warehouse_admin'],
        ),
      ],
    ),
    
    // Factory Section
    NavigationItem(
      title: 'Factory',
      icon: Icons.precision_manufacturing,
      allowedRoles: ['system_admin', 'factory_admin', 'production_operator'],
      children: [
        NavigationItem(
          title: 'Production Dashboard',
          route: '/factory/dashboard',
          icon: Icons.dashboard,
          allowedRoles: ['system_admin', 'factory_admin', 'production_operator'],
        ),
        NavigationItem(
          title: 'Recipe Management',
          route: '/factory/recipes',
          icon: Icons.menu_book,
          allowedRoles: ['system_admin', 'factory_admin'],
        ),
        NavigationItem(
          title: 'Production Orders',
          route: '/factory/orders',
          icon: Icons.assignment,
          allowedRoles: ['system_admin', 'factory_admin', 'production_operator'],
        ),
        NavigationItem(
          title: 'Material Requisition',
          route: '/factory/requisition',
          icon: Icons.shopping_cart,
          allowedRoles: ['system_admin', 'factory_admin', 'production_operator'],
        ),
      ],
    ),
    
    // Sales Section
    NavigationItem(
      title: 'Sales',
      icon: Icons.point_of_sale,
      allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
      children: [
        NavigationItem(
          title: 'Sales Dashboard',
          route: '/sales/dashboard',
          icon: Icons.dashboard,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'Customers',
          route: '/sales/customers',
          icon: Icons.people,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'New Order',
          route: '/sales/new-order',
          icon: Icons.add_shopping_cart,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'Order History',
          route: '/sales/orders',
          icon: Icons.history,
          allowedRoles: ['system_admin', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'Analytics',
          route: '/sales/analytics',
          icon: Icons.analytics,
          allowedRoles: ['system_admin', 'sales_admin'],
        ),
      ],
    ),
    
    // Logistics Section
    NavigationItem(
      title: 'Logistics',
      icon: Icons.local_shipping,
      allowedRoles: ['system_admin', 'logistics_admin', 'delivery_operator'],
      children: [
        NavigationItem(
          title: 'Logistics Dashboard',
          route: '/logistics/dashboard',
          icon: Icons.dashboard,
          allowedRoles: ['system_admin', 'logistics_admin', 'delivery_operator'],
        ),
        NavigationItem(
          title: 'Vehicles',
          route: '/logistics/vehicles',
          icon: Icons.directions_car,
          allowedRoles: ['system_admin', 'logistics_admin'],
        ),
        NavigationItem(
          title: 'Route Planning',
          route: '/logistics/routes',
          icon: Icons.map,
          allowedRoles: ['system_admin', 'logistics_admin', 'delivery_operator'],
        ),
        NavigationItem(
          title: 'Live Tracking',
          route: '/logistics/tracking',
          icon: Icons.gps_fixed,
          allowedRoles: ['system_admin', 'logistics_admin', 'delivery_operator', 'sales_admin', 'sales_operator'],
        ),
        NavigationItem(
          title: 'Delivery History',
          route: '/logistics/history',
          icon: Icons.history,
          allowedRoles: ['system_admin', 'logistics_admin', 'delivery_operator'],
        ),
      ],
    ),
    
    // Settings Section (Admin only)
    NavigationItem(
      title: 'Settings',
      icon: Icons.settings,
      allowedRoles: ['system_admin'],
      children: [
        NavigationItem(
          title: 'User Management',
          route: '/admin/users',
          icon: Icons.people,
          allowedRoles: ['system_admin'],
        ),
        NavigationItem(
          title: 'System Settings',
          route: '/admin/settings',
          icon: Icons.tune,
          allowedRoles: ['system_admin'],
        ),
      ],
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      stream: AuthService().userRoleStream,
      builder: (context, snapshot) {
        final String? userRole = snapshot.data?.role;
        
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UND Warehouse Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.data?.name ?? 'Loading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userRole?.toUpperCase() ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dynamically generate navigation items based on user role
              ...buildMenuItems(context, _navigationItems, userRole),
              
              const Divider(),
              
              // Logout is available to everyone
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await AuthService().signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  List<Widget> buildMenuItems(
    BuildContext context, 
    List<NavigationItem> items, 
    String? userRole
  ) {
    List<Widget> widgets = [];
    
    for (var item in items) {
      // Skip items that the user doesn't have access to
      if (userRole == null || !item.allowedRoles.contains(userRole)) {
        continue;
      }
      
      // If this is a section header with children
      if (item.children != null && item.children!.isNotEmpty) {
        widgets.add(
          ExpansionTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            children: buildMenuItems(
              context, 
              item.children!, 
              userRole
            ).map((widget) {
              // Add indentation for child items
              if (widget is ListTile) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: widget,
                );
              }
              return widget;
            }).toList(),
          ),
        );
      } 
      // If this is a direct navigation item
      else if (item.route != null) {
        widgets.add(
          ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(item.route!);
            },
          ),
        );
      }
    }
    
    return widgets;
  }
}
'@
Set-Content -Path $roleBasedDrawerPath -Value $roleBasedDrawerContent
Write-Host "Created 'widgets/role_based_drawer.dart'" -ForegroundColor Green

# Create screen files
$loginScreenPath = Join-Path $libDir "screens/auth/login_screen.dart"
$loginScreenContent = @'
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String? redirectTo;
  
  const LoginScreen({Key? key, this.redirectTo}) : super(key: key);
  
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  final AuthService _authService = AuthService();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (user != null) {
        // Navigate to appropriate screen based on role
        _navigateAfterLogin(user);
      } else {
        setState(() {
          _errorMessage = 'Failed to sign in. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _navigateAfterLogin(UserModel user) {
    // Navigate to the redirect route if provided
    if (widget.redirectTo != null) {
      Navigator.of(context).pushReplacementNamed(widget.redirectTo!);
      return;
    }
    
    // Otherwise, navigate based on role
    switch (user.role.role) {
      case 'system_admin':
        Navigator.of(context).pushReplacementNamed('/admin/dashboard');
        break;
      case 'warehouse_admin':
      case 'inventory_operator':
        Navigator.of(context).pushReplacementNamed('/warehouse/dashboard');
        break;
      case 'factory_admin':
      case 'production_operator':
        Navigator.of(context).pushReplacementNamed('/factory/dashboard');
        break;
      case 'sales_admin':
      case 'sales_operator':
        Navigator.of(context).pushReplacementNamed('/sales/dashboard');
        break;
      case 'logistics_admin':
      case 'delivery_operator':
        Navigator.of(context).pushReplacementNamed('/logistics/dashboard');
        break;
      default:
        // Fallback to home screen
        Navigator.of(context).pushReplacementNamed('/');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Icon(
                  Icons.inventory,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'UND Warehouse Management',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),
                
                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/forgot-password');
                          },
                          child: Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Sign in button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'@
Set-Content -Path $loginScreenPath -Value $loginScreenContent
Write-Host "Created 'screens/auth/login_screen.dart'" -ForegroundColor Green

$unauthorizedScreenPath = Join-Path $libDir "screens/auth/unauthorized_screen.dart"
$unauthorizedScreenContent = @'
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Denied'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.no_encryption_gmailerrorred,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 24),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headline4,
              ),
              SizedBox(height: 16),
              Text(
                'You do not have permission to access this area.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: Text('Go to Home'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await AuthService().signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
'@
Set-Content -Path $unauthorizedScreenPath -Value $unauthorizedScreenContent
Write-Host "Created 'screens/auth/unauthorized_screen.dart'" -ForegroundColor Green

$homeScreenPath = Join-Path $libDir "screens/home/home_screen.dart"
$homeScreenContent = @'
import 'package:flutter/material.dart';
import '../../widgets/role_based_drawer.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UND Warehouse Management System'),
      ),
      drawer: RoleBasedDrawer(),
      body: StreamBuilder<UserModel?>(
        stream: AuthService().userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          // If no user logged in, show login prompt
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildLoginPrompt(context);
          }
          
          final user = snapshot.data!;
          
          // Show role-specific dashboard
          return _buildRoleBasedDashboard(context, user);
        },
      ),
    );
  }
  
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            'Welcome to UND Warehouse Management',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 16),
          Text(
            'Please sign in to continue',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: Text(
                'Sign In',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoleBasedDashboard(BuildContext context, UserModel user) {
    // Determine which dashboard to display based on user role
    switch (user.role.role) {
      case 'system_admin':
        return _buildAdminDashboard(context, user);
      case 'warehouse_admin':
      case 'inventory_operator':
        return _redirectToDashboard(context, '/warehouse/dashboard');
      case 'factory_admin':
      case 'production_operator':
        return _redirectToDashboard(context, '/factory/dashboard');
      case 'sales_admin':
      case 'sales_operator':
        return _redirectToDashboard(context, '/sales/dashboard');
      case 'logistics_admin':
      case 'delivery_operator':
        return _redirectToDashboard(context, '/logistics/dashboard');
      default:
        return _buildDefaultDashboard(context, user);
    }
  }
  
  Widget _buildAdminDashboard(BuildContext context, UserModel user) {
    // This would normally navigate to the admin dashboard
    // For now, just show a placeholder
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/admin/dashboard');
    });
    
    return Center(child: CircularProgressIndicator());
  }
  
  Widget _redirectToDashboard(BuildContext context, String route) {
    // Navigate to the appropriate dashboard
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(route);
    });
    
    return Center(child: CircularProgressIndicator());
  }
  
  Widget _buildDefaultDashboard(BuildContext context, UserModel user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 24),
          Text(
            'Welcome, ${user.displayName ?? user.email}',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 16),
          Text(
            'Role: ${user.role.role}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 32),
          Text(
            'Please use the menu to navigate to your assigned area.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
'@
Set-Content -Path $homeScreenPath -Value $homeScreenContent
Write-Host "Created 'screens/home/home_screen.dart'" -ForegroundColor Green

# Create stub files for other screens
$screenStubs = @(
    # Warehouse screens
    @{Path = "screens/warehouse/warehouse_dashboard_screen.dart"; ClassName = "WarehouseDashboardScreen"},
    @{Path = "screens/warehouse/goods_receipt_screen.dart"; ClassName = "GoodsReceiptScreen"},
    @{Path = "screens/warehouse/goods_issue_screen.dart"; ClassName = "GoodsIssueScreen"},
    @{Path = "screens/warehouse/inventory_count_screen.dart"; ClassName = "InventoryCountScreen"},
    @{Path = "screens/warehouse/location_management_screen.dart"; ClassName = "LocationManagementScreen"},
    
    # Factory screens
    @{Path = "screens/factory/factory_dashboard_screen.dart"; ClassName = "FactoryDashboardScreen"},
    @{Path = "screens/factory/recipe_management_screen.dart"; ClassName = "RecipeManagementScreen"},
    @{Path = "screens/factory/production_orders_screen.dart"; ClassName = "ProductionOrdersScreen"},
    @{Path = "screens/factory/material_requisition_screen.dart"; ClassName = "MaterialRequisitionScreen"},
    
    # Sales screens
    @{Path = "screens/sales/sales_dashboard_screen.dart"; ClassName = "SalesDashboardScreen"},
    @{Path = "screens/sales/customer_management_screen.dart"; ClassName = "CustomerManagementScreen"},
    @{Path = "screens/sales/new_sales_order_screen.dart"; ClassName = "NewSalesOrderScreen"},
    @{Path = "screens/sales/sales_order_list_screen.dart"; ClassName = "SalesOrderListScreen"},
    @{Path = "screens/sales/sales_analytics_screen.dart"; ClassName = "SalesAnalyticsScreen"},
    
    # Logistics screens
    @{Path = "screens/logistics/logistics_dashboard_screen.dart"; ClassName = "LogisticsDashboardScreen"},
    @{Path = "screens/logistics/vehicle_management_screen.dart"; ClassName = "VehicleManagementScreen"},
    @{Path = "screens/logistics/route_management_screen.dart"; ClassName = "RouteManagementScreen"},
    @{Path = "screens/logistics/live_tracking_screen.dart"; ClassName = "LiveTrackingScreen"},
    @{Path = "screens/logistics/delivery_history_screen.dart"; ClassName = "DeliveryHistoryScreen"},
    
    # Admin screens
    @{Path = "screens/admin/user_management_screen.dart"; ClassName = "UserManagementScreen"},
    @{Path = "screens/admin/system_settings_screen.dart"; ClassName = "SystemSettingsScreen"}
)

foreach ($stub in $screenStubs) {
    $stubPath = Join-Path $libDir $stub.Path
    $stubContent = @"
import 'package:flutter/material.dart';
import '../../widgets/role_based_drawer.dart';

class $($stub.ClassName) extends StatelessWidget {
  const $($stub.ClassName)({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$($stub.ClassName)'),
      ),
      drawer: RoleBasedDrawer(),
      body: Center(
        child: Text('Implement $($stub.ClassName) here'),
      ),
    );
  }
}
"@
    Set-Content -Path $stubPath -Value $stubContent
    Write-Host "Created '$($stub.Path)'" -ForegroundColor Green
}

Write-Host "`nUND Flutter Warehouse Management App folder structure created successfully!" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run 'flutter create .' in your project directory if it's a new project" -ForegroundColor Yellow
Write-Host "2. Add required dependencies to pubspec.yaml:" -ForegroundColor Yellow
Write-Host "   - firebase_core: ^2.13.1" -ForegroundColor Yellow
Write-Host "   - firebase_auth: ^4.6.2" -ForegroundColor Yellow
Write-Host "   - cloud_firestore: ^4.8.0" -ForegroundColor Yellow
Write-Host "   - cloud_functions: ^4.3.2" -ForegroundColor Yellow
Write-Host "   - firebase_storage: ^11.2.2" -ForegroundColor Yellow
Write-Host "   - flutter_bloc: ^8.1.2" -ForegroundColor Yellow
Write-Host "   - get_it: ^7.6.0" -ForegroundColor Yellow
Write-Host "3. Run 'flutter pub get' to install dependencies" -ForegroundColor Yellow
Write-Host "4. Configure Firebase following the Firebase console instructions" -ForegroundColor Yellow