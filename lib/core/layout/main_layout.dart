import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../../l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Controls whether the navigation rail is visible
  bool _isNavRailVisible = false;
  double _dragStartX = 0;

  @override
  Widget build(BuildContext context) {
    // Get the text direction to determine swipe direction
    final TextDirection textDirection = Directionality.of(context);

    return Scaffold(
      // Add a gesture detector to handle swipes from the edge
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragStartX = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          final currentX = details.globalPosition.dx;
          final delta = currentX - _dragStartX;

          if (textDirection == TextDirection.ltr) {
            // For LTR: Swipe right to show, left to hide
            if (delta > 50 && !_isNavRailVisible) {
              setState(() => _isNavRailVisible = true);
            } else if (delta < -50 && _isNavRailVisible) {
              setState(() => _isNavRailVisible = false);
            }
          } else {
            // For RTL: Swipe left to show, right to hide
            if (delta < -50 && !_isNavRailVisible) {
              setState(() => _isNavRailVisible = true);
            } else if (delta > 50 && _isNavRailVisible) {
              setState(() => _isNavRailVisible = false);
            }
          }
        },
        child: Stack(
          children: [
            // Main content
            widget.child,

            // Navigation rail with animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: textDirection == TextDirection.ltr
                  ? (_isNavRailVisible ? 0 : -100)
                  : null,
              right: textDirection == TextDirection.rtl
                  ? (_isNavRailVisible ? 0 : -100)
                  : null,
              top: 0,
              bottom: 0,
              width: 100,
              child: Material(
                elevation: 4,
                child: _buildNavigationRail(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return NavigationRail(
      selectedIndex: _getSelectedIndex(widget.currentRoute),
      labelType: NavigationRailLabelType.all,
      minWidth: 100,
      minExtendedWidth: 150,
      onDestinationSelected: (index) {
        // Hide the rail after selection
        setState(() {
          _isNavRailVisible = false;
        });

        // Navigate to the selected route using pushReplacementNamed to replace the current route
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.suppliers);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppRoutes.inventory);
            break;
          case 2:
            Navigator.pushReplacementNamed(
                context, AppRoutes.productionExecutions);
            break;
          case 3:
            Navigator.pushReplacementNamed(
                context, AppRoutes.equipmentMaintenance);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, AppRoutes.milkReception);
            break;
          case 5:
            Navigator.pushReplacementNamed(context, AppRoutes.procurement);
            break;
          case 6:
            Navigator.pushReplacementNamed(context, AppRoutes.notifications);
            break;
          case 7:
            Navigator.pushReplacementNamed(
                context, AppRoutes.analyticsDashboard);
            break;
          case 8:
            Navigator.pushReplacementNamed(context, AppRoutes.forecasting);
            break;
          case 9:
            Navigator.pushReplacementNamed(context, AppRoutes.settings);
            break;
        }
      },
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.person),
          label: Text(l10n.getModuleName('suppliers') ?? 'Suppliers'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.inventory_2),
          label: Text(l10n.getModuleName('inventory') ?? 'Inventory'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.factory),
          label: Text(l10n.getModuleName('factory') ?? 'Factory'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.build),
          label:
              Text(l10n.getModuleName('equipmentMaintenance') ?? 'Equipment'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.water_drop),
          label: Text(l10n.getModuleName('milkReception') ?? 'Milk Reception'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.shopping_cart),
          label: Text(l10n.getModuleName('procurement') ?? 'Procurement'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.notifications),
          label: Text(l10n.notifications),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.analytics),
          label: Text(l10n.getModuleName('analytics') ?? 'Analytics'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.trending_up),
          label: Text(l10n.getModuleName('forecasting') ?? 'Forecasting'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings),
          label: Text(l10n.settings),
        ),
      ],
    );
  }

  int _getSelectedIndex(String routeName) {
    if (routeName.startsWith('/suppliers')) {
      return 0;
    } else if (routeName.startsWith('/inventory')) {
      return 1;
    } else if (routeName.startsWith('/factory/production')) {
      return 2;
    } else if (routeName.startsWith('/factory/equipment')) {
      return 3;
    } else if (routeName.startsWith('/milk')) {
      return 4;
    } else if (routeName.startsWith('/procurement')) {
      return 5;
    } else if (routeName == AppRoutes.notifications) {
      return 6;
    } else if (routeName.startsWith('/analytics')) {
      return 7;
    } else if (routeName.startsWith('/forecasting')) {
      return 8;
    } else if (routeName == AppRoutes.settings) {
      return 9;
    }

    return 0;
  }
}
