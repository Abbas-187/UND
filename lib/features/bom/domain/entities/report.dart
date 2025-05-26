import 'package:equatable/equatable.dart';

enum ReportType {
  costAnalysis,
  materialUsage,
  supplierPerformance,
  qualityCompliance,
  varianceAnalysis,
  productionEfficiency,
  inventoryImpact,
  custom
}

enum ReportFormat { pdf, excel, csv, json, html }

enum ChartType { bar, line, pie, scatter, area, table }

enum AggregationType { sum, average, count, min, max, median, percentage }

class ReportField extends Equatable {

  const ReportField({
    required this.id,
    required this.name,
    required this.dataType,
    required this.source,
    this.isRequired = false,
    this.isGroupable = false,
    this.isFilterable = false,
    this.isSortable = false,
    this.aggregationType,
    this.format,
    this.metadata = const {},
  });

  factory ReportField.fromJson(Map<String, dynamic> json) {
    return ReportField(
      id: json['id'] as String,
      name: json['name'] as String,
      dataType: json['dataType'] as String,
      source: json['source'] as String,
      isRequired: json['isRequired'] as bool? ?? false,
      isGroupable: json['isGroupable'] as bool? ?? false,
      isFilterable: json['isFilterable'] as bool? ?? false,
      isSortable: json['isSortable'] as bool? ?? false,
      aggregationType: json['aggregationType'] != null
          ? AggregationType.values.firstWhere(
              (e) => e.name == json['aggregationType'],
              orElse: () => AggregationType.sum,
            )
          : null,
      format: json['format'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
  final String id;
  final String name;
  final String dataType;
  final String source;
  final bool isRequired;
  final bool isGroupable;
  final bool isFilterable;
  final bool isSortable;
  final AggregationType? aggregationType;
  final String? format;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        id,
        name,
        dataType,
        source,
        isRequired,
        isGroupable,
        isFilterable,
        isSortable,
        aggregationType,
        format,
        metadata,
      ];

  ReportField copyWith({
    String? id,
    String? name,
    String? dataType,
    String? source,
    bool? isRequired,
    bool? isGroupable,
    bool? isFilterable,
    bool? isSortable,
    AggregationType? aggregationType,
    String? format,
    Map<String, dynamic>? metadata,
  }) {
    return ReportField(
      id: id ?? this.id,
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      source: source ?? this.source,
      isRequired: isRequired ?? this.isRequired,
      isGroupable: isGroupable ?? this.isGroupable,
      isFilterable: isFilterable ?? this.isFilterable,
      isSortable: isSortable ?? this.isSortable,
      aggregationType: aggregationType ?? this.aggregationType,
      format: format ?? this.format,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dataType': dataType,
      'source': source,
      'isRequired': isRequired,
      'isGroupable': isGroupable,
      'isFilterable': isFilterable,
      'isSortable': isSortable,
      'aggregationType': aggregationType?.name,
      'format': format,
      'metadata': metadata,
    };
  }
}

class ReportFilter extends Equatable {

  const ReportFilter({
    required this.fieldId,
    required this.operator,
    required this.value,
    this.logicalOperator,
  });

  factory ReportFilter.fromJson(Map<String, dynamic> json) {
    return ReportFilter(
      fieldId: json['fieldId'] as String,
      operator: json['operator'] as String,
      value: json['value'],
      logicalOperator: json['logicalOperator'] as String?,
    );
  }
  final String fieldId;
  final String operator;
  final dynamic value;
  final String? logicalOperator;

  @override
  List<Object?> get props => [fieldId, operator, value, logicalOperator];

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'operator': operator,
      'value': value,
      'logicalOperator': logicalOperator,
    };
  }
}

class ReportSort extends Equatable {

  const ReportSort({
    required this.fieldId,
    this.ascending = true,
  });

  factory ReportSort.fromJson(Map<String, dynamic> json) {
    return ReportSort(
      fieldId: json['fieldId'] as String,
      ascending: json['ascending'] as bool? ?? true,
    );
  }
  final String fieldId;
  final bool ascending;

  @override
  List<Object?> get props => [fieldId, ascending];

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'ascending': ascending,
    };
  }
}

class ReportChart extends Equatable {

  const ReportChart({
    required this.id,
    required this.title,
    required this.type,
    required this.xAxisField,
    required this.yAxisField,
    this.groupByField,
    this.options = const {},
  });

  factory ReportChart.fromJson(Map<String, dynamic> json) {
    return ReportChart(
      id: json['id'] as String,
      title: json['title'] as String,
      type: ChartType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChartType.table,
      ),
      xAxisField: json['xAxisField'] as String,
      yAxisField: json['yAxisField'] as String,
      groupByField: json['groupByField'] as String?,
      options: Map<String, dynamic>.from(json['options'] as Map? ?? {}),
    );
  }
  final String id;
  final String title;
  final ChartType type;
  final String xAxisField;
  final String yAxisField;
  final String? groupByField;
  final Map<String, dynamic> options;

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        xAxisField,
        yAxisField,
        groupByField,
        options,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'xAxisField': xAxisField,
      'yAxisField': yAxisField,
      'groupByField': groupByField,
      'options': options,
    };
  }
}

class ReportDefinition extends Equatable {

