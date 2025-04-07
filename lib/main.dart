import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/firebase/firebase_interface.dart';
import 'core/firebase/firebase_mock.dart';
import 'core/firebase/firebase_module.dart';
import 'core/firebase/mock_app_initializer.dart';
import 'core/firebase/mock_firebase_helpers.dart';
import 'core/routes/app_router.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/milk_reception/domain/repositories/milk_reception_repository.dart';
import 'features/milk_reception/domain/services/milk_reception_service.dart';
import 'features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'features/suppliers/domain/repositories/supplier_repository.dart';
import 'features/suppliers/presentation/providers/supplier_provider.dart';
import 'services/reception_inventory_service.dart';
import 'services/reception_notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize either real Firebase or mock Firebase
  if (useMockFirebase) {
    await MockAppInitializer.initializeMockFirebase();
  } else {
    await Firebase.initializeApp();
  }

  // Create a ProviderContainer for initialization
  final container = ProviderContainer();

  // Initialize service locator
  await _initializeServiceLocator(container);

  runApp(
    ProviderScope(
      parent: container,
      overrides: [
        supplierRepositoryProvider.overrideWithValue(
          SupplierRepositoryImpl(
              useMockFirebase ? FirestoreMock() : FirebaseFirestore.instance),
        ),
      ],
      child: MockAppInitializer.addMockIndicator(const MyApp()),
    ),
  );
}

/// Initialize the service locator with all necessary services
Future<void> _initializeServiceLocator(ProviderContainer container) async {
  // Get the appropriate Firebase instances
  final firestoreInstance =
      useMockFirebase ? FirestoreMock() : FirebaseFirestore.instance;

  final messagingInstance =
      useMockFirebase ? MockMessaging() : FirebaseMessaging.instance;

  final localNotifications = FlutterLocalNotificationsPlugin();

  // Create repositories
  final milkReceptionRepository = FirestoreMilkReceptionRepository(
    firestore: firestoreInstance,
  );

  final inventoryRepository = InventoryRepositoryImpl(
    firestore: firestoreInstance,
  );

  final supplierRepository = SupplierRepositoryImpl(firestoreInstance);

  // Create notification service with conditional initialization
  final notificationService = ReceptionNotificationService(
    firestore: firestoreInstance,
    messaging: messagingInstance,
    localNotifications: localNotifications,
  );

  // Initialize notification service (only if not using mock)
  if (!useMockFirebase) {
    await notificationService.initialize();
  }

  // Create the milk reception service with notification integration
  final milkReceptionService = initializeMilkReceptionService(
    milkReceptionRepository,
    inventoryRepository,
    supplierRepository,
    notificationService,
  );

  // Create the integration service
  final receptionInventoryService = ReceptionInventoryService(
    receptionRepository: milkReceptionRepository,
    inventoryRepository: inventoryRepository,
    firestore: firestoreInstance,
  );

  // Register services in the locator
  ServiceLocator.instance
      .register<ReceptionInventoryService>(receptionInventoryService);
  ServiceLocator.instance
      .register<ReceptionNotificationService>(notificationService);
  ServiceLocator.instance.register<MilkReceptionService>(milkReceptionService);
}

/// Helper function to initialize MilkReceptionService with proper type handling
MilkReceptionService initializeMilkReceptionService(
  MilkReceptionRepository receptionRepository,
  dynamic inventoryRepository,
  SupplierRepository supplierRepository,
  ReceptionNotificationService notificationService,
) {
  return MilkReceptionService(
    receptionRepository: receptionRepository,
    inventoryRepository: inventoryRepository,
    supplierRepository: supplierRepository,
    notificationService: notificationService,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UND Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(const Locale('en')),
      darkTheme: AppTheme.darkTheme(const Locale('en')),
      themeMode: ThemeMode.light, // Force light theme for consistent UI
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
        Locale('hi', ''), // Hindi
      ],
      // Add localization delegates in a future update when using flutter_localizations
      localizationsDelegates: const [],
      locale: const Locale('en', ''), // Set default locale explicitly
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        // Apply text direction based on locale
        return Directionality(
          textDirection:
              Localizations.maybeLocaleOf(context)?.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
