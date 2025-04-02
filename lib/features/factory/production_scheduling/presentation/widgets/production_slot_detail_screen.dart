import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/production_slot_model.dart';
import '../../../domain/providers/production_scheduling_provider.dart';

class ProductionSlotDetailScreen extends ConsumerWidget {
  const ProductionSlotDetailScreen({
    Key? key,
    required this.slot,
    required this.scheduleId,
  }) : super(key: key);

  final ProductionSlotModel slot;
  final String scheduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Production Slot: ${slot.productName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit slot screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildStatusIndicator(slot.status),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${_formatStatus(slot.status)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<SlotStatus>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (SlotStatus newStatus) {
                        // Call provider to update status
                        ref
                            .read(productionSchedulingNotifierProvider.notifier)
                            .updateSlotStatus(scheduleId, slot.id, newStatus)
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Status updated to ${_formatStatus(newStatus)}'),
                            ),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating status: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return SlotStatus.values
                            .where((status) => status != slot.status)
                            .map((SlotStatus status) {
                          return PopupMenuItem<SlotStatus>(
                            value: status,
                            child: Text(_formatStatus(status)),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Product Information
            _buildSectionCard(
              context,
              'Product Information',
              [
                _buildInfoRow('Product ID', slot.productId),
                _buildInfoRow('Product Name', slot.productName),
                _buildInfoRow('Planned Quantity', '${slot.plannedQuantity}'),
                if (slot.recipeId != null)
                  _buildInfoRow('Recipe ID', slot.recipeId!),
                if (slot.recipeVersion != null)
                  _buildInfoRow('Recipe Version', slot.recipeVersion!),
              ],
            ),

            // Time & Location Information
            _buildSectionCard(
              context,
              'Time & Location',
              [
                _buildInfoRow('Production Line', slot.lineName),
                _buildInfoRow('Start Time',
                    '${dateFormat.format(slot.startTime)} at ${timeFormat.format(slot.startTime)}'),
                _buildInfoRow('End Time',
                    '${dateFormat.format(slot.endTime)} at ${timeFormat.format(slot.endTime)}'),
                _buildInfoRow('Duration',
                    '${slot.endTime.difference(slot.startTime).inHours} hr ${slot.endTime.difference(slot.startTime).inMinutes % 60} min'),
              ],
            ),

            // Assignment & Prerequisites
            _buildSectionCard(
              context,
              'Assignment & Dependencies',
              [
                _buildInfoRow('Assigned Staff', slot.assignedStaffId),
                if (slot.prerequisiteSlotIds.isNotEmpty)
                  _buildInfoRow(
                      'Prerequisites', slot.prerequisiteSlotIds.join(', ')),
              ],
            ),

            // Pasteurization Data (if applicable)
            if (slot.pasteurizationData.isNotEmpty)
              _buildSectionCard(
                context,
                'Pasteurization Data',
                slot.pasteurizationData.entries
                    .map((entry) =>
                        _buildInfoRow(entry.key, entry.value.toString()))
                    .toList(),
              ),

            // Comments
            if (slot.comments != null && slot.comments!.isNotEmpty)
              _buildSectionCard(
                context,
                'Comments',
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(slot.comments!),
                  ),
                ],
              ),

            // Action Buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  Icons.play_arrow,
                  'Start',
                  slot.status == SlotStatus.scheduled,
                  Colors.green,
                  () {
                    // Start production
                    if (slot.status == SlotStatus.scheduled) {
                      ref
                          .read(productionSchedulingNotifierProvider.notifier)
                          .updateSlotStatus(
                              scheduleId, slot.id, SlotStatus.inProgress);
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.pause,
                  'Pause',
                  slot.status == SlotStatus.inProgress,
                  Colors.orange,
                  () {
                    // Pause production
                    if (slot.status == SlotStatus.inProgress) {
                      ref
                          .read(productionSchedulingNotifierProvider.notifier)
                          .updateSlotStatus(
                              scheduleId, slot.id, SlotStatus.delayed);
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.check,
                  'Complete',
                  slot.status == SlotStatus.inProgress ||
                      slot.status == SlotStatus.inPreparation,
                  Colors.blue,
                  () {
                    // Complete production
                    if (slot.status == SlotStatus.inProgress ||
                        slot.status == SlotStatus.inPreparation) {
                      ref
                          .read(productionSchedulingNotifierProvider.notifier)
                          .updateSlotStatus(
                              scheduleId, slot.id, SlotStatus.completed);
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.cancel,
                  'Cancel',
                  slot.status != SlotStatus.completed &&
                      slot.status != SlotStatus.cancelled,
                  Colors.red,
                  () {
                    // Cancel production
                    if (slot.status != SlotStatus.completed &&
                        slot.status != SlotStatus.cancelled) {
                      ref
                          .read(productionSchedulingNotifierProvider.notifier)
                          .updateSlotStatus(
                              scheduleId, slot.id, SlotStatus.cancelled);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(SlotStatus status) {
    final Color color;

    switch (status) {
      case SlotStatus.scheduled:
        color = Colors.blue;
        break;
      case SlotStatus.inPreparation:
        color = Colors.orange;
        break;
      case SlotStatus.inProgress:
        color = Colors.green;
        break;
      case SlotStatus.completed:
        color = Colors.purple;
        break;
      case SlotStatus.cancelled:
        color = Colors.red;
        break;
      case SlotStatus.delayed:
        color = Colors.amber;
        break;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatStatus(SlotStatus status) {
    switch (status) {
      case SlotStatus.scheduled:
        return 'Scheduled';
      case SlotStatus.inPreparation:
        return 'In Preparation';
      case SlotStatus.inProgress:
        return 'In Progress';
      case SlotStatus.completed:
        return 'Completed';
      case SlotStatus.cancelled:
        return 'Cancelled';
      case SlotStatus.delayed:
        return 'Delayed';
    }
  }

  Widget _buildSectionCard(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isEnabled,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade500,
      ),
      onPressed: isEnabled ? onPressed : null,
    );
  }
}
