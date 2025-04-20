import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/app_router.dart';
import 'core/firebase/firebase_interface.dart';
import 'core/firebase/firebase_mock.dart';
import 'core/firebase/firebase_module.dart';
import 'core/services/mock_data_service.dart';
import 'features/auth/data/datasources/mock_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart' as domain_auth;
import 'features/factory/production/data/repositories/production_execution_repository_impl.dart';
import 'features/factory/production/presentation/providers/production_execution_providers.dart'
    as production;
import 'features/inventory/presentation/providers/inventory_provider.dart';
import 'features/inventory/data/repositories/inventory_movement_repository.dart';
import 'features/inventory/data/repositories/inventory_movement_repository_impl.dart';
import 'features/inventory/data/models/inventory_movement_model.dart';
import 'features/inventory/data/models/inventory_movement_type.dart';
import 'features/shared/presentation/screens/app_settings_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

// Example of how to use the centralized mock data service:
//
// import 'core/services/mock_data_service.dart';
//
// // Access the central mock data service
// final mockData = MockDataService();
//
// // Or via the Provider in a widget:
// final mockData = ref.watch(mockDataServiceProvider);
//
// // Get inventory items
// final items = mockData.inventoryItems;
//
// // Update an inventory item
// mockData.updateInventoryItem(updatedItem);
//
// // Adjust quantity
// mockData.adjustQuantity('1', 10.0, 'Manual addition');
//
// This ensures all mock data is linked between modules instead of having separate mock data
// in each repository or data source.

// Create a mock implementation of the InventoryMovementRepository
class MockInventoryMovementRepository implements InventoryMovementRepository {
  MockInventoryMovementRepository(this.mockDataService);

  final MockDataService mockDataService;

  @override
  Future<InventoryMovementModel> createMovement(
      InventoryMovementModel movement) async {
    final String movementId = movement.movementId.isEmpty
        ? 'mov-${DateTime.now().millisecondsSinceEpoch}'
        : movement.movementId;

    final newMovement = InventoryMovementModel(
      movementId: movementId,
      timestamp: movement.timestamp,
      movementType: movement.movementType,
      sourceLocationId: movement.sourceLocationId,
      sourceLocationName: movement.sourceLocationName,
      destinationLocationId: movement.destinationLocationId,
      destinationLocationName: movement.destinationLocationName,
      initiatingEmployeeId: movement.initiatingEmployeeId,
      initiatingEmployeeName: movement.initiatingEmployeeName,
      approvalStatus: movement.approvalStatus,
      approverEmployeeId: movement.approverEmployeeId,
      approverEmployeeName: movement.approverEmployeeName,
      reasonNotes: movement.reasonNotes,
      referenceDocuments: movement.referenceDocuments,
      items: movement.items,
    );

    mockDataService.inventoryMovements.add(newMovement);
    return newMovement;
  }

  @override
  Future<void> deleteMovement(String id) async {
    mockDataService.inventoryMovements.removeWhere((m) => m.movementId == id);
  }

  @override
  Future<InventoryMovementModel> getMovementById(String id) async {
    return mockDataService.inventoryMovements
        .firstWhere((m) => m.movementId == id);
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByLocation(
      String locationId, bool isSource) async {
    return mockDataService.inventoryMovements
        .where((m) => isSource
            ? m.sourceLocationId == locationId
            : m.destinationLocationId == locationId)
        .toList();
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByProduct(
      String productId) async {
    return mockDataService.inventoryMovements
        .where((m) => m.items.any((item) => item.productId == productId))
        .toList();
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByTimeRange(
      DateTime start, DateTime end) async {
    return mockDataService.inventoryMovements
        .where((m) => m.timestamp.isAfter(start) && m.timestamp.isBefore(end))
        .toList();
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByType(
      InventoryMovementType type) async {
    return mockDataService.inventoryMovements
        .where((m) => m.movementType == type)
        .toList();
  }

  @override
  Future<InventoryMovementModel> updateMovementStatus(
      String id, ApprovalStatus status,
      {String? approverId, String? approverName}) async {
    final index = mockDataService.inventoryMovements
        .indexWhere((m) => m.movementId == id);

    if (index == -1) {
      throw Exception('Movement not found with ID: $id');
    }

    final currentMovement = mockDataService.inventoryMovements[index];

    final updatedMovement = InventoryMovementModel(
      movementId: currentMovement.movementId,
      timestamp: currentMovement.timestamp,
      movementType: currentMovement.movementType,
      sourceLocationId: currentMovement.sourceLocationId,
      sourceLocationName: currentMovement.sourceLocationName,
      destinationLocationId: currentMovement.destinationLocationId,
      destinationLocationName: currentMovement.destinationLocationName,
      initiatingEmployeeId: currentMovement.initiatingEmployeeId,
      initiatingEmployeeName: currentMovement.initiatingEmployeeName,
      approvalStatus: status,
      approverEmployeeId: approverId ?? currentMovement.approverEmployeeId,
      approverEmployeeName:
          approverName ?? currentMovement.approverEmployeeName,
      reasonNotes: currentMovement.reasonNotes,
      referenceDocuments: currentMovement.referenceDocuments,
      items: currentMovement.items,
    );

    mockDataService.inventoryMovements[index] = updatedMovement;
    return updatedMovement;
  }
}

// Create a provider for the mock data service
final mockDataServiceProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});

// Create a provider for the mock inventory movement repository
final mockInventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepository>((ref) {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return MockInventoryMovementRepository(mockDataService);
});

// Create inventory movement repository provider
final inventoryMovementRepositoryImplProvider =
    Provider<InventoryMovementRepository>((ref) {
  // Get the appropriate Firestore instance based on the flag
  final dynamic firestore =
      useMockFirebase ? FirestoreMock() : FirebaseFirestore.instance;

  return InventoryMovementRepositoryImpl(
    firestore: firestore,
    logger: Logger(),
  );
});

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Get the appropriate Firestore instance based on the flag
  final dynamic firestore =
      useMockFirebase ? FirestoreMock() : FirebaseFirestore.instance;

  runApp(
    ProviderScope(
      overrides: [
        // Override the inventory movement repository provider with mock
        inventoryMovementRepositoryProvider
            .overrideWithProvider(mockInventoryMovementRepositoryProvider),

        // Override the production execution repository provider
        production.productionExecutionRepositoryProvider
            .overrideWith((ref) => ProductionExecutionRepositoryImpl(
                  firestore: firestore,
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
    // Watch app settings for changes
    final appSettings = ref.watch(appSettingsProvider);
    final currentLocale = Locale(appSettings.language);

    return MaterialApp(
      title: 'UND Dairy Management',
      theme: AppTheme.lightTheme(currentLocale),
      darkTheme: AppTheme.darkTheme(currentLocale),
      themeMode: appSettings.themeMode,
      locale: currentLocale,
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
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
