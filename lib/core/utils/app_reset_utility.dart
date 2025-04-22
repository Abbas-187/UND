import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mock_data_service.dart';
import '../../features/forecasting/presentation/providers/forecasting_provider.dart';
import '../../features/inventory/presentation/providers/inventory_provider.dart';
import '../../features/inventory/data/repositories/inventory_movement_repository.dart';

/// Utility class to help reset app state when encountering data-related errors
class AppResetUtility {
  /// Reset all app data and state
  static void resetAppData(BuildContext context, WidgetRef ref) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Resetting App Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait while we reset your app data...'),
          ],
        ),
      ),
    );

    // Clear caches and reset providers
    try {
      // Get the mock data service and call reset
      final mockDataService = MockDataService();
      mockDataService.reset();

      // Clear any caches
      ref.invalidate(mockDataServiceProvider);

      // Invalidate other key providers - add any specific providers that need to be refreshed
      ref.invalidate(forecastingProvider);
      ref.invalidate(filteredInventoryItemsProvider);
      ref.invalidate(inventoryMovementRepositoryProvider);
      ref.invalidate(inventoryValueProvider);
      ref.invalidate(topMovingItemsProvider);
      ref.invalidate(slowMovingItemsProvider);

      // Close the dialog after a brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        // Pop the dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App data has been reset. Please restart the app.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    } catch (e) {
      // Close the dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting app data: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

/// Add this button to any screen to allow users to reset when they encounter errors
class ResetAppButton extends StatelessWidget {
  const ResetAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return IconButton(
          icon: const Icon(Icons.restore),
          tooltip: 'Reset App Data',
          onPressed: () {
            // Confirm before resetting
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reset App Data?'),
                content: const Text(
                  'This will reset all app data to its initial state. '
                  'Use this only if you are experiencing data-related errors. '
                  'Continue?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text('Reset'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppResetUtility.resetAppData(context, ref);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
