import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/app_router.dart';
import 'features/auth/data/datasources/mock_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart' as domain_auth;
import 'features/factory/production/data/repositories/production_execution_repository_impl.dart';
import 'features/factory/production/presentation/providers/production_execution_providers.dart'
    as production;
import 'features/inventory/data/providers/dairy_inventory_provider.dart'
    as dairy;
import 'features/inventory/data/providers/mock_inventory_provider.dart';
import 'features/inventory/data/repositories/dairy_inventory_repository.dart'
    as dairy_repo;
import 'features/inventory/data/repositories/inventory_movement_repository.dart';
import 'features/inventory/data/repositories/inventory_movement_repository_impl.dart';
// Hide the original inventory repository provider to avoid conflicts
import 'features/inventory/data/repositories/inventory_repository.dart'
    hide inventoryRepositoryProvider;
import 'features/inventory/data/repositories/mock_inventory_repository.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

// Create mock inventory repository provider
final mockInventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final mockProvider = ref.watch(mockInventoryProvider);
  // Cast needed since MockInventoryRepository implements domain InventoryRepository
  return MockInventoryRepository(mockProvider: mockProvider)
      as InventoryRepository;
});

// Create inventory movement repository provider
final inventoryMovementRepositoryImplProvider =
    Provider<InventoryMovementRepository>((ref) {
  return InventoryMovementRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    logger: Logger(),
  );
});

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the SharedPreferences provider
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),

        // Override the SharedPreferences provider for dairy inventory
        dairy.sharedPreferencesProvider.overrideWithValue(sharedPreferences),

        // The dairy inventory repository provider is already defined in dairy_inventory_repository.dart
        // and it automatically exposes the inventoryRepositoryProvider

        // Override the inventory movement repository provider
        inventoryMovementRepositoryProvider
            .overrideWithProvider(inventoryMovementRepositoryImplProvider),

        // Override the production execution repository provider
        production.productionExecutionRepositoryProvider
            .overrideWith((ref) => ProductionExecutionRepositoryImpl(
                  firestore: FirebaseFirestore.instance,
                  logger: Logger(),
                )),

        // Override the auth repository provider
        domain_auth.authRepositoryProvider.overrideWith((ref) =>
            AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locale = Locale(settings.language);

    return MaterialApp(
      title: 'UND Dairy Management',
      theme: AppTheme.lightTheme(locale),
      darkTheme: AppTheme.darkTheme(locale),
      themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: [
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
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRoutes.home,
      debugShowCheckedModeBanner: false,
    );
  }
}
