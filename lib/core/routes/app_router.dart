import 'package:flutter/material.dart';

import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/auth/presentation/screens/user_management_screen.dart';
import '../../features/auth/presentation/screens/user_profile_screen.dart';
import '../../features/factory/equipment_maintenance/data/models/equipment_model.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/create_maintenance_record_screen.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/equipment_detail_screen.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/equipment_maintenance_screen.dart';
import '../../features/factory/production/presentation/screens/create_production_execution_screen.dart';
import '../../features/factory/production/presentation/screens/production_execution_detail_screen.dart';
import '../../features/factory/production/presentation/screens/production_executions_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_dashboard_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_list_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inventory/presentation/screens/batch_scanner_screen.dart';
import '../../features/inventory/presentation/screens/create_movement_page.dart';
import '../../features/inventory/presentation/screens/inventory_alerts_screen.dart';
import '../../features/inventory/presentation/screens/inventory_dashboard_page.dart';
import '../../features/inventory/presentation/screens/inventory_item_details_screen.dart';
import '../../features/inventory/presentation/screens/inventory_movement_list_page.dart';
import '../../features/inventory/presentation/screens/movement_details_page.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_details_screen.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_create_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_detail_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_list_screen.dart';
import '../../features/procurement/presentation/screens/reports/procurement_dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/suppliers/domain/entities/supplier.dart';
import '../../features/suppliers/presentation/screens/supplier_details_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_edit_screen.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../layout/main_layout.dart';
import '../../features/inventory/presentation/screens/inventory_category_management_screen.dart';
import '../../features/inventory/presentation/screens/inventory_adjustment_history_screen.dart';

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
  static const String inventoryCategoryManagement = '/inventory/categories';
  static const String inventoryAdjustmentHistory = '/inventory/adjustments';
  static const String analytics = '/analytics';
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String settings = '/settings';
  static const String forecasting = '/forecasting';
  static const String forecastingCreate = '/forecasting/create';
  static const String forecastingDetail = '/forecasting/detail';
  static const String forecastingDashboard = '/forecasting/dashboard';
  static const String milkReception = '/milk/reception';
  static const String milkReceptionDetails = '/milk/reception/details';
  static const String milkQualityTests = '/milk/quality/tests';
  static const String milkQualityTestDetails = '/milk/quality/tests/details';
  static const String notifications = '/notifications';
  static const String productionExecutions = '/factory/production/executions';
  static const String productionExecutionDetail =
      '/factory/production/executions/detail';
  static const String createProductionExecution =
      '/factory/production/executions/create';
  static const String equipmentMaintenance = '/factory/equipment';
  static const String equipmentMaintenanceDetail = '/factory/equipment/details';
  static const String createMaintenanceRecord =
      '/factory/equipment/maintenance/create';
  static const String maintenanceRecordDetail =
      '/factory/equipment/maintenance/details';
  static const String procurement = '/procurement';
  static const String procurementDashboard = '/procurement/dashboard';
  static const String purchaseOrders = '/procurement/purchase-orders';
  static const String purchaseOrderDetail =
      '/procurement/purchase-orders/details';
  static const String createPurchaseOrder =
      '/procurement/purchase-orders/create';
  static const String suppliers_procurement = '/procurement/suppliers';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final routeName = settings.name ?? '/';

    // Determine if this is a main navigation screen that should have the navigation rail
    final bool isMainScreen = _isMainNavigationScreen(routeName);

    // Create the appropriate screen based on the route
    Widget screen;

    switch (routeName) {
      case AppRoutes.home:
      case '/': // Handle both home and root route
        screen = const HomeScreen();
        break;

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
        screen = const SuppliersScreen();
        break;

      case AppRoutes.supplierDetails:
        final supplierId = args['supplierId'] as String? ??
            (settings.arguments is SupplierDetailsArgs
                ? (settings.arguments as SupplierDetailsArgs).supplierId
                : '');

        return MaterialPageRoute(
          builder: (_) => SupplierDetailsScreen(supplierId: supplierId),
          settings: settings,
        );

      case AppRoutes.supplierEdit:
        final args = settings.arguments is SupplierEditArgs
            ? settings.arguments as SupplierEditArgs
            : SupplierEditArgs();

        return MaterialPageRoute(
          builder: (_) => SupplierEditScreen(supplier: args.supplier),
          settings: settings,
        );

      case AppRoutes.forecasting:
        screen = const ForecastingListScreen();
        break;

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
        screen = const ForecastingDashboardScreen();
        break;

      case AppRoutes.analyticsDashboard:
        screen = const AnalyticsDashboardScreen();
        break;

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
      case AppRoutes.inventoryDashboard:
        screen = const InventoryDashboardPage();
        break;

      case AppRoutes.inventoryDetails:
        final inventoryId = args['inventoryId'] as String;
        return MaterialPageRoute(
          builder: (_) => InventoryItemDetailsScreen(itemId: inventoryId),
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

      case AppRoutes.milkReception:
        screen = const MilkReceptionScreen();
        break;

      case AppRoutes.milkReceptionDetails:
        final receptionId = args['receptionId'] as String;
        return MaterialPageRoute(
          builder: (_) => MilkReceptionDetailsScreen(receptionId: receptionId),
          settings: settings,
        );

      case AppRoutes.notifications:
        screen = const NotificationScreen();
        break;

      case AppRoutes.equipmentMaintenance:
        screen = const EquipmentMaintenanceScreen();
        break;

      case AppRoutes.equipmentMaintenanceDetail:
        final equipmentId = args['equipmentId'] as String;
        return MaterialPageRoute(
          builder: (_) => EquipmentDetailScreen(equipmentId: equipmentId),
          settings: settings,
        );

      case AppRoutes.createMaintenanceRecord:
        final equipment = args['equipment'];
        return MaterialPageRoute(
          builder: (_) => CreateMaintenanceRecordScreen(equipment: equipment),
          settings: settings,
        );

      case AppRoutes.procurement:
      case AppRoutes.procurementDashboard:
        screen = const ProcurementDashboardScreen();
        break;

      case AppRoutes.purchaseOrders:
        screen = const PurchaseOrderListScreen();
        break;

      case AppRoutes.purchaseOrderDetail:
        final orderId = args['orderId'] as String;
        return MaterialPageRoute(
          builder: (_) => PurchaseOrderDetailScreen(orderId: orderId),
          settings: settings,
        );

      case AppRoutes.createPurchaseOrder:
        return MaterialPageRoute(
          builder: (_) => const PurchaseOrderCreateScreen(),
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

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case AppRoutes.inventoryCategoryManagement:
        return MaterialPageRoute(
          builder: (_) => const InventoryCategoryManagementScreen(),
          settings: settings,
        );

      case AppRoutes.inventoryAdjustmentHistory:
        return MaterialPageRoute(
          builder: (_) => const InventoryAdjustmentHistoryScreen(),
          settings: settings,
        );

      default:
        screen = Scaffold(
          body: Center(
            child: Text('No route defined for $routeName'),
          ),
        );
    }

    // Wrap main navigation screens with the MainLayout
    if (isMainScreen) {
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          child: screen,
          currentRoute: routeName,
        ),
        settings: settings,
      );
    } else {
      return MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
      );
    }
  }

  // Helper to determine if a route is a main navigation screen
  static bool _isMainNavigationScreen(String routeName) {
    final mainScreenRoutes = [
      AppRoutes.home,
      '/',
      AppRoutes.suppliers,
      AppRoutes.inventory,
      AppRoutes.inventoryDashboard,
      AppRoutes.notifications,
      AppRoutes.analyticsDashboard,
      AppRoutes.forecasting,
      AppRoutes.forecastingDashboard,
      AppRoutes.productionExecutions,
      AppRoutes.equipmentMaintenance,
      AppRoutes.milkReception,
      AppRoutes.procurement,
      AppRoutes.procurementDashboard,
      AppRoutes.purchaseOrders,
      AppRoutes.settings,
    ];

    return mainScreenRoutes.contains(routeName);
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
