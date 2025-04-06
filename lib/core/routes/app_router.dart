import 'package:flutter/material.dart';

import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/auth/presentation/screens/user_management_screen.dart';
import '../../features/auth/presentation/screens/user_profile_screen.dart';
import '../../features/factory/production/presentation/screens/create_production_execution_screen.dart';
import '../../features/factory/production/presentation/screens/production_execution_detail_screen.dart';
import '../../features/factory/production/presentation/screens/production_executions_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_dashboard_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_list_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_screen.dart';
import '../../features/inventory/presentation/screens/batch_scanner_screen.dart';
import '../../features/inventory/presentation/screens/create_movement_page.dart';
import '../../features/inventory/presentation/screens/inventory_alerts_screen.dart';
import '../../features/inventory/presentation/screens/inventory_dashboard_page.dart';
import '../../features/inventory/presentation/screens/inventory_item_details_screen.dart';
import '../../features/inventory/presentation/screens/inventory_movement_list_page.dart';
import '../../features/inventory/presentation/screens/movement_details_page.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_details_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/suppliers/domain/entities/supplier.dart';
import '../../features/suppliers/presentation/screens/supplier_details_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_edit_screen.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String unauthorized = '/unauthorized';
  static const String userProfile = '/user/profile';
  static const String userManagement = '/admin/users';
  static const String suppliers = '/suppliers';
  static const String supplierDetails = '/suppliers/details';
  static const String supplierEdit = '/suppliers/edit';
  static const String inventory = '/inventory';
  static const String inventoryDetails = '/inventory/details';
  static const String inventoryEdit = '/inventory/edit';
  static const String inventoryAlerts = '/inventory/alerts';
  static const String inventoryBatchScanner = '/inventory/batch-scanner';
  static const String inventoryDashboard = '/inventory/dashboard';
  static const String inventoryMovements = '/inventory/movements';
  static const String createMovement = '/inventory/movements/create';
  static const String movementDetails = '/inventory/movements/details';
  static const String analytics = '/analytics';
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String settings = '/settings';
  static const String forecasting = '/forecasting';
  static const String forecastingCreate = '/forecasting/create';
  static const String forecastingDetail = '/forecasting/detail';
  static const String forecastingDashboard = '/forecasting/dashboard';
  static const String milkReceptionDetails = '/reception/details';
  static const String notifications = '/notifications';

  // Production execution routes
  static const String productionExecutions = '/factory/production/executions';
  static const String productionExecutionDetail =
      '/factory/production/executions/detail';
  static const String createProductionExecution =
      '/factory/production/executions/create';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.unauthorized:
        return MaterialPageRoute(
          builder: (_) => const UnauthorizedScreen(),
          settings: settings,
        );

      case AppRoutes.userProfile:
        return MaterialPageRoute(
          builder: (_) => const UserProfileScreen(),
          settings: settings,
        );

      case AppRoutes.userManagement:
        return MaterialPageRoute(
          builder: (_) => const UserManagementScreen(),
          settings: settings,
        );

      case AppRoutes.suppliers:
        return MaterialPageRoute(
          builder: (_) => const SuppliersScreen(),
          settings: settings,
        );

      case AppRoutes.supplierDetails:
        final supplierId = args['supplierId'] as String;
        return MaterialPageRoute(
          builder: (_) => SupplierDetailsScreen(supplierId: supplierId),
          settings: settings,
        );

      case AppRoutes.supplierEdit:
        final args = settings.arguments as SupplierEditArgs?;
        return MaterialPageRoute(
          builder: (_) => SupplierEditScreen(supplier: args?.supplier),
          settings: settings,
        );

      case AppRoutes.forecasting:
        return MaterialPageRoute(
          builder: (_) => const ForecastingListScreen(),
          settings: settings,
        );

      case AppRoutes.forecastingCreate:
        return MaterialPageRoute(
          builder: (_) => const ForecastingScreen(),
          settings: settings,
        );

      case AppRoutes.forecastingDetail:
        final args = settings.arguments as ForecastingDetailArgs;
        return MaterialPageRoute(
          builder: (_) => ForecastingScreen(forecastId: args.forecastId),
          settings: settings,
        );

      case AppRoutes.forecastingDashboard:
        return MaterialPageRoute(
          builder: (_) => const ForecastingDashboardScreen(),
          settings: settings,
        );

      case AppRoutes.analyticsDashboard:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDashboardScreen(),
          settings: settings,
        );

      case AppRoutes.inventoryAlerts:
        return MaterialPageRoute(
          builder: (_) => const InventoryAlertsScreen(),
          settings: settings,
        );

      case AppRoutes.inventoryBatchScanner:
        return MaterialPageRoute(
          builder: (_) => const BatchScannerScreen(),
          settings: settings,
        );

      case AppRoutes.inventory:
        return MaterialPageRoute(
          builder: (_) => const InventoryDashboardPage(),
          settings: settings,
        );

      case AppRoutes.inventoryDetails:
        final inventoryId = args['inventoryId'] as String;
        return MaterialPageRoute(
          builder: (_) => InventoryItemDetailsScreen(itemId: inventoryId),
          settings: settings,
        );

      case AppRoutes.inventoryDashboard:
        return MaterialPageRoute(
          builder: (_) => const InventoryDashboardPage(),
          settings: settings,
        );

      case AppRoutes.inventoryMovements:
        return MaterialPageRoute(
          builder: (_) => const InventoryMovementListPage(),
          settings: settings,
        );

      case AppRoutes.createMovement:
        return MaterialPageRoute(
          builder: (_) => const CreateMovementPage(),
          settings: settings,
        );

      case AppRoutes.movementDetails:
        final movementId = args['movementId'] as String;
        return MaterialPageRoute(
          builder: (_) => MovementDetailsPage(movementId: movementId),
          settings: settings,
        );

      case AppRoutes.milkReceptionDetails:
        final receptionId = args['receptionId'] as String;
        return MaterialPageRoute(
          builder: (_) => MilkReceptionDetailsScreen(receptionId: receptionId),
          settings: settings,
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationScreen(),
          settings: settings,
        );

      // Production execution routes
      case AppRoutes.productionExecutions:
        return MaterialPageRoute(
          builder: (_) => const ProductionExecutionsScreen(),
          settings: settings,
        );

      case AppRoutes.productionExecutionDetail:
        final executionId = args['executionId'] as String;
        return MaterialPageRoute(
          builder: (_) =>
              ProductionExecutionDetailScreen(executionId: executionId),
          settings: settings,
        );

      case AppRoutes.createProductionExecution:
        return MaterialPageRoute(
          builder: (_) => const CreateProductionExecutionScreen(),
          settings: settings,
        );

      // Add routes for other features here

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Route arguments
class SupplierDetailsArgs {

  SupplierDetailsArgs({required this.supplierId});
  final String supplierId;
}

class SupplierEditArgs {

  SupplierEditArgs({this.supplier});
  final Supplier? supplier;
}

class ForecastingDetailArgs {

  ForecastingDetailArgs({required this.forecastId});
  final String forecastId;
}

class ProductionExecutionDetailArgs {

  ProductionExecutionDetailArgs({required this.executionId});
  final String executionId;
}
