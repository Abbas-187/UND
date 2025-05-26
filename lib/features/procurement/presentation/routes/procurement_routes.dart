import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/*
 * NOTE: This file is prepared for future migration to Go Router.
 * It is not currently in use as the app is using AppRouter instead.
 * To be used when the app is migrated from AppRouter to Go Router.
 */

import '../screens/po_approval_screen.dart';
import '../screens/po_approvals_list_screen.dart';
import '../screens/procurement_dashboard_screen.dart';
import '../screens/purchase_order/purchase_order_create_screen.dart';
import '../screens/purchase_order/purchase_order_detail_screen.dart';
import '../screens/purchase_order/purchase_order_list_screen.dart';
import '../screens/reports/procurement_dashboard_screen.dart' as reports;

/// Route names for the procurement feature
class ProcurementRoutes {
  static const String dashboard = 'procurement-dashboard';
  static const String poApproval = 'po-approval';
  static const String purchaseOrders = 'purchase-orders';
  static const String purchaseOrderDetail = 'purchase-order-detail';
  static const String createPurchaseOrder = 'create-purchase-order';
  static const String reportsDashboard = 'reports-dashboard';
  static const String poApprovalsList = 'po-approvals';

  /// Base path for all procurement routes
  static const String basePath = '/procurement';

  /// Full path for the PO approval screen
  static String poApprovalPath(String poId) => '$basePath/po/$poId/approval';

  /// Full path for the purchase order list
  static const String purchaseOrdersPath = '$basePath/purchase-orders';

  /// Full path for purchase order detail
  static String purchaseOrderDetailPath(String poId) =>
      '$basePath/purchase-orders/$poId';

  /// Full path for creating a purchase order
  static const String createPurchaseOrderPath =
      '$basePath/purchase-orders/create';

  /// Full path for the procurement dashboard
  static const String dashboardPath = basePath;

  /// Full path for the reports dashboard
  static const String reportsDashboardPath = '$basePath/reports/dashboard';

  /// Full path for the PO approvals list
  static const String poApprovalsListPath = '$basePath/po-approvals';
}

/// Adds procurement routes to the Go Router configuration
List<RouteBase> getProcurementRoutes() {
  return [
    GoRoute(
      path: ProcurementRoutes.basePath,
      name: ProcurementRoutes.dashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const ProcurementDashboardScreen();
      },
    ),
    GoRoute(
      path: '${ProcurementRoutes.basePath}/po/:poId/approval',
      name: ProcurementRoutes.poApproval,
      builder: (BuildContext context, GoRouterState state) {
        final poId = state.pathParameters['poId'] ?? '';
        return POApprovalScreen(purchaseOrderId: poId);
      },
    ),
    GoRoute(
      path: ProcurementRoutes.poApprovalsListPath,
      name: ProcurementRoutes.poApprovalsList,
      builder: (BuildContext context, GoRouterState state) {
        return const POApprovalsListScreen();
      },
    ),
    GoRoute(
      path: ProcurementRoutes.purchaseOrdersPath,
      name: ProcurementRoutes.purchaseOrders,
      builder: (BuildContext context, GoRouterState state) {
        return const PurchaseOrderListScreen();
      },
    ),
    GoRoute(
      path: '${ProcurementRoutes.basePath}/purchase-orders/:poId',
      name: ProcurementRoutes.purchaseOrderDetail,
      builder: (BuildContext context, GoRouterState state) {
        final poId = state.pathParameters['poId'] ?? '';
        return PurchaseOrderDetailScreen(orderId: poId);
      },
    ),
    GoRoute(
      path: ProcurementRoutes.createPurchaseOrderPath,
      name: ProcurementRoutes.createPurchaseOrder,
      builder: (BuildContext context, GoRouterState state) {
        return const PurchaseOrderCreateScreen();
      },
    ),
    GoRoute(
      path: ProcurementRoutes.reportsDashboardPath,
      name: ProcurementRoutes.reportsDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const reports.ProcurementDashboardScreen();
      },
    ),
  ];
}
