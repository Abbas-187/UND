import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_go_router.dart';
import '../../../../features/shared/models/app_modules.dart';
import '../../../../features/shared/models/user_role.dart';
import '../../../../features/shared/providers/selected_route_provider.dart';
import '../../../../features/shared/providers/selected_screen_title_provider.dart';
import '../../../../features/shared/providers/user_role_provider.dart';

final Map<String, String Function(AppLocalizations)> l10nModuleGetters = {
  // Module names
  'inventory': (l10n) => l10n.inventory,
  'factory': (l10n) => l10n.factory,
  'milkReception': (l10n) => l10n.milkReception,
  'procurement': (l10n) => l10n.procurement,
  'analytics': (l10n) => l10n.analytics,
  'forecasting': (l10n) => l10n.forecasting,
  'orderManagement': (l10n) => l10n.orderManagement,
  'crm': (l10n) => l10n.crm,
  'sales': (l10n) => l10n.sales,

  // Inventory module screens
  'inventoryDashboard': (l10n) => l10n.inventoryDashboard,
  'inventoryDashboardDesc': (l10n) => l10n.inventoryDashboardDesc,
  'inventoryMain': (l10n) => l10n.inventoryMain,
  'inventoryListDesc': (l10n) => l10n.inventoryListDesc,
  'inventoryAlerts': (l10n) => l10n.inventoryAlerts,
  'inventoryAlertsDesc': (l10n) => l10n.inventoryAlertsDesc,
  'inventoryMovements': (l10n) => l10n.inventoryMovements,
  'inventoryMovementsDesc': (l10n) => l10n.inventoryMovementsDesc,
  'createMovement': (l10n) => l10n.createMovement,
  'createMovementDesc': (l10n) => l10n.createMovementDesc,
  'inventoryBatchScanner': (l10n) => l10n.inventoryBatchScanner,
  'inventoryBatchScannerDesc': (l10n) => l10n.inventoryBatchScannerDesc,
  'inventoryEdit': (l10n) => l10n.inventoryEdit,
  'inventoryEditDesc': (l10n) => l10n.inventoryEditDesc,
  'inventoryAnalytics': (l10n) => l10n.inventoryAnalytics,
  'inventoryAnalyticsDesc': (l10n) => l10n.inventoryAnalyticsDesc,
  'inventoryTrends': (l10n) => l10n.inventoryTrends,
  'inventoryTrendsDesc': (l10n) => l10n.inventoryTrendsDesc,
  'inventoryBarcodeScan': (l10n) => l10n.inventoryBarcodeScan,
  'inventoryBarcodeScanDesc': (l10n) => l10n.inventoryBarcodeScanDesc,
  'inventoryBatchInventory': (l10n) => l10n.inventoryBatchInventory,
  'inventoryBatchInventoryDesc': (l10n) => l10n.inventoryBatchInventoryDesc,
  'dairyInventory': (l10n) => l10n.dairyInventory,
  'dairyInventoryDesc': (l10n) => l10n.dairyInventoryDesc,
  'dairyInventoryDemo': (l10n) => l10n.dairyInventoryDemo,
  'dairyInventoryDemoDesc': (l10n) => l10n.dairyInventoryDemoDesc,
  'inventoryCategoryManagement': (l10n) => l10n.inventoryCategoryManagement,
  'inventoryCategoryManagementDesc': (l10n) =>
      l10n.inventoryCategoryManagementDesc,
  'inventoryAdjustmentHistory': (l10n) => l10n.inventoryAdjustmentHistory,
  'inventoryAdjustmentHistoryDesc': (l10n) =>
      l10n.inventoryAdjustmentHistoryDesc,
  'inventoryReports': (l10n) => l10n.inventoryReports,
  'inventoryReportsDesc': (l10n) => l10n.inventoryReportsDesc,
  'inventoryReportDedicated': (l10n) => l10n.inventoryReportDedicated,
  'inventoryReportDedicatedDesc': (l10n) => l10n.inventoryReportDedicatedDesc,
  'inventorySettings': (l10n) => l10n.inventorySettings,
  'inventorySettingsDesc': (l10n) => l10n.inventorySettingsDesc,
  'inventoryDatabaseManagement': (l10n) => l10n.inventoryDatabaseManagement,
  'inventoryDatabaseManagementDesc': (l10n) =>
      l10n.inventoryDatabaseManagementDesc,

  // Factory module screens
  'productionExecutions': (l10n) => l10n.productionExecutions,
  'productionExecutionsDesc': (l10n) => l10n.productionExecutionsDesc,
  'createProductionExecution': (l10n) => l10n.createProductionExecution,
  'createProductionExecutionDesc': (l10n) => l10n.createProductionExecutionDesc,
  'productionExecutionList': (l10n) => l10n.productionExecutionList,
  'productionExecutionListDesc': (l10n) => l10n.productionExecutionListDesc,
  'batchTracking': (l10n) => l10n.batchTracking,
  'batchTrackingDesc': (l10n) => l10n.batchTrackingDesc,
  'productionPlanDetail': (l10n) => l10n.productionPlanDetail,
  'productionPlanDetailDesc': (l10n) => l10n.productionPlanDetailDesc,
  'productionScheduling': (l10n) => l10n.productionScheduling,
  'productionSchedulingDesc': (l10n) => l10n.productionSchedulingDesc,
  'equipmentMaintenance': (l10n) => l10n.equipmentMaintenance,
  'equipmentMaintenanceDesc': (l10n) => l10n.equipmentMaintenanceDesc,
  'createMaintenanceRecord': (l10n) => l10n.createMaintenanceRecord,
  'createMaintenanceRecordDesc': (l10n) => l10n.createMaintenanceRecordDesc,
  'addEditEquipment': (l10n) => l10n.addEditEquipment,
  'addEditEquipmentDesc': (l10n) => l10n.addEditEquipmentDesc,
  'productionList': (l10n) => l10n.productionList,
  'productionListDesc': (l10n) => l10n.productionListDesc,
  'productionExecutionDetail': (l10n) => l10n.productionExecutionDetail,
  'productionExecutionDetailDesc': (l10n) => l10n.productionExecutionDetailDesc,
  'equipmentDetail': (l10n) => l10n.equipmentDetail,
  'equipmentDetailDesc': (l10n) => l10n.equipmentDetailDesc,
  'maintenanceRecordDetail': (l10n) => l10n.maintenanceRecordDetail,
  'maintenanceRecordDetailDesc': (l10n) => l10n.maintenanceRecordDetailDesc,

  // Milk Reception module screens
  'milkReceptionScreen': (l10n) => l10n.milkReceptionScreen,
  'milkReceptionDesc': (l10n) => l10n.milkReceptionDesc,
  'milkQualityTests': (l10n) => l10n.milkQualityTests,
  'milkQualityTestsDesc': (l10n) => l10n.milkQualityTestsDesc,

  // Procurement module screens
  'purchaseOrders': (l10n) => l10n.purchaseOrders,
  'purchaseOrdersDesc': (l10n) => l10n.purchaseOrdersDesc,
  'createPurchaseOrder': (l10n) => l10n.createPurchaseOrder,
  'createPurchaseOrderDesc': (l10n) => l10n.createPurchaseOrderDesc,
  'suppliers': (l10n) => l10n.suppliers,
  'suppliersDesc': (l10n) => l10n.suppliersDesc,
  'poApprovalsList': (l10n) => l10n.poApprovalsList,
  'poApprovalsListDesc': (l10n) => l10n.poApprovalsListDesc,

  // Analytics module screens
  'analyticsDashboard': (l10n) => l10n.analyticsDashboard,
  'analyticsDashboardDesc': (l10n) => l10n.analyticsDashboardDesc,

  // Forecasting module screens
  'forecastingList': (l10n) => l10n.forecastingList,
  'forecastingDesc': (l10n) => l10n.forecastingDesc,
  'forecastingCreate': (l10n) => l10n.forecastingCreate,
  'forecastingCreateDesc': (l10n) => l10n.forecastingCreateDesc,
  'forecastingDashboard': (l10n) => l10n.forecastingDashboard,
  'forecastingDashboardDesc': (l10n) => l10n.forecastingDashboardDesc,

  // Order Management module screens
  'orderList': (l10n) => l10n.orderList,
  'orderListDesc': (l10n) => l10n.orderListDesc,
  'createOrder': (l10n) => l10n.createOrder,
  'createOrderDesc': (l10n) => l10n.createOrderDesc,

  // CRM module screens
  'customerList': (l10n) => l10n.customerList,
  'customerListDesc': (l10n) => l10n.customerListDesc,
  'customerDetails': (l10n) => l10n.customerDetails,
  'customerDetailsDesc': (l10n) => l10n.customerDetailsDesc,
  'leadManagement': (l10n) => l10n.leadManagement,
  'leadManagementDesc': (l10n) => l10n.leadManagementDesc,
  'interactions': (l10n) => l10n.interactions,
  'interactionsDesc': (l10n) => l10n.interactionsDesc,

  // Sales module screens
  'salesOrders': (l10n) => l10n.salesOrders,
  'salesOrdersDesc': (l10n) => l10n.salesOrdersDesc,
  'salesCustomers': (l10n) => l10n.salesCustomers,
  'salesCustomersDesc': (l10n) => l10n.salesCustomersDesc,
  'salesDashboard': (l10n) => l10n.salesDashboard,
  'salesDashboardDesc': (l10n) => l10n.salesDashboardDesc,
  'salesAnalytics': (l10n) => l10n.salesAnalytics,
  'salesAnalyticsDesc': (l10n) => l10n.salesAnalyticsDesc,

  // New BOM module screens
  'bomList': (l10n) => 'BOM List',
  'bomListDesc': (l10n) => 'View and manage Bills of Materials',
  'bomCreate': (l10n) => 'Create BOM',
  'bomCreateDesc': (l10n) => 'Create new Bill of Materials',
  'bomDetail': (l10n) => 'BOM Details',
  'bomDetailDesc': (l10n) => 'View Bill of Materials details',
};

