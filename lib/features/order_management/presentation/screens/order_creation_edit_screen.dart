import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_form_provider.dart';
import '../widgets/customer_dropdown.dart';
import '../widgets/branch_dropdown.dart';
import '../widgets/product_list_dropdown.dart';
import '../widgets/product_quantity_list.dart';
import '../widgets/date_picker.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/order_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/order_item_model.dart';

class OrderCreationEditScreen extends ConsumerStatefulWidget {
  const OrderCreationEditScreen({super.key});

  @override
  ConsumerState<OrderCreationEditScreen> createState() =>
      _OrderCreationEditScreenState();
}

class _OrderCreationEditScreenState
    extends ConsumerState<OrderCreationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isEdit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = GoRouterState.of(context).extra;
    if (args != null && !_isEdit) {
      // Pre-fill form state if editing
      final order = args as OrderModel;
      final notifier = ref.read(orderFormProvider.notifier);
      // Create a CustomerModel from order data (branches will be empty)
      final customer = CustomerModel(
          id: order.customerId, name: order.customerName, branches: []);
      notifier.setCustomer(customer);
      // Set branch if shippingAddress is not null and is a Map
      if (order.shippingAddress != null &&
          order.shippingAddress is Map<String, dynamic>) {
        final branchMap = order.shippingAddress as Map<String, dynamic>;
        final branch = CustomerBranch.fromJson(branchMap);
        notifier.setBranch(branch);
      }
      // Set productQuantityItems
      final items = order.items
          .map((e) => e is OrderItemModel
              ? e
              : OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      notifier.state = notifier.state.copyWith(productQuantityItems: items);
      notifier.setDueDate(order.requiredDeliveryDate!);
      notifier.setNotes(order.notes ?? '');
      _isEdit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderFormState = ref.watch(orderFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Order' : 'Create Order'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Customer selection dropdown
                      const CustomerDropdown(),
                      const SizedBox(height: 16),
                      // Branch selection dropdown (only shown when customer has branches)
                      if (orderFormState.selectedCustomer != null &&
                          (orderFormState.customerBranches?.isNotEmpty ??
                              false))
                        const BranchDropdown(),
                      // Customer details when selected
                      if (orderFormState.selectedCustomer != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Customer ID: \\${orderFormState.selectedCustomer?.id ?? ""}'),
                              Text(
                                  'Name: \\${orderFormState.selectedCustomer?.name ?? ""}'),
                              if (orderFormState.selectedBranch != null)
                                Text(
                                    'Branch: \\${orderFormState.selectedBranch?.name ?? ""}'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Product List Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Save list button
                          if (orderFormState.selectedCustomer != null &&
                              orderFormState.productQuantityItems.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _showSaveListDialog(context),
                              icon: const Icon(Icons.save),
                              label: const Text('Save as List'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Saved lists dropdown
                      if (orderFormState.selectedCustomer != null)
                        const ProductListDropdown(),
                      const SizedBox(height: 16),
                      // Product selection and quantity list
                      if (orderFormState.selectedCustomer != null)
                        const ProductQuantityList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Due Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Due date picker
                      const DueDatePicker(),
                      // Notes field
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Any special instructions or notes',
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          ref.read(orderFormProvider.notifier).setNotes(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting || !_isFormValid(orderFormState)
                      ? null
                      : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(_isEdit ? 'Save Changes' : 'Submit Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFormValid(dynamic state) {
    // TODO: Update type after provider migration
    return state.selectedCustomer != null &&
        state.productQuantityItems.isNotEmpty &&
        state.dueDate != null;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      await ref.read(orderFormProvider.notifier).submitOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Order updated successfully'
                : 'Order created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting order: \\${e.toString()}'),
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

  Future<void> _showSaveListDialog(BuildContext context) async {
    final nameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Product List'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'List Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Save product list logic
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
