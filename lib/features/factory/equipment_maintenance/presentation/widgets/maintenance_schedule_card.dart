import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../equipment_maintenance/data/models/maintenance_record_model.dart';
import '../../data/models/maintenance_models.dart';

class MaintenanceScheduleCard extends StatelessWidget {
  const MaintenanceScheduleCard({
    super.key,
    required this.record,
    this.onTap,
  });
  final MaintenanceRecordModel record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormatter.format(record.scheduledDate);
    final isOverdue = record.scheduledDate.isBefore(DateTime.now()) &&
        record.status != MaintenanceStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isOverdue ? Colors.red.shade50 : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      record.equipmentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(record.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: isOverdue ? Colors.red : null,
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    const Text(
                      '(OVERDUE)',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.build, size: 16),
                  const SizedBox(width: 8),
                  Text(_formatMaintenanceType(record.maintenanceType)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Assigned to: ${record.performedByName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(MaintenanceStatus status) {
    Color color;
    String text;

    switch (status) {
      case MaintenanceStatus.scheduled:
        color = Colors.blue;
        text = 'Scheduled';
        break;
      case MaintenanceStatus.inProgress:
        color = Colors.orange;
        text = 'In Progress';
        break;
      case MaintenanceStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case MaintenanceStatus.deferred:
        color = Colors.amber;
        text = 'Deferred';
        break;
      case MaintenanceStatus.delayed:
        color = Colors.deepOrange;
        text = 'Delayed';
        break;
      case MaintenanceStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case MaintenanceStatus.pending:
        color = Colors.grey;
        text = 'Pending';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatMaintenanceType(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventive Maintenance';
      case MaintenanceType.corrective:
        return 'Corrective Maintenance';
      case MaintenanceType.predictive:
        return 'Predictive Maintenance';
      case MaintenanceType.sanitization:
        return 'Sanitization';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.calibration:
        return 'Calibration';
      case MaintenanceType.replacement:
        return 'Part Replacement';
      case MaintenanceType.overhaul:
        return 'Overhaul';
      case MaintenanceType.other:
        return 'Other';
    }
  }
}
