// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/crm/models/crm_report.dart';
import '../../features/crm/models/customer.dart';
import '../../features/crm/screens/crm_analytics_dashboard_screen.dart';
import '../../features/crm/screens/crm_main_screen.dart';
import '../../features/crm/screens/crm_onboarding_screen.dart';
import '../../features/crm/screens/crm_reminders_screen.dart';
import '../../features/crm/screens/crm_report_screen.dart';
import '../../features/crm/screens/customer_bulk_actions_screen.dart';
import '../../features/crm/screens/customer_import_export_screen.dart';
import '../../features/crm/screens/customer_profile_screen.dart';
import '../../features/crm/screens/customer_search_screen.dart';
import '../../features/crm/screens/customer_tagging_screen.dart';
import '../../features/factory/equipment_maintenance/data/models/equipment_model.dart';
import '../../features/factory/equipment_maintenance/data/models/maintenance_record_model.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/add_edit_equipment_screen.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/create_maintenance_record_screen.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/edit_maintenance_record_screen.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/equipment_detail_screen.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/equipment_maintenance_screen.dart';
import '../../features/factory/equipment_maintenance/presentation/screens/maintenance_record_detail_screen.dart';
import '../../features/factory/production/presentation/screens/batch_tracking_screen.dart';
import '../../features/factory/production/presentation/screens/create_production_execution_screen.dart';
import '../../features/factory/production/presentation/screens/production_execution_detail_screen.dart';
import '../../features/factory/production/presentation/screens/production_execution_list_screen.dart';
import '../../features/factory/production/presentation/screens/production_executions_screen.dart';
import '../../features/factory/production/presentation/screens/production_plan_detail_screen.dart';
import '../../features/factory/production_scheduling/presentation/screens/production_scheduling_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_dashboard_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_list_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inventory/presentation/screens/batch_barcode_scan_screen.dart';
import '../../features/inventory/presentation/screens/batch_inventory_screen.dart';
import '../../features/inventory/presentation/screens/batch_scanner_screen.dart';
import '../../features/inventory/presentation/screens/create_movement_page.dart';
import '../../features/inventory/presentation/screens/dairy_inventory_demo_screen.dart';
import '../../features/inventory/presentation/screens/dairy_inventory_screen.dart';
import '../../features/inventory/presentation/screens/inventory_adjustment_history_screen.dart';
import '../../features/inventory/presentation/screens/inventory_alerts_screen.dart';
import '../../features/inventory/presentation/screens/inventory_analytics_dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_category_management_screen.dart';
import '../../features/inventory/presentation/screens/inventory_dashboard_page.dart';
import '../../features/inventory/presentation/screens/inventory_database_management_screen.dart';
import '../../features/inventory/presentation/screens/inventory_edit_screen.dart';
import '../../features/inventory/presentation/screens/inventory_item_details_screen.dart';
import '../../features/inventory/presentation/screens/inventory_list_screen.dart';
import '../../features/inventory/presentation/screens/inventory_movement_history_screen.dart';
import '../../features/inventory/presentation/screens/inventory_movement_list_page.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/inventory/presentation/screens/inventory_settings_screen.dart';
import '../../features/inventory/presentation/screens/inventory_transfer_screen.dart';
import '../../features/inventory/presentation/screens/inventory_trends_screen.dart';
import '../../features/inventory/presentation/screens/movement_details_page.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_details_screen.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_screen.dart';
import '../../features/milk_reception/presentation/screens/milk_reception_wizard_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/order_management/presentation/screens/audit_trail_screen.dart';
import '../../features/order_management/presentation/screens/discussion_room_screen.dart';
import '../../features/order_management/presentation/screens/order_creation_edit_screen.dart';
import '../../features/order_management/presentation/screens/order_detail_screen.dart';
import '../../features/order_management/presentation/screens/order_list_screen.dart';
import '../../features/procurement/presentation/screens/po_approval_screen.dart';
import '../../features/procurement/presentation/screens/procurement_dashboard_screen.dart';
import '../../features/procurement/presentation/screens/procurement_main_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_create_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_detail_screen.dart';
import '../../features/procurement/presentation/screens/purchase_order/purchase_order_list_screen.dart';
import '../../features/procurement/presentation/screens/test_navigation_screen.dart';
import '../../features/reports/screens/inventory_report_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shared/presentation/screens/app_settings_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_contract_detail_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_contract_list_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_details_screen.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../auth/services/auth_service.dart';
import '../config.dart';
import '../layout/main_layout.dart';
import '../../features/sales/presentation/screens/customers/customer_list_screen.dart';
import '../../features/sales/presentation/screens/dashboard/sales_dashboard_screen.dart';
import '../../features/sales/presentation/screens/analytics/sales_analytics_screen.dart';
import '../../features/inventory/presentation/screens/inventory_audit_log_screen.dart';
import '../../features/procurement/presentation/screens/purchase_request_create_screen.dart';
import '../../features/procurement/presentation/screens/requested_purchase_orders_screen.dart';
import '../../features/procurement/presentation/screens/po_approvals_list_screen.dart';

