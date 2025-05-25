import 'package:flutter/material.dart';

import '../routes/location_optimization_routes.dart';

/// Button to open the location optimization screen
class LocationOptimizationButton extends StatelessWidget {
  const LocationOptimizationButton({
    super.key,
    this.tooltip = 'Optimize Warehouse Locations',
    this.label = 'Optimize Locations',
  });

  final String tooltip;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.apartment),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(
            LocationOptimizationRoutes.locationOptimizationScreen(),
          );
        },
      ),
    );
  }
}
