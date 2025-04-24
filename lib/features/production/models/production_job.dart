// Production job model to represent production jobs in the system
// This model is used by the ProductionService for managing the production pipeline

import '../../../core/errors/exceptions.dart';

/// Represents the status of a production job
enum ProductionJobStatus {
  scheduled,
  inProgress,
  onHold,
  completed,
  cancelled;

  /// Get the display name of this status
  String get displayName {
    switch (this) {
      case ProductionJobStatus.scheduled:
        return 'Scheduled';
      case ProductionJobStatus.inProgress:
        return 'In Progress';
      case ProductionJobStatus.onHold:
        return 'On Hold';
      case ProductionJobStatus.completed:
        return 'Completed';
      case ProductionJobStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Create a status from a string
  static ProductionJobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return ProductionJobStatus.scheduled;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return ProductionJobStatus.inProgress;
      case 'on_hold':
      case 'onhold':
      case 'on hold':
        return ProductionJobStatus.onHold;
      case 'completed':
      case 'complete':
      case 'done':
        return ProductionJobStatus.completed;
      case 'cancelled':
      case 'canceled':
        return ProductionJobStatus.cancelled;
      default:
        throw ArgumentError('Invalid production job status: $status');
    }
  }

  @override
  String toString() {
    switch (this) {
      case ProductionJobStatus.scheduled:
        return 'scheduled';
      case ProductionJobStatus.inProgress:
        return 'in_progress';
      case ProductionJobStatus.onHold:
        return 'on_hold';
      case ProductionJobStatus.completed:
        return 'completed';
      case ProductionJobStatus.cancelled:
        return 'cancelled';
    }
  }
}

/// Represents the priority level of a production job
enum ProductionPriority {
  low,
  medium,
  high,
  urgent;

  /// Get the display name of this priority
  String get displayName {
    switch (this) {
      case ProductionPriority.low:
        return 'Low';
      case ProductionPriority.medium:
        return 'Medium';
      case ProductionPriority.high:
        return 'High';
      case ProductionPriority.urgent:
        return 'Urgent';
    }
  }

  /// Create a priority from a string
  static ProductionPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return ProductionPriority.low;
      case 'medium':
      case 'normal':
      case 'standard':
        return ProductionPriority.medium;
      case 'high':
        return ProductionPriority.high;
      case 'urgent':
      case 'critical':
        return ProductionPriority.urgent;
      default:
        throw ArgumentError('Invalid production priority: $priority');
    }
  }

  @override
  String toString() {
    switch (this) {
      case ProductionPriority.low:
        return 'low';
      case ProductionPriority.medium:
        return 'medium';
      case ProductionPriority.high:
        return 'high';
      case ProductionPriority.urgent:
        return 'urgent';
    }
  }
}

/// Represents a production job in the system
class ProductionJob {
  final String id;
  final String orderId;
  final String location;
  final DateTime startTime;
  final DateTime estimatedEndTime;
  final ProductionJobStatus status;
  final ProductionPriority priority;
  final double? percentComplete;
  final String? assignedTo;
  final String? notes;
  final List<QualityCheck>? qualityChecks;
  final List<ProductionIssue>? issues;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  /// Creates a new production job
  ProductionJob({
    required this.id,
    required this.orderId,
    required this.location,
    required this.startTime,
    required this.estimatedEndTime,
    required this.status,
    required this.priority,
    this.percentComplete,
    this.assignedTo,
    this.notes,
    this.qualityChecks,
    this.issues,
    this.completedAt,
    this.updatedAt,
  });

