import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/customer_model.dart';
import '../providers/order_form_provider.dart';

class CustomerDropdown extends ConsumerWidget {
  const CustomerDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);

    return DropdownButtonFormField<CustomerModel>(
      decoration: const InputDecoration(
        labelText: 'Select Customer',
        border: OutlineInputBorder(),
      ),
      items: customers.when(
        data: (data) => data
            .map(
              (customer) => DropdownMenuItem<CustomerModel>(
                value: customer,
                child: Text(customer.name),
              ),
            )
            .toList(),
        loading: () => [],
        error: (err, stack) => [],
      ),
      onChanged: (value) {
        if (value is CustomerModel) {
          ref.read(orderFormProvider.notifier).setCustomer(value);
        }
      },
    );
  }
}
