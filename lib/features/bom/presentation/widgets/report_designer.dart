import 'package:flutter/material.dart';
import '../../domain/entities/report.dart';

class ReportDesigner extends StatefulWidget {
  final List<ReportField> availableFields;
  final List<ReportField> selectedFields;
  final Function(ReportField) onFieldAdded;
  final Function(ReportField) onFieldRemoved;
  final Function(int, int) onFieldReordered;

  const ReportDesigner({
    super.key,
    required this.availableFields,
    required this.selectedFields,
    required this.onFieldAdded,
    required this.onFieldRemoved,
    required this.onFieldReordered,
  });

  @override
  State<ReportDesigner> createState() => _ReportDesignerState();
}

class _ReportDesignerState extends State<ReportDesigner> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Available fields panel
        Expanded(
          flex: 1,
          child: _buildAvailableFieldsPanel(),
        ),
        const VerticalDivider(),
        // Selected fields panel
        Expanded(
          flex: 1,
          child: _buildSelectedFieldsPanel(),
        ),
      ],
    );
  }

  Widget _buildAvailableFieldsPanel() {
    return Column(
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
            itemCount: widget.availableFields.length,
            itemBuilder: (context, index) {
              final field = widget.availableFields[index];
              final isSelected =
                  widget.selectedFields.any((f) => f.id == field.id);

              return Draggable<ReportField>(
                data: field,
                feedback: Material(
                  elevation: 4,
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      field.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: _buildFieldTile(field, isSelected),
                ),
                child: _buildFieldTile(field, isSelected),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFieldsPanel() {
    return Column(
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
          child: widget.selectedFields.isEmpty
              ? DragTarget<ReportField>(
                  onAccept: (field) => widget.onFieldAdded(field),
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 48,
                              color: candidateData.isNotEmpty
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              candidateData.isNotEmpty
                                  ? 'Drop field here'
                                  : 'Drag fields here to build your report',
                              style: TextStyle(
                                color: candidateData.isNotEmpty
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ReorderableListView.builder(
                  itemCount: widget.selectedFields.length,
                  onReorder: widget.onFieldReordered,
                  itemBuilder: (context, index) {
                    final field = widget.selectedFields[index];
                    return DragTarget<ReportField>(
                      key: ValueKey(field.id),
                      onAccept: (droppedField) {
                        if (!widget.selectedFields
                            .any((f) => f.id == droppedField.id)) {
                          widget.onFieldAdded(droppedField);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: candidateData.isNotEmpty
                              ? BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: ListTile(
                            leading: const Icon(Icons.drag_handle),
                            title: Text(field.name),
                            subtitle:
                                Text('${field.dataType} • ${field.source}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (field.aggregationType != null)
                                  Chip(
                                    label: Text(
                                      field.aggregationType!.name.toUpperCase(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.blue.shade100,
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () => widget.onFieldRemoved(field),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFieldTile(ReportField field, bool isSelected) {
    return ListTile(
      title: Text(field.name),
      subtitle: Text('${field.dataType} • ${field.source}'),
      leading: Icon(_getFieldIcon(field.dataType)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (field.isFilterable)
            const Icon(Icons.filter_list, size: 16, color: Colors.blue),
          if (field.isSortable)
            const Icon(Icons.sort, size: 16, color: Colors.green),
          if (field.isGroupable)
            const Icon(Icons.group_work, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.add_circle_outline),
        ],
      ),
      onTap: isSelected ? null : () => widget.onFieldAdded(field),
      enabled: !isSelected,
    );
  }

  IconData _getFieldIcon(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'string':
        return Icons.text_fields;
      case 'integer':
      case 'decimal':
        return Icons.numbers;
      case 'date':
      case 'datetime':
        return Icons.calendar_today;
      case 'boolean':
        return Icons.check_box;
      default:
        return Icons.data_object;
    }
  }
}

class ReportFieldCard extends StatelessWidget {
  final ReportField field;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ReportFieldCard({
    super.key,
    required this.field,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getFieldIcon(field.dataType),
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      field.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : null,
                          ),
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${field.dataType} • ${field.source}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  if (field.isFilterable)
                    _buildCapabilityChip(
                        'Filter', Icons.filter_list, Colors.blue),
                  if (field.isSortable)
                    _buildCapabilityChip('Sort', Icons.sort, Colors.green),
                  if (field.isGroupable)
                    _buildCapabilityChip(
                        'Group', Icons.group_work, Colors.orange),
                  if (field.aggregationType != null)
                    _buildCapabilityChip(
                      field.aggregationType!.name.toUpperCase(),
                      Icons.functions,
                      Colors.purple,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityChip(String label, IconData icon, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
      avatar: Icon(icon, size: 12),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  IconData _getFieldIcon(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'string':
        return Icons.text_fields;
      case 'integer':
      case 'decimal':
        return Icons.numbers;
      case 'date':
      case 'datetime':
        return Icons.calendar_today;
      case 'boolean':
        return Icons.check_box;
      default:
        return Icons.data_object;
    }
  }
}

class ReportPreview extends StatelessWidget {
  final ReportDefinition definition;
  final ReportResult? result;

  const ReportPreview({
    super.key,
    required this.definition,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildFieldsSection(context),
          if (definition.filters.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildFiltersSection(context),
          ],
          if (definition.charts.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildChartsSection(context),
          ],
          if (result != null) ...[
            const SizedBox(height: 16),
            _buildDataSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              definition.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(_formatReportTypeName(definition.type)),
                  avatar: const Icon(Icons.category, size: 16),
                ),
                if (definition.isTemplate)
                  const Chip(
                    label: Text('Template'),
                    avatar: Icon(Icons.bookmark_outline, size: 16),
                  ),
                Chip(
                  label: Text('${definition.fields.length} Fields'),
                  avatar: const Icon(Icons.view_column, size: 16),
                ),
                if (definition.filters.isNotEmpty)
                  Chip(
                    label: Text('${definition.filters.length} Filters'),
                    avatar: const Icon(Icons.filter_list, size: 16),
                  ),
                if (definition.charts.isNotEmpty)
                  Chip(
                    label: Text('${definition.charts.length} Charts'),
                    avatar: const Icon(Icons.bar_chart, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fields',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...definition.fields.map((field) {
              return ListTile(
                dense: true,
                leading: Icon(_getFieldIcon(field.dataType)),
                title: Text(field.name),
                subtitle: Text('${field.dataType} • ${field.source}'),
                trailing: field.aggregationType != null
                    ? Chip(
                        label: Text(field.aggregationType!.name.toUpperCase()),
                        backgroundColor: Colors.blue.shade100,
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...definition.filters.map((filter) {
              final field = definition.fields.firstWhere(
                (f) => f.id == filter.fieldId,
              );
              return ListTile(
                dense: true,
                leading: const Icon(Icons.filter_list),
                title: Text(field.name),
                subtitle: Text('${filter.operator} ${filter.value}'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Charts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...definition.charts.map((chart) {
              return ListTile(
                dense: true,
                leading: Icon(_getChartIcon(chart.type)),
                title: Text(chart.title),
                subtitle: Text(
                    '${chart.type.name} • ${chart.xAxisField} vs ${chart.yAxisField}'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Generated ${result!.totalRows} rows in ${result!.executionTime.inMilliseconds}ms',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (result!.data.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: definition.fields.map((field) {
                    return DataColumn(label: Text(field.name));
                  }).toList(),
                  rows: result!.data.take(5).map((row) {
                    return DataRow(
                      cells: definition.fields.map((field) {
                        return DataCell(Text(row[field.id]?.toString() ?? ''));
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              if (result!.data.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '... and ${result!.data.length - 5} more rows',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getFieldIcon(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'string':
        return Icons.text_fields;
      case 'integer':
      case 'decimal':
        return Icons.numbers;
      case 'date':
      case 'datetime':
        return Icons.calendar_today;
      case 'boolean':
        return Icons.check_box;
      default:
        return Icons.data_object;
    }
  }

  IconData _getChartIcon(ChartType type) {
    switch (type) {
      case ChartType.bar:
        return Icons.bar_chart;
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.pie:
        return Icons.pie_chart;
      case ChartType.scatter:
        return Icons.scatter_plot;
      case ChartType.area:
        return Icons.area_chart;
      case ChartType.table:
        return Icons.table_chart;
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
}
