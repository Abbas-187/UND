import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cost_layer.dart';
import '../../domain/providers/inventory_costing_provider.dart';

class InventoryCostingSettingsScreen extends ConsumerWidget {
  const InventoryCostingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costingState = ref.watch(costingMethodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Costing Settings'),
      ),
      body: costingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Default Costing Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCostingMethodSelector(ref, costingState),
                  if (costingState.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              costingState.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'About Inventory Costing Methods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCostingMethodExplanation(),
                ],
              ),
            ),
    );
  }

  Widget _buildCostingMethodSelector(WidgetRef ref, CostingMethodState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCostingMethodTile(
              ref: ref,
              title: 'First-In-First-Out (FIFO)',
              subtitle: 'Oldest inventory items are sold/used first',
              method: CostingMethod.fifo,
              currentMethod: state.selectedCostingMethod,
            ),
            const Divider(),
            _buildCostingMethodTile(
              ref: ref,
              title: 'Last-In-First-Out (LIFO)',
              subtitle: 'Newest inventory items are sold/used first',
              method: CostingMethod.lifo,
              currentMethod: state.selectedCostingMethod,
            ),
            const Divider(),
            _buildCostingMethodTile(
              ref: ref,
              title: 'Weighted Average Cost (WAC)',
              subtitle:
                  'Cost is based on the average of all items in inventory',
              method: CostingMethod.wac,
              currentMethod: state.selectedCostingMethod,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostingMethodTile({
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required CostingMethod method,
    required CostingMethod currentMethod,
  }) {
    return RadioListTile<CostingMethod>(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      value: method,
      groupValue: currentMethod,
      onChanged: (value) {
        if (value != null && value != currentMethod) {
          ref.read(costingMethodProvider.notifier).changeCostingMethod(value);
        }
      },
    );
  }

  Widget _buildCostingMethodExplanation() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExplanationSection(
              title: 'FIFO (First-In-First-Out)',
              description:
                  'In the FIFO method, the oldest inventory items are sold or used first. This is most appropriate for businesses with perishable goods or items that can become obsolete over time.',
              benefits: [
                'Closely matches the actual flow of inventory',
                'Generally accepted for financial reporting',
                'Reduces the risk of inventory obsolescence'
              ],
              limitations: [
                'Can lead to higher taxable income during inflation',
                'More complex record-keeping'
              ],
            ),
            const Divider(height: 32),
            _buildExplanationSection(
              title: 'LIFO (Last-In-First-Out)',
              description:
                  'In the LIFO method, the newest inventory items are sold or used first. This method can be useful for tax purposes in certain jurisdictions.',
              benefits: [
                'Can reduce taxable income during inflation',
                'Matches current costs with current revenues'
              ],
              limitations: [
                'May not reflect actual inventory flow',
                'Not allowed in many international accounting standards',
                'Older inventory might never be valued'
              ],
            ),
            const Divider(height: 32),
            _buildExplanationSection(
              title: 'WAC (Weighted Average Cost)',
              description:
                  'The weighted average cost method calculates an average cost for all items in inventory, regardless of purchase date.',
              benefits: [
                'Simplifies record-keeping',
                'Less affected by price fluctuations',
                'Especially useful for items that cannot be differentiated'
              ],
              limitations: [
                'Doesn\'t reflect the most recent costs',
                'Less precise than other methods'
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationSection({
    required String title,
    required String description,
    required List<String> benefits,
    required List<String> limitations,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 8),
        const Text(
          'Benefits:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...benefits.map((b) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(b)),
                ],
              ),
            )),
        const SizedBox(height: 8),
        const Text(
          'Limitations:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...limitations.map((l) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(l)),
                ],
              ),
            )),
      ],
    );
  }
}
