import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/*
 * NOTE: This file is prepared for future migration to Go Router.
 * It is not currently in use as the app is using AppRouter instead.
 * To be used when the app is migrated from AppRouter to Go Router.
 */

import '../screens/batch_barcode_scan_screen.dart';
import '../screens/batch_inventory_screen.dart';
import '../screens/batch_scanner_screen.dart';
import '../screens/create_movement_page.dart';
import '../screens/dairy_inventory_demo_screen.dart';
import '../screens/dairy_inventory_screen.dart';
import '../screens/inventory_adjustment_history_screen.dart';
import '../screens/inventory_alerts_screen.dart';
import '../screens/inventory_analytics_dashboard_screen.dart';
import '../screens/inventory_audit_log_screen.dart';
import '../screens/inventory_category_management_screen.dart';
import '../screens/inventory_dashboard_page.dart';
import '../screens/inventory_edit_screen.dart';
import '../screens/inventory_item_details_screen.dart';
import '../screens/inventory_movement_history_screen.dart';
import '../screens/inventory_movement_list_page.dart';
import '../screens/inventory_screen.dart';
import '../screens/inventory_settings_screen.dart';
import '../screens/inventory_transfer_screen.dart';
import '../screens/inventory_trends_screen.dart';
import '../screens/movement_details_page.dart';

/// Route names for the inventory feature
class InventoryRoutes {
  static const String dashboard = 'inventory-dashboard';
  static const String mainScreen = 'inventory-main';
  static const String itemDetails = 'inventory-item-details';
  static const String editItem = 'inventory-edit';
  static const String alerts = 'inventory-alerts';
  static const String batchScanner = 'inventory-batch-scanner';
  static const String batchBarcodeScan = 'inventory-batch-barcode-scan';
  static const String batchInventory = 'inventory-batch';
  static const String movements = 'inventory-movements';
  static const String createMovement = 'inventory-create-movement';
  static const String movementDetails = 'inventory-movement-details';
  static const String movementHistory = 'inventory-movement-history';
  static const String trends = 'inventory-trends';
  static const String reports = 'inventory-reports';
  static const String settings = 'inventory-settings';
  static const String categoryManagement = 'inventory-category-management';
  static const String adjustmentHistory = 'inventory-adjustment-history';
  static const String analyticsDashboard = 'inventory-analytics-dashboard';
  static const String transfer = 'inventory-transfer';
  static const String dairyInventory = 'inventory-dairy';
  static const String dairyInventoryDemo = 'inventory-dairy-demo';
  static const String auditLog = 'inventory-audit-log';

  /// Base path for all inventory routes
  static const String basePath = '/inventory';

  /// Full paths for inventory screens
  static const String dashboardPath = basePath;
  static const String mainScreenPath = '$basePath/main';
  static String itemDetailsPath(String itemId) => '$basePath/items/$itemId';
  static String editItemPath(String itemId) => '$basePath/items/$itemId/edit';
  static const String alertsPath = '$basePath/alerts';
  static const String batchScannerPath = '$basePath/batch-scanner';
  static const String batchBarcodeScanPath = '$basePath/batch-barcode-scan';
  static const String batchInventoryPath = '$basePath/batch';
  static const String movementsPath = '$basePath/movements';
  static const String createMovementPath = '$basePath/movements/create';
  static String movementDetailsPath(String movementId) =>
      '$basePath/movements/$movementId';
  static String movementHistoryPath(String itemId) =>
      '$basePath/movements/history/$itemId';
  static const String trendsPath = '$basePath/trends';
  static const String reportsPath = '$basePath/reports';
  static const String settingsPath = '$basePath/settings';
  static const String categoryManagementPath = '$basePath/categories';
  static const String adjustmentHistoryPath = '$basePath/adjustments';
  static const String analyticsDashboardPath = '$basePath/analytics';
  static const String transferPath = '$basePath/transfer';
  static const String dairyInventoryPath = '$basePath/dairy';
  static const String dairyInventoryDemoPath = '$basePath/dairy-demo';
  static const String auditLogPath = '$basePath/audit-logs';
}