/// Centralized string constants for named routes
class AppRoutes {
  static const home = '/';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const analytics = '/analytics';
  static const forecasting = '/forecasting';
  static const milkReception = '/milk-reception';
  // Supplier module
  static const suppliers = '/suppliers';
  static const supplierDetails = '/suppliers/details/:id';
  static const supplierContracts = '/suppliers/contracts';
  static const supplierContractDetail = '/suppliers/contracts/detail';
  static const supplierEdit = '/suppliers/edit';
  // Procurement
  static const procurementMain = '/procurement';
  static const procurementDashboard = '/procurement/dashboard';
  static const purchaseOrders = '/procurement/purchase-orders';
  static const createPurchaseOrder = '/procurement/purchase-orders/create';
  static const purchaseOrderDetail = '/procurement/purchase-orders/detail/:id';
  static const poApproval = '/procurement/po-approval';
  static const testNavigation = '/procurement/test-navigation';

  // Inventory Module Routes
  // Ensure these are the FULL paths as understood by GoRouter for direct navigation
  // from the HomeScreen module list.
  // AppRoutes.inventoryMain ('/inventory') typically maps to the base InventoryScreen.
  // Specific sub-screens should have their full path.

  static const inventoryMain =
      '/inventory'; // Base for the inventory module shell/screen
  static const inventoryDashboard =
      '/inventory/dashboard'; // Corrected: Full path
  static const dairyInventory = '/inventory/dairy';
  static const dairyInventoryDemo = '/inventory/dairy-demo';
  static const batchInventory = '/inventory/batch';
  static const batchBarcodeScan = '/inventory/batch-scan';
  static const batchScanner = '/inventory/batch-scanner';
  static const inventoryAdjustments =
      '/inventory/adjustments'; // Leads to InventoryAdjustmentHistoryScreen
  static const inventoryMovementHistory =
      '/inventory/movement-history'; // Note: GoRouter expects /:id. This screen might not be suitable for direct nav from home.
  static const inventoryItemDetails =
      '/inventory/item-details'; // Note: GoRouter expects /:id. This screen might not be suitable for direct nav from home.
  static const inventoryEdit =
      '/inventory/edit'; // Navigates to InventoryEditScreen (no ID version)
  static const inventoryCategoryManagement = '/inventory/category-management';
  static const inventoryReports =
      '/inventory/reports'; // This seems to map to InventoryAnalyticsDashboardScreen in GoRouter
  static const inventoryAnalytics =
      '/inventory/analytics'; // Also maps to InventoryAnalyticsDashboardScreen
  static const inventoryAlerts = '/inventory/alerts';
  static const inventorySettings = '/inventory/settings';
  static const inventoryTrends = '/inventory/trends';
  static const inventoryTransfer =
      '/inventory/transfer'; // Note: GoRouter expects /:sourceItemId. Not suitable for direct nav from home.
  // The following might be redundant or need clarification based on your GoRouter paths:
  static const inventoryBatchBarcodeScan =
      '/inventory/batch-barcode-scan'; // Ensure this matches a unique GoRouter path if different from batchBarcodeScan
  static const inventoryAdjustmentHistory =
      '/inventory/adjustment-history'; // Same as inventoryAdjustments?
  static const inventoryMovements =
      '/inventory/movements'; // Leads to InventoryMovementListPage
  static const inventoryMovementDetails =
      '/inventory/movement-details'; // Note: GoRouter expects /:id. Not suitable for direct nav from home.
  static const createMovement = '/inventory/movement-create';
  static const inventoryBatchScanner =
      '/inventory/batch-scanner'; // Same as batchScanner?
  static const inventoryItemEdit =
      '/inventory/item-edit'; // Same as inventoryEdit or for item-specific edit?
  static const inventoryBarcodeScan =
      '/inventory/barcode-scan'; // Same as batchBarcodeScan?
  static const inventoryBatchInventory =
      '/inventory/batch-inventory'; // Same as batchInventory?
  static const inventoryReport =
      '/inventory/report'; // Leads to InventoryReportScreen
  static const inventoryDatabaseManagement = '/inventory/database-management';
  static const inventoryList =
      '/inventory/list'; // New route for inventory list