  /// Creates a production job from a JSON map
  factory ProductionJob.fromJson(Map<String, dynamic> json) {
    try {
      return ProductionJob(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        location: json['location'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        estimatedEndTime: DateTime.parse(json['estimatedEndTime'] as String),
        status: ProductionJobStatus.fromString(json['status'] as String),
        priority: ProductionPriority.fromString(json['priority'] as String),
        percentComplete: json['percentComplete'] != null
            ? (json['percentComplete'] as num).toDouble()
            : null,
        assignedTo: json['assignedTo'] as String?,
        notes: json['notes'] as String?,
        qualityChecks: json['qualityChecks'] != null
            ? (json['qualityChecks'] as List)
                .map((e) => QualityCheck.fromJson(e))
                .toList()
            : null,
        issues: json['issues'] != null
            ? (json['issues'] as List)
                .map((e) => ProductionIssue.fromJson(e))
                .toList()
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      throw DataParsingException(
          'Error parsing production job: ${e.toString()}');
    }
  }

  /// Converts this production job to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'estimatedEndTime': estimatedEndTime.toIso8601String(),
      'status': status.toString(),
      'priority': priority.toString(),
      if (percentComplete != null) 'percentComplete': percentComplete,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (notes != null) 'notes': notes,
      if (qualityChecks != null)
        'qualityChecks': qualityChecks!.map((e) => e.toJson()).toList(),
      if (issues != null) 'issues': issues!.map((e) => e.toJson()).toList(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this production job with the given fields replaced
  ProductionJob copyWith({
    String? id,
    String? orderId,
    String? location,
    DateTime? startTime,
    DateTime? estimatedEndTime,
    ProductionJobStatus? status,
    ProductionPriority? priority,
    double? percentComplete,
    String? assignedTo,
    String? notes,
    List<QualityCheck>? qualityChecks,
    List<ProductionIssue>? issues,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return ProductionJob(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      estimatedEndTime: estimatedEndTime ?? this.estimatedEndTime,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      percentComplete: percentComplete ?? this.percentComplete,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
      qualityChecks: qualityChecks ?? this.qualityChecks,
      issues: issues ?? this.issues,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate the duration of this production job in hours
  double get durationHours {
    return estimatedEndTime.difference(startTime).inMinutes / 60.0;
  }

  /// Check if this production job can be updated
  bool get canBeUpdated {
    return status != ProductionJobStatus.completed &&
        status != ProductionJobStatus.cancelled;
  }

  /// Check if this production job is currently active
  bool get isActive {
    return status == ProductionJobStatus.inProgress;
  }

  /// Check if this production job is delayed
  bool get isDelayed {
    if (status == ProductionJobStatus.completed ||
        status == ProductionJobStatus.cancelled) {
      return false;
    }

    final now = DateTime.now();
    if (status == ProductionJobStatus.scheduled && now.isAfter(startTime)) {
      return true;
    }

    if (status == ProductionJobStatus.inProgress &&
        now.isAfter(estimatedEndTime)) {
      return true;
    }

    return false;
  }
}

/// Represents a quality check in a production job
class QualityCheck {
  final String id;
  final String checkName;
  final bool passed;
  final String? notes;
  final DateTime timestamp;
  final String performedBy;

  /// Creates a new quality check
  QualityCheck({
    required this.id,
    required this.checkName,
    required this.passed,
    this.notes,
    required this.timestamp,
    required this.performedBy,
  });

  /// Creates a quality check from a JSON map
  factory QualityCheck.fromJson(Map<String, dynamic> json) {
    try {
      return QualityCheck(
        id: json['id'] as String,
        checkName: json['checkName'] as String,
        passed: json['passed'] as bool,
        notes: json['notes'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        performedBy: json['performedBy'] as String,
      );
    } catch (e) {
      throw DataParsingException(
          'Error parsing quality check: ${e.toString()}');
    }
  }

  /// Converts this quality check to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkName': checkName,
      'passed': passed,
      if (notes != null) 'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
    };
  }
}

/// Represents an issue in a production job
class ProductionIssue {
  final String id;
  final String description;
  final String severity;
  final DateTime reportedAt;
  final String reportedBy;
  final String? assignedTo;
  final bool resolved;
  final String? resolution;
  final DateTime? resolvedAt;

  /// Creates a new production issue
  ProductionIssue({
    required this.id,
    required this.description,
    required this.severity,
    required this.reportedAt,
    required this.reportedBy,
    this.assignedTo,
    required this.resolved,
    this.resolution,
    this.resolvedAt,
  });

  /// Creates a production issue from a JSON map
  factory ProductionIssue.fromJson(Map<String, dynamic> json) {
    try {
      return ProductionIssue(
        id: json['id'] as String,
        description: json['description'] as String,
        severity: json['severity'] as String,
        reportedAt: DateTime.parse(json['reportedAt'] as String),
        reportedBy: json['reportedBy'] as String,
        assignedTo: json['assignedTo'] as String?,
        resolved: json['resolved'] as bool,
        resolution: json['resolution'] as String?,
        resolvedAt: json['resolvedAt'] != null
            ? DateTime.parse(json['resolvedAt'] as String)
            : null,
      );
    } catch (e) {
      throw DataParsingException(
          'Error parsing production issue: ${e.toString()}');
    }
  }

  /// Converts this production issue to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'severity': severity,
      'reportedAt': reportedAt.toIso8601String(),
      'reportedBy': reportedBy,
      if (assignedTo != null) 'assignedTo': assignedTo,
      'resolved': resolved,
      if (resolution != null) 'resolution': resolution,
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this production issue with the given fields replaced
  ProductionIssue copyWith({
    String? id,
    String? description,
    String? severity,
    DateTime? reportedAt,
    String? reportedBy,
    String? assignedTo,
    bool? resolved,
    String? resolution,
    DateTime? resolvedAt,
  }) {
    return ProductionIssue(
      id: id ?? this.id,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      resolved: resolved ?? this.resolved,
      resolution: resolution ?? this.resolution,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
