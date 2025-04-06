import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/milk_reception_model.dart';
import '../../domain/providers/milk_reception_provider.dart';

class MilkReceptionForm extends ConsumerStatefulWidget {
  const MilkReceptionForm({super.key});

  @override
  ConsumerState<MilkReceptionForm> createState() => _MilkReceptionFormState();
}

class _MilkReceptionFormState extends ConsumerState<MilkReceptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _supplierIdController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _observationsController = TextEditingController();
  final _notesController = TextEditingController();

  MilkType _selectedMilkType = MilkType.rawCow;
  ContainerType _selectedContainerType = ContainerType.aluminumCan;
  int _containerCount = 1;
  bool _hasVisibleContamination = false;
  String _appearance = 'Normal';
  String _smell = 'Normal';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _supplierNameController.dispose();
    _supplierIdController.dispose();
    _driverNameController.dispose();
    _vehiclePlateController.dispose();
    _quantityController.dispose();
    _temperatureController.dispose();
    _observationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reception = MilkReceptionModel(
        id: '', // Will be assigned by Firebase
        timestamp: DateTime.now(),
        supplierId: _supplierIdController.text,
        supplierName: _supplierNameController.text,
        driverName: _driverNameController.text,
        vehiclePlate: _vehiclePlateController.text,
        quantityLiters: double.parse(_quantityController.text),
        temperatureAtArrival: double.parse(_temperatureController.text),
        milkType: _selectedMilkType,
        containerType: _selectedContainerType,
        containerCount: _containerCount,
        initialObservations: _observationsController.text,
        receptionStatus: ReceptionStatus.pendingTesting,
        receivingEmployeeId: '', // Will be set by the system
        smell: _smell,
        appearance: _appearance,
        hasVisibleContamination: _hasVisibleContamination,
        contaminationDescription:
            _hasVisibleContamination ? _notesController.text : null,
        notes: !_hasVisibleContamination ? _notesController.text : null,
      );

      final receptionId =
          await ref.read(createMilkReceptionProvider(reception).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Milk reception recorded: $receptionId'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _supplierNameController.clear();
        _supplierIdController.clear();
        _driverNameController.clear();
        _vehiclePlateController.clear();
        _quantityController.clear();
        _temperatureController.clear();
        _observationsController.clear();
        _notesController.clear();
        setState(() {
          _selectedMilkType = MilkType.rawCow;
          _selectedContainerType = ContainerType.aluminumCan;
          _containerCount = 1;
          _hasVisibleContamination = false;
          _appearance = 'Normal';
          _smell = 'Normal';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Milk Reception',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Supplier Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supplier Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _supplierNameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _supplierIdController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier ID';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Transport Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transport Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _driverNameController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter driver name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehiclePlateController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Plate',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle plate';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Milk Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Milk Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MilkType>(
                    decoration: const InputDecoration(
                      labelText: 'Milk Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMilkType,
                    items: MilkType.values
                        .map((type) => DropdownMenuItem<MilkType>(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMilkType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity (Liters)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            try {
                              final quantity = double.parse(value);
                              if (quantity <= 0) {
                                return 'Quantity must be positive';
                              }
                            } catch (e) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _temperatureController,
                          decoration: const InputDecoration(
                            labelText: 'Temperature (°C)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter temperature';
                            }
                            try {
                              double.parse(value);
                            } catch (e) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit Reception'),
            ),
          ),
        ],
      ),
    );
  }
}