/// Adds inventory routes to the Go Router configuration
List<RouteBase> getInventoryRoutes() {
  return [
    GoRoute(
      path: InventoryRoutes.dashboardPath,
      name: InventoryRoutes.dashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryDashboardPage();
      },
    ),
    GoRoute(
      path: InventoryRoutes.mainScreenPath,
      name: InventoryRoutes.mainScreen,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryScreen();
      },
    ),
    GoRoute(
      path: '${InventoryRoutes.basePath}/items/:itemId',
      name: InventoryRoutes.itemDetails,
      builder: (BuildContext context, GoRouterState state) {
        final itemId = state.pathParameters['itemId'] ?? '';
        return InventoryItemDetailsScreen(itemId: itemId);
      },
    ),
    GoRoute(
      path: '${InventoryRoutes.basePath}/items/:itemId/edit',
      name: InventoryRoutes.editItem,
      builder: (BuildContext context, GoRouterState state) {
        final itemId = state.pathParameters['itemId'] ?? '';
        return InventoryEditScreen(itemId: itemId);
      },
    ),
    GoRoute(
      path: InventoryRoutes.alertsPath,
      name: InventoryRoutes.alerts,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryAlertsScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.batchScannerPath,
      name: InventoryRoutes.batchScanner,
      builder: (BuildContext context, GoRouterState state) {
        return const BatchScannerScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.batchBarcodeScanPath,
      name: InventoryRoutes.batchBarcodeScan,
      builder: (BuildContext context, GoRouterState state) {
        return const BatchBarcodeScanScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.batchInventoryPath,
      name: InventoryRoutes.batchInventory,
      builder: (BuildContext context, GoRouterState state) {
        return const BatchInventoryScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.movementsPath,
      name: InventoryRoutes.movements,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryMovementListPage();
      },
    ),
    GoRoute(
      path: InventoryRoutes.createMovementPath,
      name: InventoryRoutes.createMovement,
      builder: (BuildContext context, GoRouterState state) {
        return const CreateMovementPage();
      },
    ),
    GoRoute(
      path: '${InventoryRoutes.basePath}/movements/:movementId',
      name: InventoryRoutes.movementDetails,
      builder: (BuildContext context, GoRouterState state) {
        final movementId = state.pathParameters['movementId'] ?? '';
        return MovementDetailsPage(movementId: movementId);
      },
    ),
    GoRoute(
      path: '${InventoryRoutes.basePath}/movements/history/:itemId',
      name: InventoryRoutes.movementHistory,
      builder: (BuildContext context, GoRouterState state) {
        final itemId = state.pathParameters['itemId'] ?? '';
        return InventoryMovementHistoryScreen(itemId: itemId);
      },
    ),
    GoRoute(
      path: InventoryRoutes.trendsPath,
      name: InventoryRoutes.trends,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryTrendsScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.reportsPath,
      name: InventoryRoutes.reports,
      builder: (BuildContext context, GoRouterState state) {
        // return const InventoryReportsScreen(); // TODO: Remove old reports screen reference
        return const SizedBox
            .shrink(); // TODO: Replace with new reports screen or remove route
      },
    ),
    GoRoute(
      path: InventoryRoutes.settingsPath,
      name: InventoryRoutes.settings,
      builder: (BuildContext context, GoRouterState state) {
        return const InventorySettingsScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.categoryManagementPath,
      name: InventoryRoutes.categoryManagement,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryCategoryManagementScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.adjustmentHistoryPath,
      name: InventoryRoutes.adjustmentHistory,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryAdjustmentHistoryScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.analyticsDashboardPath,
      name: InventoryRoutes.analyticsDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryAnalyticsDashboardScreen();
      },
    ),
    GoRoute(
      path: '${InventoryRoutes.basePath}/transfer/:sourceItemId',
      name: InventoryRoutes.transfer,
      builder: (BuildContext context, GoRouterState state) {
        final sourceItemId = state.pathParameters['sourceItemId'] ?? '';
        return InventoryTransferScreen(sourceItemId: sourceItemId);
      },
    ),
    GoRoute(
      path: InventoryRoutes.dairyInventoryPath,
      name: InventoryRoutes.dairyInventory,
      builder: (BuildContext context, GoRouterState state) {
        return const DairyInventoryScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.dairyInventoryDemoPath,
      name: InventoryRoutes.dairyInventoryDemo,
      builder: (BuildContext context, GoRouterState state) {
        return const DairyInventoryDemoScreen();
      },
    ),
    GoRoute(
      path: InventoryRoutes.auditLogPath,
      name: InventoryRoutes.auditLog,
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryAuditLogScreen();
      },
    ),
  ];
}
