import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/widgets/detail_appbar.dart';
import '../../widgets/purchase_order_list.dart';

class PurchaseOrderListScreen extends ConsumerWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop && !Navigator.of(context).canPop()) {
          context.go('/procurement/dashboard');
        }
      },
      child: Scaffold(
        appBar: DetailAppBar(
          title: 'Purchase Orders',
        ),
        body: const PurchaseOrderList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/procurement/purchase-orders/create');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
