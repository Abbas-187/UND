import 'package:flutter/material.dart';
import '../../domain/models/production_batch_model.dart';

/// Widget that displays detailed information about a production batch
class BatchDetailCard extends StatelessWidget {

  const BatchDetailCard({super.key, required this.batch});
  final ProductionBatchModel batch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Batch #${batch.batchNumber}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(batch.status),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            _buildInfoRow('Product', batch.productName),
            _buildInfoRow('Product ID', batch.productId),
            _buildInfoRow('Target Quantity',
                '${batch.targetQuantity} ${batch.unitOfMeasure}'),
            if (batch.temperature != null)
              _buildInfoRow('Temperature', '${batch.temperature}°C'),
            if (batch.pH != null)
              _buildInfoRow('pH Level', batch.pH.toString()),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo('Created', batch.createdAt),
                if (batch.updatedAt != batch.createdAt)
                  _buildTimeInfo('Updated', batch.updatedAt),
              ],
            ),
            const SizedBox(height: 8.0),
            if (batch.processParameters != null &&
                batch.processParameters!.isNotEmpty)
              _buildProcessParameters(batch.processParameters!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, DateTime dateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),
        ),
        Text(
          _formatDateTime(dateTime),
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessParameters(Map<String, dynamic> parameters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Process Parameters',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 8.0),
        ...parameters.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: _buildInfoRow(
              _formatParameterName(entry.key),
              entry.value.toString(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusChip(BatchStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText;

    switch (status) {
      case BatchStatus.notStarted:
        backgroundColor = Colors.grey;
        statusText = 'Not Started';
      case BatchStatus.inProgress:
        backgroundColor = Colors.blue;
        statusText = 'In Progress';
      case BatchStatus.completed:
        backgroundColor = Colors.green;
        statusText = 'Completed';
      case BatchStatus.failed:
        backgroundColor = Colors.red;
        statusText = 'Failed';
      case BatchStatus.onHold:
        backgroundColor = Colors.amber;
        textColor = Colors.black87;
        statusText = 'On Hold';
    }

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatParameterName(String name) {
    // Convert camelCase or snake_case to Title Case with spaces
    final result = name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .trim();

    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }
}
