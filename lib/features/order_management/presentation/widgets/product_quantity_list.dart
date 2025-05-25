import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_form_provider.dart';

class ProductQuantityList extends ConsumerWidget {
  const ProductQuantityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productQuantities = ref
        .watch(orderFormProvider.select((state) => state.productQuantityItems));

    return Column(
      children: productQuantities.map((item) {
        return ListTile(
          title: Text(item.productName),
          subtitle: Text('Quantity: \\${item.quantity}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref
                  .read(orderFormProvider.notifier)
                  .removeProduct(item.productId);
            },
          ),
        );
      }).toList(),
    );
  }
}
