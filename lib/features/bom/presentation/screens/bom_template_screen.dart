import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bom_template.dart';
import '../widgets/template_card.dart';
import '../widgets/template_filter_bar.dart';
import '../widgets/template_search_bar.dart';
import 'bom_template_create_screen.dart';
import 'bom_template_detail_screen.dart';

class BomTemplateScreen extends ConsumerStatefulWidget {
  const BomTemplateScreen({super.key});

  @override
  ConsumerState<BomTemplateScreen> createState() => _BomTemplateScreenState();
}

class _BomTemplateScreenState extends ConsumerState<BomTemplateScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TemplateCategory? _selectedCategory;
  TemplateComplexity? _selectedComplexity;
  List<String> _selectedTags = [];
  bool _showOnlyPublic = false;
  bool _showOnlyMine = false;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('BOM Templates'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateTemplate(),
            tooltip: 'Create Template',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text('Import Templates'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Templates'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'statistics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('View Statistics'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Popular', icon: Icon(Icons.trending_up)),
            Tab(text: 'Recent', icon: Icon(Icons.access_time)),
            Tab(text: 'My Templates', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TemplateSearchBar(
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TemplateFilterBar(
                  selectedCategory: _selectedCategory,
                  selectedComplexity: _selectedComplexity,
                  selectedTags: _selectedTags,
                  showOnlyPublic: _showOnlyPublic,
                  showOnlyMine: _showOnlyMine,
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  onComplexityChanged: (complexity) {
                    setState(() {
                      _selectedComplexity = complexity;
                    });
                  },
                  onTagsChanged: (tags) {
                    setState(() {
                      _selectedTags = tags;
                    });
                  },
                  onPublicToggled: (value) {
                    setState(() {
                      _showOnlyPublic = value;
                    });
                  },
                  onMineToggled: (value) {
                    setState(() {
                      _showOnlyMine = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Templates Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTemplatesTab(),
                _buildPopularTemplatesTab(),
                _buildRecentTemplatesTab(),
                _buildMyTemplatesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateTemplate,
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
      ),
    );
  }

  Widget _buildAllTemplatesTab() {
    return FutureBuilder<List<BomTemplate>>(
      future: _searchTemplates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading templates',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final templates = snapshot.data ?? [];

        if (templates.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTemplateGrid(templates);
      },
    );
  }

  Widget _buildPopularTemplatesTab() {
    return FutureBuilder<List<BomTemplate>>(
      future: _getPopularTemplates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final templates = snapshot.data ?? [];
        return _buildTemplateGrid(templates);
      },
    );
  }

  Widget _buildRecentTemplatesTab() {
    return FutureBuilder<List<BomTemplate>>(
      future: _getRecentTemplates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final templates = snapshot.data ?? [];
        return _buildTemplateGrid(templates);
      },
    );
  }

  Widget _buildMyTemplatesTab() {
    return FutureBuilder<List<BomTemplate>>(
      future: _getMyTemplates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final templates = snapshot.data ?? [];

        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No templates created yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first template to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _navigateToCreateTemplate,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Template'),
                ),
              ],
            ),
          );
        }

        return _buildTemplateGrid(templates);
      },
    );
  }

  Widget _buildTemplateGrid(List<BomTemplate> templates) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return TemplateCard(
            template: template,
            onTap: () => _navigateToTemplateDetail(template),
            onUse: () => _useTemplate(template),
            onEdit: () => _editTemplate(template),
            onDuplicate: () => _duplicateTemplate(template),
            onDelete: () => _deleteTemplate(template),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No templates found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _navigateToCreateTemplate,
                icon: const Icon(Icons.add),
                label: const Text('Create Template'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToCreateTemplate() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const BomTemplateCreateScreen(),
          ),
        )
        .then((_) => setState(() {}));
  }

  void _navigateToTemplateDetail(BomTemplate template) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BomTemplateDetailScreen(template: template),
          ),
        )
        .then((_) => setState(() {}));
  }

  // Template actions
  void _useTemplate(BomTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _UseTemplateDialog(template: template),
    );
  }

  void _editTemplate(BomTemplate template) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BomTemplateCreateScreen(template: template),
          ),
        )
        .then((_) => setState(() {}));
  }

  void _duplicateTemplate(BomTemplate template) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _DuplicateTemplateDialog(template: template),
    );

    if (result != null) {
      try {
        // TODO: Call template use case to duplicate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template duplicated successfully')),
        );
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating template: $e')),
        );
      }
    }
  }

  void _deleteTemplate(BomTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
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
      try {
        // TODO: Call template use case to delete
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template deleted successfully')),
        );
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting template: $e')),
        );
      }
    }
  }

  // Menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'import':
        _importTemplates();
        break;
      case 'export':
        _exportTemplates();
        break;
      case 'statistics':
        _showStatistics();
        break;
    }
  }

  void _importTemplates() {
    // TODO: Implement template import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon')),
    );
  }

  void _exportTemplates() {
    // TODO: Implement template export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  void _showStatistics() {
    // TODO: Show template statistics
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics feature coming soon')),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedComplexity = null;
      _selectedTags.clear();
      _showOnlyPublic = false;
      _showOnlyMine = false;
    });
  }

  // Data fetching methods
  Future<List<BomTemplate>> _searchTemplates() async {
    // TODO: Implement actual search using template use case
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockTemplates();
  }

  Future<List<BomTemplate>> _getPopularTemplates() async {
    // TODO: Implement actual popular templates fetching
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockTemplates().take(6).toList();
  }

  Future<List<BomTemplate>> _getRecentTemplates() async {
    // TODO: Implement actual recent templates fetching
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockTemplates().take(4).toList();
  }

  Future<List<BomTemplate>> _getMyTemplates() async {
    // TODO: Implement actual user templates fetching
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockTemplates().take(2).toList();
  }

  List<BomTemplate> _getMockTemplates() {
    return [
      BomTemplate(
        id: '1',
        name: 'Milk Processing Standard',
        description: 'Standard template for milk processing operations',
        category: TemplateCategory.dairy,
        complexity: TemplateComplexity.intermediate,
        version: '1.0',
        isActive: true,
        isPublic: true,
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        items: [],
        tags: ['milk', 'processing', 'standard'],
        usageCount: 45,
        rating: 4.5,
      ),
      BomTemplate(
        id: '2',
        name: 'Cheese Production Basic',
        description: 'Basic template for cheese production',
        category: TemplateCategory.dairy,
        complexity: TemplateComplexity.simple,
        version: '2.1',
        isActive: true,
        isPublic: true,
        createdBy: 'user2',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        items: [],
        tags: ['cheese', 'production', 'basic'],
        usageCount: 32,
        rating: 4.2,
      ),
    ];
  }
}

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
  void dispose() {
    _bomCodeController.dispose();
    _bomNameController.dispose();
    _productCodeController.dispose();
    _baseQuantityController.dispose();
    _baseUnitController.dispose();
    super.dispose();
  }

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
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'BOM code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bomNameController,
                decoration: const InputDecoration(
                  labelText: 'BOM Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'BOM name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productCodeController,
                decoration: const InputDecoration(
                  labelText: 'Product Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Product code is required';
                  }
                  return null;
                },
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
                        if (value?.isEmpty ?? true) {
                          return 'Quantity is required';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Invalid number';
                        }
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
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Unit is required';
                        }
                        return null;
                      },
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
          onPressed: _createBomFromTemplate,
          child: const Text('Create BOM'),
        ),
      ],
    );
  }

  void _createBomFromTemplate() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement BOM creation from template
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('BOM created from template successfully')),
      );
    }
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
