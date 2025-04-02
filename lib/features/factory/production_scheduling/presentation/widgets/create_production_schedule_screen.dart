import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/production_line_allocation_model.dart';
import '../../data/models/production_schedule_model.dart';
import '../../data/models/production_slot_model.dart';
import '../../../domain/providers/production_scheduling_provider.dart';

class CreateProductionScheduleScreen extends ConsumerStatefulWidget {
  const CreateProductionScheduleScreen({super.key});

  @override
  ConsumerState<CreateProductionScheduleScreen> createState() =>
      _CreateProductionScheduleScreenState();
}

class _CreateProductionScheduleScreenState
    extends ConsumerState<CreateProductionScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _scheduleDate = DateTime.now();
  final List<ProductionLineAllocationModel> _selectedLines = [];
  final List<ProductionSlotModel> _slots = [];

  // For new slot form
  bool _showNewSlotForm = false;
  String? _selectedLineId;
  String? _selectedProductId;
  String _selectedProductName = '';
  final _quantityController = TextEditingController();
  DateTime _slotStartTime = DateTime.now();
  DateTime _slotEndTime = DateTime.now().add(const Duration(hours: 2));

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Production Schedule'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            onPressed: _saveSchedule,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Basic Schedule Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Schedule Name',
                        hintText: 'Enter a name for this schedule',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a schedule name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _scheduleDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );

                        if (selectedDate != null) {
                          setState(() {
                            _scheduleDate = selectedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Schedule Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat.yMMMMd().format(_scheduleDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional notes about this schedule',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Production Lines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Production Lines',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Line'),
                          onPressed: _showAddLineDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedLines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('No production lines added yet'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedLines.length,
                        itemBuilder: (context, index) {
                          final line = _selectedLines[index];
                          return ListTile(
                            title: Text(line.lineName),
                            subtitle: Text('Capacity: ${line.capacity} L/hr'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  _selectedLines.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Production Slots
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Production Slots',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (_selectedLines.isNotEmpty && !_showNewSlotForm)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Slot'),
                            onPressed: () {
                              setState(() {
                                _showNewSlotForm = true;
                                _selectedLineId = _selectedLines.first.lineId;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_showNewSlotForm) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'New Production Slot',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Production Line',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedLineId,
                        items: _selectedLines.map((line) {
                          return DropdownMenuItem<String>(
                            value: line.lineId,
                            child: Text(line.lineName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLineId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a production line';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Product ID',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedProductId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product ID';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // TODO: Show product search dialog
                              setState(() {
                                _selectedProductName = 'Sample Product';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedProductName,
                        onChanged: (value) {
                          setState(() {
                            _selectedProductName = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Planned Quantity (L)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter planned quantity';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateTimeField(
                              label: 'Start Time',
                              value: _slotStartTime,
                              onChanged: (dateTime) {
                                setState(() {
                                  _slotStartTime = dateTime;

                                  // Ensure end time is after start time
                                  if (_slotEndTime.isBefore(_slotStartTime)) {
                                    _slotEndTime = _slotStartTime
                                        .add(const Duration(hours: 2));
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateTimeField(
                              label: 'End Time',
                              value: _slotEndTime,
                              onChanged: (dateTime) {
                                if (dateTime.isAfter(_slotStartTime)) {
                                  setState(() {
                                    _slotEndTime = dateTime;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'End time must be after start time'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showNewSlotForm = false;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _addProductionSlot,
                            child: const Text('Add Slot'),
                          ),
                        ],
                      ),
                    ],
                    if (!_showNewSlotForm) ...[
                      const SizedBox(height: 16),
                      if (_slots.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text('No production slots added yet'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _slots.length,
                          itemBuilder: (context, index) {
                            final slot = _slots[index];
                            final line = _selectedLines.firstWhere(
                              (line) => line.lineId == slot.lineId,
                              orElse: () => _selectedLines.first,
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            slot.productName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          onPressed: () {
                                            setState(() {
                                              _slots.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Line: ${line.lineName}'),
                                    Text('Quantity: ${slot.plannedQuantity} L'),
                                    Text(
                                      'Time: ${DateFormat('HH:mm').format(slot.startTime)} - ${DateFormat('HH:mm').format(slot.endTime)}',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Save Production Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );

        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(value),
          );

          if (time != null) {
            final newDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );

            onChanged(newDateTime);
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          DateFormat('MMM dd, HH:mm').format(value),
        ),
      ),
    );
  }

  void _showAddLineDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String lineName = '';
        String lineId = '';
        double capacity = 100;

        return AlertDialog(
          title: const Text('Add Production Line'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Line ID',
                  hintText: 'Enter unique line ID',
                ),
                onChanged: (value) {
                  lineId = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Line Name',
                  hintText: 'Enter line name',
                ),
                onChanged: (value) {
                  lineName = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Capacity (L/hr)',
                  hintText: 'Enter line capacity',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  capacity = double.tryParse(value) ?? 100;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (lineName.isNotEmpty && lineId.isNotEmpty) {
                  setState(() {
                    _selectedLines.add(
                      ProductionLineAllocationModel(
                        id: const Uuid().v4(),
                        lineId: lineId,
                        lineName: lineName,
                        capacity: capacity,
                        availableTimeBlocks: [
                          TimeBlock(
                            startTime: DateTime(
                              _scheduleDate.year,
                              _scheduleDate.month,
                              _scheduleDate.day,
                              8,
                              0,
                            ),
                            endTime: DateTime(
                              _scheduleDate.year,
                              _scheduleDate.month,
                              _scheduleDate.day,
                              17,
                              0,
                            ),
                            isAllocated: false,
                          ),
                        ],
                        isAvailable: true,
                        metadata: {},
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addProductionSlot() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedLineId == null || _selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a production line and product'),
          ),
        );
        return;
      }

      if (_slotEndTime.isBefore(_slotStartTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
          ),
        );
        return;
      }

      final lineName = _selectedLines
          .firstWhere((line) => line.lineId == _selectedLineId)
          .lineName;

      setState(() {
        _slots.add(
          ProductionSlotModel(
            id: const Uuid().v4(),
            productId: _selectedProductId!,
            productName: _selectedProductName,
            lineId: _selectedLineId!,
            lineName: lineName,
            startTime: _slotStartTime,
            endTime: _slotEndTime,
            plannedQuantity: double.tryParse(_quantityController.text) ?? 0,
            status: SlotStatus.scheduled,
            assignedStaffId: 'unassigned',
            prerequisiteSlotIds: [],
            pasteurizationData: {},
            metadata: {},
          ),
        );

        // Reset form
        _showNewSlotForm = false;
        _quantityController.clear();
        _selectedProductName = '';
      });
    }
  }

  void _saveSchedule() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedLines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one production line'),
          ),
        );
        return;
      }

      if (_slots.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one production slot'),
          ),
        );
        return;
      }

      final newSchedule = ProductionScheduleModel(
        id: const Uuid().v4(),
        name: _nameController.text,
        scheduleDate: _scheduleDate,
        createdDate: DateTime.now(),
        createdBy:
            ref.read(currentUserProvider).valueOrNull?.uid ?? 'anonymous',
        lineAllocations: _selectedLines,
        slots: _slots,
        notes: _notesController.text,
        isActive: true,
        status: ScheduleStatus.draft,
        metadata: {},
      );

      // Save schedule using provider
      ref
          .read(productionSchedulingNotifierProvider.notifier)
          .createSchedule(newSchedule)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Production schedule created successfully'),
          ),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating schedule: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }
}
