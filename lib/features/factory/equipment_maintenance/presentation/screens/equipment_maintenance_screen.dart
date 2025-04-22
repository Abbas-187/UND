import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/equipment_maintenance_provider.dart';
import '../widgets/maintenance_schedule_card.dart';
import 'add_edit_equipment_screen.dart';
import 'create_maintenance_record_screen.dart';

class EquipmentMaintenanceScreen extends ConsumerWidget {
  const EquipmentMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(allEquipmentProvider);
    final upcomingMaintenanceAsync =
        ref.watch(upcomingMaintenanceRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Equipment',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditEquipmentScreen(),
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
            const Text(
              'All Equipment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            equipmentAsync.when(
              data: (equipmentList) {
                if (equipmentList.isEmpty) {
                  return const Text('No equipment found.');
                }
                return Column(
                  children: equipmentList.map((equipment) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(equipment.name),
                        subtitle: Text(
                            'Type:  ${equipment.type.toString().split('.').last} | Status: ${equipment.status.toString().split('.').last}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Equipment',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditEquipmentScreen(
                                    equipment: equipment),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/factory/equipment/details',
                            arguments: {'equipmentId': equipment.id},
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading equipment: $e'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Upcoming Maintenance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            upcomingMaintenanceAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Text('No upcoming maintenance records.');
                }
                return Column(
                  children: records
                      .map((record) => MaintenanceScheduleCard(record: record))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading maintenance: $e'),
            ),
          ],
        ),
      ),
      floatingActionButton: equipmentAsync.when(
        data: (equipmentList) => equipmentList.isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateMaintenanceRecordScreen(
                          equipment: equipmentList.first),
                    ),
                  );
                },
                child: const Icon(Icons.add),
                tooltip: 'Add Maintenance Record',
              )
            : null,
        loading: () => null,
        error: (e, st) => null,
      ),
    );
  }
}
