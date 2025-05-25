import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../widgets/mobile_optimized_widgets.dart';

class MobileBomItemScreen extends ConsumerStatefulWidget {
  final BillOfMaterials bom;

  const MobileBomItemScreen({super.key, required this.bom});

  @override
  ConsumerState<MobileBomItemScreen> createState() =>
      _MobileBomItemScreenState();
}

class _MobileBomItemScreenState extends ConsumerState<MobileBomItemScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  bool _isExpanded = false;
  bool _isLoading = false;
  List<BomItem> _bomItems = [];

  // Expandable sections state
  bool _headerExpanded = true;
  bool _costExpanded = false;
  bool _itemsExpanded = true;
  bool _notesExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockBomItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMockBomItems() {
    // Mock BOM items data
    _bomItems = [
      BomItem(
        id: '1',
        bomId: widget.bom.id,
        itemId: 'ITEM-001',
        itemCode: 'MILK-RAW-001',
        itemName: 'Raw Milk Grade A',
        itemDescription: 'Raw Milk Grade A',
        itemType: BomItemType.rawMaterial,
        quantity: 950.0,
        unit: 'L',
        costPerUnit: 0.65,
        totalCost: 617.5,
        consumptionType: ConsumptionType.fixed,
        sequenceNumber: 1,
        status: BomItemStatus.active,
        notes: 'High quality raw milk from certified suppliers',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      BomItem(
        id: '2',
        bomId: widget.bom.id,
        itemId: 'ITEM-002',
        itemCode: 'PKG-BTL-1L',
        itemName: '1L Plastic Bottle',
        itemDescription: '1L Plastic Bottle',
        itemType: BomItemType.packaging,
        quantity: 1000.0,
        unit: 'pcs',
        costPerUnit: 0.025,
        totalCost: 25.0,
        consumptionType: ConsumptionType.fixed,
        sequenceNumber: 2,
        status: BomItemStatus.active,
        notes: 'Food grade plastic bottles',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      BomItem(
        id: '3',
        bomId: widget.bom.id,
        itemId: 'ITEM-003',
        itemCode: 'LBL-MILK-1L',
        itemName: 'Milk Label 1L',
        itemDescription: 'Milk Label 1L',
        itemType: BomItemType.packaging,
        quantity: 1000.0,
        unit: 'pcs',
        costPerUnit: 0.005,
        totalCost: 5.0,
        consumptionType: ConsumptionType.fixed,
        sequenceNumber: 3,
        status: BomItemStatus.active,
        notes: 'Waterproof labels with nutritional information',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeaderSection(),
            _buildTabBarSection(),
            _buildContentSection(),
          ],
        ),
      ),
      floatingActionButton: MobileFloatingActionButton(
        onPressed: _addNewItem,
        icon: Icons.add,
        label: 'Add Item',
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.bom.bomCode),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _editBom,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: MobileExpandableCard(
          title: 'BOM Details',
          isExpanded: _headerExpanded,
          onToggle: () => setState(() => _headerExpanded = !_headerExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('BOM Name', widget.bom.bomName),
              _buildDetailRow('Product', widget.bom.productName),
              _buildDetailRow('Type', _formatBomType(widget.bom.bomType)),
              _buildDetailRow('Status', _formatBomStatus(widget.bom.status)),
              _buildDetailRow('Version', widget.bom.version),
              _buildDetailRow('Base Quantity',
                  '${widget.bom.baseQuantity} ${widget.bom.baseUnit}'),
              _buildDetailRow('Created By', widget.bom.createdBy ?? 'Unknown'),
              _buildDetailRow('Created', _formatDate(widget.bom.createdAt)),
              _buildDetailRow('Updated', _formatDate(widget.bom.updatedAt)),
              const SizedBox(height: 16),
              _buildCostSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Cost',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '\$${widget.bom.totalCost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Material Cost'),
              Text(
                  '\$${widget.bom.calculateMaterialCost(widget.bom.baseQuantity).toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Labor Cost'),
              Text('\$${widget.bom.laborCost.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overhead Cost'),
              Text('\$${widget.bom.overheadCost.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSection() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Items', icon: Icon(Icons.list)),
            Tab(text: 'Cost', icon: Icon(Icons.attach_money)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildItemsTab(),
          _buildCostTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildItemsTab() {
    if (_bomItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No items in this BOM'),
            Text('Tap + to add items'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bomItems.length,
      itemBuilder: (context, index) {
        final item = _bomItems[index];
        return MobileBomItemCard(
          item: item,
          onTap: () => _viewItemDetail(item),
          onEdit: () => _editItem(item),
          onDelete: () => _deleteItem(item),
        );
      },
    );
  }

  Widget _buildCostTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCostBreakdownCard(),
          const SizedBox(height: 16),
          _buildCostAnalysisCard(),
          const SizedBox(height: 16),
          _buildCostTrendCard(),
        ],
      ),
    );
  }

  Widget _buildCostBreakdownCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCostItem('Raw Materials', 617.5, widget.bom.totalCost),
            _buildCostItem('Packaging', 30.0, widget.bom.totalCost),
            _buildCostItem('Labor', widget.bom.laborCost, widget.bom.totalCost),
            _buildCostItem(
                'Overhead', widget.bom.overheadCost, widget.bom.totalCost),
            const Divider(),
            _buildCostItem('Total', widget.bom.totalCost, widget.bom.totalCost,
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(String label, double cost, double total,
      {bool isTotal = false}) {
    final percentage = (cost / total * 100);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${cost.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostAnalysisCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildAnalysisRow('Cost per Unit',
                '\$${(widget.bom.totalCost / widget.bom.baseQuantity).toStringAsFixed(3)}'),
            _buildAnalysisRow('Material %',
                '${((widget.bom.calculateMaterialCost(widget.bom.baseQuantity) / widget.bom.totalCost) * 100).toStringAsFixed(1)}%'),
            _buildAnalysisRow('Labor %',
                '${((widget.bom.laborCost / widget.bom.totalCost) * 100).toStringAsFixed(1)}%'),
            _buildAnalysisRow('Overhead %',
                '${((widget.bom.overheadCost / widget.bom.totalCost) * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCostTrendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Trend (Last 30 Days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Cost trend chart would go here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHistoryItem(
          'BOM Created',
          'Initial BOM creation with 3 items',
          widget.bom.createdAt,
          Icons.add_circle,
          Colors.green,
        ),
        _buildHistoryItem(
          'Item Added',
          'Added packaging materials',
          DateTime.now().subtract(const Duration(days: 1)),
          Icons.add,
          Colors.blue,
        ),
        _buildHistoryItem(
          'Cost Updated',
          'Material costs updated due to supplier change',
          DateTime.now().subtract(const Duration(hours: 6)),
          Icons.attach_money,
          Colors.orange,
        ),
        _buildHistoryItem(
          'Status Changed',
          'Status changed from Draft to Active',
          DateTime.now().subtract(const Duration(hours: 2)),
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String title, String description, DateTime timestamp,
      IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _addNewItem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new item feature coming soon')),
    );
  }

  void _editBom() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit BOM feature coming soon')),
    );
  }

  void _viewItemDetail(BomItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MobileItemDetailSheet(item: item),
    );
  }

  void _editItem(BomItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${item.itemCode}')),
    );
  }

  void _deleteItem(BomItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.itemCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _bomItems.removeWhere((i) => i.id == item.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.itemCode} deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate BOM feature coming soon')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export BOM feature coming soon')),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share BOM feature coming soon')),
        );
        break;
      case 'delete':
        _deleteBom();
        break;
    }
  }

  void _deleteBom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete BOM'),
        content: Text('Are you sure you want to delete ${widget.bom.bomCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.bom.bomCode} deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatBomType(BomType type) {
    switch (type) {
      case BomType.production:
        return 'Production';
      case BomType.engineering:
        return 'Engineering';
      case BomType.sales:
        return 'Sales';
      case BomType.costing:
        return 'Costing';
      case BomType.planning:
        return 'Planning';
    }
  }

  String _formatBomStatus(BomStatus status) {
    switch (status) {
      case BomStatus.draft:
        return 'Draft';
      case BomStatus.active:
        return 'Active';
      case BomStatus.inactive:
        return 'Inactive';
      case BomStatus.obsolete:
        return 'Obsolete';
      case BomStatus.underReview:
        return 'Under Review';
      case BomStatus.approved:
        return 'Approved';
      case BomStatus.rejected:
        return 'Rejected';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Sticky tab bar delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