  // Factory module
  static const productionExecutions = '/factory/production/executions';
  static const productionExecutionList = '/factory/production/execution-list';
  static const productionExecutionDetail =
      '/factory/production/execution-detail/:id';
  static const createProductionExecution =
      '/factory/production/create-execution';
  static const batchTracking = '/factory/production/batch-tracking';
  static const productionPlanDetail = '/factory/production/plan-detail';
  static const productionScheduling = '/factory/production-scheduling';
  static const equipmentMaintenance = '/factory/equipment-maintenance';
  static const addEditEquipment = '/factory/equipment-maintenance/add-edit';
  static const createMaintenanceRecord =
      '/factory/equipment-maintenance/create-record';
  static const maintenanceRecordDetail =
      '/factory/equipment-maintenance/record-detail';
  static const equipmentMaintenanceDetail =
      '/factory/equipment-maintenance/equipment-detail';
  static const editMaintenanceRecord =
      '/factory/equipment-maintenance/edit-record';
  static const productionOrders = '/factory/production/orders';
  static const recipes = '/factory/production/recipes';
  static const recipeCreate = '/factory/production/recipes/create';
  static const recipeDetail = '/factory/production/recipes/detail';
  // Milk Reception
  static const milkQualityTests = '/milk-reception/quality-tests';
  // Analytics
  static const analyticsDashboard = '/analytics/dashboard';
  // Forecasting
  static const forecastingCreate = '/forecasting/create';
  static const forecastingDashboard = '/forecasting/dashboard';
  // Order Management
  static const orderCreate = '/order-management/create';
  static const login = '/login';
  static const unauthorized = '/unauthorized';
}

// Custom ChangeNotifier to refresh GoRouter on stream events
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Trigger initial evaluation
    stream.listen((_) => notifyListeners());
  }
}

