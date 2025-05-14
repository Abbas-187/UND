import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/order_model.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_provider.dart';

class OrderCreationEditScreen extends ConsumerStatefulWidget {
  const OrderCreationEditScreen({super.key});

  @override
  ConsumerState<OrderCreationEditScreen> createState() =>
      _OrderCreationEditScreenState();
}

class _OrderCreationEditScreenState
    extends ConsumerState<OrderCreationEditScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  late bool _isEdit;
  late String _id;
  String _customerName = '';
  DateTime _date = DateTime.now();
  String _itemsText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = GoRouterState.of(context).extra;
    if (args is OrderEntity) {
      _isEdit = true;
      _id = args.id;
      _customerName = args.customerName;
      _date = args.date;
      _itemsText = args.items.join(', ');
    } else {
      _isEdit = false;
      _id = UniqueKey().toString();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isSubmitting = true;
    });
    final items = _itemsText.split(',').map((e) => e.trim()).toList();
    final order = OrderEntity(
      id: _id,
      customerName: _customerName,
      date: _date,
      items: items,
    );
    try {
      if (_isEdit) {
        await ref
            .read(orderProvider.notifier)
            .updateOrder(OrderModel.fromEntity(order));
      } else {
        await ref
            .read(orderProvider.notifier)
            .createOrder(OrderModel.fromEntity(order));
      }
      if (mounted) context.go('/order-management');
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Order' : 'Create Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _customerName,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _customerName = v!,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_date.toLocal().toString().split(' ')[0]),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _itemsText,
                decoration: const InputDecoration(
                  labelText: 'Items (comma separated)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _itemsText = v!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Save Changes' : 'Create Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
