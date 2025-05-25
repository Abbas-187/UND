import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../widgets/mobile_optimized_widgets.dart';
import 'mobile_bom_item_screen.dart';

class MobileBomScreen extends ConsumerStatefulWidget {
  const MobileBomScreen({super.key});

  @override
  ConsumerState<MobileBomScreen> createState() => _MobileBomScreenState();
}

class _MobileBomScreenState extends ConsumerState<MobileBomScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';
  BomStatus? _selectedStatus;
  BomType? _selectedType;

  // Mock data - in real implementation, this would come from providers
  List<BillOfMaterials> _boms = [];
  List<BillOfMaterials> _filteredBoms = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
    _filteredBoms = _boms;

    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _boms = [
      BillOfMaterials(
        id: '1',
        bomCode: 'BOM-2024-001',
        bomName: 'Milk Processing Line A',
        productId: 'PROD-001',
        productCode: 'PROD-001',
        productName: 'Whole Milk 1L',
        bomType: BomType.production,
        status: BomStatus.active,
        version: '1.0',
        baseQuantity: 1000.0,
        baseUnit: 'L',
        totalCost: 850.0,
        laborCost: 150.0,
        overheadCost: 50.0,
        createdBy: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [],
      ),
      BillOfMaterials(
        id: '2',
        bomCode: 'BOM-2024-002',
        bomName: 'Cheese Production Batch 5',
        productId: 'PROD-002',
        productCode: 'PROD-002',
        productName: 'Cheddar Cheese 500g',
        bomType: BomType.production,
        status: BomStatus.draft,
        version: '2.1',
        baseQuantity: 500.0,
        baseUnit: 'kg',
        totalCost: 1250.0,
        laborCost: 200.0,
        overheadCost: 100.0,
        createdBy: 'Jane Smith',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        items: [],
      ),
      BillOfMaterials(
        id: '3',
        bomCode: 'BOM-2024-003',
        bomName: 'Yogurt Manufacturing',
        productId: 'PROD-003',
        productCode: 'PROD-003',
        productName: 'Greek Yogurt 200g',
        bomType: BomType.sales,
        status: BomStatus.active,
        version: '1.5',
        baseQuantity: 200.0,
        baseUnit: 'g',
        totalCost: 320.0,
        laborCost: 80.0,
        overheadCost: 20.0,
        createdBy: 'Mike Johnson',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        items: [],
      ),
    ];
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreBoms();
    }
  }

  void _loadMoreBoms() {
    // Implement infinite scroll loading
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _filterBoms() {
    setState(() {
      _filteredBoms = _boms.where((bom) {
        final matchesSearch = _searchQuery.isEmpty ||
            bom.bomName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bom.bomCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bom.productName.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesStatus =
            _selectedStatus == null || bom.status == _selectedStatus;
        final matchesType =
            _selectedType == null || bom.bomType == _selectedType;

        return matchesSearch && matchesStatus && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          _buildFilterChips(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBomList(_filteredBoms),
                _buildBomList(_filteredBoms
                    .where((b) => b.status == BomStatus.active)
                    .toList()),
                _buildBomList(_filteredBoms
                    .where((b) => b.status == BomStatus.draft)
                    .toList()),
                _buildBomList(_filteredBoms
                    .where((b) => b.createdBy == 'John Doe')
                    .toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: MobileFloatingActionButton(
        onPressed: _createNewBom,
        icon: Icons.add,
        label: 'New BOM',
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('BOMs'),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
                _filterBoms();
              }
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sync',
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Sync'),
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
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search BOMs...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _filterBoms();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _filterBoms();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All Status'),
            selected: _selectedStatus == null,
            onSelected: (selected) {
              setState(() {
                _selectedStatus = null;
              });
              _filterBoms();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Active'),
            selected: _selectedStatus == BomStatus.active,
            onSelected: (selected) {
              setState(() {
                _selectedStatus = selected ? BomStatus.active : null;
              });
              _filterBoms();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Draft'),
            selected: _selectedStatus == BomStatus.draft,
            onSelected: (selected) {
              setState(() {
                _selectedStatus = selected ? BomStatus.draft : null;
              });
              _filterBoms();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Production'),
            selected: _selectedType == BomType.production,
            onSelected: (selected) {
              setState(() {
                _selectedType = selected ? BomType.production : null;
              });
              _filterBoms();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Packaging'),
            selected: _selectedType == BomType.sales,
            onSelected: (selected) {
              setState(() {
                _selectedType = selected ? BomType.sales : null;
              });
              _filterBoms();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Active'),
          Tab(text: 'Draft'),
          Tab(text: 'My BOMs'),
        ],
      ),
    );
  }

  Widget _buildBomList(List<BillOfMaterials> boms) {
    if (boms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No BOMs found'),
            Text('Pull down to refresh or create a new BOM'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBoms,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: boms.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == boms.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final bom = boms[index];
          return MobileBomCard(
            bom: bom,
            onTap: () => _navigateToBomDetail(bom),
            onEdit: () => _editBom(bom),
            onDuplicate: () => _duplicateBom(bom),
            onDelete: () => _deleteBom(bom),
            onShare: () => _shareBom(bom),
          );
        },
      ),
    );
  }

  Future<void> _refreshBoms() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadMockData();
      _filterBoms();
    });
  }

  void _navigateToBomDetail(BillOfMaterials bom) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MobileBomItemScreen(bom: bom),
      ),
    );
  }

  void _createNewBom() {
    // Navigate to BOM creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create new BOM feature coming soon')),
    );
  }

  void _editBom(BillOfMaterials bom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${bom.bomCode}')),
    );
  }

  void _duplicateBom(BillOfMaterials bom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicate ${bom.bomCode}')),
    );
  }

  void _deleteBom(BillOfMaterials bom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete BOM'),
        content: Text('Are you sure you want to delete ${bom.bomCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${bom.bomCode} deleted')),
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

  void _shareBom(BillOfMaterials bom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share ${bom.bomCode}')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sync':
        _syncBoms();
        break;
      case 'export':
        _exportBoms();
        break;
      case 'settings':
        _openSettings();
        break;
    }
  }

  void _syncBoms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing BOMs...')),
    );
  }

  void _exportBoms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature coming soon')),
    );
  }
}
