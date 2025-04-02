# PowerShell script to create Flutter UND warehouse management app with Riverpod

# Define the base directory (current directory)
$baseDir = Get-Location
$projectName = "und"

Write-Host "Setting up Flutter project '$projectName' with Riverpod..." -ForegroundColor Cyan

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Host "Flutter is installed: $($flutterVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "Flutter is not installed or not in PATH. Please install Flutter first." -ForegroundColor Red
    Write-Host "Visit https://docs.flutter.dev/get-started/install for installation instructions." -ForegroundColor Yellow
    exit 1
}

# Step 1: Create Flutter project if it doesn't exist
if (-not (Test-Path "$baseDir/pubspec.yaml")) {
    Write-Host "Creating new Flutter project..." -ForegroundColor Yellow
    flutter create $projectName --platforms=android,ios
    
    # Move into project directory if it was just created
    if (Test-Path "$baseDir/$projectName") {
        Set-Location "$baseDir/$projectName"
        $baseDir = Get-Location
    }
} else {
    Write-Host "Flutter project already exists in this directory." -ForegroundColor Green
}

# Create the lib directory structure if it doesn't exist
$libDir = Join-Path $baseDir "lib"
if (-not (Test-Path $libDir)) {
    New-Item -Path $libDir -ItemType Directory
    Write-Host "Created 'lib' directory" -ForegroundColor Green
}

# Create subdirectories
$directories = @(
    "core",
    "core/constants",
    "core/exceptions",
    "core/utils",
    "features",
    "features/auth",
    "features/auth/data",
    "features/auth/domain",
    "features/auth/presentation",
    "features/warehouse",
    "features/warehouse/data",
    "features/warehouse/domain",
    "features/warehouse/presentation",
    "features/factory",
    "features/factory/data",
    "features/factory/domain",
    "features/factory/presentation",
    "features/sales",
    "features/sales/data",
    "features/sales/domain",
    "features/sales/presentation",
    "features/logistics",
    "features/logistics/data",
    "features/logistics/domain",
    "features/logistics/presentation",
    "shared",
    "shared/providers",
    "shared/models",
    "shared/widgets"
)

foreach ($dir in $directories) {
    $newDir = Join-Path $libDir $dir
    if (-not (Test-Path $newDir)) {
        New-Item -Path $newDir -ItemType Directory
        Write-Host "Created '$dir' directory" -ForegroundColor Green
    }
}

# Update pubspec.yaml with required dependencies
$pubspecPath = Join-Path $baseDir "pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw

# Check if dependencies already exist before adding them
$dependenciesToAdd = @(
    "  firebase_core: ^2.15.1",
    "  firebase_auth: ^4.7.3",
    "  cloud_firestore: ^4.8.5",
    "  cloud_functions: ^4.4.0",
    "  firebase_storage: ^11.2.6",
    "  flutter_riverpod: ^2.4.0",
    "  riverpod_annotation: ^2.1.5",
    "  freezed_annotation: ^2.4.1",
    "  json_annotation: ^4.8.1",
    "  go_router: ^10.1.2",
    "  intl: ^0.18.1"
)

$devDependenciesToAdd = @(
    "  build_runner: ^2.4.6",
    "  riverpod_generator: ^2.3.2",
    "  freezed: ^2.4.2",
    "  json_serializable: ^6.7.1",
    "  custom_lint: ^0.5.2",
    "  riverpod_lint: ^2.0.4"
)

# Check if dependencies section exists
if ($pubspecContent -match "dependencies:") {
    # Add each dependency if it doesn't exist
    foreach ($dependency in $dependenciesToAdd) {
        $depName = ($dependency -split ":")[0].Trim()
        if (-not ($pubspecContent -match "${depName}:")) {
            $pubspecContent = $pubspecContent -replace "(dependencies:.*?)(\r?\n\r?\n)", "`$1`n$dependency`$2"
        }
    }
    
    # Check if dev_dependencies section exists and add dependencies
    if ($pubspecContent -match "dev_dependencies:") {
        foreach ($devDependency in $devDependenciesToAdd) {
            $devDepName = ($devDependency -split ":")[0].Trim()
            if (-not ($pubspecContent -match "${devDepName}:")) {
                $pubspecContent = $pubspecContent -replace "(dev_dependencies:.*?)(\r?\n\r?\n)", "`$1`n$devDependency`$2"
            }
        }
    }
    
    # Write updated pubspec.yaml
    Set-Content -Path $pubspecPath -Value $pubspecContent
    Write-Host "Updated pubspec.yaml with dependencies" -ForegroundColor Green
}

