import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_model.dart';
import '../../domain/providers/equipment_maintenance_provider.dart';

class AddEditEquipmentScreen extends ConsumerStatefulWidget {
  final EquipmentModel? equipment;
  const AddEditEquipmentScreen({super.key, this.equipment});

  @override
  ConsumerState<AddEditEquipmentScreen> createState() =>
      _AddEditEquipmentScreenState();
}

class _AddEditEquipmentScreenState
    extends ConsumerState<AddEditEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationNameController;
  late TextEditingController _manufacturerController;
  late TextEditingController _modelController;
  late TextEditingController _serialNumberController;
  late DateTime _installDate;
  late int _maintenanceIntervalDays;
  late int _sanitizationIntervalHours;
  late bool _requiresSanitization;

  @override
  void initState() {
    super.initState();
    final e = widget.equipment;
    _nameController = TextEditingController(text: e?.name ?? '');
    _locationNameController =
        TextEditingController(text: e?.locationName ?? '');
    _manufacturerController =
        TextEditingController(text: e?.manufacturer ?? '');
    _modelController = TextEditingController(text: e?.model ?? '');
    _serialNumberController =
        TextEditingController(text: e?.serialNumber ?? '');
    _installDate = e?.installDate ?? DateTime.now();
    _maintenanceIntervalDays = e?.maintenanceIntervalDays ?? 30;
    _sanitizationIntervalHours = e?.sanitizationIntervalHours ?? 24;
    _requiresSanitization = e?.requiresSanitization ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationNameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.equipment != null;
    final equipmentState =
        ref.watch(equipmentStateProvider(widget.equipment?.id));
    final equipmentNotifier =
        ref.read(equipmentStateProvider(widget.equipment?.id).notifier);
    final isLoading = equipmentState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Equipment' : 'Add Equipment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                  labelText: 'Location', border: OutlineInputBorder()),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                  labelText: 'Manufacturer', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                  labelText: 'Model', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serialNumberController,
              decoration: const InputDecoration(
                  labelText: 'Serial Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Maintenance Interval (days)',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              initialValue: _maintenanceIntervalDays.toString(),
              onChanged: (value) =>
                  _maintenanceIntervalDays = int.tryParse(value) ?? 30,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Sanitization Interval (hours)',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              initialValue: _sanitizationIntervalHours.toString(),
              onChanged: (value) =>
                  _sanitizationIntervalHours = int.tryParse(value) ?? 24,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Requires Sanitization'),
              value: _requiresSanitization,
              onChanged: (value) =>
                  setState(() => _requiresSanitization = value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final equipment = EquipmentModel(
                          id: widget.equipment?.id ?? '',
                          name: _nameController.text,
                          type: widget.equipment?.type ?? EquipmentType.other,
                          status: widget.equipment?.status ??
                              EquipmentStatus.operational,
                          locationId: widget.equipment?.locationId ?? '',
                          locationName: _locationNameController.text,
                          manufacturer: _manufacturerController.text,
                          model: _modelController.text,
                          serialNumber: _serialNumberController.text,
                          installDate: _installDate,
                          lastMaintenanceDate:
                              widget.equipment?.lastMaintenanceDate,
                          nextMaintenanceDate:
                              widget.equipment?.nextMaintenanceDate,
                          maintenanceIntervalDays: _maintenanceIntervalDays,
                          responsiblePersonId:
                              widget.equipment?.responsiblePersonId,
                          responsiblePersonName:
                              widget.equipment?.responsiblePersonName,
                          lastSanitizationDate:
                              widget.equipment?.lastSanitizationDate,
                          sanitizationIntervalHours: _sanitizationIntervalHours,
                          requiresSanitization: _requiresSanitization,
                          runningHoursTotal:
                              widget.equipment?.runningHoursTotal ?? 0,
                          runningHoursSinceLastMaintenance: widget
                              .equipment?.runningHoursSinceLastMaintenance,
                          specifications:
                              widget.equipment?.specifications ?? {},
                          metadata: widget.equipment?.metadata ?? {},
                        );
                        try {
                          if (isEdit) {
                            await equipmentNotifier.updateEquipment(equipment);
                          } else {
                            await equipmentNotifier.createEquipment(equipment);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(isEdit
                                      ? 'Equipment updated!'
                                      : 'Equipment added!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEdit ? 'Save Changes' : 'Add Equipment'),
            ),
          ],
        ),
      ),
    );
  }
}
