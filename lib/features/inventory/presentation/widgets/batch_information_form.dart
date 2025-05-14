import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Form widget for capturing batch/lot information, production date, and expiration date
class BatchInformationForm extends StatelessWidget {
  const BatchInformationForm({
    super.key,
    this.batchLotNumber,
    this.productionDate,
    this.expirationDate,
    required this.onBatchLotNumberChanged,
    required this.onProductionDateChanged,
    required this.onExpirationDateChanged,
    this.isRequired = false,
  });

  final String? batchLotNumber;
  final DateTime? productionDate;
  final DateTime? expirationDate;
  final Function(String?) onBatchLotNumberChanged;
  final Function(DateTime?) onProductionDateChanged;
  final Function(DateTime?) onExpirationDateChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MM/dd/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch Information',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Batch/Lot Number
        TextFormField(
          initialValue: batchLotNumber,
          decoration: InputDecoration(
            labelText: 'Batch/Lot Number${isRequired ? ' *' : ''}',
            hintText: 'Enter batch or lot number',
            border: const OutlineInputBorder(),
          ),
          onChanged: onBatchLotNumberChanged,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Please enter a batch/lot number';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Production Date
        InkWell(
          onTap: () => _selectDate(
            context,
            productionDate,
            onProductionDateChanged,
            'Production Date',
            DateTime(2000),
            DateTime.now(),
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Production Date${isRequired ? ' *' : ''}',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              productionDate != null
                  ? dateFormat.format(productionDate!)
                  : 'Select production date',
            ),
          ),
        ),

        if (isRequired && productionDate == null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Text(
              'Production date is required',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12.0,
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Expiration Date
        InkWell(
          onTap: () => _selectDate(
            context,
            expirationDate,
            onExpirationDateChanged,
            'Expiration Date',
            DateTime.now(),
            DateTime(2100),
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Expiration Date${isRequired ? ' *' : ''}',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              expirationDate != null
                  ? dateFormat.format(expirationDate!)
                  : 'Select expiration date',
            ),
          ),
        ),

        if (isRequired && expirationDate == null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Text(
              'Expiration date is required',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12.0,
              ),
            ),
          ),

        // Warning if production date is after expiration date
        if (productionDate != null &&
            expirationDate != null &&
            productionDate!.isAfter(expirationDate!))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Warning: Production date is after expiration date',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12.0,
              ),
            ),
          ),

        // Calculate shelf life if both dates are set
        if (productionDate != null && expirationDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Shelf Life: ${expirationDate!.difference(productionDate!).inDays} days',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onDateChanged,
    String title,
    DateTime firstDate,
    DateTime lastDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: title,
    );

    if (picked != null && (initialDate == null || picked != initialDate)) {
      onDateChanged(picked);
    }
  }
}