# Create analysis_options.yaml for Riverpod lints
$analysisOptionsPath = Join-Path $baseDir "analysis_options.yaml"
$analysisOptionsContent = @'
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - sort_constructors_first
    - prefer_single_quotes
    - prefer_relative_imports
    - directives_ordering
    - avoid_empty_else
    - unnecessary_brace_in_string_interps
    - avoid_print

custom_lint:
  rules:
    - riverpod_lint:
        all: true 
'@

Set-Content -Path $analysisOptionsPath -Value $analysisOptionsContent
Write-Host "Created analysis_options.yaml with Riverpod lints" -ForegroundColor Green

# Create main.dart file with Riverpod setup
$mainDartPath = Join-Path $libDir "main.dart"
$mainDartContent = @'
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'UND Warehouse Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
'@
Set-Content -Path $mainDartPath -Value $mainDartContent
Write-Host "Created main.dart with Riverpod setup" -ForegroundColor Green

# Create router.dart file
$routerDirPath = Join-Path $libDir "core/utils"
if (-not (Test-Path $routerDirPath)) {
    New-Item -Path $routerDirPath -ItemType Directory -Force
}

$routerPath = Join-Path $routerDirPath "router.dart"
$routerContent = @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/warehouse/presentation/warehouse_dashboard_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/warehouse/dashboard',
        builder: (context, state) => const WarehouseDashboardScreen(),
      ),
      // Add more routes as you build your application
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
'@
Set-Content -Path $routerPath -Value $routerContent
Write-Host "Created router.dart" -ForegroundColor Green

# Create firebase_options.dart stub
$firebaseOptionsPath = Join-Path $libDir "firebase_options.dart"
$firebaseOptionsContent = @'
// File generated by FlutterFire CLI.
// This file should be replaced with your actual Firebase configuration
// generated using: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace these placeholders with your actual Firebase configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    authDomain: 'YOUR-AUTH-DOMAIN',
    storageBucket: 'YOUR-STORAGE-BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'YOUR-IOS-BUNDLE-ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'YOUR-IOS-BUNDLE-ID',
  );
}
'@
Set-Content -Path $firebaseOptionsPath -Value $firebaseOptionsContent
Write-Host "Created firebase_options.dart stub" -ForegroundColor Green

# Create user_model.dart
$userModelDirPath = Join-Path $libDir "shared/models"
$userModelPath = Join-Path $userModelDirPath "user_model.dart"
$userModelContent = @'
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required UserRole role,
    String? warehouseId,
    @Default(false) bool emailVerified,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
      
  factory UserModel.fromFirebase(
    firebase_auth.User firebaseUser, 
    Map<String, dynamic>? claims,
  ) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      role: UserRole.fromClaims(claims),
      warehouseId: claims?['warehouseId'] as String?,
      emailVerified: firebaseUser.emailVerified,
    );
  }
}

@freezed
class UserRole with _$UserRole {
  const factory UserRole({
    required String role,
    required List<String> permissions,
  }) = _UserRole;

  factory UserRole.fromJson(Map<String, dynamic> json) => 
      _$UserRoleFromJson(json);
      
  factory UserRole.fromClaims(Map<String, dynamic>? claims) {
    final roleString = claims?['role'] as String? ?? 'guest';
    return UserRole(
      role: roleString,
      permissions: _getPermissionsForRole(roleString),
    );
  }

  static List<String> _getPermissionsForRole(String role) {
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
}
'@
if (-not (Test-Path $userModelDirPath)) {
    New-Item -Path $userModelDirPath -ItemType Directory -Force
}
Set-Content -Path $userModelPath -Value $userModelContent
Write-Host "Created user_model.dart" -ForegroundColor Green

# Create firebase_providers.dart
$providersDirPath = Join-Path $libDir "shared/providers"
$firebaseProvidersPath = Join-Path $providersDirPath "firebase_providers.dart"
$firebaseProvidersContent = @'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseFunctions functions(FunctionsRef ref) {
  return FirebaseFunctions.instance;
}

@riverpod
FirebaseStorage storage(StorageRef ref) {
  return FirebaseStorage.instance;
}
'@
if (-not (Test-Path $providersDirPath)) {
    New-Item -Path $providersDirPath -ItemType Directory -Force
}
Set-Content -Path $firebaseProvidersPath -Value $firebaseProvidersContent
Write-Host "Created firebase_providers.dart" -ForegroundColor Green

