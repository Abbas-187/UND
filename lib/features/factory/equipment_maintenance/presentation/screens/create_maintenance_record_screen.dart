import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_model.dart' as factory_equipment;
import '../../data/models/maintenance_models.dart';

class CreateMaintenanceRecordScreen extends ConsumerStatefulWidget {
  const CreateMaintenanceRecordScreen({super.key, required this.equipment});
  final factory_equipment.EquipmentModel equipment;

  @override
  ConsumerState<CreateMaintenanceRecordScreen> createState() =>
      _CreateMaintenanceRecordScreenState();
}

class _CreateMaintenanceRecordScreenState
    extends ConsumerState<CreateMaintenanceRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _scheduledDate = DateTime.now();
  String? _maintenanceType;
  String? _status;
  List<String> _partsReplaced = [];
  double? _downtimeHours;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Maintenance Record'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _maintenanceType,
              decoration: const InputDecoration(
                labelText: 'Maintenance Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Preventive',
                  child: Text('Preventive'),
                ),
                DropdownMenuItem(
                  value: 'Corrective',
                  child: Text('Corrective'),
                ),
                DropdownMenuItem(
                  value: 'Predictive',
                  child: Text('Predictive'),
                ),
                DropdownMenuItem(
                  value: 'Condition-Based',
                  child: Text('Condition-Based'),
                ),
                DropdownMenuItem(
                  value: 'Emergency',
                  child: Text('Emergency'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _maintenanceType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a maintenance type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Scheduled Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller:
                  TextEditingController(text: _scheduledDate.toIso8601String()),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _scheduledDate = selectedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _status = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Parts Replaced',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _partsReplaced = value.split(',');
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Downtime Hours',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _downtimeHours = double.tryParse(value);
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process data
                }
              },
              child: const Text('Create Record'),
            ),
          ],
        ),
      ),
    );
  }
}
