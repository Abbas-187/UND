import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/providers/inventory_costing_provider.dart';
import '../../domain/usecases/generate_picking_suggestions_usecase.dart';

class InventoryPickingSuggestionsScreen extends ConsumerStatefulWidget {
  const InventoryPickingSuggestionsScreen({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantityNeeded,
  });

  final String itemId;
  final String itemName;
  final String warehouseId;
  final String warehouseName;
  final double quantityNeeded;

  @override
  ConsumerState<InventoryPickingSuggestionsScreen> createState() =>
      _InventoryPickingSuggestionsScreenState();
}

class _InventoryPickingSuggestionsScreenState
    extends ConsumerState<InventoryPickingSuggestionsScreen> {
  PickingStrategy _selectedStrategy = PickingStrategy.fefo;
  bool _includeExpiringSoon = true;
  int _expiringThresholdDays = 30;

  @override
  Widget build(BuildContext context) {
    // Watch picking suggestions
    final suggestionsAsyncValue = ref.watch(
      pickingSuggestionsProvider({
        'itemId': widget.itemId,
        'warehouseId': widget.warehouseId,
        'quantityNeeded': widget.quantityNeeded,
        'strategy': _selectedStrategy,
        'includeExpiringSoon': _includeExpiringSoon,
        'expiringThresholdDays': _expiringThresholdDays,
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Picking Suggestions'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildStrategySelector(),
          Expanded(
            child: suggestionsAsyncValue.when(
              data: (suggestions) => _buildSuggestionsList(suggestions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error loading suggestions: $err',
                    style: TextStyle(color: Colors.red.shade700)),
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final formatter = NumberFormat.decimalPattern();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.itemName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    'Warehouse',
                    widget.warehouseName,
                    Icons.warehouse,
                  ),
                ),
                Expanded(
                  child: _buildInfoBox(
                    'Quantity Needed',
                    formatter.format(widget.quantityNeeded),
                    Icons.inventory_2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySelector() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Picking Strategy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<PickingStrategy>(
              segments: const [
                ButtonSegment(
                  value: PickingStrategy.fefo,
                  label: Text('FEFO'),
                  icon: Icon(Icons.date_range),
                ),
                ButtonSegment(
                  value: PickingStrategy.fifo,
                  label: Text('FIFO'),
                  icon: Icon(Icons.arrow_forward),
                ),
                ButtonSegment(
                  value: PickingStrategy.lifo,
                  label: Text('LIFO'),
                  icon: Icon(Icons.arrow_back),
                ),
              ],
              selected: {_selectedStrategy},
              onSelectionChanged: (Set<PickingStrategy> selected) {
                setState(() {
                  _selectedStrategy = selected.first;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _includeExpiringSoon,
                  onChanged: (value) {
                    setState(() {
                      _includeExpiringSoon = value ?? false;
                    });
                  },
                ),
                const Text('Include items expiring within:'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 65,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    controller: TextEditingController(
                      text: _expiringThresholdDays.toString(),
                    ),
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null && days > 0) {
                        setState(() {
                          _expiringThresholdDays = days;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                const Text('days'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<PickingSuggestion> suggestions) {
    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'No suggestions available. Try changing your picking strategy or check if the item is in stock.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Format for currency and numbers
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final numberFormat = NumberFormat.decimalPattern();
    final dateFormat = DateFormat('MMM d, yyyy');

    return ListView.builder(
      itemCount: suggestions.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final isExpiringSoon = suggestion.daysUntilExpiration != null &&
            suggestion.daysUntilExpiration! <= _expiringThresholdDays;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isExpiringSoon
                ? BorderSide(color: Colors.orange.shade300, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text(
                  'Batch/Lot: ${suggestion.batchLotNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isExpiringSoon) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Expiring in ${suggestion.daysUntilExpiration} days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSuggestionDetail(
                          'Available',
                          numberFormat.format(suggestion.availableQuantity),
                        ),
                      ),
                      Expanded(
                        child: _buildSuggestionDetail(
                          'Suggested',
                          numberFormat.format(suggestion.suggestedQuantity),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSuggestionDetail(
                          'Unit Cost',
                          suggestion.costAtTransaction != null
                              ? currencyFormat
                                  .format(suggestion.costAtTransaction!)
                              : 'N/A',
                        ),
                      ),
                      Expanded(
                        child: _buildSuggestionDetail(
                          'Expiration',
                          suggestion.expirationDate != null
                              ? dateFormat.format(suggestion.expirationDate!)
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Allow changing the suggested quantity
                    _editSuggestedQuantity(context, suggestion);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.done),
              label: const Text('Confirm Selection'),
              onPressed: () {
                // TODO: Implement confirmation logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Picking suggestions applied')),
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editSuggestedQuantity(
      BuildContext context, PickingSuggestion suggestion) {
    final controller = TextEditingController(
      text: suggestion.suggestedQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Suggested Quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Batch/Lot: ${suggestion.batchLotNumber}'),
              const SizedBox(height: 8),
              Text('Available: ${suggestion.availableQuantity}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantity to Pick',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null &&
                    value >= 0 &&
                    value <= suggestion.availableQuantity) {
                  // TODO: Update the suggestion
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Invalid quantity. Must be between 0 and ${suggestion.availableQuantity}',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
