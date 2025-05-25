import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

// Import real implementation dependencies
import 'core/routes/app_go_router.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart'; // Real Firebase auth datasource
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart' as domain_auth;
import 'features/factory/production/data/repositories/production_execution_repository_impl.dart';
import 'features/factory/production/presentation/providers/production_execution_providers.dart'
    as production;
import 'features/inventory/data/repositories/inventory_movement_repository.dart';
import 'features/inventory/data/repositories/inventory_movement_repository_impl.dart';
import 'features/inventory/domain/providers/inventory_repository_provider.dart';
import 'features/inventory/domain/services/inventory_rop_safety_stock_scheduler.dart';
import 'features/inventory/domain/usecases/apply_dynamic_reorder_point_usecase.dart';
import 'features/shared/presentation/screens/app_settings_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme/app_theme.dart';

// Use real Firebase implementation
// (mock-data block removed)

// Create inventory movement repository provider with real Firebase
final inventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepository>((ref) {
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
  InventoryRopSafetyStockScheduler? _scheduler;

  @override
  void initState() {
    super.initState();
    // Use ProviderContainer for non-widget Riverpod context
    final container = ProviderContainer();
    // Use the container directly to get the required providers
    final inventoryRepo = container.read(inventoryRepositoryProvider);
    final applyDynamicRop =
        container.read(applyDynamicReorderPointUseCaseProvider);
    _scheduler = InventoryRopSafetyStockScheduler(
      ref: container,
      inventoryRepository: inventoryRepo,
      applyDynamicRopUseCase: applyDynamicRop,
    );
    _scheduler!.start();
  }

  @override
  void dispose() {
    _scheduler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure SemanticsBinding for better Windows accessibility handling
  SemanticsBinding.instance.ensureSemantics();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure user is signed out on startup to always show login screen
  await FirebaseAuth.instance.signOut();

  runApp(
    ProviderScope(
      overrides: [
        // Override with real implementations
        production.productionExecutionRepositoryProvider.overrideWith(
          (ref) => ProductionExecutionRepositoryImpl(
            firestore: FirebaseFirestore.instance,
            logger: Logger(),
          ),
        ),

        // Override the auth repository provider with real implementation
        domain_auth.authRepositoryProvider.overrideWith(
          (ref) =>
              AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider)),
        ),
      ],
      child: RopSafetyStockSchedulerProvider(child: const MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch app settings for changes
    final appSettings = ref.watch(appSettingsProvider);
    final currentLocale = Locale(appSettings.language);

    return RopSafetyStockSchedulerProvider(
      child: MaterialApp.router(
        title: 'UND Dairy Management',
        theme: AppTheme.lightTheme(currentLocale),
        darkTheme: AppTheme.darkTheme(currentLocale),
        themeMode: appSettings.themeMode,
        locale: currentLocale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ar'), // Arabic
          Locale('ur'), // Urdu
          Locale('hi'), // Hindi
        ],
        routerConfig: ref.watch(goRouterProvider),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Disable semantic nodes that cause accessibility bridge errors on Windows
          return MediaQuery(
            // Prevent some accessibility issues by limiting the update frequency
            data: MediaQuery.of(context).copyWith(
              accessibleNavigation: false,
            ),
            child: ExcludeSemantics(
              // Selectively disable problematic semantic nodes while maintaining core accessibility
              excluding: false,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