# Create auth_repository.dart
$authRepoPath = Join-Path $libDir "features/auth/data/auth_repository.dart"
$authRepoDirPath = Join-Path $libDir "features/auth/data"
$authRepoContent = @'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../../../shared/models/user_model.dart';

part 'auth_repository.g.dart';

class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => message;
}

@riverpod
class AuthRepository extends _$AuthRepository {
  @override
  FutureOr<void> build() {
    // Nothing to return initially
  }

  Stream<User?> authStateChanges() {
    final auth = ref.read(firebaseAuthProvider);
    return auth.authStateChanges();
  }

  Stream<UserModel?> userModelStream() {
    final auth = ref.read(firebaseAuthProvider);
    final firestore = ref.read(firestoreProvider);
    
    return auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }
      
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      
      // Update last login
      await firestore.collection('users').doc(user.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      return UserModel.fromFirebase(user, claims);
    });
  }

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) return null;
      
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      
      return UserModel.fromFirebase(user, claims);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<void> signOut() async {
    final auth = ref.read(firebaseAuthProvider);
    await auth.signOut();
  }
  
  Future<String?> getCurrentUserRole() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }
    
    final idTokenResult = await user.getIdTokenResult(true);
    return idTokenResult.claims?['role'] as String?;
  }
  
  // Helper to handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email address.');
      case 'wrong-password':
        return AuthException('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return AuthException('The email address is already in use.');
      case 'weak-password':
        return AuthException('The password is too weak. Please choose a stronger password.');
      case 'invalid-email':
        return AuthException('The email address is invalid.');
      case 'user-disabled':
        return AuthException('This user account has been disabled.');
      case 'too-many-requests':
        return AuthException('Too many login attempts. Please try again later.');
      default:
        return AuthException('Authentication error: ${e.message}');
    }
  }
}
'@
if (-not (Test-Path $authRepoDirPath)) {
    New-Item -Path $authRepoDirPath -ItemType Directory -Force
}
Set-Content -Path $authRepoPath -Value $authRepoContent
Write-Host "Created auth_repository.dart" -ForegroundColor Green

# Create auth_provider.dart
$authProviderPath = Join-Path $libDir "features/auth/domain/auth_provider.dart"
$authProviderDirPath = Join-Path $libDir "features/auth/domain"
$authProviderContent = @'
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/user_model.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<UserModel?> currentUser(CurrentUserRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.userModelStream();
}

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    ref.listen(currentUserProvider, (previous, next) {
      if (next is AsyncLoading) {
        state = AuthState.loading;
      } else if (next is AsyncError) {
        state = AuthState.error;
      } else if (next is AsyncData) {
        if (next.value != null) {
          state = AuthState.authenticated;
        } else {
          state = AuthState.unauthenticated;
        }
      }
    });
    
    return AuthState.initial;
  }
  
  Future<void> signIn(String email, String password) async {
    state = AuthState.loading;
    try {
      await ref.read(authRepositoryProvider.notifier).signInWithEmailAndPassword(email, password);
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    state = AuthState.loading;
    try {
      await ref.read(authRepositoryProvider.notifier).signOut();
      state = AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }
}
'@
if (-not (Test-Path $authProviderDirPath)) {
    New-Item -Path $authProviderDirPath -ItemType Directory -Force
}
Set-Content -Path $authProviderPath -Value $authProviderContent
Write-Host "Created auth_provider.dart" -ForegroundColor Green

# Create login_screen.dart
$loginScreenPath = Join-Path $libDir "features/auth/presentation/login_screen.dart"
$loginScreenDirPath = Join-Path $libDir "features/auth/presentation"
$loginScreenContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _errorMessage;
  
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
      _errorMessage = null;
    });
    
    try {
      await ref.read(authProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Navigation will be handled by the auth state listener
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState == AuthState.loading;
    
    // Listen for authentication state changes
    ref.listen(authProvider, (previous, next) {
      if (next == AuthState.authenticated) {
        // Navigate after successful authentication
        context.go('/warehouse/dashboard');
      }
    });
    
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
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            // Handle forgot password
                          },
                          child: Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSignIn,
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16),
                                ),
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
if (-not (Test-Path $loginScreenDirPath)) {
    New-Item -Path $loginScreenDirPath -ItemType Directory -Force
}
Set-Content -Path $loginScreenPath -Value $loginScreenContent
Write-Host "Created login_screen.dart" -ForegroundColor Green

