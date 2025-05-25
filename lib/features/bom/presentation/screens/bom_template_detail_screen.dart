import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bom_template.dart';
import 'bom_template_create_screen.dart';

class BomTemplateDetailScreen extends ConsumerStatefulWidget {
  final BomTemplate template;

  const BomTemplateDetailScreen({super.key, required this.template});

  @override
  ConsumerState<BomTemplateDetailScreen> createState() =>
      _BomTemplateDetailScreenState();
}

class _BomTemplateDetailScreenState
    extends ConsumerState<BomTemplateDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTemplate,
            tooltip: 'Edit Template',
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.info)),
            Tab(text: 'Items', icon: Icon(Icons.list)),
            Tab(text: 'Usage', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildItemsTab(),
          _buildUsageTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _useTemplate,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Use Template'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildDetailsCard(),
          const SizedBox(height: 16),
          _buildTagsCard(),
          const SizedBox(height: 16),
          _buildValidationRulesCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getCategoryColor(widget.template.category),
              _getCategoryColor(widget.template.category).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.template.category),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.template.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCategoryName(widget.template.category),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatComplexityName(widget.template.complexity),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(widget.template.category),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.template.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.star,
                    label: widget.template.rating.toStringAsFixed(1),
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    icon: Icons.download,
                    label: '${widget.template.usageCount}',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    icon: Icons.inventory_2,
                    label: '${widget.template.items.length}',
                    color: Colors.blue,
                  ),
                  const Spacer(),
                  if (widget.template.isPublic)
                    const Icon(Icons.public, color: Colors.white, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Version', widget.template.version),
            _buildDetailRow('Created By', widget.template.createdBy),
            _buildDetailRow('Created', _formatDate(widget.template.createdAt)),
            _buildDetailRow('Updated', _formatDate(widget.template.updatedAt)),
            _buildDetailRow(
                'Status', widget.template.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow(
                'Visibility', widget.template.isPublic ? 'Public' : 'Private'),
          ],
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

  Widget _buildTagsCard() {
    if (widget.template.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.template.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationRulesCard() {
    if (widget.template.validationRules.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validation Rules',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...widget.template.validationRules.map((rule) {
              return ListTile(
                leading: const Icon(Icons.rule, color: Colors.green),
                title: Text(_getValidationRuleDescription(rule)),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab() {
    if (widget.template.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No items in this template'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.template.items.length,
      itemBuilder: (context, index) {
        final item = widget.template.items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${item.itemCode}'),
                Text('Type: ${item.itemType}'),
                Text('Quantity: ${item.quantity} ${item.unit}'),
                if (item.description != null)
                  Text('Description: ${item.description}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.isOptional)
                  const Chip(
                    label: Text('Optional', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.orange,
                  ),
                if (item.isVariable)
                  const Chip(
                    label: Text('Variable', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue,
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildUsageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUsageStatsCard(),
          const SizedBox(height: 16),
          _buildRecentUsageCard(),
        ],
      ),
    );
  }

  Widget _buildUsageStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Uses',
                    '${widget.template.usageCount}',
                    Icons.download,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Rating',
                    widget.template.rating.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'This Month',
                    '12', // Mock data
                    Icons.calendar_month,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'This Week',
                    '3', // Mock data
                    Icons.date_range,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Usage',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Mock recent usage data
            _buildUsageItem(
                'BOM-2024-001', 'Milk Processing Line A', '2 hours ago'),
            _buildUsageItem(
                'BOM-2024-002', 'Cheese Production Batch 5', '1 day ago'),
            _buildUsageItem(
                'BOM-2024-003', 'Yogurt Manufacturing', '3 days ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageItem(String bomCode, String bomName, String timeAgo) {
    return ListTile(
      leading: const Icon(Icons.description),
      title: Text(bomName),
      subtitle: Text('BOM: $bomCode'),
      trailing: Text(
        timeAgo,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  // Helper methods
  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.dairy:
        return Colors.blue;
      case TemplateCategory.packaging:
        return Colors.green;
      case TemplateCategory.processing:
        return Colors.orange;
      case TemplateCategory.quality:
        return Colors.purple;
      case TemplateCategory.maintenance:
        return Colors.red;
      case TemplateCategory.custom:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.dairy:
        return Icons.local_drink;
      case TemplateCategory.packaging:
        return Icons.inventory_2;
      case TemplateCategory.processing:
        return Icons.precision_manufacturing;
      case TemplateCategory.quality:
        return Icons.verified;
      case TemplateCategory.maintenance:
        return Icons.build;
      case TemplateCategory.custom:
        return Icons.extension;
    }
  }

  String _formatCategoryName(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.dairy:
        return 'Dairy';
      case TemplateCategory.packaging:
        return 'Packaging';
      case TemplateCategory.processing:
        return 'Processing';
      case TemplateCategory.quality:
        return 'Quality';
      case TemplateCategory.maintenance:
        return 'Maintenance';
      case TemplateCategory.custom:
        return 'Custom';
    }
  }

  String _formatComplexityName(TemplateComplexity complexity) {
    switch (complexity) {
      case TemplateComplexity.simple:
        return 'Simple';
      case TemplateComplexity.intermediate:
        return 'Intermediate';
      case TemplateComplexity.advanced:
        return 'Advanced';
      case TemplateComplexity.expert:
        return 'Expert';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getValidationRuleDescription(String rule) {
    switch (rule) {
      case 'require_dairy_items':
        return 'Require at least one dairy item';
      case 'max_items_50':
        return 'Maximum 50 items allowed';
      case 'require_packaging':
        return 'Require packaging items';
      default:
        return rule;
    }
  }

  // Action methods
  void _editTemplate() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                BomTemplateCreateScreen(template: widget.template),
          ),
        )
        .then((_) => setState(() {}));
  }

  void _useTemplate() {
    showDialog(
      context: context,
      builder: (context) => _UseTemplateDialog(template: widget.template),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        _duplicateTemplate();
        break;
      case 'export':
        _exportTemplate();
        break;
      case 'share':
        _shareTemplate();
        break;
      case 'delete':
        _deleteTemplate();
        break;
    }
  }

  void _duplicateTemplate() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _DuplicateTemplateDialog(template: widget.template),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template duplicated successfully')),
      );
    }
  }

  void _exportTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  void _shareTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }

  void _deleteTemplate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content:
            Text('Are you sure you want to delete "${widget.template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template deleted successfully')),
      );
    }
  }
}

