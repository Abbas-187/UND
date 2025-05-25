import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/production_plan_datasource.dart';
import '../../data/models/production_plan_model.dart';

class EditableProductionPlanScreen extends ConsumerStatefulWidget {
  const EditableProductionPlanScreen({super.key});

  @override
  ConsumerState<EditableProductionPlanScreen> createState() =>
      _EditableProductionPlanScreenState();
}

class _EditableProductionPlanScreenState
    extends ConsumerState<EditableProductionPlanScreen> {
  late ProductionPlan _plan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlan();
  }

  Future<void> _fetchPlan() async {
    final dataSource = ref.read(productionPlanDataSourceProvider);
    final plan = await dataSource.fetchProductionPlan('plan_001');
    setState(() {
      _plan = plan;
      _isLoading = false;
    });
  }

  void _addProduct() {
    setState(() {
      _plan.items.add(ProductionPlanItem(
        productId: '',
        productName: '',
        requiredQuantity: 0,
        availableStock: 0,
        productionQuantity: 0,
        deadline: DateTime.now(),
      ));
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _plan.items.removeAt(index);
    });
  }

  Future<void> _savePlan() async {
    final dataSource = ref.read(productionPlanDataSourceProvider);
    await dataSource.updateProductionPlan(_plan);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan saved successfully!')),
    );
  }

  Future<void> _submitPlan() async {
    final dataSource = ref.read(productionPlanDataSourceProvider);
    await dataSource.submitProductionPlan(_plan.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editable Production Plan')),
      body: ListView.builder(
        itemCount: _plan.items.length,
        itemBuilder: (context, index) {
          final item = _plan.items[index];
          return ListTile(
            title: TextFormField(
              initialValue: item.productName,
              decoration: const InputDecoration(labelText: 'Product Name'),
              onChanged: (value) => setState(() {
                _plan.items[index] = item.copyWith(productName: value);
              }),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: item.productionQuantity.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Production Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    _plan.items[index] = item.copyWith(
                      productionQuantity: int.parse(value),
                    );
                  }),
                ),
                TextFormField(
                  initialValue: item.deadline.toIso8601String(),
                  decoration: const InputDecoration(labelText: 'Deadline'),
                  onChanged: (value) => setState(() {
                    _plan.items[index] = item.copyWith(
                      deadline: DateTime.parse(value),
                    );
                  }),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeProduct(index),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addProduct,
            tooltip: 'Add Product',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _savePlan,
            tooltip: 'Save Plan',
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _submitPlan,
            tooltip: 'Submit Plan',
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