  const ReportDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.fields,
    this.filters = const [],
    this.sorting = const [],
    this.groupBy = const [],
    this.charts = const [],
    this.parameters = const {},
    this.isTemplate = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportDefinition.fromJson(Map<String, dynamic> json) {
    return ReportDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.custom,
      ),
      fields: (json['fields'] as List)
          .map((f) => ReportField.fromJson(f as Map<String, dynamic>))
          .toList(),
      filters: (json['filters'] as List? ?? [])
          .map((f) => ReportFilter.fromJson(f as Map<String, dynamic>))
          .toList(),
      sorting: (json['sorting'] as List? ?? [])
          .map((s) => ReportSort.fromJson(s as Map<String, dynamic>))
          .toList(),
      groupBy: List<String>.from(json['groupBy'] as List? ?? []),
      charts: (json['charts'] as List? ?? [])
          .map((c) => ReportChart.fromJson(c as Map<String, dynamic>))
          .toList(),
      parameters: Map<String, dynamic>.from(json['parameters'] as Map? ?? {}),
      isTemplate: json['isTemplate'] as bool? ?? false,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final List<ReportField> fields;
  final List<ReportFilter> filters;
  final List<ReportSort> sorting;
  final List<String> groupBy;
  final List<ReportChart> charts;
  final Map<String, dynamic> parameters;
  final bool isTemplate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        fields,
        filters,
        sorting,
        groupBy,
        charts,
        parameters,
        isTemplate,
        createdBy,
        createdAt,
        updatedAt,
      ];

  ReportDefinition copyWith({
    String? id,
    String? name,
    String? description,
    ReportType? type,
    List<ReportField>? fields,
    List<ReportFilter>? filters,
    List<ReportSort>? sorting,
    List<String>? groupBy,
    List<ReportChart>? charts,
    Map<String, dynamic>? parameters,
    bool? isTemplate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      fields: fields ?? this.fields,
      filters: filters ?? this.filters,
      sorting: sorting ?? this.sorting,
      groupBy: groupBy ?? this.groupBy,
      charts: charts ?? this.charts,
      parameters: parameters ?? this.parameters,
      isTemplate: isTemplate ?? this.isTemplate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'fields': fields.map((f) => f.toJson()).toList(),
      'filters': filters.map((f) => f.toJson()).toList(),
      'sorting': sorting.map((s) => s.toJson()).toList(),
      'groupBy': groupBy,
      'charts': charts.map((c) => c.toJson()).toList(),
      'parameters': parameters,
      'isTemplate': isTemplate,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ReportResult extends Equatable {

  const ReportResult({
    required this.id,
    required this.definitionId,
    required this.name,
    required this.data,
    this.summary = const {},
    this.charts = const [],
    required this.totalRows,
    required this.generatedAt,
    required this.executionTime,
    this.metadata = const {},
  });

  factory ReportResult.fromJson(Map<String, dynamic> json) {
    return ReportResult(
      id: json['id'] as String,
      definitionId: json['definitionId'] as String,
      name: json['name'] as String,
      data: List<Map<String, dynamic>>.from(json['data'] as List),
      summary: Map<String, dynamic>.from(json['summary'] as Map? ?? {}),
      charts: (json['charts'] as List? ?? [])
          .map((c) => ReportChart.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalRows: json['totalRows'] as int,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      executionTime: Duration(milliseconds: json['executionTime'] as int),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
  final String id;
  final String definitionId;
  final String name;
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> summary;
  final List<ReportChart> charts;
  final int totalRows;
  final DateTime generatedAt;
  final Duration executionTime;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        id,
        definitionId,
        name,
        data,
        summary,
        charts,
        totalRows,
        generatedAt,
        executionTime,
        metadata,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'definitionId': definitionId,
      'name': name,
      'data': data,
      'summary': summary,
      'charts': charts.map((c) => c.toJson()).toList(),
      'totalRows': totalRows,
      'generatedAt': generatedAt.toIso8601String(),
      'executionTime': executionTime.inMilliseconds,
      'metadata': metadata,
    };
  }
}

class ReportSchedule extends Equatable {

  const ReportSchedule({
    required this.id,
    required this.reportDefinitionId,
    required this.name,
    required this.cronExpression,
    required this.format,
    this.recipients = const [],
    this.isActive = true,
    this.lastRun,
    this.nextRun,
    required this.createdBy,
    required this.createdAt,
  });

  factory ReportSchedule.fromJson(Map<String, dynamic> json) {
    return ReportSchedule(
      id: json['id'] as String,
      reportDefinitionId: json['reportDefinitionId'] as String,
      name: json['name'] as String,
      cronExpression: json['cronExpression'] as String,
      format: ReportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ReportFormat.pdf,
      ),
      recipients: List<String>.from(json['recipients'] as List? ?? []),
      isActive: json['isActive'] as bool? ?? true,
      lastRun: json['lastRun'] != null
          ? DateTime.parse(json['lastRun'] as String)
          : null,
      nextRun: json['nextRun'] != null
          ? DateTime.parse(json['nextRun'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  final String id;
  final String reportDefinitionId;
  final String name;
  final String cronExpression;
  final ReportFormat format;
  final List<String> recipients;
  final bool isActive;
  final DateTime? lastRun;
  final DateTime? nextRun;
  final String createdBy;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        reportDefinitionId,
        name,
        cronExpression,
        format,
        recipients,
        isActive,
        lastRun,
        nextRun,
        createdBy,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportDefinitionId': reportDefinitionId,
      'name': name,
      'cronExpression': cronExpression,
      'format': format.name,
      'recipients': recipients,
      'isActive': isActive,
      'lastRun': lastRun?.toIso8601String(),
      'nextRun': nextRun?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
