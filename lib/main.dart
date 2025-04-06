import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_router.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/milk_reception/domain/repositories/milk_reception_repository.dart';
import 'features/milk_reception/domain/services/milk_reception_service.dart';
import 'features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'features/suppliers/domain/repositories/supplier_repository.dart';
import 'features/suppliers/presentation/providers/supplier_provider.dart';
import 'services/reception_inventory_service.dart';
import 'services/reception_notification_service.dart';
import 'utils/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize service locator
  await _initializeServiceLocator();

  runApp(
    ProviderScope(
      overrides: [
        supplierRepositoryProvider.overrideWithValue(
          SupplierRepositoryImpl(FirebaseFirestore.instance),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialize the service locator with all necessary services
Future<void> _initializeServiceLocator() async {
  final firestore = FirebaseFirestore.instance;
  final messaging = FirebaseMessaging.instance;
  final localNotifications = FlutterLocalNotificationsPlugin();

  // Create repositories
  final milkReceptionRepository = FirestoreMilkReceptionRepository(
    firestore: firestore,
  );

  final inventoryRepository = InventoryRepositoryImpl(
    firestore: firestore,
  );

  final supplierRepository = SupplierRepositoryImpl(firestore);

  // Create notification service
  final notificationService = ReceptionNotificationService(
    firestore: firestore,
    messaging: messaging,
    localNotifications: localNotifications,
  );

  // Initialize notification service
  await notificationService.initialize();

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
    firestore: firestore,
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      // Add localization delegates in a future update when using flutter_localizations
      localizationsDelegates: const [],
      initialRoute: AppRoutes.suppliers,
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        return Scaffold(
          body: Row(
            children: [
              _buildNavigationRail(context),
              Expanded(child: child ?? const SizedBox()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _getSelectedIndex(ModalRoute.of(context)?.settings.name),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Suppliers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2),
          label: Text('Inventory'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications),
          label: Text('Notifications'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics),
          label: Text('Analytics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.trending_up),
          label: Text('Forecasting'),
        ),
      ],
      onDestinationSelected: (index) {
        // Navigate to the selected route
        switch (index) {
          case 0:
            Navigator.pushNamed(context, AppRoutes.suppliers);
            break;
          case 1:
            Navigator.pushNamed(context, AppRoutes.inventory);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.notifications);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.analyticsDashboard);
            break;
          case 4:
            Navigator.pushNamed(context, AppRoutes.forecasting);
            break;
        }
      },
    );
  }

  int _getSelectedIndex(String? routeName) {
    if (routeName == null) return 0;

    if (routeName.startsWith('/suppliers')) {
      return 0;
    } else if (routeName.startsWith('/inventory')) {
      return 1;
    } else if (routeName == AppRoutes.notifications) {
      return 2;
    } else if (routeName.startsWith('/analytics')) {
      return 3;
    } else if (routeName.startsWith('/forecasting')) {
      return 4;
    }

    return 0;
  }
}
