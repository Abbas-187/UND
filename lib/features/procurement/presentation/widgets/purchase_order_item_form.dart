import 'package:flutter/material.dart';

import '../../../../utils/formatters/currency_formatter.dart';
import '../../domain/entities/purchase_order.dart';

/// Widget for displaying and editing a purchase order item.
class PurchaseOrderItemForm extends StatefulWidget {

  const PurchaseOrderItemForm({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onRemove,
  });
  final PurchaseOrderItem item;
  final Function(PurchaseOrderItem) onUpdate;
  final VoidCallback onRemove;

  @override
  State<PurchaseOrderItemForm> createState() => _PurchaseOrderItemFormState();
}

class _PurchaseOrderItemFormState extends State<PurchaseOrderItemForm> {
  late TextEditingController _quantityController;
  late DateTime _requiredByDate;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _requiredByDate = widget.item.requiredByDate;
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove item',
                ),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity field
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      suffixText: widget.item.unit,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity =
                          double.tryParse(value) ?? widget.item.quantity;
                      _updateItem(quantity: quantity);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Unit price (read only)
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue:
                        CurrencyFormatter.format(widget.item.unitPrice),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Required by date
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Required By',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_requiredByDate.day}/${_requiredByDate.month}/${_requiredByDate.year}',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Total price (read only)
                Expanded(
                  child: TextFormField(
                    initialValue:
                        CurrencyFormatter.format(widget.item.totalPrice),
                    decoration: const InputDecoration(
                      labelText: 'Total Price',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _updateItem(notes: value.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _requiredByDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _requiredByDate) {
      setState(() {
        _requiredByDate = picked;
      });
      _updateItem(requiredByDate: picked);
    }
  }

  void _updateItem({
    double? quantity,
    DateTime? requiredByDate,
    String? notes,
  }) {
    final updatedQuantity = quantity ?? widget.item.quantity;
    final updatedTotalPrice = updatedQuantity * widget.item.unitPrice;

    final updatedItem = widget.item.copyWith(
      quantity: updatedQuantity,
      totalPrice: updatedTotalPrice,
      requiredByDate: requiredByDate ?? _requiredByDate,
      notes: notes ?? widget.item.notes,
    );

    widget.onUpdate(updatedItem);
  }
}
