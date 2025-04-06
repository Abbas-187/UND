import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/error_view.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../domain/models/production_batch_model.dart';
import '../providers/production_batch_providers.dart';
import '../widgets/batch_detail_card.dart';
import '../widgets/process_parameters_form.dart';

/// Screen for tracking a production batch in real-time
class BatchTrackingScreen extends ConsumerWidget {

  const BatchTrackingScreen({super.key, required this.batchId});
  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchAsync = ref.watch(watchBatchProvider(batchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(watchBatchProvider(batchId)),
          ),
        ],
      ),
      body: batchAsync.when(
        data: (batch) => _buildBatchTrackingView(context, ref, batch),
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorView(
          error: error.toString(),
          onRetry: () => ref.refresh(watchBatchProvider(batchId)),
        ),
      ),
    );
  }

  Widget _buildBatchTrackingView(
      BuildContext context, WidgetRef ref, ProductionBatchModel batch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Batch information card
          BatchDetailCard(batch: batch),

          const SizedBox(height: 16.0),

          // Status controls
          _buildStatusControls(context, ref, batch),

          const SizedBox(height: 16.0),

          // Process parameters form
          if (batch.status == BatchStatus.inProgress)
            ProcessParametersForm(batchId: batchId),

          const SizedBox(height: 16.0),

          // Progress tracking
          _buildProgressTracking(batch),

          const SizedBox(height: 16.0),

          // Quality control button
          if (batch.status == BatchStatus.inProgress)
            ElevatedButton.icon(
              icon: const Icon(Icons.checklist),
              label: const Text('Record Quality Check'),
              onPressed: () => _navigateToQualityControl(context, batch),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusControls(
      BuildContext context, WidgetRef ref, ProductionBatchModel batch) {
    switch (batch.status) {
      case BatchStatus.notStarted:
        return ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Batch Process'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _startBatch(context, ref),
        );

      case BatchStatus.inProgress:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showCompleteBatchDialog(context, ref),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.dangerous),
                label: const Text('Fail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showFailBatchDialog(context, ref),
              ),
            ),
          ],
        );

      case BatchStatus.completed:
        return Card(
          color: Colors.green[50],
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8.0),
                Text(
                  'Batch Completed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );

      case BatchStatus.failed:
        return Card(
          color: Colors.red[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dangerous, color: Colors.red),
                    SizedBox(width: 8.0),
                    Text(
                      'Batch Failed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                if (batch.notes != null) ...[
                  const SizedBox(height: 8.0),
                  Text('Reason: ${batch.notes}'),
                ],
              ],
            ),
          ),
        );

      case BatchStatus.onHold:
        return ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Resume Batch Process'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _startBatch(context, ref),
        );
    }
  }

  Widget _buildProgressTracking(ProductionBatchModel batch) {
    final hasStartTime = batch.startTime != null;
    final hasEndTime = batch.endTime != null;
    final hasActualQuantity = batch.actualQuantity != null;

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Tracking',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Timeline
            Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  color: hasStartTime ? Colors.green : Colors.grey,
                  size: 16.0,
                ),
                Expanded(
                  child: Container(
                    height: 2.0,
                    color:
                        hasStartTime && hasEndTime ? Colors.green : Colors.grey,
                  ),
                ),
                Icon(
                  Icons.fiber_manual_record,
                  color: hasEndTime ? Colors.green : Colors.grey,
                  size: 16.0,
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            // Start and end times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start: ${hasStartTime ? _formatDateTime(batch.startTime!) : "Not started"}',
                  style: TextStyle(
                    color: hasStartTime ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  'End: ${hasEndTime ? _formatDateTime(batch.endTime!) : "Not complete"}',
                  style: TextStyle(
                    color: hasEndTime ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16.0),

            // Production quantities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target: ${batch.targetQuantity} ${batch.unitOfMeasure}'),
                Text(
                  'Actual: ${hasActualQuantity ? '${batch.actualQuantity} ${batch.unitOfMeasure}' : "N/A"}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasActualQuantity ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),

            if (hasActualQuantity && batch.targetQuantity > 0) ...[
              const SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: batch.actualQuantity! / batch.targetQuantity,
                backgroundColor: Colors.grey[200],
                color: _getYieldColor(
                    batch.actualQuantity! / batch.targetQuantity),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Yield: ${(batch.actualQuantity! / batch.targetQuantity * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startBatch(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Start'),
        content:
            const Text('Are you sure you want to start this batch process?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmStartBatch(ref);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _confirmStartBatch(WidgetRef ref) {
    ref.read(startBatchProvider(batchId));
  }

  void _showCompleteBatchDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Batch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the actual quantity produced:'),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Actual Quantity',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              final quantity = double.tryParse(quantityController.text);
              if (quantity != null) {
                _completeBatch(ref, quantity);
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _completeBatch(WidgetRef ref, double actualQuantity) {
    final params = CompleteBatchParams(
      batchId: batchId,
      actualQuantity: actualQuantity,
    );

    ref.read(completeBatchProvider(params));
  }

  void _showFailBatchDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fail Batch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the reason for batch failure:'),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Failure Reason',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);

              if (reasonController.text.isNotEmpty) {
                _failBatch(ref, reasonController.text);
              }
            },
            child: const Text('Mark as Failed'),
          ),
        ],
      ),
    );
  }

  void _failBatch(WidgetRef ref, String reason) {
    final params = FailBatchParams(
      batchId: batchId,
      reason: reason,
    );

    ref.read(failBatchProvider(params));
  }

  void _navigateToQualityControl(
      BuildContext context, ProductionBatchModel batch) {
    // Navigate to quality control screen
    // Implementation will depend on your routing system
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getYieldColor(double yieldRatio) {
    if (yieldRatio >= 0.95) return Colors.green;
    if (yieldRatio >= 0.8) return Colors.amber;
    return Colors.red;
  }
}
