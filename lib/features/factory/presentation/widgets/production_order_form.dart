import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/production_order_model.dart';

class ProductionOrderForm extends StatefulWidget {
  const ProductionOrderForm({
    super.key,
    this.initialValue,
    required this.onSubmit,
    this.isEditing = false,
  });
  final ProductionOrderModel? initialValue;
  final Function(ProductionOrderModel) onSubmit;
  final bool isEditing;

  @override
  State<ProductionOrderForm> createState() => _ProductionOrderFormState();
}

class _ProductionOrderFormState extends State<ProductionOrderForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  late TextEditingController _orderNumberController;
  late TextEditingController _productIdController;
  late TextEditingController _productNameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late DateTime _scheduledDate;
  late DateTime _dueDate;
  late String _status;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values or defaults
    _orderNumberController = TextEditingController(
      text: widget.initialValue?.orderNumber ?? 'PO-',
    );
    _productIdController = TextEditingController(
      text: widget.initialValue?.productId ?? '',
    );
    _productNameController = TextEditingController(
      text: widget.initialValue?.productName ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.initialValue?.quantity.toString() ?? '',
    );
    _unitController = TextEditingController(
      text: widget.initialValue?.unit ?? 'kg',
    );
    _scheduledDate = widget.initialValue?.scheduledDate ?? DateTime.now();
    _dueDate = widget.initialValue?.dueDate ??
        DateTime.now().add(const Duration(days: 7));
    _status = widget.initialValue?.status ?? 'pending';
    _notesController = TextEditingController(
      text: widget.initialValue?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _productIdController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateDates() {
    if (_scheduledDate.isAfter(_dueDate)) {
      return 'Scheduled date cannot be after due date';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _orderNumberController,
              decoration: const InputDecoration(
                labelText: 'Order Number',
                hintText: 'Enter order number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an order number';
                }
                if (!value.startsWith('PO-')) {
                  return 'Order number must start with PO-';
                }
                return null;
              },
              enabled:
                  !widget.isEditing, // Can't change order number when editing
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productIdController,
                    decoration: const InputDecoration(
                      labelText: 'Product ID',
                      hintText: 'Enter product ID',
                    ),
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
                  onPressed: _selectProduct,
                  tooltip: 'Select Product',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'Enter product name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter quantity',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final quantity = double.tryParse(value);
                      if (quantity == null) {
                        return 'Please enter a valid number';
                      }
                      if (quantity <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'e.g., kg, pcs',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter unit';
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
                  child: _buildDateField(
                    label: 'Scheduled Date',
                    value: _scheduledDate,
                    onChanged: (date) {
                      setState(() {
                        _scheduledDate = date;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'Due Date',
                    value: _dueDate,
                    onChanged: (date) {
                      setState(() {
                        _dueDate = date;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_validateDates() != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _validateDates()!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12.0,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (widget.isEditing)
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'confirmed', child: Text('Confirmed')),
                  DropdownMenuItem(
                      value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(
                      value: 'cancelled', child: Text('Cancelled')),
                  DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _status = newValue;
                    });
                  }
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter additional notes',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(widget.isEditing
                  ? 'Update Production Order'
                  : 'Create Production Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && picked != value) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_dateFormat.format(value)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _selectProduct() async {
    try {
      // TODO: Implement product selection
      // This would typically open a dialog or navigate to a product selection screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Product selection will be implemented in future updates'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting product: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _validateDates() == null) {
      try {
        final quantity = double.tryParse(_quantityController.text);
        if (quantity == null) {
          throw Exception('Invalid quantity value');
        }

        final order = ProductionOrderModel(
          id: widget.initialValue?.id,
          orderNumber: _orderNumberController.text,
          productId: _productIdController.text,
          productName: _productNameController.text,
          quantity: quantity,
          unit: _unitController.text,
          scheduledDate: _scheduledDate,
          dueDate: _dueDate,
          status: _status,
          assignedToUserId: widget.initialValue?.assignedToUserId,
          startTime: widget.initialValue?.startTime,
          endTime: widget.initialValue?.endTime,
          relatedSalesOrderIds: widget.initialValue?.relatedSalesOrderIds,
          notes: _notesController.text,
          createdAt: widget.initialValue?.createdAt ?? DateTime.now(),
          createdByUserId: widget.initialValue?.createdByUserId,
          updatedAt: widget.isEditing ? DateTime.now() : null,
        );

        widget.onSubmit(order);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting form: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
