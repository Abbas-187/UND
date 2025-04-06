import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/milk_reception_model.dart';
import '../controllers/milk_reception_controller.dart';

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
    final statusColor = _getStatusColor(reception.receptionStatus);

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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    _formatReceptionStatus(reception.receptionStatus),
                    style: TextStyle(
                      color: statusColor == Colors.grey
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Received on: ${_formatDateTime(reception.timestamp)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Received by: ${reception.receivingEmployeeId}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierInfo(
      BuildContext context, MilkReceptionModel reception) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supplier Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Supplier: ${reception.supplierName}'),
            Text('Driver: ${reception.driverName}'),
            Text('Vehicle: ${reception.vehiclePlate}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkInfo(BuildContext context, MilkReceptionModel reception) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Milk Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Type: ${_formatMilkType(reception.milkType)}'),
            Text('Quantity: ${reception.quantityLiters} liters'),
            Text(
                'Containers: ${reception.containerCount} ${_formatContainerType(reception.containerType)}'),
            Text('Temperature: ${reception.temperatureAtArrival}°C'),
            if (reception.phValue != null) Text('pH: ${reception.phValue}'),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityInfo(BuildContext context, MilkReceptionModel reception) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quality Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Smell: ${reception.smell}'),
            Text('Appearance: ${reception.appearance}'),
            Text(
                'Contamination: ${reception.hasVisibleContamination ? 'Yes' : 'No'}'),
            if (reception.hasVisibleContamination &&
                reception.contaminationDescription != null)
              Text(
                  'Contamination details: ${reception.contaminationDescription}'),
            const SizedBox(height: 8),
            Text('Initial observations: ${reception.initialObservations}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
      BuildContext context, WidgetRef ref, MilkReceptionModel reception) {
    // Only show actions if reception is in pending status
    if (reception.receptionStatus == ReceptionStatus.pendingTesting) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () =>
                        _showFinalizeDialog(context, ref, reception, true),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(reception.notes ?? 'No notes available'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccepting ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAccepting
                          ? 'Reception accepted successfully'
                          : 'Reception rejected successfully',
                    ),
                    backgroundColor: isAccepting ? Colors.green : Colors.red,
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

  Color _getStatusColor(ReceptionStatus status) {
    switch (status) {
      case ReceptionStatus.pendingTesting:
        return Colors.orange;
      case ReceptionStatus.accepted:
        return Colors.green;
      case ReceptionStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInventoryCard(
      BuildContext context, MilkReceptionModel reception) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
                'Status: ${reception.receptionStatus == ReceptionStatus.accepted ? 'Added to inventory' : 'Not in inventory'}'),
            if (reception.receptionStatus == ReceptionStatus.accepted) ...[
              const SizedBox(height: 4),
              Text('Quantity: ${reception.quantityLiters} liters'),
              Text('Storage ID: ${reception.id}'),
            ],
          ],
        ),
      ),
    );
  }
}
