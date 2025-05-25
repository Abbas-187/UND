import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../factory/data/models/production_order_model.dart';
import '../../../factory/domain/providers/production_provider.dart';
import '../../domain/services/production_integration_service.dart';
import '../../domain/usecases/production/issue_materials_to_production_usecase.dart';
import '../../domain/usecases/production/receive_finished_goods_usecase.dart';

/// Production Integration View for managing inventory-production workflows
class ProductionIntegrationView extends ConsumerStatefulWidget {
  const ProductionIntegrationView({super.key});

  @override
  ConsumerState<ProductionIntegrationView> createState() =>
      _ProductionIntegrationViewState();
}

class _ProductionIntegrationViewState
    extends ConsumerState<ProductionIntegrationView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedProductionOrderId;
  ProductionOrderModel? _selectedProductionOrder;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productionOrders = ref.watch(productionOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Integration'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Orders'),
            Tab(icon: Icon(Icons.input), text: 'Material Issue'),
            Tab(icon: Icon(Icons.output), text: 'Finished Goods'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductionOrdersList(productionOrders),
          _buildMaterialIssuanceTab(),
          _buildFinishedGoodsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildProductionOrdersList(
      AsyncValue<List<ProductionOrderModel>> productionOrders) {
    return productionOrders.when(
      data: (orders) => Column(
        children: [
          _buildOrderSelectionHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildProductionOrderCard(order);
              },
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Error loading production orders: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(productionOrdersProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Select a production order to manage material issuance and finished goods receipt',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionOrderCard(ProductionOrderModel order) {
    final isSelected = _selectedProductionOrderId == order.id;
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: () => _selectProductionOrder(order),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.productName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildOrderInfoChip(
                    Icons.production_quantity_limits,
                    '${order.quantity} ${order.unit}',
                  ),
                  const SizedBox(width: 12),
                  _buildOrderInfoChip(
                    Icons.schedule,
                    DateFormat('MMM dd').format(order.dueDate),
                  ),
                  if (order.requiredMaterials?.isNotEmpty ?? false) ...[
                    const SizedBox(width: 12),
                    _buildOrderInfoChip(
                      Icons.inventory,
                      '${order.requiredMaterials!.length} materials',
                    ),
                  ],
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 16),
                _buildQuickActions(order),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ProductionOrderModel order) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: order.status == 'planned' || order.status == 'approved'
                ? () => _handleMaterialIssuance(order)
                : null,
            icon: const Icon(Icons.input, size: 18),
            label: const Text('Issue Materials'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                order.status == 'in_progress' || order.status == 'inProgress'
                    ? () => _handleFinishedGoodsReceipt(order)
                    : null,
            icon: const Icon(Icons.output, size: 18),
            label: const Text('Receive Goods'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialIssuanceTab() {
    if (_selectedProductionOrder == null) {
      return _buildNoSelectionMessage(
          'Select a production order to issue materials');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectedOrderHeader(),
          const SizedBox(height: 24),
          _buildMaterialAvailabilityCheck(),
          const SizedBox(height: 24),
          _buildMaterialIssuanceForm(),
        ],
      ),
    );
  }

  Widget _buildFinishedGoodsTab() {
    if (_selectedProductionOrder == null) {
      return _buildNoSelectionMessage(
          'Select a production order to receive finished goods');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectedOrderHeader(),
          const SizedBox(height: 24),
          _buildFinishedGoodsForm(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Production Integration Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildAnalyticsCards(),
          const SizedBox(height: 24),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildNoSelectionMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(0),
            child: const Text('Go to Orders'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedOrderHeader() {
    final order = _selectedProductionOrder!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Order: ${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.productName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Quantity: ${order.quantity} ${order.unit}'),
                const SizedBox(width: 24),
                Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(order.dueDate)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialAvailabilityCheck() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Material Availability Check',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _checkMaterialAvailability(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final availability = snapshot.data!;
                final allAvailable =
                    availability['allMaterialsAvailable'] as bool;
                final materials =
                    availability['materials'] as Map<String, dynamic>;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: allAvailable
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: allAvailable ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            allAvailable ? Icons.check_circle : Icons.warning,
                            color: allAvailable ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              allAvailable
                                  ? 'All materials are available'
                                  : 'Some materials have insufficient stock',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: allAvailable
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...materials.entries
                        .map((entry) => _buildMaterialAvailabilityItem(
                              entry.key,
                              entry.value as Map<String, dynamic>,
                            )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialAvailabilityItem(
      String materialId, Map<String, dynamic> data) {
    final isAvailable = data['isAvailable'] as bool;
    final required = data['required'] as double;
    final available = data['available'] as double;
    final shortage = data['shortage'] as double;
    final itemName = data['itemName'] as String? ?? 'Unknown Item';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.error,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Required: $required | Available: $available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (!isAvailable)
                  Text(
                    'Shortage: $shortage',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialIssuanceForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Issue Materials to Production',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Allow Partial Issuance'),
                    subtitle: const Text(
                        'Issue available quantities even if not fully available'),
                    value: false,
                    onChanged: (value) {
                      // Handle checkbox change
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional notes for material issuance',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _handleMaterialIssuance(_selectedProductionOrder!),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.input),
                label: Text(_isLoading ? 'Processing...' : 'Issue Materials'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedGoodsForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receive Finished Goods',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Quantity Produced',
                hintText: 'Enter actual quantity produced',
                border: OutlineInputBorder(),
                suffixText: 'units',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Labor Cost',
                      hintText: 'Optional',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Overhead Cost',
                      hintText: 'Optional',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Quality Status',
                border: OutlineInputBorder(),
              ),
              value: 'PENDING_QC',
              items: const [
                DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                DropdownMenuItem(
                    value: 'PENDING_QC', child: Text('Pending QC')),
                DropdownMenuItem(
                    value: 'QUARANTINE', child: Text('Quarantine')),
                DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
              ],
              onChanged: (value) {
                // Handle dropdown change
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional notes for finished goods receipt',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () =>
                        _handleFinishedGoodsReceipt(_selectedProductionOrder!),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.output),
                label: Text(
                    _isLoading ? 'Processing...' : 'Receive Finished Goods'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildAnalyticsCard(
          'Material Issues',
          '24',
          'This Month',
          Icons.input,
          Colors.orange,
        ),
        _buildAnalyticsCard(
          'Finished Goods',
          '18',
          'This Month',
          Icons.output,
          Colors.green,
        ),
        _buildAnalyticsCard(
          'Avg. Cycle Time',
          '3.2 days',
          'Last 30 days',
          Icons.schedule,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'Material Efficiency',
          '94.5%',
          'This Month',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Materials issued for PO-2024-001',
              '2 hours ago',
              Icons.input,
              Colors.orange,
            ),
            _buildActivityItem(
              'Finished goods received for PO-2024-002',
              '4 hours ago',
              Icons.output,
              Colors.green,
            ),
            _buildActivityItem(
              'Production order PO-2024-003 started',
              '6 hours ago',
              Icons.play_arrow,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
      case 'approved':
        return Colors.blue;
      case 'in_progress':
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _selectProductionOrder(ProductionOrderModel order) {
    setState(() {
      _selectedProductionOrderId = order.id;
      _selectedProductionOrder = order;
    });
  }

  Future<Map<String, dynamic>> _checkMaterialAvailability() async {
    if (_selectedProductionOrder == null) {
      return {'allMaterialsAvailable': false, 'materials': {}};
    }

    final service = ref.read(productionIntegrationServiceProvider);
    return await service.checkMaterialAvailability(
      productionOrderId: _selectedProductionOrder!.id ?? '',
    );
  }

  Future<void> _handleMaterialIssuance(ProductionOrderModel order) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(productionIntegrationServiceProvider);
      final result = await service.handleProductionStart(
        productionOrderId: order.id ?? '',
        issuedBy: 'CURRENT_USER', // Replace with actual user ID
        allowPartialIssuance: false,
        notes: 'Material issuance from production integration UI',
      );

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Materials issued successfully for ${order.orderNumber}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Refresh production orders
        ref.refresh(productionOrdersProvider);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to issue materials: ${result.errors.join(', ')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleFinishedGoodsReceipt(ProductionOrderModel order) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(productionIntegrationServiceProvider);
      final result = await service.handleProductionCompletion(
        productionOrderId: order.id ?? '',
        quantityProduced: order.quantity, // Use order quantity as default
        receivedBy: 'CURRENT_USER', // Replace with actual user ID
        qualityStatus: 'PENDING_QC',
        notes: 'Finished goods receipt from production integration UI',
      );

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Finished goods received successfully for ${order.orderNumber}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Refresh production orders
        ref.refresh(productionOrdersProvider);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to receive finished goods: ${result.errors.join(', ')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
