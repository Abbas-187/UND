import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_form_provider.dart';

class ProductListDropdown extends ConsumerWidget {
  const ProductListDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLists = ref.watch(savedProductListsProvider);

    return DropdownButtonFormField<ProductList>(
      decoration: const InputDecoration(
        labelText: 'Select Saved List',
        border: OutlineInputBorder(),
      ),
      items: savedLists.when(
        data: (data) => data
            .map(
              (list) => DropdownMenuItem<ProductList>(
                value: list,
                child: Text(list.name),
              ),
            )
            .toList(),
        loading: () => [],
        error: (err, stack) => [],
      ),
      onChanged: (value) {
        if (value is ProductList) {
          ref.read(orderFormProvider.notifier).setSavedList(value);
        }
      },
    );
  }
}
