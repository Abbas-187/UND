import 'package:flutter/material.dart';
import '../../features/suppliers/domain/entities/supplier.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_details_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_edit_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_list_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_screen.dart';
import '../../features/forecasting/presentation/screens/forecasting_dashboard_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String suppliers = '/suppliers';
  static const String supplierDetails = '/suppliers/details';
  static const String supplierEdit = '/suppliers/edit';
  static const String inventory = '/inventory';
  static const String inventoryDetails = '/inventory/details';
  static const String inventoryEdit = '/inventory/edit';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String forecasting = '/forecasting';
  static const String forecastingCreate = '/forecasting/create';
  static const String forecastingDetail = '/forecasting/detail';
  static const String forecastingDashboard = '/forecasting/dashboard';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.suppliers:
        return MaterialPageRoute(
          builder: (_) => const SuppliersScreen(),
          settings: settings,
        );

      case AppRoutes.supplierDetails:
        final args = settings.arguments as SupplierDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => SupplierDetailsScreen(supplierId: args.supplierId),
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
  final String supplierId;

  SupplierDetailsArgs({required this.supplierId});
}

class SupplierEditArgs {
  final Supplier? supplier;

  SupplierEditArgs({this.supplier});
}

class ForecastingDetailArgs {
  final String forecastId;

  ForecastingDetailArgs({required this.forecastId});
}
