import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/customer_model.dart';
import '../providers/order_form_provider.dart';

class BranchDropdown extends ConsumerWidget {
  const BranchDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderFormState = ref.watch(orderFormProvider);
    final branches = orderFormState.customerBranches;

    return DropdownButtonFormField<CustomerBranch>(
      decoration: const InputDecoration(
        labelText: 'Select Branch',
        border: OutlineInputBorder(),
      ),
      items: branches
          .map(
            (branch) => DropdownMenuItem<CustomerBranch>(
              value: branch,
              child: Text(branch.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value is CustomerBranch) {
          ref.read(orderFormProvider.notifier).setBranch(value);
        }
      },
    );
  }
}
