import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report.dart';

class ReportBuilderScreen extends ConsumerStatefulWidget {
  final ReportDefinition? existingReport;

  const ReportBuilderScreen({super.key, this.existingReport});

  @override
  ConsumerState<ReportBuilderScreen> createState() =>
      _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends ConsumerState<ReportBuilderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Report configuration
  ReportType _selectedType = ReportType.custom;
  List<ReportField> _availableFields = [];
  List<ReportField> _selectedFields = [];
  List<ReportFilter> _filters = [];
  List<ReportSort> _sorting = [];
  List<String> _groupBy = [];
  List<ReportChart> _charts = [];
  Map<String, dynamic> _parameters = {};
  bool _isTemplate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAvailableFields();

    if (widget.existingReport != null) {
      _loadExistingReport();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadAvailableFields() {
    // Mock data - in real implementation, load from repository
    _availableFields = [
      const ReportField(
        id: 'bom_code',
        name: 'BOM Code',
        dataType: 'string',
        source: 'boms',
        isGroupable: true,
        isFilterable: true,
        isSortable: true,
      ),
      const ReportField(
        id: 'bom_name',
        name: 'BOM Name',
        dataType: 'string',
        source: 'boms',
        isFilterable: true,
        isSortable: true,
      ),
      const ReportField(
        id: 'product_name',
        name: 'Product Name',
        dataType: 'string',
        source: 'boms',
        isGroupable: true,
        isFilterable: true,
        isSortable: true,
      ),
      const ReportField(
        id: 'total_cost',
        name: 'Total Cost',
        dataType: 'decimal',
        source: 'boms',
        aggregationType: AggregationType.sum,
        format: 'currency',
        isSortable: true,
      ),
      const ReportField(
        id: 'item_code',
        name: 'Item Code',
        dataType: 'string',
        source: 'bom_items',
        isGroupable: true,
        isFilterable: true,
        isSortable: true,
      ),
      const ReportField(
        id: 'item_name',
        name: 'Item Name',
        dataType: 'string',
        source: 'bom_items',
        isFilterable: true,
        isSortable: true,
      ),
      const ReportField(
        id: 'quantity',
        name: 'Quantity',
        dataType: 'decimal',
        source: 'bom_items',
        aggregationType: AggregationType.sum,
        isSortable: true,
      ),
      const ReportField(
        id: 'unit_cost',
        name: 'Unit Cost',
        dataType: 'decimal',
        source: 'bom_items',
        format: 'currency',
        isSortable: true,
      ),
    ];
  }

  void _loadExistingReport() {
    final report = widget.existingReport!;
    _nameController.text = report.name;
    _descriptionController.text = report.description;
    _selectedType = report.type;
    _selectedFields = List.from(report.fields);
    _filters = List.from(report.filters);
    _sorting = List.from(report.sorting);
    _groupBy = List.from(report.groupBy);
    _charts = List.from(report.charts);
    _parameters = Map.from(report.parameters);
    _isTemplate = report.isTemplate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingReport != null ? 'Edit Report' : 'Create Report'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Basic Info'),
            Tab(icon: Icon(Icons.view_column), text: 'Fields'),
            Tab(icon: Icon(Icons.filter_list), text: 'Filters'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Charts'),
            Tab(icon: Icon(Icons.preview), text: 'Preview'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveReport,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildFieldsTab(),
          _buildFiltersTab(),
          _buildChartsTab(),
          _buildPreviewTab(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Report Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Report name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Report Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ReportType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_formatReportTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Save as Template'),
              subtitle: const Text(
                  'Make this report available as a template for others'),
              value: _isTemplate,
              onChanged: (value) {
                setState(() {
                  _isTemplate = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsTab() {
    return Row(
      children: [
        // Available fields
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  children: [
                    const Icon(Icons.storage),
                    const SizedBox(width: 8),
                    Text(
                      'Available Fields',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableFields.length,
                  itemBuilder: (context, index) {
                    final field = _availableFields[index];
                    final isSelected =
                        _selectedFields.any((f) => f.id == field.id);

                    return ListTile(
                      title: Text(field.name),
                      subtitle: Text('${field.dataType} • ${field.source}'),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.add),
                      onTap: isSelected ? null : () => _addField(field),
                      enabled: !isSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        // Selected fields
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  children: [
                    const Icon(Icons.view_column),
                    const SizedBox(width: 8),
                    Text(
                      'Selected Fields',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedFields.isEmpty
                    ? const Center(
                        child: Text('No fields selected'),
                      )
                    : ReorderableListView.builder(
                        itemCount: _selectedFields.length,
                        onReorder: _reorderFields,
                        itemBuilder: (context, index) {
                          final field = _selectedFields[index];
                          return ListTile(
                            key: ValueKey(field.id),
                            title: Text(field.name),
                            subtitle:
                                Text('${field.dataType} • ${field.source}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _removeField(field),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              Text(
                'Report Filters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _selectedFields.isEmpty ? null : _addFilter,
                icon: const Icon(Icons.add),
                label: const Text('Add Filter'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filters.isEmpty
              ? const Center(
                  child: Text('No filters configured'),
                )
              : ListView.builder(
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final field = _selectedFields.firstWhere(
                      (f) => f.id == filter.fieldId,
                      orElse: () => _availableFields.firstWhere(
                        (f) => f.id == filter.fieldId,
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(field.name),
                        subtitle: Text('${filter.operator} ${filter.value}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeFilter(index),
                        ),
                        onTap: () => _editFilter(index),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChartsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.bar_chart),
              const SizedBox(width: 8),
              Text(
                'Charts & Visualizations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _selectedFields.isEmpty ? null : _addChart,
                icon: const Icon(Icons.add),
                label: const Text('Add Chart'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _charts.isEmpty
              ? const Center(
                  child: Text('No charts configured'),
                )
              : ListView.builder(
                  itemCount: _charts.length,
                  itemBuilder: (context, index) {
                    final chart = _charts[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(chart.title),
                        subtitle: Text(
                            '${_formatChartTypeName(chart.type)} • ${chart.xAxisField} vs ${chart.yAxisField}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeChart(index),
                        ),
                        onTap: () => _editChart(index),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Preview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isEmpty
                        ? 'Untitled Report'
                        : _nameController.text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _descriptionController.text.isEmpty
                        ? 'No description'
                        : _descriptionController.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: Text(_formatReportTypeName(_selectedType)),
                        avatar: const Icon(Icons.category, size: 16),
                      ),
                      const SizedBox(width: 8),
                      if (_isTemplate)
                        const Chip(
                          label: Text('Template'),
                          avatar: Icon(Icons.bookmark_outline, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedFields.isNotEmpty) ...[
            Text(
              'Fields (${_selectedFields.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _selectedFields.map((field) {
                  return ListTile(
                    dense: true,
                    title: Text(field.name),
                    subtitle: Text('${field.dataType} • ${field.source}'),
                    trailing: field.aggregationType != null
                        ? Chip(
                            label:
                                Text(field.aggregationType!.name.toUpperCase()),
                            backgroundColor: Colors.blue.shade100,
                          )
                        : null,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_filters.isNotEmpty) ...[
            Text(
              'Filters (${_filters.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _filters.map((filter) {
                  final field = _selectedFields.firstWhere(
                    (f) => f.id == filter.fieldId,
                    orElse: () => _availableFields.firstWhere(
                      (f) => f.id == filter.fieldId,
                    ),
                  );
                  return ListTile(
                    dense: true,
                    title: Text(field.name),
                    subtitle: Text('${filter.operator} ${filter.value}'),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_charts.isNotEmpty) ...[
            Text(
              'Charts (${_charts.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _charts.map((chart) {
                  return ListTile(
                    dense: true,
                    title: Text(chart.title),
                    subtitle: Text(
                        '${_formatChartTypeName(chart.type)} • ${chart.xAxisField} vs ${chart.yAxisField}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addField(ReportField field) {
    setState(() {
      _selectedFields.add(field);
    });
  }

  void _removeField(ReportField field) {
    setState(() {
      _selectedFields.removeWhere((f) => f.id == field.id);
      // Remove related filters and charts
      _filters.removeWhere((filter) => filter.fieldId == field.id);
      _charts.removeWhere((chart) =>
          chart.xAxisField == field.id ||
          chart.yAxisField == field.id ||
          chart.groupByField == field.id);
    });
  }

  void _reorderFields(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final field = _selectedFields.removeAt(oldIndex);
      _selectedFields.insert(newIndex, field);
    });
  }

  void _addFilter() {
    // Show filter dialog
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        availableFields: _selectedFields.where((f) => f.isFilterable).toList(),
        onFilterAdded: (filter) {
          setState(() {
            _filters.add(filter);
          });
        },
      ),
    );
  }

  void _removeFilter(int index) {
    setState(() {
      _filters.removeAt(index);
    });
  }

  void _editFilter(int index) {
    // Show edit filter dialog
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        availableFields: _selectedFields.where((f) => f.isFilterable).toList(),
        existingFilter: _filters[index],
        onFilterAdded: (filter) {
          setState(() {
            _filters[index] = filter;
          });
        },
      ),
    );
  }

  void _addChart() {
    // Show chart dialog
    showDialog(
      context: context,
      builder: (context) => _ChartDialog(
        availableFields: _selectedFields,
        onChartAdded: (chart) {
          setState(() {
            _charts.add(chart);
          });
        },
      ),
    );
  }

  void _removeChart(int index) {
    setState(() {
      _charts.removeAt(index);
    });
  }

  void _editChart(int index) {
    // Show edit chart dialog
    showDialog(
      context: context,
      builder: (context) => _ChartDialog(
        availableFields: _selectedFields,
        existingChart: _charts[index],
        onChartAdded: (chart) {
          setState(() {
            _charts[index] = chart;
          });
        },
      ),
    );
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0); // Go to basic info tab
      return;
    }

    if (_selectedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one field')),
      );
      _tabController.animateTo(1); // Go to fields tab
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reportDefinition = ReportDefinition(
        id: widget.existingReport?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        fields: _selectedFields,
        filters: _filters,
        sorting: _sorting,
        groupBy: _groupBy,
        charts: _charts,
        parameters: _parameters,
        isTemplate: _isTemplate,
        createdBy: 'current_user', // Get from auth
        createdAt: widget.existingReport?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Save using use case
      // await ref.read(advancedReportingUseCaseProvider).createReportDefinition(reportDefinition);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved successfully')),
        );
        Navigator.of(context).pop(reportDefinition);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving report: $e')),
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

  String _formatReportTypeName(ReportType type) {
    switch (type) {
      case ReportType.costAnalysis:
        return 'Cost Analysis';
      case ReportType.materialUsage:
        return 'Material Usage';
      case ReportType.supplierPerformance:
        return 'Supplier Performance';
      case ReportType.qualityCompliance:
        return 'Quality Compliance';
      case ReportType.varianceAnalysis:
        return 'Variance Analysis';
      case ReportType.productionEfficiency:
        return 'Production Efficiency';
      case ReportType.inventoryImpact:
        return 'Inventory Impact';
      case ReportType.custom:
        return 'Custom';
    }
  }

  String _formatChartTypeName(ChartType type) {
    switch (type) {
      case ChartType.bar:
        return 'Bar Chart';
      case ChartType.line:
        return 'Line Chart';
      case ChartType.pie:
        return 'Pie Chart';
      case ChartType.scatter:
        return 'Scatter Plot';
      case ChartType.area:
        return 'Area Chart';
      case ChartType.table:
        return 'Table';
    }
  }
}

// Filter Dialog
class _FilterDialog extends StatefulWidget {
  final List<ReportField> availableFields;
  final ReportFilter? existingFilter;
  final Function(ReportFilter) onFilterAdded;

  const _FilterDialog({
    required this.availableFields,
    this.existingFilter,
    required this.onFilterAdded,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  ReportField? _selectedField;
  String _selectedOperator = 'equals';
  final _valueController = TextEditingController();

  final List<String> _operators = [
    'equals',
    'not_equals',
    'contains',
    'starts_with',
    'ends_with',
    'greater_than',
    'less_than',
    'between',
    'in',
    'not_in',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingFilter != null) {
      _selectedField = widget.availableFields.firstWhere(
        (f) => f.id == widget.existingFilter!.fieldId,
      );
      _selectedOperator = widget.existingFilter!.operator;
      _valueController.text = widget.existingFilter!.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingFilter != null ? 'Edit Filter' : 'Add Filter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ReportField>(
            value: _selectedField,
            decoration: const InputDecoration(
              labelText: 'Field',
              border: OutlineInputBorder(),
            ),
            items: widget.availableFields.map((field) {
              return DropdownMenuItem(
                value: field,
                child: Text(field.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedField = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedOperator,
            decoration: const InputDecoration(
              labelText: 'Operator',
              border: OutlineInputBorder(),
            ),
            items: _operators.map((operator) {
              return DropdownMenuItem(
                value: operator,
                child: Text(operator.replaceAll('_', ' ').toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedOperator = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedField != null && _valueController.text.isNotEmpty
              ? () {
                  final filter = ReportFilter(
                    fieldId: _selectedField!.id,
                    operator: _selectedOperator,
                    value: _valueController.text,
                  );
                  widget.onFilterAdded(filter);
                  Navigator.of(context).pop();
                }
              : null,
          child: Text(widget.existingFilter != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}

// Chart Dialog
class _ChartDialog extends StatefulWidget {
  final List<ReportField> availableFields;
  final ReportChart? existingChart;
  final Function(ReportChart) onChartAdded;

  const _ChartDialog({
    required this.availableFields,
    this.existingChart,
    required this.onChartAdded,
  });

  @override
  State<_ChartDialog> createState() => _ChartDialogState();
}

class _ChartDialogState extends State<_ChartDialog> {
  final _titleController = TextEditingController();
  ChartType _selectedType = ChartType.bar;
  ReportField? _xAxisField;
  ReportField? _yAxisField;
  ReportField? _groupByField;

  @override
  void initState() {
    super.initState();
    if (widget.existingChart != null) {
      _titleController.text = widget.existingChart!.title;
      _selectedType = widget.existingChart!.type;
      _xAxisField = widget.availableFields.firstWhere(
        (f) => f.id == widget.existingChart!.xAxisField,
      );
      _yAxisField = widget.availableFields.firstWhere(
        (f) => f.id == widget.existingChart!.yAxisField,
      );
      if (widget.existingChart!.groupByField != null) {
        _groupByField = widget.availableFields.firstWhere(
          (f) => f.id == widget.existingChart!.groupByField,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingChart != null ? 'Edit Chart' : 'Add Chart'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Chart Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChartType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Chart Type',
                border: OutlineInputBorder(),
              ),
              items: ChartType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportField>(
              value: _xAxisField,
              decoration: const InputDecoration(
                labelText: 'X-Axis Field',
                border: OutlineInputBorder(),
              ),
              items: widget.availableFields.map((field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text(field.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _xAxisField = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportField>(
              value: _yAxisField,
              decoration: const InputDecoration(
                labelText: 'Y-Axis Field',
                border: OutlineInputBorder(),
              ),
              items: widget.availableFields.map((field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text(field.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _yAxisField = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportField?>(
              value: _groupByField,
              decoration: const InputDecoration(
                labelText: 'Group By (Optional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<ReportField?>(
                  value: null,
                  child: Text('None'),
                ),
                ...widget.availableFields
                    .where((f) => f.isGroupable)
                    .map((field) {
                  return DropdownMenuItem(
                    value: field,
                    child: Text(field.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _groupByField = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.isNotEmpty &&
                  _xAxisField != null &&
                  _yAxisField != null
              ? () {
                  final chart = ReportChart(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    type: _selectedType,
                    xAxisField: _xAxisField!.id,
                    yAxisField: _yAxisField!.id,
                    groupByField: _groupByField?.id,
                  );
                  widget.onChartAdded(chart);
                  Navigator.of(context).pop();
                }
              : null,
          child: Text(widget.existingChart != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
