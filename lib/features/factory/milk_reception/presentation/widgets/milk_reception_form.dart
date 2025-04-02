import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/milk_reception_model.dart';
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
  final _quantityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _fatController = TextEditingController();
  final _proteinController = TextEditingController();
  final _notesController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final ReceptionStatus _selectedStatus = ReceptionStatus.received;
  MilkType _selectedMilkType = MilkType.cow;
  bool _isOrganic = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _supplierNameController.dispose();
    _supplierIdController.dispose();
    _quantityController.dispose();
    _temperatureController.dispose();
    _fatController.dispose();
    _proteinController.dispose();
    _notesController.dispose();
    _batchNumberController.dispose();
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
        receptionDate: DateTime.now(),
        supplierId: _supplierIdController.text,
        supplierName: _supplierNameController.text,
        quantityLiters: double.parse(_quantityController.text),
        temperatureCelsius: double.parse(_temperatureController.text),
        milkType: _selectedMilkType,
        receivedBy: '', // Will be set by repository
        status: _selectedStatus,
        testResults: [], // Initial empty tests
        fatPercentage: double.parse(_fatController.text),
        proteinPercentage: double.parse(_proteinController.text),
        notes: _notesController.text,
        organicCertified: _isOrganic,
        batchNumber: _batchNumberController.text.isNotEmpty
            ? _batchNumberController.text
            : null,
        metadata: {},
      );

      final receptionId = await ref
          .read(milkReceptionStateProvider(null).notifier)
          .createReception(
            reception,
          );

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
        _quantityController.clear();
        _temperatureController.clear();
        _fatController.clear();
        _proteinController.clear();
        _notesController.clear();
        _batchNumberController.clear();
        setState(() {
          _selectedMilkType = MilkType.cow;
          _isOrganic = false;
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
                              child: Text(type.name),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      if (value != null) {
                        _selectedMilkType = value;
                      }
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity (L)',
                            border: OutlineInputBorder(),
                            suffixText: 'L',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            if (double.tryParse(value) == null) {
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
                            suffixText: '°C',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter temperature';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _fatController,
                          decoration: const InputDecoration(
                            labelText: 'Fat (%)',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter fat %';
                            }
                            final fat = double.tryParse(value);
                            if (fat == null || fat < 0 || fat > 15) {
                              return 'Please enter a valid number (0-15)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _proteinController,
                          decoration: const InputDecoration(
                            labelText: 'Protein (%)',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter protein %';
                            }
                            final protein = double.tryParse(value);
                            if (protein == null ||
                                protein < 0 ||
                                protein > 10) {
                              return 'Please enter a valid number (0-10)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _batchNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Organic Certified'),
                    value: _isOrganic,
                    onChanged: (value) {
                      setState(() {
                        _isOrganic = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Record Milk Reception'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
