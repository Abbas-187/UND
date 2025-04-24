import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'order_creation_edit_screen.dart';
import '../widgets/responsive_builder.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  final bool isEmbedded;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
    this.isEmbedded = false,
  }) : super(key: key);

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isLoading = true;
  Order? _order;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderNotifier = ref.read(orderProviderProvider.notifier);
      final order = await orderNotifier.getOrderById(widget.orderId);

      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return _buildContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.orderId}',
          semanticsLabel: 'Order details for order number ${widget.orderId}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrderDetails,
            tooltip: 'Refresh order details',
            semanticLabel: 'Refresh order details',
          ),
          if (_order != null && canEditOrder(_order!))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditOrder(),
              tooltip: 'Edit Order',
              semanticLabel: 'Edit Order',
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading order details...'),
        ],
      ));
    }

    if (_order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Order not found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The requested order could not be found or has been deleted.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: _loadOrderDetails,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrderDetails,
      child: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSection(),
          const SizedBox(height: 16),
          _buildBasicInfoSection(),
          const SizedBox(height: 16),
          _buildItemsSection(),
          if (_order!.customerAllergies != null &&
              _order!.customerAllergies!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAllergiesSection(),
          ],
          if (_order!.customerPreferences != null) ...[
            const SizedBox(height: 16),
            _buildPreferencesSection(),
          ],
          if (_order!.justification != null) ...[
            const SizedBox(height: 16),
            _buildJustificationSection(),
          ],
          if (_order!.cancellationReason != null) ...[
            const SizedBox(height: 16),
            _buildCancellationSection(),
          ],
          // Add some bottom padding for better scrolling experience
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSection(),
          const SizedBox(height: 24),
          // Use a two-column layout for tablet
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBasicInfoSection(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildItemsSection(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Conditional sections
          if (_order!.customerAllergies != null &&
              _order!.customerAllergies!.isNotEmpty) ...[
            _buildAllergiesSection(),
            const SizedBox(height: 16),
          ],
          if (_order!.customerPreferences != null) ...[
            _buildPreferencesSection(),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_order!.justification != null)
                Expanded(child: _buildJustificationSection()),
              if (_order!.justification != null &&
                  _order!.cancellationReason != null)
                const SizedBox(width: 16),
              if (_order!.cancellationReason != null)
                Expanded(child: _buildCancellationSection()),
            ],
          ),
          // Add some bottom padding for better scrolling experience
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildStatusSection(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildActionsPanel(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Main content in three columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Basic info
              Expanded(
                child: _buildBasicInfoSection(),
              ),
              const SizedBox(width: 24),
              // Middle column - Items
              Expanded(
                child: _buildItemsSection(),
              ),
              const SizedBox(width: 24),
              // Right column - Customer info
              Expanded(
                child: Column(
                  children: [
                    if (_order!.customerAllergies != null &&
                        _order!.customerAllergies!.isNotEmpty) ...[
                      _buildAllergiesSection(),
                      const SizedBox(height: 24),
                    ],
                    if (_order!.customerPreferences != null) ...[
                      _buildPreferencesSection(),
                      const SizedBox(height: 24),
                    ],
                    if (_order!.justification != null) ...[
                      _buildJustificationSection(),
                      const SizedBox(height: 24),
                    ],
                    if (_order!.cancellationReason != null) ...[
                      _buildCancellationSection(),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Add some bottom padding for better scrolling experience
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionsPanel() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (canEditOrder(_order!)) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Order'),
                onTap: _navigateToEditOrder,
              ),
            ],
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View Audit Trail'),
              onTap: () => _viewAuditTrail(),
            ),
            if (_order!.status != OrderStatus.cancelled &&
                _order!.status != OrderStatus.completed &&
                _order!.status != OrderStatus.delivered) ...[
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel Order',
                    style: TextStyle(color: Colors.red)),
                onTap: () => _showCancelOrderDialog(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool canEditOrder(Order order) {
    // This is a simplified check - in a real app, this would also check user permissions
    return order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.completed &&
        order.status != OrderStatus.delivered;
  }

  Widget _buildStatusSection() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              semanticsLabel: 'Order status section',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Semantics(
                  label:
                      'Order status ${_getStatusDisplayName(_order!.status)}',
                  child: _buildStatusIndicator(_order!.status),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusDisplayName(_order!.status),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(_order!.status),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Semantics(
                  label:
                      'Production status ${_getProductionStatusName(_order!.productionStatus)}',
                  child: _buildStatusDetail(
                    'Production',
                    _getProductionStatusName(_order!.productionStatus),
                    _getProductionStatusColor(_order!.productionStatus),
                  ),
                ),
                Semantics(
                  label:
                      'Procurement status ${_getProcurementStatusName(_order!.procurementStatus)}',
                  child: _buildStatusDetail(
                    'Procurement',
                    _getProcurementStatusName(_order!.procurementStatus),
                    _getProcurementStatusColor(_order!.procurementStatus),
                  ),
                ),
              ],
            ),
            if (canShowEstimatedDates()) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (_order!.estimatedCompletionDate != null)
                    _buildDateDetail(
                      'Est. Completion',
                      _formatDate(_order!.estimatedCompletionDate!),
                    ),
                  if (_order!.estimatedDeliveryDate != null)
                    _buildDateDetail(
                      'Est. Delivery',
                      _formatDate(_order!.estimatedDeliveryDate!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool canShowEstimatedDates() {
    // Only show estimated dates for certain statuses
    return _order!.status != OrderStatus.draft &&
        _order!.status != OrderStatus.pending &&
        _order!.status != OrderStatus.cancelled &&
        _order!.status != OrderStatus.rejected;
  }

  Widget _buildBasicInfoSection() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              semanticsLabel: 'Basic order information',
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Customer', _order!.customer),
            _buildInfoRow('Location', _order!.location),
            if (_order!.recipeId != null)
              _buildInfoRow('Recipe ID', _order!.recipeId!),
            _buildInfoRow('Created By', _order!.createdBy),
            _buildInfoRow('Created At', _formatDateTime(_order!.createdAt)),
            _buildInfoRow('Updated At', _formatDateTime(_order!.updatedAt)),
            if (_order!.customerTier != null)
              _buildInfoRow('Customer Tier', _order!.customerTier!),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order!.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _order!.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item.quantity} ${item.unit}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Customer Allergies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _order!.customerAllergies!.map((allergy) {
                  return Chip(
                    backgroundColor: Colors.red.shade100,
                    label: Text(
                      allergy,
                      style: TextStyle(
                        color: Colors.red.shade900,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...(_order!.customerPreferences as Map<String, dynamic>)
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (_order!.customerNotes != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_order!.customerNotes!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJustificationSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Justification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(_order!.justification!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancellationSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cancel,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Cancelled By', _order!.cancellationBy!),
              _buildInfoRow(
                'Cancelled At',
                _formatDateTime(_order!.cancellationAt!),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reason:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_order!.cancellationReason!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(OrderStatus status) {
    final color = _getStatusColor(status);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          _getStatusIcon(status),
          color: color,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildStatusDetail(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _navigateToEditOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderCreationEditScreen(orderId: widget.orderId),
      ),
    ).then((_) => _loadOrderDetails());
  }

  void _viewAuditTrail() {
    // Placeholder for viewing audit trail
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Audit trail feature is not implemented yet.')),
    );
  }

  void _showCancelOrderDialog() {
    // Placeholder for cancel order dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Cancel order feature is not implemented yet.')),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Colors.grey;
      case OrderStatus.pending:
        return Colors.purple;
      case OrderStatus.approved:
        return Colors.teal;
      case OrderStatus.awaitingProcurement:
        return Colors.blue;
      case OrderStatus.readyForProduction:
        return Colors.amber;
      case OrderStatus.inProduction:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.lightGreen;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.green.shade800;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.rejected:
        return Colors.deepOrange;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Icons.edit_note;
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.approved:
        return Icons.thumb_up;
      case OrderStatus.awaitingProcurement:
        return Icons.shopping_cart;
      case OrderStatus.readyForProduction:
        return Icons.pending_actions;
      case OrderStatus.inProduction:
        return Icons.precision_manufacturing;
      case OrderStatus.ready:
        return Icons.inventory;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.delivered:
        return Icons.local_shipping;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.awaitingProcurement:
        return 'Awaiting Procurement';
      case OrderStatus.readyForProduction:
        return 'Ready for Production';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Order has been created but not submitted for processing.';
      case OrderStatus.pending:
        return 'Order has been submitted and is pending approval.';
      case OrderStatus.approved:
        return 'Order has been approved and is ready for processing.';
      case OrderStatus.awaitingProcurement:
        return 'Order is waiting for procurement of necessary ingredients.';
      case OrderStatus.readyForProduction:
        return 'All ingredients are available and order is ready for production.';
      case OrderStatus.inProduction:
        return 'Order is currently in production.';
      case OrderStatus.ready:
        return 'Order is ready for delivery.';
      case OrderStatus.completed:
        return 'Order has been completed and delivered.';
      case OrderStatus.delivered:
        return 'Order has been delivered to the customer.';
      case OrderStatus.cancelled:
        return 'Order has been cancelled.';
      case OrderStatus.rejected:
        return 'Order has been rejected.';
    }
  }

  String _getProductionStatusName(ProductionStatus status) {
    switch (status) {
      case ProductionStatus.notStarted:
        return 'Not Started';
      case ProductionStatus.inProgress:
        return 'In Progress';
      case ProductionStatus.onHold:
        return 'On Hold';
      case ProductionStatus.completed:
        return 'Completed';
      case ProductionStatus.failed:
        return 'Failed';
    }
  }

  Color _getProductionStatusColor(ProductionStatus status) {
    switch (status) {
      case ProductionStatus.notStarted:
        return Colors.grey;
      case ProductionStatus.inProgress:
        return Colors.orange;
      case ProductionStatus.onHold:
        return Colors.amber;
      case ProductionStatus.completed:
        return Colors.green;
      case ProductionStatus.failed:
        return Colors.red;
    }
  }

  String _getProcurementStatusName(ProcurementStatus status) {
    switch (status) {
      case ProcurementStatus.notRequired:
        return 'Not Required';
      case ProcurementStatus.pending:
        return 'Pending';
      case ProcurementStatus.ordered:
        return 'Ordered';
      case ProcurementStatus.partiallyReceived:
        return 'Partially Received';
      case ProcurementStatus.received:
        return 'Received';
      case ProcurementStatus.delayed:
        return 'Delayed';
      case ProcurementStatus.fulfilled:
        return 'Fulfilled';
      case ProcurementStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getProcurementStatusColor(ProcurementStatus status) {
    switch (status) {
      case ProcurementStatus.notRequired:
        return Colors.grey;
      case ProcurementStatus.pending:
        return Colors.blue;
      case ProcurementStatus.ordered:
        return Colors.indigo;
      case ProcurementStatus.partiallyReceived:
        return Colors.amber;
      case ProcurementStatus.received:
        return Colors.lightGreen;
      case ProcurementStatus.delayed:
        return Colors.orange;
      case ProcurementStatus.fulfilled:
        return Colors.green;
      case ProcurementStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
