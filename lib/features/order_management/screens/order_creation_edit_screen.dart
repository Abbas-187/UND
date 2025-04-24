import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'package:uuid/uuid.dart';
import '../services/order_service.dart';
import '../widgets/customer_context_panel.dart';
import '../widgets/product_recommendation_widget.dart';

class OrderCreationEditScreen extends ConsumerStatefulWidget {
  final String? orderId; // Nullable for new orders

  const OrderCreationEditScreen({Key? key, this.orderId}) : super(key: key);

  @override
  ConsumerState<OrderCreationEditScreen> createState() =>
      _OrderCreationEditScreenState();
}

class _OrderCreationEditScreenState
    extends ConsumerState<OrderCreationEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _recipeIdController = TextEditingController();
  final TextEditingController _justificationController =
      TextEditingController();

  List<OrderItemFormField> _itemFields = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  Order? _existingOrder;

  // Add customer profile related state
  final OrderService _orderService = OrderService();
  bool _showCustomerPanel = true;
  String _selectedCustomerId = '';
  Map<String, dynamic>? _customerPreferences;
  List<String>? _customerAllergies;
  String? _customerNotes;
  String? _customerTier;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    if (widget.orderId != null) {
      await _loadExistingOrder();

      // Get the customer ID from the existing order
      if (_existingOrder != null) {
        _selectedCustomerId = _existingOrder!.customer;
        _customerController.text = _selectedCustomerId;
        await _loadCustomerData(_selectedCustomerId);
      }
    } else {
      // For new orders
      _itemFields.add(OrderItemFormField(
        nameController: TextEditingController(),
        quantityController: TextEditingController(),
        unitController: TextEditingController(),
      ));
    }
  }

  Future<void> _loadExistingOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderNotifier = ref.read(orderProviderProvider.notifier);
      final order = await orderNotifier.getOrderById(widget.orderId!);

      if (order != null) {
        setState(() {
          _existingOrder = order;
          _customerController.text = order.customer;
          _locationController.text = order.location;
          _recipeIdController.text = order.recipeId ?? '';

          // Set up the item form fields from existing order items
          _itemFields.clear();
          for (final item in order.items) {
            _itemFields.add(OrderItemFormField(
              nameController: TextEditingController(text: item.name),
              quantityController:
                  TextEditingController(text: item.quantity.toString()),
              unitController: TextEditingController(text: item.unit),
            ));
          }
        });
      }
    } catch (e) {
      // Handle error
      print('Error loading order: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomerData(String customerId) async {
    if (customerId.isEmpty) return;

    try {
      final customerData =
          await _orderService.getCustomerOrderPreferences(customerId);

      setState(() {
        _customerPreferences = customerData['preferences'];
        _customerAllergies = List<String>.from(customerData['allergies'] ?? []);
        _customerNotes = customerData['notes'];
        _customerTier = customerData['tier'];
        _selectedCustomerId = customerId;
      });
    } catch (e) {
      // Handle error
      print('Error loading customer data: $e');
    }
  }

  // Handle selection of a recommended product
  void _handleProductSelected(
      String productId, String productName, double price) {
    // Add the product to the order items
    // This is a simplified implementation - you would typically look up the product details
    setState(() {
      _itemFields.add(OrderItemFormField(
        nameController: TextEditingController(text: productName),
        quantityController: TextEditingController(text: '1'),
        unitController: TextEditingController(text: 'unit'),
        // In a real implementation, you would also store the price
      ));
    });

    // Show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Added $productName (\$${price.toStringAsFixed(2)}) to the order')),
    );
  }

  void _addItem() {
    setState(() {
      _itemFields.add(OrderItemFormField(
        nameController: TextEditingController(),
        quantityController: TextEditingController(),
        unitController: TextEditingController(),
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemFields.removeAt(index);
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final items = _itemFields.map((field) {
        return OrderItem(
          name: field.nameController.text,
          quantity: int.parse(field.quantityController.text),
          unit: field.unitController.text,
        );
      }).toList();

      final now = DateTime.now();

      if (widget.orderId == null) {
        // Creating a new order
        final newOrder = Order(
          id: 'ord_${now.millisecondsSinceEpoch}', // In real app, server would generate
          customer: _customerController.text,
          items: items,
          location: _locationController.text,
          status: OrderStatus.draft,
          createdBy: 'currentUser', // In real app, get from auth
          createdAt: now,
          updatedAt: now,
          productionStatus: ProductionStatus.notStarted,
          procurementStatus: ProcurementStatus.notRequired,
          recipeId: _recipeIdController.text.isNotEmpty
              ? _recipeIdController.text
              : null,
          customerPreferences: _customerPreferences,
          customerAllergies: _customerAllergies,
          customerNotes: _customerNotes,
          customerTier: _customerTier,
        );

        await ref.read(orderProviderProvider.notifier).createOrder(newOrder);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully')),
        );
      } else {
        // Updating existing order
        final updatedOrder = _existingOrder!.copyWith(
          customer: _customerController.text,
          items: items,
          location: _locationController.text,
          updatedAt: now,
          justification: _justificationController.text.isNotEmpty
              ? _justificationController.text
              : null,
          recipeId: _recipeIdController.text.isNotEmpty
              ? _recipeIdController.text
              : null,
          customerPreferences: _customerPreferences,
          customerAllergies: _customerAllergies,
          customerNotes: _customerNotes,
          customerTier: _customerTier,
        );

        await ref
            .read(orderProviderProvider.notifier)
            .updateOrder(updatedOrder);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order updated successfully')),
        );
      }

      // Return to previous screen
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
    final isEditing = widget.orderId != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Order' : 'Create Order'),
          actions: [
            // Add toggle for customer panel
            IconButton(
              icon: Icon(_showCustomerPanel ? Icons.person_off : Icons.person),
              onPressed: () {
                setState(() {
                  _showCustomerPanel = !_showCustomerPanel;
                });
              },
              tooltip: _showCustomerPanel
                  ? 'Hide customer info'
                  : 'Show customer info',
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main order form
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer field
                            TextFormField(
                              controller: _customerController,
                              decoration: const InputDecoration(
                                labelText: 'Customer',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a customer';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  _loadCustomerData(value);
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Display customer allergies as warning if present
                            if (_customerAllergies != null &&
                                _customerAllergies!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.amber),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning,
                                        color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Customer allergies: ${_customerAllergies!.join(", ")}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_customerAllergies != null &&
                                _customerAllergies!.isNotEmpty)
                              const SizedBox(height: 16),

                            // Location field
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a location';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Recipe ID field
                            TextFormField(
                              controller: _recipeIdController,
                              decoration: const InputDecoration(
                                labelText: 'Recipe ID',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Order items section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Order Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Item'),
                                  onPressed: _addItem,
                                ),
                              ],
                            ),

                            // Display product recommendations if customer is selected
                            if (_selectedCustomerId.isNotEmpty)
                              ProductRecommendationWidget(
                                customerId: _selectedCustomerId,
                                onProductSelected: _handleProductSelected,
                              ),

                            const SizedBox(height: 8),

                            // Order items list
                            ..._buildOrderItemFields(),

                            const SizedBox(height: 24),

                            // Justification field for editing
                            if (isEditing)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Justification for Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _justificationController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Provide reason for changes...',
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),

                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitOrder,
                                child: _isSubmitting
                                    ? const CircularProgressIndicator()
                                    : Text(isEditing
                                        ? 'Update Order'
                                        : 'Create Order'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Customer context panel (conditionally shown)
            if (_showCustomerPanel && _selectedCustomerId.isNotEmpty)
              CustomerContextPanel(
                customerId: _selectedCustomerId,
                showFullProfile: false,
                onClose: () {
                  setState(() {
                    _showCustomerPanel = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrderItemFields() {
    if (_itemFields.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No items added yet. Click "Add Item" to begin.'),
          ),
        ),
      ];
    }

    return _itemFields.asMap().entries.map((entry) {
      final index = entry.key;
      final field = entry.value;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Item ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem(index),
                    tooltip: 'Remove item',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: field.nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: field.quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Numbers only';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: field.unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
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
      );
    }).toList();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _locationController.dispose();
    _recipeIdController.dispose();
    _justificationController.dispose();
    for (final field in _itemFields) {
      field.nameController.dispose();
      field.quantityController.dispose();
      field.unitController.dispose();
    }
    super.dispose();
  }
}

class OrderItemFormField {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;

  OrderItemFormField({
    required this.nameController,
    required this.quantityController,
    required this.unitController,
  });
}
