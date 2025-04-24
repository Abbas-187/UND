import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/auth/presentation/screens/user_management_screen.dart';
import '../../features/auth/presentation/screens/user_profile_screen.dart';
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
import '../../features/inventory/presentation/screens/inventory_settings_screen.dart';
import '../../features/inventory/presentation/screens/movement_details_page.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_details_screen.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_create_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_detail_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_list_screen.dart';
import '../../features/procurement/presentation/screens/reports/procurement_dashboard_screen.dart'
    as reports;
import '../../features/procurement/presentation/screens/procurement_dashboard_screen.dart';
import '../../features/procurement/presentation/routes/procurement_routes.dart';
import '../../features/shared/presentation/screens/app_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/suppliers/domain/entities/supplier.dart';
import '../../features/suppliers/presentation/screens/supplier_details_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_edit_screen.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../layout/main_layout.dart';
import 'package:flutter/material.dart';
import '../../features/inventory/presentation/screens/inventory_movement_history_screen.dart';
import '../../features/inventory/presentation/screens/inventory_transfer_screen.dart';
import '../../features/inventory/presentation/screens/inventory_trends_screen.dart';
import '../../features/inventory/presentation/screens/batch_barcode_scan_screen.dart';
import '../../features/inventory/presentation/screens/batch_inventory_screen.dart';
import '../../features/inventory/presentation/screens/dairy_inventory_screen.dart';
import '../../features/inventory/presentation/screens/dairy_inventory_demo_screen.dart';
import '../../features/inventory/presentation/screens/inventory_adjustment_history_screen.dart';
import '../../features/inventory/presentation/screens/inventory_analytics_dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_category_management_screen.dart';
import '../../features/inventory/presentation/screens/inventory_reports_screen.dart';
import '../../features/factory/presentation/screens/recipe/recipe_list_screen.dart';
import '../../features/factory/presentation/screens/recipe/recipe_create_screen.dart';
import '../../features/factory/presentation/screens/recipe/recipe_detail_screen.dart';
import '../../features/procurement/presentation/screens/po_approval_screen.dart';
import '../../features/factory/presentation/screens/recipe/recipe_edit_screen.dart';
import '../../features/factory/presentation/screens/recipe/recipe_history_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/inventory/presentation/screens/inventory_edit_screen.dart';
import '../../features/inventory/presentation/screens/inventory_item_details_screen.dart';
import '../../features/order_management/screens/order_list_screen.dart';
import '../../features/order_management/screens/order_detail_screen.dart';
import '../../features/order_management/screens/order_creation_edit_screen.dart';
import '../../features/order_management/screens/discussion_room_screen.dart';

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
  static const String inventorySettings = '/inventory/settings';
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
  static const String recipes = '/factory/recipes';
  static const String recipeDetail = '/factory/recipe/detail';
  static const String recipeCreate = '/factory/recipe/create';
  static const String procurement = '/procurement';
  static const String procurementDashboard = '/procurement/dashboard';
  static const String purchaseOrders = '/procurement/purchase-orders';
  static const String purchaseOrderDetail =
      '/procurement/purchase-orders/details';
  static const String purchaseOrderApproval = '/procurement/po-approval';
  static const String createPurchaseOrder =
      '/procurement/purchase-orders/create';
  static const String suppliersProcurement = '/procurement/suppliers';
  static const String inventoryMovementHistory = '/inventory/movements/history';
  static const String inventoryTransfer = '/inventory/transfer';
  static const String inventoryTrends = '/inventory/trends';
  static const String inventoryBarcodeScan = '/inventory/barcode-scan';
  static const String inventoryBatchInventory = '/inventory/batch-inventory';
  static const String dairyInventory = '/inventory/dairy';
  static const String dairyInventoryDemo = '/inventory/dairy-demo';
  static const String inventoryAnalytics = '/inventory/analytics';
  static const String inventoryReports = '/inventory/reports';
  static const String recipeEdit = '/factory/recipe/edit';
  static const String recipeHistory = '/factory/recipe/history';
  static const String inventoryMain = '/inventory/main';
  static const String inventoryItemDetails = '/inventory/items/details';
  static const String inventoryItemEdit = '/inventory/items/edit';
  static const String inventoryBatchBarcodeScan =
      '/inventory/batch-barcode-scan';
  static const String inventoryMovementDetails = '/inventory/movements/details';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/detail';
  static const String orderCreate = '/orders/create';
  static const String orderEdit = '/orders/edit';
  static const String orderDiscussion = '/orders/discussion';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final routeName = settings.name ?? '/';

    // Identify auth/profile screens that should NOT use MainLayout
    final bool isAuthScreen = [
      AppRoutes.login,
      AppRoutes.unauthorized,
      AppRoutes.userProfile,
      AppRoutes.userManagement,
    ].contains(routeName);

    // Create the appropriate screen based on the route
    Widget screen = Scaffold(
      body: Center(
        child: Text('No route defined for $routeName'),
      ),
    );

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
        screen = SupplierDetailsScreen(supplierId: supplierId);
        break;

      case AppRoutes.supplierEdit:
        final args = settings.arguments is SupplierEditArgs
            ? settings.arguments as SupplierEditArgs
            : SupplierEditArgs();
        screen = SupplierEditScreen(supplier: args.supplier);
        break;

      case AppRoutes.forecasting:
        screen = const ForecastingListScreen();
        break;

      case AppRoutes.forecastingCreate:
        screen = const ForecastingScreen();
        break;

      case AppRoutes.forecastingDetail:
        final args = settings.arguments as ForecastingDetailArgs;
        screen = ForecastingScreen(forecastId: args.forecastId);
        break;

      case AppRoutes.forecastingDashboard:
        screen = const ForecastingDashboardScreen();
        break;

      case AppRoutes.analyticsDashboard:
        screen = const AnalyticsDashboardScreen();
        break;

      case AppRoutes.inventoryAlerts:
        screen = const InventoryAlertsScreen();
        break;

      case AppRoutes.inventoryBatchScanner:
        screen = const BatchScannerScreen();
        break;

      case AppRoutes.inventory:
        screen = const InventoryDashboardPage();
        break;

      case AppRoutes.inventoryDetails:
        final inventoryId = args['inventoryId'] as String;
        screen = InventoryItemDetailsScreen(itemId: inventoryId);
        break;

      case AppRoutes.inventoryMovements:
        screen = const InventoryMovementListPage();
        break;

      case AppRoutes.createMovement:
        screen = const CreateMovementPage();
        break;

      case AppRoutes.movementDetails:
        final movementId = args['movementId'] as String;
        screen = MovementDetailsPage(movementId: movementId);
        break;

      case AppRoutes.milkReception:
        screen = const MilkReceptionScreen();
        break;

      case AppRoutes.milkReceptionDetails:
        final receptionId = args['receptionId'] as String;
        screen = MilkReceptionDetailsScreen(receptionId: receptionId);
        break;

      case AppRoutes.notifications:
        screen = const NotificationScreen();
        break;

      case AppRoutes.equipmentMaintenance:
        screen = const EquipmentMaintenanceScreen();
        break;

      case AppRoutes.equipmentMaintenanceDetail:
        final equipmentId = args['equipmentId'] as String;
        screen = EquipmentDetailScreen(equipmentId: equipmentId);
        break;

      case AppRoutes.createMaintenanceRecord:
        final equipment = args['equipment'];
        screen = CreateMaintenanceRecordScreen(equipment: equipment);
        break;

      case AppRoutes.procurement:
      case AppRoutes.procurementDashboard:
        screen = const ProcurementDashboardScreen();
        break;

      case AppRoutes.purchaseOrders:
        screen = const PurchaseOrderListScreen();
        break;

      case AppRoutes.purchaseOrderDetail:
        final orderId = args['orderId'] as String;
        screen = PurchaseOrderDetailScreen(orderId: orderId);
        break;

      case AppRoutes.purchaseOrderApproval:
        final purchaseOrderId = args['purchaseOrderId'] as String;
        screen = POApprovalScreen(purchaseOrderId: purchaseOrderId);
        break;

      case AppRoutes.createPurchaseOrder:
        screen = const PurchaseOrderCreateScreen();
        break;

      // Production execution routes
      case AppRoutes.productionExecutions:
        screen = const ProductionExecutionsScreen();
        break;

      case AppRoutes.productionExecutionDetail:
        final executionId = args['executionId'] as String;
        screen = ProductionExecutionDetailScreen(executionId: executionId);
        break;

      case AppRoutes.createProductionExecution:
        screen = const CreateProductionExecutionScreen();
        break;

      case AppRoutes.settings:
        screen = const SettingsScreen();
        break;

      case AppRoutes.inventorySettings:
        screen = const InventorySettingsScreen();
        break;

      case AppRoutes.inventoryEdit:
        screen = const InventoryEditScreen();
        break;

      case AppRoutes.inventoryItemDetails:
        final itemId = args['itemId'] as String;
        screen = InventoryItemDetailsScreen(itemId: itemId);
        break;

      case AppRoutes.inventoryItemEdit:
        final itemId = args['itemId'] as String;
        screen = InventoryEditScreen(itemId: itemId);
        break;

      case AppRoutes.inventoryBatchBarcodeScan:
        screen = const BatchBarcodeScanScreen();
        break;

      case AppRoutes.inventoryBatchInventory:
        screen = const BatchInventoryScreen();
        break;

      case AppRoutes.inventoryMovementDetails:
        final movementId = args['movementId'] as String;
        screen = MovementDetailsPage(movementId: movementId);
        break;

      case AppRoutes.inventoryMovementHistory:
        final itemId = args['itemId'] as String;
        screen = InventoryMovementHistoryScreen(itemId: itemId);
        break;

      case AppRoutes.inventoryTrends:
        screen = const InventoryTrendsScreen();
        break;

      case AppRoutes.inventoryBarcodeScan:
        screen = const BatchBarcodeScanScreen();
        break;

      case AppRoutes.dairyInventory:
        screen = const DairyInventoryScreen();
        break;

      case AppRoutes.dairyInventoryDemo:
        screen = const DairyInventoryDemoScreen();
        break;

      case AppRoutes.inventoryCategoryManagement:
        screen = const InventoryCategoryManagementScreen();
        break;

      case AppRoutes.inventoryAdjustmentHistory:
        screen = const InventoryAdjustmentHistoryScreen();
        break;

      case AppRoutes.inventoryAnalytics:
        screen = const InventoryAnalyticsDashboardScreen();
        break;

      case AppRoutes.inventoryReports:
        // screen = const InventoryReportsScreen(); // TODO: Remove old reports screen reference
        break;

      case AppRoutes.milkQualityTestDetails:
        // Add implementation for milk quality test details
        break;

      case AppRoutes.recipes:
        screen = const RecipeListScreen();
        break;

      case AppRoutes.recipeCreate:
        screen = const RecipeCreateScreen();
        break;

      case AppRoutes.recipeDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final recipeId = args['recipeId'] as String;
        screen = RecipeDetailScreen(recipeId: recipeId);
        break;

      case AppRoutes.recipeEdit:
        final args = settings.arguments as Map<String, dynamic>;
        final recipeId = args['recipeId'] as String;
        screen = RecipeEditScreen(recipeId: recipeId);
        break;

      case AppRoutes.recipeHistory:
        final args = settings.arguments as Map<String, dynamic>;
        final recipeId = args['recipeId'] as String;
        final history = args['history'] as List<dynamic>;
        screen = RecipeHistoryScreen(recipeId: recipeId, history: history);
        break;

      case AppRoutes.inventoryMain:
        screen = const InventoryScreen();
        break;

      case AppRoutes.orders:
        screen = const OrderListScreen();
        break;

      case AppRoutes.orderDetail:
        final orderId = args['orderId'] as String;
        screen = OrderDetailScreen(orderId: orderId);
        break;

      case AppRoutes.orderCreate:
        screen = const OrderCreationEditScreen();
        break;

      case AppRoutes.orderEdit:
        final orderId = args['orderId'] as String;
        screen = OrderCreationEditScreen(orderId: orderId);
        break;

      case AppRoutes.orderDiscussion:
        final orderId = args['orderId'] as String;
        final discussionId = args['discussionId'] as String?;
        screen = DiscussionRoomScreen(
          orderId: orderId,
          discussionId: discussionId,
        );
        break;
    }

    // For auth/profile screens, return direct routes without MainLayout
    if (isAuthScreen) {
      return MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
      );
    }

    // For all other screens, wrap with MainLayout
    return MaterialPageRoute(
      builder: (_) => MainLayout(
        child: screen,
        currentRoute: routeName,
      ),
      settings: settings,
    );
  }

  // This method is kept for backward compatibility but no longer needed for deciding which screens get MainLayout
  static bool _isMainNavigationScreen(String routeName) {
    final mainScreenRoutes = [
      AppRoutes.home,
      '/',
      AppRoutes.suppliers,
      AppRoutes.inventory,
      AppRoutes.forecastingDashboard,
      AppRoutes.forecasting,
      AppRoutes.analyticsDashboard,
      AppRoutes.productionExecutions,
      AppRoutes.equipmentMaintenance,
      AppRoutes.milkReception,
      AppRoutes.procurementDashboard,
    ];

    return mainScreenRoutes.contains(routeName) ||
        routeName.startsWith('/procurement');
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
