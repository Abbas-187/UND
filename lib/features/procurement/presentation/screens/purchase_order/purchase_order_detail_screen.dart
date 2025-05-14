import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/detail_appbar.dart';
import '../../../../../common/widgets/loading_overlay.dart';
import '../../../../../common/widgets/status_badge.dart';
import '../../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../../domain/entities/purchase_order.dart';
import '../../../domain/services/purchase_order_print_service.dart';
import '../../providers/purchase_order_providers.dart';

/// Provider for PurchaseOrderPrintService to resolve the missing reference
final purchaseOrderPrintServiceProvider =
    Provider<PurchaseOrderPrintService>((ref) {
  return PurchaseOrderPrintService();
});

class PurchaseOrderDetailScreen extends ConsumerWidget {
  const PurchaseOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poDetailState =
        ref.watch(purchaseOrderDetailNotifierProvider(orderId));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        GoRouter.of(context).go('/procurement/purchase-orders');
      },
      child: Scaffold(
        appBar: DetailAppBar(
          title: 'Purchase Order Details',
          actions: [
            if (poDetailState.purchaseOrder != null &&
                poDetailState.purchaseOrder!.status ==
                    PurchaseOrderStatus.approved)
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => _printPurchaseOrder(
                    context, ref, poDetailState.purchaseOrder!),
                tooltip: 'Print Approved PO',
              ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: poDetailState.isLoading,
          child: poDetailState.hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        poDetailState.errorMessage ?? 'An error occurred',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(purchaseOrderDetailNotifierProvider(orderId)
                                .notifier)
                            .refreshPurchaseOrder(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : poDetailState.purchaseOrder == null
                  ? const Center(child: Text('Purchase order not found'))
                  : _buildPurchaseOrderDetails(
                      context, ref, poDetailState.purchaseOrder!),
        ),
      ),
    );
  }

  Widget _buildPurchaseOrderDetails(
      BuildContext context, WidgetRef ref, PurchaseOrder purchaseOrder) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    final supplierId = purchaseOrder.supplierId;
    final supplierAsync = (supplierId.isNotEmpty)
        ? ref.watch(supplierProvider(supplierId))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'PO #${purchaseOrder.poNumber}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              StatusBadge(
                  status: purchaseOrder.status.toString().split('.').last),
            ],
          ),
          const SizedBox(height: 24),

          // Info cards row
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  'Request Date',
                  dateFormat.format(purchaseOrder.requestDate),
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  context,
                  'Total Amount',
                  currencyFormat.format(purchaseOrder.totalAmount),
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Supplier info
          _buildSection(
            context,
            'Supplier Information',
            supplierAsync != null
                ? supplierAsync.when(
                    data: (supplier) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${supplier.name}'),
                        Text('ID: ${supplier.id}'),
                        // Add more supplier fields if desired
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${purchaseOrder.supplierName}'),
                        Text('ID: ${purchaseOrder.supplierId}'),
                        Text('Supplier info unavailable'),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${purchaseOrder.supplierName}'),
                      Text('ID: ${purchaseOrder.supplierId}'),
                      Text('Supplier info unavailable'),
                    ],
                  ),
          ),

          // Request info
          _buildSection(
            context,
            'Request Information',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Requested By: ${purchaseOrder.requestedBy}'),
                if (purchaseOrder.approvedBy != null)
                  Text('Approved By: ${purchaseOrder.approvedBy}'),
                if (purchaseOrder.approvalDate != null)
                  Text(
                      'Approval Date: ${dateFormat.format(purchaseOrder.approvalDate!)}'),
              ],
            ),
          ),

          // Delivery info
          if (purchaseOrder.deliveryDate != null)
            _buildSection(
              context,
              'Delivery Information',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (purchaseOrder.deliveryDate != null)
                    Text(
                        'Delivered On: ${dateFormat.format(purchaseOrder.deliveryDate!)}'),
                ],
              ),
            ),

          // Purpose
          _buildSection(
            context,
            'Purpose',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason for Request: ${purchaseOrder.reasonForRequest}'),
                const SizedBox(height: 8),
                Text('Intended Use: ${purchaseOrder.intendedUse}'),
                const SizedBox(height: 8),
                Text(
                    'Quantity Justification: ${purchaseOrder.quantityJustification}'),
              ],
            ),
          ),

          // Items
          _buildSection(
            context,
            'Items',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table headers
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Item',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Quantity',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Unit Price',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),

                // Table rows
                ...purchaseOrder.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  item.itemName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item.quantity} ${item.unit}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  currencyFormat.format(item.unitPrice),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  currencyFormat.format(item.totalPrice),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Expanded(
                                flex: 5,
                                child: Text(
                                  'Required by:',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  dateFormat.format(item.requiredByDate),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4.0),
                            Text(
                              'Notes: ${item.notes}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          // Divider after each item except the last one
                          if (item != purchaseOrder.items.last)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Divider(),
                            ),
                        ],
                      ),
                    )),

                // Total row at the bottom
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 5,
                        child: Text(
                          'Grand Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 4,
                        child: SizedBox(),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormat.format(purchaseOrder.totalAmount),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Supporting Documents
          if (purchaseOrder.supportingDocuments.isNotEmpty)
            _buildSection(
              context,
              'Supporting Documents',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: purchaseOrder.supportingDocuments
                    .map((doc) => ListTile(
                          title: Text(doc.name),
                          subtitle: Text(doc.type),
                          leading: const Icon(Icons.insert_drive_file),
                          onTap: () {
                            // View document
                          },
                        ))
                    .toList(),
              ),
            ),

          const SizedBox(height: 32),

          // Action buttons depending on status
          _buildActionButtons(context, ref, purchaseOrder),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, PurchaseOrder purchaseOrder) {
    // Different action buttons depending on the purchase order status
    switch (purchaseOrder.status) {
      case PurchaseOrderStatus.draft:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              onPressed: () {
                // Navigate to edit screen
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Submit for Approval'),
              onPressed: () => _updateStatus(
                  context, ref, purchaseOrder, PurchaseOrderStatus.pending),
            ),
          ],
        );
      case PurchaseOrderStatus.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _updateStatus(
                  context, ref, purchaseOrder, PurchaseOrderStatus.approved),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('Decline'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _updateStatus(
                  context, ref, purchaseOrder, PurchaseOrderStatus.declined),
            ),
          ],
        );
      case PurchaseOrderStatus.approved:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print'),
              onPressed: () => _printPurchaseOrder(context, ref, purchaseOrder),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_shipping),
              label: const Text('Mark as Delivered'),
              onPressed: () => _updateStatus(
                  context, ref, purchaseOrder, PurchaseOrderStatus.delivered),
            ),
          ],
        );
      case PurchaseOrderStatus.delivered:
        return ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('Mark as Complete'),
          onPressed: () => _updateStatus(
              context, ref, purchaseOrder, PurchaseOrderStatus.completed),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref,
      PurchaseOrder purchaseOrder, PurchaseOrderStatus newStatus) async {
    final notifier =
        ref.read(purchaseOrderDetailNotifierProvider(orderId).notifier);
    final result = await notifier.updateStatus(newStatus);

    if (context.mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Purchase order status updated to ${newStatus.toString().split('.').last}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failure?.message ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printPurchaseOrder(
      BuildContext context, WidgetRef ref, PurchaseOrder purchaseOrder) async {
    if (purchaseOrder.status != PurchaseOrderStatus.approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only approved purchase orders can be printed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final printService = ref.read(purchaseOrderPrintServiceProvider);
    await printService.printPurchaseOrder(purchaseOrder);
  }
}