String getL10nString(AppLocalizations l10n, String key) {
  return l10nModuleGetters[key]?.call(l10n) ?? key;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 600;
    final theme = Theme.of(context);

    // Get current user role
    final userRole = ref.watch(userRoleProvider);

    // Track the currently selected screen (route)
    final selectedRoute = ref.watch(selectedRouteProvider);
    final selectedScreenTitle = ref.watch(selectedScreenTitleProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 140,
            elevation: 2,
            shadowColor: theme.colorScheme.shadow.withOpacity(0.15),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 18),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeToUndManager ?? '',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          userRole.icon,
                          size: 14,
                          color: theme.colorScheme.onPrimary.withOpacity(0.85),
                          semanticLabel: userRole.name,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userRole.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onPrimary.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selectedRoute != '/') ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.onPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  selectedScreenTitle ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimary
                                        .withOpacity(0.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary
                          .withBlue(theme.colorScheme.primary.blue + 10),
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Opacity(
                  opacity: 0.08,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: Icon(
                        userRole.icon,
                        size: 80,
                        color: theme.colorScheme.onPrimary,
                        semanticLabel: userRole.name,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (userRole.canAccessNotifications)
                Tooltip(
                  message: l10n.notifications ?? '',
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Show feedback snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening notifications'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.push('/notifications');
                    },
                  ),
                ),
              if (userRole.canAccessSettings)
                Tooltip(
                  message: l10n.settings ?? '',
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Show feedback snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening settings'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.push('/settings');
                    },
                  ),
                ),
              Tooltip(
                message: 'Profile',
                child: IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    // Show feedback snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening profile'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.push('/profile');
                  },
                ),
              ),
            ],
          ),

          // Welcome section with user role info
          SliverToBoxAdapter(
            child: _buildWelcomeSection(context, l10n, ref, userRole),
          ),

          // Quick action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: _buildQuickActionButtons(context, l10n, userRole),
            ),
          ),

          // Module header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.modules ?? '',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (!isLargeScreen)
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.view_module,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'View All',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Modules grid or list - filtered by role
          isLargeScreen
              ? _buildModulesGrid(context, l10n, userRole)
              : _buildModulesList(context, l10n, userRole),

          // Footer space
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AppLocalizations l10n,
      WidgetRef ref, UserRole userRole) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      child: Column(
        children: [
          // Role section
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.6),
                  theme.colorScheme.primaryContainer.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    userRole.icon,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${userRole.name}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userRole.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show feedback snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening settings to change role'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.push('/settings');
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daily stats overview
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: theme.colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Overview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(
                        context,
                        '12',
                        'Tasks',
                        Icons.task_alt,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        context,
                        '3',
                        'Alerts',
                        Icons.warning_amber,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        context,
                        '5',
                        'Orders',
                        Icons.shopping_cart,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesList(
      BuildContext context, AppLocalizations l10n, UserRole userRole) {
    // Filter the modules based on user role
    final allowedModules = appModules.entries
        .where((entry) => userRole.allowedModules.contains(entry.key))
        .toList();

    return Consumer(
      builder: (context, ref, _) {
        final selectedRoute = ref.watch(selectedRouteProvider);

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final module = allowedModules[index].value;

              return _buildModuleSection(
                context,
                getL10nString(l10n, module.nameKey),
                module,
                selectedRoute,
              );
            },
            childCount: allowedModules.length,
          ),
        );
      },
    );
  }

  Widget _buildModulesGrid(
      BuildContext context, AppLocalizations l10n, UserRole userRole) {
    // Filter the modules based on user role
    final allowedModules = appModules.entries
        .where((entry) => userRole.allowedModules.contains(entry.key))
        .toList();

    return Consumer(
      builder: (context, ref, _) {
        final selectedRoute = ref.watch(selectedRouteProvider);

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = allowedModules[index].value;

                return _buildModuleCard(
                  context,
                  getL10nString(l10n, module.nameKey),
                  module,
                  selectedRoute,
                );
              },
              childCount: allowedModules.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    AppModule module,
    String selectedRoute,
  ) {
    final theme = Theme.of(context);
    final isLightColor = module.color.computeLuminance() > 0.5;
    final textColor = isLightColor ? Colors.black87 : Colors.white;

    return Card(
      elevation: 1,
      shadowColor: module.color.withOpacity(0.2),
      margin: EdgeInsets.zero,
      color: module.color.withOpacity(0.85), // Fill with module color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Show screen selection if module has multiple screens
          if (module.screens.length > 1) {
            _showModuleScreenSelection(context, title, module);
          } else if (module.screens.isNotEmpty) {
            // If module has only one screen, navigate directly
            // Show feedback snackbar
            final l10n = AppLocalizations.of(context)!;
            final screenName =
                getL10nString(l10n, module.screens.first.nameKey);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigating to: $screenName'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.push(module.screens.first.route);
          }
        },
        borderRadius: BorderRadius.circular(8),
        splashColor: module.color.withOpacity(0.3),
        highlightColor: module.color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  module.icon,
                  size: 32,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  '${module.screens.length} ${module.screens.length == 1 ? 'screen' : 'screens'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show modal with all screens in the module
  void _showModuleScreenSelection(
    BuildContext context,
    String moduleTitle,
    AppModule module,
  ) {
    // Capture GoRouter context for navigation
    final goRouterContext = context;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        module.color.withOpacity(0.7),
                        module.color.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          module.icon,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moduleTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Select a screen to navigate',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Screens list
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: module.screens.length,
                    itemBuilder: (context, index) {
                      final screen = module.screens[index];
                      final screenName = getL10nString(l10n, screen.nameKey);
                      final description =
                          getL10nString(l10n, screen.descriptionKey);

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: module.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            screen.icon,
                            color: module.color,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          screenName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: description.isNotEmpty
                            ? Text(
                                description,
                                style: theme.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(sheetContext); // Close the modal

                          // Show feedback snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Navigating to: $screenName'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          goRouterContext.push(screen.route);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleSection(BuildContext context, String title,
      AppModule module, String selectedRoute) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shadowColor: module.color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Module header
          InkWell(
            onTap: () {
              // Show all screens in a bottom sheet if the module has screens
              if (module.screens.isNotEmpty) {
                _showModuleScreenSelection(context, title, module);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    module.color.withOpacity(0.7),
                    module.color.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      module.icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.apps, size: 18),
                      color: Colors.white,
                      onPressed: () {
                        // Show all screens in a bottom sheet
                        if (module.screens.isNotEmpty) {
                          _showModuleScreenSelection(context, title, module);
                        }
                      },
                      iconSize: 18,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Module screens
          if (module.screens.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(l10n.noScreensAvailable ?? ''),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 450 ? 4 : 3;
                  final childAspectRatio = 0.85;

                  // Calculate the height needed for the grid
                  final itemCount =
                      module.screens.length > 6 ? 6 : module.screens.length;
                  final rowCount = (itemCount / crossAxisCount).ceil();
                  final totalHeight = rowCount *
                      (constraints.maxWidth /
                          crossAxisCount /
                          childAspectRatio);

                  return SizedBox(
                    height: totalHeight + 10, // Add a small buffer
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        final screen = module.screens[index];
                        final screenName = getL10nString(l10n, screen.nameKey);
                        final description =
                            getL10nString(l10n, screen.descriptionKey);

                        // If this is the last item and there are more than 6 screens,
                        // show a "More" button instead
                        if (index == 5 && module.screens.length > 6) {
                          return InkWell(
                            onTap: () {
                              _showModuleScreenSelection(
                                  context, title, module);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: module.color.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: module.color.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: module.color.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '+${module.screens.length - 5}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: module.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'View more',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: module.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return _buildScreenCard(
                          context: context,
                          title: screenName,
                          icon: screen.icon,
                          color: module.color,
                          onTap: () => context.push(screen.route),
                          tooltip: description,
                          selectedRoute: selectedRoute,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreenCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String tooltip = '',
    required String selectedRoute,
  }) {
    final theme = Theme.of(context);
    // Check if this screen's route matches the currently selected route
    final isSelected = selectedRoute == tooltip;

    return Card(
      elevation: isSelected ? 4 : 1,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? color : color.withOpacity(0.05),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Tooltip(
        message: tooltip.isNotEmpty ? tooltip : title,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? theme.colorScheme.primary : color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 24,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(
      BuildContext context, AppLocalizations l10n, UserRole userRole) {
    final theme = Theme.of(context);

    // Filter quick actions based on user role
    final List<Map<String, dynamic>> quickActions = [
      {
        'title': 'BOM Management',
        'icon': Icons.menu_book,
        'color': Colors.deepOrange,
        'route': '/bom',
        'moduleId': 'bom',
      },
      {
        'title': 'Inventory Report',
        'icon': Icons.bar_chart,
        'color': Colors.teal,
        'route': '/inventory/report',
        'moduleId': 'inventory',
      },
      {
        'title': 'Purchase Orders',
        'icon': Icons.shopping_cart,
        'color': Colors.purple,
        'route': '/procurement/purchase-orders',
        'moduleId': 'procurement',
      },
      {
        'title': 'Inventory',
        'icon': Icons.inventory_2,
        'color': Colors.blue,
        'route': '/inventory',
        'moduleId': 'inventory',
      },
      {
        'title': 'Production',
        'icon': Icons.factory,
        'color': Colors.green,
        'route': AppRoutes.productionExecutions,
        'moduleId': 'factory',
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics,
        'color': Colors.amber,
        'route': '/analytics',
        'moduleId': 'analytics',
      },
      {
        'title': 'Customer Management',
        'icon': Icons.people,
        'color': Colors.indigo,
        'route': '/crm',
        'moduleId': 'crm',
      },
      {
        'title': 'Orders',
        'icon': Icons.assignment,
        'color': Colors.orange,
        'route': '/order-management',
        'moduleId': 'order_management',
      },
    ];

    // Filter actions based on user role allowed modules
    final allowedActions = quickActions
        .where((action) => userRole.allowedModules.contains(action['moduleId']))
        .toList();

    // If no allowed actions, don't show the section
    if (allowedActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < allowedActions.length; i++)
                    Row(
                      children: [
                        _buildQuickActionButton(
                          context,
                          allowedActions[i]['title'],
                          allowedActions[i]['icon'],
                          allowedActions[i]['color'],
                          () {
                            // Show feedback snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Navigating to: ${allowedActions[i]['title']}'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            context.push(allowedActions[i]['route']);
                          },
                        ),
                        if (i < allowedActions.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }
}
