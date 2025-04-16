import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

class InventoryTrendsScreen extends ConsumerWidget {
  const InventoryTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryTrends),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock Level Trends
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.stockLevels,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Placeholder for stock level chart
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.notAvailable)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Movement Trends
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.inventoryMovements,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Placeholder for movement trends chart
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.notAvailable)
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Legend for the chart (would be dynamic in a real app)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(context, 'IN', Colors.green),
                          const SizedBox(width: 16),
                          _buildLegendItem(context, 'OUT', Colors.red),
                          const SizedBox(width: 16),
                          _buildLegendItem(context, 'TRANSFER', Colors.blue),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.valueByCategory,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Placeholder for category distribution chart
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pie_chart,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.notAvailable)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
