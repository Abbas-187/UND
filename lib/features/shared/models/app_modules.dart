import 'package:flutter/material.dart';
import '../../../core/routes/app_go_router.dart';

@immutable
class ModuleScreen {
  const ModuleScreen({
    required this.nameKey,
    required this.route,
    required this.icon,
    required this.descriptionKey,
  });
  final String nameKey;
  final String route;
  final IconData icon;
  final String descriptionKey;

  ModuleScreen copyWith({
    String? nameKey,
    String? route,
    IconData? icon,
    String? descriptionKey,
  }) {
    return ModuleScreen(
      nameKey: nameKey ?? this.nameKey,
      route: route ?? this.route,
      icon: icon ?? this.icon,
      descriptionKey: descriptionKey ?? this.descriptionKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleScreen &&
          runtimeType == other.runtimeType &&
          nameKey == other.nameKey &&
          route == other.route &&
          icon == other.icon &&
          descriptionKey == other.descriptionKey;

  @override
  int get hashCode =>
      nameKey.hashCode ^
      route.hashCode ^
      icon.hashCode ^
      descriptionKey.hashCode;
}

@immutable
class AppModule {
  const AppModule({
    required this.nameKey,
    required this.icon,
    required this.color,
    required this.screens,
  });
  final String nameKey;
  final IconData icon;
  final Color color;
  final List<ModuleScreen> screens;

  AppModule copyWith({
    String? nameKey,
    IconData? icon,
    Color? color,
    List<ModuleScreen>? screens,
  }) {
    return AppModule(
      nameKey: nameKey ?? this.nameKey,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      screens: screens ?? this.screens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppModule &&
          runtimeType == other.runtimeType &&
          nameKey == other.nameKey &&
          icon == other.icon &&
          color == other.color &&
          screens == other.screens;

  @override
  int get hashCode =>
      nameKey.hashCode ^ icon.hashCode ^ color.hashCode ^ screens.hashCode;
}

final Map<String, AppModule> appModules = {
  'inventory': const AppModule(
    nameKey: 'inventory',
    icon: Icons.inventory_2,
    color: Colors.blue,
    screens: [
      ModuleScreen(
        nameKey: 'inventoryDashboard',
        route: AppRoutes.inventoryDashboard,
        icon: Icons.dashboard,
        descriptionKey: 'inventoryDashboardDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryMain',
        route: AppRoutes.inventoryMain,
        icon: Icons.list,
        descriptionKey: 'inventoryListDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryAlerts',
        route: AppRoutes.inventoryAlerts,
        icon: Icons.warning,
        descriptionKey: 'inventoryAlertsDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryMovements',
        route: AppRoutes.inventoryMovements,
        icon: Icons.swap_horiz,
        descriptionKey: 'inventoryMovementsDesc',
      ),
      ModuleScreen(
        nameKey: 'createMovement',
        route: AppRoutes.createMovement,
        icon: Icons.add_circle,
        descriptionKey: 'createMovementDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryBatchScanner',
        route: AppRoutes.batchScanner,
        icon: Icons.qr_code_scanner,
        descriptionKey: 'inventoryBatchScannerDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryEdit',
        route: AppRoutes.inventoryEdit,
        icon: Icons.edit,
        descriptionKey: 'inventoryEditDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryAnalytics',
        route: AppRoutes.inventoryAnalytics,
        icon: Icons.analytics,
        descriptionKey: 'inventoryAnalyticsDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryTrends',
        route: AppRoutes.inventoryTrends,
        icon: Icons.trending_up,
        descriptionKey: 'inventoryTrendsDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryBarcodeScan',
        route: AppRoutes.batchBarcodeScan,
        icon: Icons.qr_code,
        descriptionKey: 'inventoryBarcodeScanDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryBatchInventory',
        route: AppRoutes.batchInventory,
        icon: Icons.inventory,
        descriptionKey: 'inventoryBatchInventoryDesc',
      ),
      ModuleScreen(
        nameKey: 'dairyInventory',
        route: AppRoutes.dairyInventory,
        icon: Icons.water_drop,
        descriptionKey: 'dairyInventoryDesc',
      ),
      ModuleScreen(
        nameKey: 'dairyInventoryDemo',
        route: AppRoutes.dairyInventoryDemo,
        icon: Icons.water_drop,
        descriptionKey: 'dairyInventoryDemoDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryCategoryManagement',
        route: AppRoutes.inventoryCategoryManagement,
        icon: Icons.category,
        descriptionKey: 'inventoryCategoryManagementDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryAdjustmentHistory',
        route: AppRoutes.inventoryAdjustments,
        icon: Icons.history,
        descriptionKey: 'inventoryAdjustmentHistoryDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryReports',
        route: AppRoutes.inventoryReports,
        icon: Icons.summarize,
        descriptionKey: 'inventoryReportsDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryReportDedicated',
        route: AppRoutes.inventoryReport,
        icon: Icons.assessment,
        descriptionKey: 'inventoryReportDedicatedDesc',
      ),
      ModuleScreen(
        nameKey: 'inventorySettings',
        route: AppRoutes.inventorySettings,
        icon: Icons.settings,
        descriptionKey: 'inventorySettingsDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryDatabaseManagement',
        route: AppRoutes.inventoryDatabaseManagement,
        icon: Icons.storage,
        descriptionKey: 'inventoryDatabaseManagementDesc',
      ),
    ],
  ),
  'factory': const AppModule(
    nameKey: 'factory',
    icon: Icons.factory,
    color: Colors.green,
    screens: [
      ModuleScreen(
        nameKey: 'productionExecutions',
        route: AppRoutes.productionExecutions,
        icon: Icons.engineering,
        descriptionKey: 'productionExecutionsDesc',
      ),
      ModuleScreen(
        nameKey: 'createProductionExecution',
        route: AppRoutes.createProductionExecution,
        icon: Icons.add_task,
        descriptionKey: 'createProductionExecutionDesc',
      ),
      ModuleScreen(
        nameKey: 'productionExecutionList',
        route: AppRoutes.productionExecutionList,
        icon: Icons.view_list,
        descriptionKey: 'productionExecutionListDesc',
      ),
      ModuleScreen(
        nameKey: 'batchTracking',
        route: AppRoutes.batchTracking,
        icon: Icons.track_changes,
        descriptionKey: 'batchTrackingDesc',
      ),
      ModuleScreen(
        nameKey: 'productionPlanDetail',
        route: AppRoutes.productionPlanDetail,
        icon: Icons.calendar_today,
        descriptionKey: 'productionPlanDetailDesc',
      ),
      ModuleScreen(
        nameKey: 'productionScheduling',
        route: AppRoutes.productionScheduling,
        icon: Icons.schedule,
        descriptionKey: 'productionSchedulingDesc',
      ),
      ModuleScreen(
        nameKey: 'equipmentMaintenance',
        route: AppRoutes.equipmentMaintenance,
        icon: Icons.build,
        descriptionKey: 'equipmentMaintenanceDesc',
      ),
      ModuleScreen(
        nameKey: 'createMaintenanceRecord',
        route: AppRoutes.createMaintenanceRecord,
        icon: Icons.build_circle,
        descriptionKey: 'createMaintenanceRecordDesc',
      ),
      ModuleScreen(
        nameKey: 'addEditEquipment',
        route: AppRoutes.addEditEquipment,
        icon: Icons.edit,
        descriptionKey: 'addEditEquipmentDesc',
      ),
      ModuleScreen(
        nameKey: 'productionList',
        route: AppRoutes.productionOrders,
        icon: Icons.list_alt,
        descriptionKey: 'productionListDesc',
      ),
      ModuleScreen(
        nameKey: 'productionExecutionDetail',
        route: AppRoutes.productionExecutionDetail,
        icon: Icons.info_outline,
        descriptionKey: 'productionExecutionDetailDesc',
      ),
      ModuleScreen(
        nameKey: 'recipeList',
        route: AppRoutes.recipes,
        icon: Icons.menu_book,
        descriptionKey: 'recipeListDesc',
      ),
      ModuleScreen(
        nameKey: 'recipeCreate',
        route: AppRoutes.recipeCreate,
        icon: Icons.add_box,
        descriptionKey: 'recipeCreateDesc',
      ),
      ModuleScreen(
        nameKey: 'recipeDetail',
        route: AppRoutes.recipeDetail,
        icon: Icons.receipt_long,
        descriptionKey: 'recipeDetailDesc',
      ),
      ModuleScreen(
        nameKey: 'equipmentDetail',
        route: AppRoutes.equipmentMaintenanceDetail,
        icon: Icons.precision_manufacturing,
        descriptionKey: 'equipmentDetailDesc',
      ),
      ModuleScreen(
        nameKey: 'maintenanceRecordDetail',
        route: AppRoutes.maintenanceRecordDetail,
        icon: Icons.article,
        descriptionKey: 'maintenanceRecordDetailDesc',
      ),
    ],
  ),
  'milk_reception': const AppModule(
    nameKey: 'milkReception',
    icon: Icons.water_drop,
    color: Colors.orange,
    screens: [
      ModuleScreen(
        nameKey: 'milkReceptionScreen',
        route: AppRoutes.milkReception,
        icon: Icons.water_drop,
        descriptionKey: 'milkReceptionDesc',
      ),
      ModuleScreen(
        nameKey: 'milkQualityTests',
        route: AppRoutes.milkQualityTests,
        icon: Icons.science,
        descriptionKey: 'milkQualityTestsDesc',
      ),
    ],
  ),
  'procurement': const AppModule(
    nameKey: 'procurement',
    icon: Icons.shopping_cart,
    color: Colors.purple,
    screens: [
      ModuleScreen(
        nameKey: 'purchaseOrders',
        route: AppRoutes.purchaseOrders,
        icon: Icons.receipt_long,
        descriptionKey: 'purchaseOrdersDesc',
      ),
      ModuleScreen(
        nameKey: 'createPurchaseOrder',
        route: AppRoutes.createPurchaseOrder,
        icon: Icons.add_shopping_cart,
        descriptionKey: 'createPurchaseOrderDesc',
      ),
      ModuleScreen(
        nameKey: 'suppliers',
        route: AppRoutes.suppliers,
        icon: Icons.people,
        descriptionKey: 'suppliersDesc',
      ),
    ],
  ),
  'analytics': const AppModule(
    nameKey: 'analytics',
    icon: Icons.analytics,
    color: Colors.amber,
    screens: [
      ModuleScreen(
        nameKey: 'analyticsDashboard',
        route: AppRoutes.analyticsDashboard,
        icon: Icons.bar_chart,
        descriptionKey: 'analyticsDashboardDesc',
      ),
    ],
  ),
  'forecasting': const AppModule(
    nameKey: 'forecasting',
    icon: Icons.trending_up,
    color: Colors.teal,
    screens: [
      ModuleScreen(
        nameKey: 'forecastingList',
        route: AppRoutes.forecasting,
        icon: Icons.list,
        descriptionKey: 'forecastingDesc',
      ),
      ModuleScreen(
        nameKey: 'forecastingCreate',
        route: AppRoutes.forecastingCreate,
        icon: Icons.add_chart,
        descriptionKey: 'forecastingCreateDesc',
      ),
      ModuleScreen(
        nameKey: 'forecastingDashboard',
        route: AppRoutes.forecastingDashboard,
        icon: Icons.dashboard,
        descriptionKey: 'forecastingDashboardDesc',
      ),
    ],
  ),
  'order_management': const AppModule(
    nameKey: 'orderManagement',
    icon: Icons.assignment,
    color: Colors.amber,
    screens: [
      ModuleScreen(
        nameKey: 'orderList',
        route: '/order-management',
        icon: Icons.list_alt,
        descriptionKey: 'orderListDesc',
      ),
      ModuleScreen(
        nameKey: 'createOrder',
        route: AppRoutes.orderCreate,
        icon: Icons.add_box,
        descriptionKey: 'createOrderDesc',
      ),
    ],
  ),
  'crm': const AppModule(
    nameKey: 'crm',
    icon: Icons.people,
    color: Colors.indigo,
    screens: [
      ModuleScreen(
        nameKey: 'customerList',
        route: '/crm',
        icon: Icons.people_outline,
        descriptionKey: 'customerListDesc',
      ),
      ModuleScreen(
        nameKey: 'customerDetails',
        route: '/crm/customers/details',
        icon: Icons.person,
        descriptionKey: 'customerDetailsDesc',
      ),
      ModuleScreen(
        nameKey: 'leadManagement',
        route: '/crm/leads',
        icon: Icons.contact_phone,
        descriptionKey: 'leadManagementDesc',
      ),
      ModuleScreen(
        nameKey: 'interactions',
        route: '/crm/interactions',
        icon: Icons.chat,
        descriptionKey: 'interactionsDesc',
      ),
    ],
  ),
};