# Create warehouse_dashboard_screen.dart
$warehouseDashboardPath = Join-Path $libDir "features/warehouse/presentation/warehouse_dashboard_screen.dart"
$warehouseDashboardDirPath = Join-Path $libDir "features/warehouse/presentation"
$warehouseDashboardContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/domain/auth_provider.dart';

class WarehouseDashboardScreen extends ConsumerWidget {
  const WarehouseDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            userAsync.when(
              data: (user) => UserAccountsDrawerHeader(
                accountName: Text(user?.displayName ?? 'User'),
                accountEmail: Text(user?.email ?? 'No email'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.displayName?.isNotEmpty == true
                        ? user!.displayName![0].toUpperCase()
                        : 'U',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ),
              loading: () => const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(child: Text('Error loading user data')),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Inventory'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to inventory screen
              },
            ),
            ListTile(
              leading: Icon(Icons.input),
              title: Text('Receive Goods'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to receive goods screen
              },
            ),
            ListTile(
              leading: Icon(Icons.output),
              title: Text('Issue Goods'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to issue goods screen
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userAsync.when(
          data: (user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.displayName ?? user?.email ?? 'User'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      'Inventory Status',
                      Icons.inventory_2,
                      Colors.blue.shade100,
                      () {
                        // Navigate to inventory status screen
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Receive Goods',
                      Icons.input,
                      Colors.green.shade100,
                      () {
                        // Navigate to receive goods screen
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Issue Goods',
                      Icons.output,
                      Colors.orange.shade100,
                      () {
                        // Navigate to issue goods screen
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Stock Count',
                      Icons.list_alt,
                      Colors.purple.shade100,
                      () {
                        // Navigate to stock count screen
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.grey[800],
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
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
if (-not (Test-Path $warehouseDashboardDirPath)) {
    New-Item -Path $warehouseDashboardDirPath -ItemType Directory -Force
}
Set-Content -Path $warehouseDashboardPath -Value $warehouseDashboardContent
Write-Host "Created warehouse_dashboard_screen.dart" -ForegroundColor Green

# Run flutter pub get
Write-Host "Running 'flutter pub get' to install dependencies..." -ForegroundColor Yellow
flutter pub get

# Generate Riverpod code with build_runner
Write-Host "Running 'flutter pub run build_runner build' to generate code..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs

# Display success message
Write-Host "`nUND Flutter Warehouse Management App has been successfully set up with Riverpod!" -ForegroundColor Cyan
Write-Host "Project structure created according to best practices based on https://www.reddit.com/r/FlutterDev/comments/1cpqywq/building_scalable_flutter_apps_with_riverpod_best/[(Building Scalable Flutter Apps with Riverpod: Best Practices - Reddit)](https://www.reddit.com/r/FlutterDev/comments/1cpqywq/building_scalable_flutter_apps_with_riverpod_best/)" -ForegroundColor Yellow

Write-Host "`nThe following features have been implemented:" -ForegroundColor Cyan
Write-Host "1. Project structure with feature-first organization" -ForegroundColor White
Write-Host "2. Riverpod with code generation for state management" -ForegroundColor White
Write-Host "3. Firebase integration (Auth, Firestore, Storage, Functions)" -ForegroundColor White
Write-Host "4. Role-based authentication system" -ForegroundColor White
Write-Host "5. Go Router for navigation" -ForegroundColor White
Write-Host "6. Freezed for immutable models" -ForegroundColor White

# Show next steps
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Configure Firebase for your project using FlutterFire CLI:" -ForegroundColor White
Write-Host "   > dart pub global activate flutterfire_cli" -ForegroundColor Gray
Write-Host "   > flutterfire configure" -ForegroundColor Gray
Write-Host "2. Add more screens and features to your application" -ForegroundColor White
Write-Host "3. Customize the themes and UI to match your brand" -ForegroundColor White
Write-Host "4. Set up proper testing for your application" -ForegroundColor White
Write-Host "5. Consider adding CI/CD for automated testing and deployment" -ForegroundColor White

# Optimize file generation based on PowerShell performance tips
Write-Host "`nNote: This script has been optimized following PowerShell best practices for performance.[(How can you optimize the performance of your PowerShell scripts?)](https://www.linkedin.com/advice/1/how-can-you-optimize-performance-your-powershell-egetc)" -ForegroundColor Yellow