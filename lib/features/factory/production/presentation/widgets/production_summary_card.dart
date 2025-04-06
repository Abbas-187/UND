import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/routes/app_router.dart';

class ProductionSummaryCard extends ConsumerWidget {
  const ProductionSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // In a real app, this data would come from providers
    final completedToday = 12;
    final inProgress = 3;
    final pendingApproval = 5;
    final oeeValue = 87.5; // Overall Equipment Effectiveness
    final targetCompletion = 15;
    final completionPercentage = (completedToday / targetCompletion) * 100;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Production Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, AppRoutes.productionExecutions);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // OEE (Overall Equipment Effectiveness) Indicator
            _buildProgressIndicator(
              context,
              'OEE',
              oeeValue,
              100,
              Colors.blue,
              suffix: '%',
            ),

            const SizedBox(height: 16),

            // Production Completion Indicator
            _buildProgressIndicator(
              context,
              'Production Completion',
              completedToday.toDouble(),
              targetCompletion.toDouble(),
              Colors.green,
              valueText: '$completedToday/$targetCompletion',
            ),

            const SizedBox(height: 16),

            // Production Status Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusItem(
                  context,
                  'Completed Today',
                  completedToday.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatusItem(
                  context,
                  'In Progress',
                  inProgress.toString(),
                  Icons.autorenew,
                  Colors.orange,
                ),
                _buildStatusItem(
                  context,
                  'Pending Approval',
                  pendingApproval.toString(),
                  Icons.pending_actions,
                  Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                      context, AppRoutes.createProductionExecution);
                },
                icon: const Icon(Icons.add),
                label: const Text('Start New Production'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    String label,
    double value,
    double maxValue,
    Color color, {
    String? valueText,
    String suffix = '',
  }) {
    final theme = Theme.of(context);
    final percentage = (value / maxValue) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              valueText ?? '${value.toStringAsFixed(1)}$suffix',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
