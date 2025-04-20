import 'package:flutter/material.dart';
import '../../../core/routes/app_router.dart';

@immutable
class ModuleScreen {
  final String nameKey;
  final String route;
  final IconData icon;
  final String descriptionKey;

  const ModuleScreen({
    required this.nameKey,
    required this.route,
    required this.icon,
    required this.descriptionKey,
  });

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
  final String nameKey;
  final IconData icon;
  final Color color;
  final List<ModuleScreen> screens;

  const AppModule({
    required this.nameKey,
    required this.icon,
    required this.color,
    required this.screens,
  });

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
        nameKey: 'inventoryAlerts',
        route: AppRoutes.inventoryAlerts,
        icon: Icons.warning,
        descriptionKey: 'inventoryAlertsDesc',
      ),
      ModuleScreen(
        nameKey: 'inventoryMovementsScreen',
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
        route: AppRoutes.inventoryBatchScanner,
        icon: Icons.qr_code_scanner,
        descriptionKey: 'inventoryBatchScannerDesc',
      ),
      ModuleScreen(
        nameKey: 'inventorySettings',
        route: AppRoutes.inventorySettings,
        icon: Icons.settings,
        descriptionKey: 'inventorySettingsDesc',
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
};