// Supporting dialog widgets
class _UseTemplateDialog extends StatefulWidget {
  final BomTemplate template;

  const _UseTemplateDialog({required this.template});

  @override
  State<_UseTemplateDialog> createState() => _UseTemplateDialogState();
}

class _UseTemplateDialogState extends State<_UseTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bomCodeController = TextEditingController();
  final _bomNameController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _baseQuantityController = TextEditingController(text: '1.0');
  final _baseUnitController = TextEditingController(text: 'kg');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Use Template: ${widget.template.name}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _bomCodeController,
                decoration: const InputDecoration(
                  labelText: 'BOM Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bomNameController,
                decoration: const InputDecoration(
                  labelText: 'BOM Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productCodeController,
                decoration: const InputDecoration(
                  labelText: 'Product Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _baseQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Base Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(value!) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _baseUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Base Unit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('BOM created from template successfully')),
              );
            }
          },
          child: const Text('Create BOM'),
        ),
      ],
    );
  }
}

class _DuplicateTemplateDialog extends StatefulWidget {
  final BomTemplate template;

  const _DuplicateTemplateDialog({required this.template});

  @override
  State<_DuplicateTemplateDialog> createState() =>
      _DuplicateTemplateDialogState();
}

class _DuplicateTemplateDialogState extends State<_DuplicateTemplateDialog> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.template.name} (Copy)';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Template'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'New Template Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_nameController.text),
          child: const Text('Duplicate'),
        ),
      ],
    );
  }
}
