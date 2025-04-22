import 'package:flutter/material.dart';
import '../../data/models/maintenance_record_model.dart';
import 'edit_maintenance_record_screen.dart';

class MaintenanceRecordDetailScreen extends StatelessWidget {
  final MaintenanceRecordModel record;
  const MaintenanceRecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Record Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMaintenanceRecordScreen(record: record),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Equipment: ${record.equipmentName}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Type: ${record.equipmentType.toString().split('.').last}'),
            Text('Scheduled: ${record.scheduledDate.toLocal()}'),
            if (record.completionDate != null)
              Text('Completed: ${record.completionDate!.toLocal()}'),
            Text('Type: ${record.maintenanceType.toString().split('.').last}'),
            Text('Status: ${record.status.toString().split('.').last}'),
            Text('Performed By: ${record.performedByName}'),
            if (record.notes != null) Text('Notes: ${record.notes}'),
            if (record.partsReplaced != null &&
                record.partsReplaced!.isNotEmpty)
              Text('Parts Replaced: ${record.partsReplaced!.join(", ")}'),
            if (record.downtimeHours != null)
              Text('Downtime Hours: ${record.downtimeHours}'),
            const SizedBox(height: 16),
            Text('Description:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(record.description),
          ],
        ),
      ),
    );
  }
}