// Riverpod provider for GoRouter with automatic refresh on auth state changes
final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MainLayout(currentRoute: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(
            path: AppRoutes.inventoryMain,
            builder: (c, s) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: 'dashboard',
                builder: (c, s) => const InventoryDashboardPage(),
              ),
              GoRoute(
                path: 'dairy',
                builder: (c, s) => const DairyInventoryScreen(),
              ),
              GoRoute(
                path: 'dairy-demo',
                builder: (c, s) => const DairyInventoryDemoScreen(),
              ),
              GoRoute(
                path: 'batch',
                builder: (c, s) => const BatchInventoryScreen(),
              ),
              GoRoute(
                path: 'batch-scan',
                builder: (c, s) => const BatchBarcodeScanScreen(),
              ),
              GoRoute(
                path: 'batch-scanner',
                builder: (c, s) => const BatchScannerScreen(),
              ),
              GoRoute(
                path: 'adjustments',
                builder: (c, s) => const InventoryAdjustmentHistoryScreen(),
              ),
              GoRoute(
                path: 'movement-history',
                builder: (c, s) => InventoryMovementHistoryScreen(
                    itemId: s.pathParameters['id']!),
              ),
              GoRoute(
                path: 'item-details/:id',
                builder: (c, s) =>
                    InventoryItemDetailsScreen(itemId: s.pathParameters['id']!),
              ),
              GoRoute(
                path: 'edit',
                builder: (c, s) => const InventoryEditScreen(),
              ),
              GoRoute(
                path: 'edit/:itemId',
                builder: (c, s) =>
                    InventoryEditScreen(itemId: s.pathParameters['itemId']!),
              ),
              GoRoute(
                path: 'category-management',
                builder: (c, s) => const InventoryCategoryManagementScreen(),
              ),
              GoRoute(
                path: 'reports',
                builder: (c, s) => const InventoryAnalyticsDashboardScreen(),
              ),
              GoRoute(
                path: 'analytics',
                builder: (c, s) => const InventoryAnalyticsDashboardScreen(),
              ),
              GoRoute(
                path: 'alerts',
                builder: (c, s) => const InventoryAlertsScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (c, s) => const InventorySettingsScreen(),
              ),
              GoRoute(
                path: 'trends',
                builder: (c, s) => const InventoryTrendsScreen(),
              ),
              GoRoute(
                path: 'transfer/:sourceItemId',
                builder: (c, s) => InventoryTransferScreen(
                    sourceItemId: s.pathParameters['sourceItemId']!),
              ),
              GoRoute(
                path: 'batch-barcode-scan',
                builder: (c, s) => const BatchBarcodeScanScreen(),
              ),
              GoRoute(
                path: 'adjustment-history',
                builder: (c, s) => const InventoryAdjustmentHistoryScreen(),
              ),
              GoRoute(
                path: 'movements',
                builder: (c, s) => const InventoryMovementListPage(),
              ),
              GoRoute(
                path: 'movement-details/:id',
                builder: (c, s) =>
                    MovementDetailsPage(movementId: s.pathParameters['id']!),
              ),
              GoRoute(
                path: 'movement-create',
                builder: (c, s) => const CreateMovementPage(),
              ),
              GoRoute(
                path: 'batch-scanner',
                builder: (c, s) => const BatchScannerScreen(),
              ),
              GoRoute(
                path: 'item-edit',
                builder: (c, s) => const InventoryEditScreen(),
              ),
              GoRoute(
                path: 'barcode-scan',
                builder: (c, s) => const BatchBarcodeScanScreen(),
              ),
              GoRoute(
                path: 'batch-inventory',
                builder: (c, s) => const BatchInventoryScreen(),
              ),
              GoRoute(
                path: 'database-management',
                builder: (c, s) => const InventoryDatabaseManagementScreen(),
              ),
              GoRoute(
                path: 'list',
                builder: (c, s) => const InventoryListScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.productionExecutions,
            builder: (c, s) => const ProductionExecutionsScreen(),
            routes: [
              GoRoute(
                path: 'execution-detail/:id',
                builder: (c, s) {
                  final id = s.pathParameters['id']!;
                  return ProductionExecutionDetailScreen(executionId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.milkReception,
            builder: (c, s) => const MilkReceptionScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (c, s) {
                  final id = s.pathParameters['id']!;
                  return MilkReceptionDetailsScreen(receptionId: id);
                },
              ),
              GoRoute(
                path: 'wizard',
                builder: (c, s) => const MilkReceptionWizardScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.suppliers,
            builder: (c, s) => SuppliersScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (c, s) {
                  final id = s.pathParameters['id']!;
                  return SupplierDetailsScreen(supplierId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.purchaseOrders,
            builder: (c, s) => const PurchaseOrderListScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (c, s) {
                  final id = s.pathParameters['id']!;
                  return PurchaseOrderDetailScreen(orderId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.poApproval,
            builder: (c, s) => const POApprovalScreen(purchaseOrderId: ''),
            routes: [
              GoRoute(
                path: ':poId',
                builder: (c, s) {
                  final poId = s.pathParameters['poId']!;
                  return POApprovalScreen(purchaseOrderId: poId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.analytics,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.analytics),
              child: const AnalyticsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.forecasting,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.forecasting),
              child: const ForecastingDashboardScreen(),
            ),
            routes: [
              GoRoute(
                path: 'list',
                builder: (context, state) => KeyedSubtree(
                  key: const ValueKey('forecasting-list'),
                  child: ForecastingListScreen(),
                ),
              ),
              GoRoute(
                path: 'create',
                builder: (context, state) => KeyedSubtree(
                  key: const ValueKey('forecasting-create'),
                  child: ForecastingScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/crm',
            builder: (context, state) => KeyedSubtree(
              key: ValueKey('/crm'),
              child: CrmMainScreen(),
            ),
          ),
          GoRoute(
            path: '/order-management',
            builder: (context, state) => KeyedSubtree(
              key: ValueKey('/order-management'),
              child: const OrderListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.supplierContracts,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.supplierContracts),
              child: SupplierContractListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.supplierContractDetail,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.supplierContractDetail),
              child: SupplierContractDetailScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.procurementMain,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.procurementMain),
              child: ProcurementMainScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.procurementDashboard,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.procurementDashboard),
              child: ProcurementDashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.createPurchaseOrder,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.createPurchaseOrder),
              child: PurchaseOrderCreateScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.testNavigation,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.testNavigation),
              child: TestNavigationScreen(),
            ),
          ),
          GoRoute(
            path: '/crm/customers/details',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              final customer = args?['customer'] as Customer;
              final orders = args?['orders'];
              return KeyedSubtree(
                key: const ValueKey('/crm/customers/details'),
                child:
                    CustomerProfileScreen(customer: customer, orders: orders),
              );
            },
          ),
          GoRoute(
            path: '/crm/leads',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              final customers = args?['customers'] as List<Customer>? ?? [];
              final onBulkAction = args?['onBulkAction'] as void Function(
                      List<Customer>, String)? ??
                  (_, __) {};
              return KeyedSubtree(
                key: const ValueKey('/crm/leads'),
                child: CustomerBulkActionsScreen(
                    customers: customers, onBulkAction: onBulkAction),
              );
            },
          ),
          GoRoute(
            path: '/crm/interactions',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              return KeyedSubtree(
                key: const ValueKey('/crm/interactions'),
                child: CustomerTaggingScreen(
                  customer: args?['customer'],
                  availableTags: args?['availableTags'] ?? [],
                  onTagsUpdated: args?['onTagsUpdated'] ?? (_) {},
                ),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.inventoryReport,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.inventoryReport),
              child: InventoryReportScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.inventoryDatabaseManagement,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.inventoryDatabaseManagement),
              child: const InventoryDatabaseManagementScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => KeyedSubtree(
              key: ValueKey(AppRoutes.settings),
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/sales/orders',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/sales/orders'),
              child: const OrderListScreen(),
            ),
          ),
          GoRoute(
            path: '/sales/orders/create',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/sales/orders/create'),
              child: OrderCreationEditScreen(),
            ),
          ),
          GoRoute(
            path: '/sales/customers',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/sales/customers'),
              child: CustomerListScreen(),
            ),
          ),
          GoRoute(
            path: '/sales/dashboard',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/sales/dashboard'),
              child: SalesDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/sales/analytics',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/sales/analytics'),
              child: SalesAnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: '/order-management/discussion',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/order-management/discussion'),
              child: DiscussionRoomScreen(),
            ),
          ),
          GoRoute(
            path: '/order-management/create',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/order-management/create'),
              child: OrderCreationEditScreen(),
            ),
          ),
          GoRoute(
            path: '/order-management/detail',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/order-management/detail'),
              child: OrderDetailScreen(),
            ),
          ),
          GoRoute(
            path: '/inventory/audit-logs',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/inventory/audit-logs'),
              child: InventoryAuditLogScreen(),
            ),
          ),
          GoRoute(
            path: '/order-management/audit-trail',
            builder: (context, state) {
              final orderId = state.uri.queryParameters['id'] ?? '';
              return KeyedSubtree(
                key: const ValueKey('/order-management/audit-trail'),
                child: AuditTrailScreen(orderId: orderId),
              );
            },
          ),
          GoRoute(
            path: '/procurement/purchase-request',
            builder: (context, state) {
              final item = state.extra;
              return PurchaseRequestCreateScreen(item: item);
            },
          ),
          GoRoute(
            path: '/procurement/requested-purchase-orders',
            builder: (context, state) => KeyedSubtree(
              key: const ValueKey('/procurement/requested-purchase-orders'),
              child: RequestedPurchaseOrdersScreen(),
            ),
          ),
          GoRoute(
            path: '/procurement/po-approvals',
            builder: (context, state) => const POApprovalsListScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final authService = container.read(authServiceProvider);
      final isLoggedIn = authService.currentUser != null;
      final loggingIn = state.uri.toString() == AppRoutes.login;
      if (!isLoggedIn && !loggingIn) return AppRoutes.login;
      if (isLoggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
    errorBuilder: (context, state) => _GlobalNavigationErrorScreen(),
  );
});

class _GlobalNavigationErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong with navigation.\nYou may have reached an unknown or empty page.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Go to Dashboard'),
              onPressed: () {
                context.go(AppRoutes.procurementDashboard);
              },
            ),
          ],
        ),
      ),
    );
  }
}
