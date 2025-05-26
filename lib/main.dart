import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'core/routes/app_go_router.dart';
import 'features/inventory/data/repositories/inventory_movement_repository_impl.dart';
import 'features/inventory/domain/providers/inventory_repository_provider.dart';
import 'features/inventory/domain/services/optimized_inventory_rop_safety_stock_scheduler.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'core/data/unified_data_manager.dart';
import 'core/error/error_boundary.dart';

// Create inventory movement repository provider with real Firebase
final inventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepositoryImpl>((ref) {
  return InventoryMovementRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    logger: Logger(),
  );
});

class RopSafetyStockSchedulerProvider extends ConsumerStatefulWidget {
  const RopSafetyStockSchedulerProvider({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<RopSafetyStockSchedulerProvider> createState() =>
      _RopSafetyStockSchedulerProviderState();
}

class _RopSafetyStockSchedulerProviderState
    extends ConsumerState<RopSafetyStockSchedulerProvider> {
  OptimizedInventoryRopSafetyStockScheduler? _scheduler;

  @override
  void initState() {
    super.initState();

    // Initialize scheduler after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _scheduler = ref.read(optimizedRopSchedulerProvider);
        _scheduler!.start();
      } catch (e) {
        debugPrint('Failed to initialize ROP scheduler: $e');
      }
    });
  }

  @override
  void dispose() {
    _scheduler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure SemanticsBinding for better Windows accessibility handling
  SemanticsBinding.instance.ensureSemantics();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Unified Data Manager
  await UnifiedDataManager.instance.initialize();

  // Setup global error handling for better debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log errors for debugging
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');

    // Track error with analytics
    ErrorAnalytics.trackError(
      details.exception,
      details.stack,
      context: 'FlutterError',
    );
  };

  // Ensure user is signed out on startup to always show login screen
  await FirebaseAuth.instance.signOut();

  runApp(
    ProviderScope(
      child: RopSafetyStockSchedulerProvider(
        child: const DairyManagementApp(),
      ),
    ),
  );
}

class DairyManagementApp extends ConsumerWidget {
  const DairyManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      child: PerformanceMonitorWidget(
        child: MaterialApp.router(
          title: 'Dairy Management System',
          theme: AppTheme.lightTheme(const Locale('en')),
          darkTheme: AppTheme.darkTheme(const Locale('en')),
          themeMode: ThemeMode.system,
          routerConfig: ref.watch(goRouterProvider),
          debugShowCheckedModeBanner: false,

          // Global error handling
          builder: (context, child) {
            return ErrorBoundary(
              child: child ?? const SizedBox.shrink(),
              errorBuilder: (error, stackTrace, retry) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Application Error',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Restart App'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
