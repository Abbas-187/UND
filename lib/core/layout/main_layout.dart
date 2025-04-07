import 'package:flutter/material.dart';
import '../routes/app_router.dart';

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

  @override
  Widget build(BuildContext context) {
    // Get the text direction to determine swipe direction
    final TextDirection textDirection = Directionality.of(context);

    return Scaffold(
      // Add a gesture detector to handle swipes from the edge
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // For LTR languages (like English), swipe right reveals the rail
          // For RTL languages (like Arabic), swipe left reveals the rail
          if (textDirection == TextDirection.ltr) {
            // Check if swipe was from left edge to right
            if (details.primaryVelocity! > 0 && !_isNavRailVisible) {
              setState(() {
                _isNavRailVisible = true;
              });
            }
            // Check if swipe was from right to left edge
            else if (details.primaryVelocity! < 0 && _isNavRailVisible) {
              setState(() {
                _isNavRailVisible = false;
              });
            }
          } else {
            // RTL: Check if swipe was from right edge to left
            if (details.primaryVelocity! < 0 && !_isNavRailVisible) {
              setState(() {
                _isNavRailVisible = true;
              });
            }
            // Check if swipe was from left to right edge
            else if (details.primaryVelocity! > 0 && _isNavRailVisible) {
              setState(() {
                _isNavRailVisible = false;
              });
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
                  ? (_isNavRailVisible ? 0 : -80)
                  : null,
              right: textDirection == TextDirection.rtl
                  ? (_isNavRailVisible ? 0 : -80)
                  : null,
              top: 0,
              bottom: 0,
              width: 80,
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
    return NavigationRail(
      selectedIndex: _getSelectedIndex(widget.currentRoute),
      labelType: NavigationRailLabelType.all,
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
        }
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Suppliers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2),
          label: Text('Inventory'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.factory),
          label: Text('Production'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.build),
          label: Text('Equipment'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.water_drop),
          label: Text('Milk Reception'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shopping_cart),
          label: Text('Procurement'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications),
          label: Text('Notifications'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics),
          label: Text('Analytics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.trending_up),
          label: Text('Forecasting'),
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
    }

    return 0;
  }
}
