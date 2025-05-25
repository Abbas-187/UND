import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_go_router.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });
  final Widget child;
  final String currentRoute;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

// Static variable to maintain nav rail visibility across all screens
class _NavRailState {
  static bool isVisible = false;
  static bool isPinned = false;
}

class _MainLayoutState extends State<MainLayout> {
  // Controls whether the navigation rail is visible
  bool _isNavRailVisible = _NavRailState.isVisible;
  // Controls whether the navigation rail is pinned open
  bool _isPinned = _NavRailState.isPinned;

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
              _updateNavRailVisibility(true);
            } else if (delta < -50 && _isNavRailVisible && !_isPinned) {
              _updateNavRailVisibility(false);
            }
          } else {
            // For RTL: Swipe left to show, right to hide
            if (delta < -50 && !_isNavRailVisible) {
              _updateNavRailVisibility(true);
            } else if (delta > 50 && _isNavRailVisible && !_isPinned) {
              _updateNavRailVisibility(false);
            }
          }
        },
        child: Stack(
          children: [
            // Main content with padding when nav is visible
            AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                left: textDirection == TextDirection.ltr && _isNavRailVisible
                    ? 100
                    : 0,
                right: textDirection == TextDirection.rtl && _isNavRailVisible
                    ? 100
                    : 0,
              ),
              child: widget.child,
            ),

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

            // Handle to pull out the navigation rail
            if (!_isNavRailVisible)
              Positioned(
                left: textDirection == TextDirection.ltr ? 0 : null,
                right: textDirection == TextDirection.rtl ? 0 : null,
                top: 0,
                bottom: 0,
                width: 20,
                child: GestureDetector(
                  onTap: () {
                    _updateNavRailVisibility(true);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.5 * 255),
                      borderRadius: BorderRadius.only(
                        topRight: textDirection == TextDirection.ltr
                            ? const Radius.circular(8)
                            : Radius.zero,
                        bottomRight: textDirection == TextDirection.ltr
                            ? const Radius.circular(8)
                            : Radius.zero,
                        topLeft: textDirection == TextDirection.rtl
                            ? const Radius.circular(8)
                            : Radius.zero,
                        bottomLeft: textDirection == TextDirection.rtl
                            ? const Radius.circular(8)
                            : Radius.zero,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        textDirection == TextDirection.ltr
                            ? Icons.chevron_right
                            : Icons.chevron_left,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Update the navigation rail visibility in both state and static variable
  void _updateNavRailVisibility(bool isVisible) {
    setState(() {
      _isNavRailVisible = isVisible;
      _NavRailState.isVisible = isVisible;
    });
  }

  // Toggle pin state
  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
      _NavRailState.isPinned = _isPinned;
    });
  }

  Widget _buildNavigationRail(BuildContext context) {
    final theme = Theme.of(context);

    // Create a list of all destinations with their IconData
    final List<Map<String, dynamic>> navItems = [
      {
        'icon': Icons.home,
        'label': Text('Home'),
        'route': AppRoutes.home,
      },
      {
        'icon': Icons.person,
        'label': Text('Suppliers'),
        'route': AppRoutes.suppliers,
      },
      {
        'icon': Icons.inventory_2,
        'label': Text('Inventory'),
        'route': AppRoutes.inventoryDashboard,
      },
      {
        'icon': Icons.factory,
        'label': Text('Factory'),
        'route': AppRoutes.productionExecutions,
      },
      {
        'icon': Icons.build,
        'label': Text('Equipment'),
        'route': AppRoutes.equipmentMaintenance,
      },
      {
        'icon': Icons.water_drop,
        'label': Text('Milk Reception'),
        'route': '/milk-reception',
      },
      {
        'icon': Icons.shopping_cart,
        'label': Text('Procurement'),
        'route': AppRoutes.procurementMain,
      },
      {
        'icon': Icons.notifications,
        'label': Text('Notifications'),
        'route': '/notifications',
      },
      {
        'icon': Icons.analytics,
        'label': Text('Analytics'),
        'route': '/analytics',
      },
      {
        'icon': Icons.trending_up,
        'label': Text('Forecasting'),
        'route': '/forecasting',
      },
      {
        'icon': Icons.settings,
        'label': Text('Settings'),
        'route': AppRoutes.settings,
      },
    ];

    // Custom navigation rail solution with scrolling
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // App logo or header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Icon(
              Icons.agriculture,
              color: theme.colorScheme.primary,
              size: 36,
            ),
          ),

          // Selected index indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Navigation',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Scrollable list of nav items
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(navItems.length, (index) {
                  final isSelected =
                      index == _getSelectedIndex(widget.currentRoute);
                  final item = navItems[index];

                  return InkWell(
                    onTap: () {
                      // Only navigate if not already on this route
                      if (widget.currentRoute != item['route']) {
                        context.go(item['route']);
                        if (!_isPinned) {
                          _updateNavRailVisibility(false);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'],
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7 * 255),
                          ),
                          const SizedBox(height: 4),
                          DefaultTextStyle(
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7 * 255),
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            child: item['label'],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Bottom controls: pin toggle and close
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  onPressed: _togglePin,
                  tooltip: _isPinned ? 'Unpin navigation' : 'Pin navigation',
                ),
                if (!_isPinned)
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _updateNavRailVisibility(false),
                    tooltip: 'Close navigation',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String routeName) {
    if (routeName == AppRoutes.home || routeName == '/') {
      return 0;
    } else if (routeName.startsWith('/suppliers')) {
      return 1;
    } else if (routeName.startsWith('/inventory')) {
      return 2;
    } else if (routeName.startsWith('/factory/production')) {
      return 3;
    } else if (routeName.startsWith('/factory/equipment')) {
      return 4;
    } else if (routeName.startsWith(AppRoutes.milkReception)) {
      return 5;
    } else if (routeName.startsWith('/procurement')) {
      return 6;
    } else if (routeName == '/notifications') {
      return 7;
    } else if (routeName.startsWith('/analytics')) {
      return 8;
    } else if (routeName.startsWith('/forecasting')) {
      return 9;
    } else if (routeName == AppRoutes.settings) {
      return 10;
    }

    return 0;
  }
}
