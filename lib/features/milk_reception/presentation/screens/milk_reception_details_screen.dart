import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/milk_reception_model.dart';
import '../controllers/milk_reception_controller.dart';
import '../../../../theme/app_theme_extensions.dart';

/// Screen that displays detailed information about a milk reception
class MilkReceptionDetailsScreen extends ConsumerWidget {
  const MilkReceptionDetailsScreen({
    super.key,
    required this.receptionId,
  });

  final String receptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receptionState =
        ref.watch(milkReceptionControllerProvider(receptionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Reception Details'),
      ),
      body: receptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : receptionState.errorMessage != null
              ? Center(child: Text('Error: ${receptionState.errorMessage}'))
              : _buildReceptionDetails(
                  context, ref, receptionState.receptionModel),
    );
  }

  Widget _buildReceptionDetails(
    BuildContext context,
    WidgetRef ref,
    MilkReceptionModel reception,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReceptionHeader(context, reception),
            const SizedBox(height: 24),
            _buildSupplierInfo(context, reception),
            const SizedBox(height: 24),
            _buildMilkInfo(context, reception),
            const SizedBox(height: 24),
            _buildQualityInfo(context, reception),
            const SizedBox(height: 24),
            _buildStatusSection(context, ref, reception),
            const SizedBox(height: 24),
            _buildInventoryCard(context, reception),
          ],
        ),
      ),
    );
  }

  Widget _buildReceptionHeader(
      BuildContext context, MilkReceptionModel reception) {
    final statusColor = _getStatusColor(context, reception.receptionStatus);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Reception #${reception.id}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    _formatReceptionStatus(reception.receptionStatus),
                    style: TextStyle(
                      color: _getTextColorForStatus(context, statusColor),
                    ),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Received on: ${_formatDateTime(reception.timestamp)}',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Received by: ${reception.receivingEmployeeId}',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierInfo(
      BuildContext context, MilkReceptionModel reception) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supplier Information',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Supplier: ${reception.supplierName}',
                style: textTheme.bodyLarge),
            Text('Driver: ${reception.driverName}', style: textTheme.bodyLarge),
            Text('Vehicle: ${reception.vehiclePlate}',
                style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkInfo(BuildContext context, MilkReceptionModel reception) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Milk Information',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Type: ${_formatMilkType(reception.milkType)}',
                style: textTheme.bodyLarge),
            Text('Quantity: ${reception.quantityLiters} liters',
                style: textTheme.bodyLarge),
            Text(
              'Containers: ${reception.containerCount} ${_formatContainerType(reception.containerType)}',
              style: textTheme.bodyLarge,
            ),
            Text('Temperature: ${reception.temperatureAtArrival}°C',
                style: textTheme.bodyLarge),
            if (reception.phValue != null)
              Text('pH: ${reception.phValue}', style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityInfo(BuildContext context, MilkReceptionModel reception) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality Information',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Smell: ${reception.smell}', style: textTheme.bodyLarge),
            Text('Appearance: ${reception.appearance}',
                style: textTheme.bodyLarge),
            Text(
              'Contamination: ${reception.hasVisibleContamination ? 'Yes' : 'No'}',
              style: textTheme.bodyLarge,
            ),
            if (reception.hasVisibleContamination &&
                reception.contaminationDescription != null)
              Text(
                'Contamination details: ${reception.contaminationDescription}',
                style: textTheme.bodyLarge,
              ),
            const SizedBox(height: 8),
            Text('Initial observations: ${reception.initialObservations}',
                style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
      BuildContext context, WidgetRef ref, MilkReceptionModel reception) {
    final textTheme = Theme.of(context).textTheme;
    final buttonStyles = Theme.of(context).extension<CustomButtonStyles>();

    // Only show actions if reception is in pending status
    if (reception.receptionStatus == ReceptionStatus.pendingTesting) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Accept'),
                    style: buttonStyles?.successButton,
                    onPressed: () =>
                        _showFinalizeDialog(context, ref, reception, true),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () =>
                        _showFinalizeDialog(context, ref, reception, false),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // For finalized receptions, just show notes
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notes',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(reception.notes ?? 'No notes available',
                  style: textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }
  }

  void _showFinalizeDialog(
    BuildContext context,
    WidgetRef ref,
    MilkReceptionModel reception,
    bool isAccepting,
  ) {
    final TextEditingController notesController = TextEditingController();
    final buttonStyles = Theme.of(context).extension<CustomButtonStyles>();
    final statusColors = Theme.of(context).extension<StatusColors>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAccepting ? 'Accept Reception' : 'Reject Reception'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAccepting
                  ? 'Are you sure you want to accept this milk reception?'
                  : 'Are you sure you want to reject this milk reception?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: isAccepting
                ? buttonStyles?.successButton
                : ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Finalize reception
              final success = await ref
                  .read(milkReceptionControllerProvider(receptionId).notifier)
                  .finalizeReception(
                    isAccepted: isAccepting,
                    notes: notesController.text,
                  );

              if (success && context.mounted) {
                final backgroundColor = isAccepting
                    ? statusColors?.success ?? Colors.green
                    : Theme.of(context).colorScheme.error;

                final textColor = isAccepting
                    ? statusColors?.onSuccess ?? Colors.white
                    : Theme.of(context).colorScheme.onError;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAccepting
                          ? 'Reception accepted successfully'
                          : 'Reception rejected successfully',
                      style: TextStyle(color: textColor),
                    ),
                    backgroundColor: backgroundColor,
                  ),
                );
              }
            },
            child: Text(isAccepting ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatReceptionStatus(ReceptionStatus status) {
    switch (status) {
      case ReceptionStatus.pendingTesting:
        return 'Pending';
      case ReceptionStatus.accepted:
        return 'Accepted';
      case ReceptionStatus.rejected:
        return 'Rejected';
      default:
        return status.toString().split('.').last;
    }
  }

  String _formatMilkType(MilkType type) {
    switch (type) {
      case MilkType.rawCow:
        return 'Raw Cow Milk';
      case MilkType.rawGoat:
        return 'Raw Goat Milk';
      case MilkType.rawSheep:
        return 'Raw Sheep Milk';
      case MilkType.pasteurizedCow:
        return 'Pasteurized Cow Milk';
      case MilkType.pasteurizedGoat:
        return 'Pasteurized Goat Milk';
      case MilkType.pasteurizedSheep:
        return 'Pasteurized Sheep Milk';
      default:
        return type.toString().split('.').last;
    }
  }

  String _formatContainerType(ContainerType type) {
    switch (type) {
      case ContainerType.aluminumCan:
        return 'Aluminum Cans';
      case ContainerType.steelCan:
        return 'Steel Cans';
      case ContainerType.plasticContainer:
        return 'Plastic Containers';
      case ContainerType.bulk:
        return 'Bulk Container';
      default:
        return type.toString().split('.').last;
    }
  }

  Color _getStatusColor(BuildContext context, ReceptionStatus status) {
    final statusColors = Theme.of(context).extension<StatusColors>();

    switch (status) {
      case ReceptionStatus.pendingTesting:
        return statusColors?.warning ?? Colors.orange;
      case ReceptionStatus.accepted:
        return statusColors?.success ?? Colors.green;
      case ReceptionStatus.rejected:
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColorForStatus(BuildContext context, Color backgroundColor) {
    final statusColors = Theme.of(context).extension<StatusColors>();

    if (backgroundColor == statusColors?.success) {
      return statusColors?.onSuccess ?? Colors.white;
    } else if (backgroundColor == statusColors?.warning) {
      return statusColors?.onWarning ?? Colors.white;
    } else if (backgroundColor == Theme.of(context).colorScheme.error) {
      return Theme.of(context).colorScheme.onError;
    } else {
      return Colors.black;
    }
  }

  Widget _buildInventoryCard(
      BuildContext context, MilkReceptionModel reception) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Information',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${reception.receptionStatus == ReceptionStatus.accepted ? 'Added to inventory' : 'Not in inventory'}',
              style: textTheme.bodyLarge,
            ),
            if (reception.receptionStatus == ReceptionStatus.accepted) ...[
              const SizedBox(height: 4),
              Text('Quantity: ${reception.quantityLiters} liters',
                  style: textTheme.bodyLarge),
              Text('Storage ID: ${reception.id}', style: textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}
