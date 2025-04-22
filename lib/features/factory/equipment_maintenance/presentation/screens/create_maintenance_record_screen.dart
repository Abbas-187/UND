import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_model.dart' as factory_equipment;
import '../../domain/providers/equipment_maintenance_provider.dart';
import '../../data/models/maintenance_record_model.dart';
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
    final recordState = ref.watch(maintenanceRecordStateProvider(null));
    final recordNotifier =
        ref.read(maintenanceRecordStateProvider(null).notifier);
    final isLoading = recordState is AsyncLoading;

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
                  value: 'preventive',
                  child: Text('Preventive'),
                ),
                DropdownMenuItem(
                  value: 'corrective',
                  child: Text('Corrective'),
                ),
                DropdownMenuItem(
                  value: 'predictive',
                  child: Text('Predictive'),
                ),
                DropdownMenuItem(
                  value: 'sanitization',
                  child: Text('Sanitization'),
                ),
                DropdownMenuItem(
                  value: 'calibration',
                  child: Text('Calibration'),
                ),
                DropdownMenuItem(
                  value: 'inspection',
                  child: Text('Inspection'),
                ),
                DropdownMenuItem(
                  value: 'replacement',
                  child: Text('Replacement'),
                ),
                DropdownMenuItem(
                  value: 'overhaul',
                  child: Text('Overhaul'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Other'),
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
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                DropdownMenuItem(
                    value: 'inProgress', child: Text('In Progress')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'deferred', child: Text('Deferred')),
                DropdownMenuItem(value: 'delayed', child: Text('Delayed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a status';
                }
                return null;
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
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final record = MaintenanceRecordModel(
                          id: '',
                          equipmentId: widget.equipment.id,
                          equipmentName: widget.equipment.name,
                          equipmentType: widget.equipment.type,
                          scheduledDate: _scheduledDate,
                          completionDate: null,
                          maintenanceType: MaintenanceType.values.firstWhere(
                            (e) =>
                                e.toString().split('.').last ==
                                _maintenanceType,
                            orElse: () => MaintenanceType.other,
                          ),
                          description: _descriptionController.text,
                          status: MaintenanceStatus.values.firstWhere(
                            (e) => e.toString().split('.').last == _status,
                            orElse: () => MaintenanceStatus.scheduled,
                          ),
                          performedById: 'user-1', // Replace with actual user
                          performedByName:
                              'Technician', // Replace with actual user
                          notes: null,
                          partsReplaced: _partsReplaced,
                          downtimeHours: _downtimeHours,
                          metadata: {},
                        );
                        try {
                          await recordNotifier.createRecord(record);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Maintenance record created!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to create record: $e')),
                            );
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Record'),
            ),
          ],
        ),
      ),
    );
  }
}
