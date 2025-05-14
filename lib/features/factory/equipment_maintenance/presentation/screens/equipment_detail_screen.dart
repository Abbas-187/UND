import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/widgets/detail_appbar.dart';
import '../../domain/providers/equipment_maintenance_provider.dart';
import '../screens/create_maintenance_record_screen.dart';
import '../widgets/maintenance_schedule_card.dart';
import 'add_edit_equipment_screen.dart';
import 'maintenance_record_detail_screen.dart';

class EquipmentDetailScreen extends ConsumerWidget {
  const EquipmentDetailScreen({
    super.key,
    required this.equipmentId,
  });

  final String equipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(equipmentProvider(equipmentId));
    final recordsAsync =
        ref.watch(equipmentMaintenanceRecordsProvider(equipmentId));

    return Scaffold(
      appBar: DetailAppBar(
        title: 'Equipment Details',
        actions: [
          equipmentAsync.when(
            data: (equipment) => equipment == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Equipment',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditEquipmentScreen(equipment: equipment),
                        ),
                      );
                    },
                  ),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            equipmentAsync.when(
              data: (equipment) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${equipment.type.toString().split('.').last}'),
                    Text(
                        'Status: ${equipment.status.toString().split('.').last}'),
                    Text('Location: ${equipment.locationName}'),
                    Text('Manufacturer: ${equipment.manufacturer}'),
                    Text('Model: ${equipment.model}'),
                    Text('Serial Number: ${equipment.serialNumber}'),
                    Text(
                        'Installed: ${equipment.installDate.toLocal().toString().split(' ')[0]}'),
                    if (equipment.lastMaintenanceDate != null)
                      Text(
                          'Last Maintenance: ${equipment.lastMaintenanceDate!.toLocal().toString().split(' ')[0]}'),
                    if (equipment.nextMaintenanceDate != null)
                      Text(
                          'Next Maintenance: ${equipment.nextMaintenanceDate!.toLocal().toString().split(' ')[0]}'),
                    Text(
                        'Maintenance Interval: ${equipment.maintenanceIntervalDays} days'),
                    if (equipment.responsiblePersonName != null)
                      Text('Responsible: ${equipment.responsiblePersonName}'),
                    if (equipment.lastSanitizationDate != null)
                      Text(
                          'Last Sanitization: ${equipment.lastSanitizationDate!.toLocal().toString().split(' ')[0]}'),
                    Text(
                        'Sanitization Interval: ${equipment.sanitizationIntervalHours} hours'),
                    Text(
                        'Requires Sanitization: ${equipment.requiresSanitization ? "Yes" : "No"}'),
                    Text('Running Hours: ${equipment.runningHoursTotal}'),
                    if (equipment.runningHoursSinceLastMaintenance != null)
                      Text(
                          'Hours Since Last Maintenance: ${equipment.runningHoursSinceLastMaintenance}'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateMaintenanceRecordScreen(
                                equipment: equipment),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Maintenance Record'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading equipment: $e'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Maintenance History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Text('No maintenance records found.');
                }
                return Column(
                  children: records
                      .map((record) => GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MaintenanceRecordDetailScreen(
                                      record: record),
                                ),
                              );
                            },
                            child: MaintenanceScheduleCard(record: record),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading records: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
