import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'features/suppliers/domain/repositories/supplier_repository.dart';
import 'features/suppliers/presentation/providers/supplier_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UND Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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
          label: Text('Alerts'),
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
            Navigator.pushNamed(context, AppRoutes.inventoryAlerts);
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
    } else if (routeName == AppRoutes.inventoryAlerts) {
      return 2;
    } else if (routeName.startsWith('/analytics')) {
      return 3;
    } else if (routeName.startsWith('/forecasting')) {
      return 4;
    }

    return 0;
  }
}
