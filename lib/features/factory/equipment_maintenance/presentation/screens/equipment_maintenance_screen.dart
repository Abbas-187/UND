import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/maintenance_record_model.dart';
import '../../data/repositories/equipment_maintenance_repository.dart';
import '../../domain/providers/equipment_maintenance_provider.dart';
import '../widgets/equipment_status_card.dart';
import '../widgets/maintenance_schedule_card.dart';
import 'create_maintenance_record_screen.dart';

class EquipmentMaintenanceScreen extends ConsumerWidget {
  const EquipmentMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Maintenance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Equipment Maintenance',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
                'Equipment maintenance schedule and records will be displayed here.'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to equipment details (placeholder)
                Navigator.pushNamed(
                  context,
                  '/factory/equipment/details',
                  arguments: {'equipmentId': 'equip-123'},
                );
              },
              child: const Text('View Equipment Details'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Future functionality to add maintenance record
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
