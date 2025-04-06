import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the severity of a production issue
enum IssueSeverity {
  critical, // Stops production, safety risk
  major, // Significant impact on production or quality
  moderate, // Notable impact but production can continue
  minor, // Small impact, easily resolved
  observation // Not an issue but worth noting
}

/// Enum representing the status of a production issue
enum IssueStatus {
  identified, // Newly identified, not yet addressed
  inProgress, // Being actively addressed
  resolved, // Issue has been resolved
  mitigated, // Problem reduced but not fully resolved
  closed, // Issue has been closed
  reopened // Previously resolved issue has recurred
}

/// Model to document production issues and incidents
class ProductionIssueModel {

  /// Creates an empty issue record with default values
  factory ProductionIssueModel.empty() {
    return ProductionIssueModel(
      id: '',
      productionOrderId: '',
      title: '',
      description: '',
      severity: IssueSeverity.moderate,
      status: IssueStatus.identified,
      reportedById: '',
      reportTime: DateTime.now(),
      affectedBatches: [],
    );
  }

  /// Creates a model from Firestore document
  factory ProductionIssueModel.fromJson(Map<String, dynamic> json) {
    return ProductionIssueModel(
      id: json['id'] as String,
      productionOrderId: json['productionOrderId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: IssueSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => IssueSeverity.moderate,
      ),
      status: IssueStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => IssueStatus.identified,
      ),
      reportedById: json['reportedById'] as String,
      reportedByName: json['reportedByName'] as String?,
      reportTime: (json['reportTime'] as Timestamp).toDate(),
      affectedBatches: List<String>.from(json['affectedBatches'] ?? []),
      issueLocation: json['issueLocation'] as String?,
      equipment: json['equipment'] as String?,
      product: json['product'] as String?,
      assignedToId: json['assignedToId'] as String?,
      assignedToName: json['assignedToName'] as String?,
      resolution: json['resolution'] as String?,
      resolutionTime: json['resolutionTime'] != null
          ? (json['resolutionTime'] as Timestamp).toDate()
          : null,
      rootCause: json['rootCause'] as String?,
      correctiveActions: List<String>.from(json['correctiveActions'] ?? []),
      preventiveActions: List<String>.from(json['preventiveActions'] ?? []),
      attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      relatedIssueIds: List<String>.from(json['relatedIssueIds'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
  const ProductionIssueModel({
    required this.id,
    required this.productionOrderId,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.reportedById,
    required this.reportTime,
    required this.affectedBatches,
    this.reportedByName,
    this.issueLocation,
    this.equipment,
    this.product,
    this.assignedToId,
    this.assignedToName,
    this.resolution,
    this.resolutionTime,
    this.rootCause,
    this.correctiveActions = const [],
    this.preventiveActions = const [],
    this.attachmentUrls = const [],
    this.tags = const [],
    this.relatedIssueIds = const [],
    this.metadata = const {},
  });

  /// Unique identifier for this issue
  final String id;

  /// Reference to the production order
  final String productionOrderId;

  /// Short title/name of the issue
  final String title;

  /// Detailed description of the issue
  final String description;

  /// Severity level of the issue
  final IssueSeverity severity;

  /// Current status of the issue
  final IssueStatus status;

  /// ID of the person who reported the issue
  final String reportedById;

  /// Name of the person who reported the issue
  final String? reportedByName;

  /// When the issue was reported
  final DateTime reportTime;

  /// List of batch numbers affected by this issue
  final List<String> affectedBatches;

  /// Location in the factory where the issue occurred
  final String? issueLocation;

  /// Equipment involved in the issue
  final String? equipment;

  /// Product affected by the issue
  final String? product;

  /// ID of the person assigned to resolve the issue
  final String? assignedToId;

  /// Name of the person assigned to resolve the issue
  final String? assignedToName;

  /// Description of how the issue was resolved
  final String? resolution;

  /// When the issue was resolved
  final DateTime? resolutionTime;

  /// Identified root cause of the issue
  final String? rootCause;

  /// Actions taken to correct the issue
  final List<String> correctiveActions;

  /// Actions taken to prevent future occurrences
  final List<String> preventiveActions;

  /// URLs to photos, documents, or videos related to this issue
  final List<String> attachmentUrls;

  /// Tags for categorizing and filtering issues
  final List<String> tags;

  /// IDs of related issues
  final List<String> relatedIssueIds;

  /// Additional metadata for extensibility
  final Map<String, dynamic> metadata;

  /// Converts model to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productionOrderId': productionOrderId,
      'title': title,
      'description': description,
      'severity': severity.toString(),
      'status': status.toString(),
      'reportedById': reportedById,
      'reportedByName': reportedByName,
      'reportTime': Timestamp.fromDate(reportTime),
      'affectedBatches': affectedBatches,
      'issueLocation': issueLocation,
      'equipment': equipment,
      'product': product,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'resolution': resolution,
      'resolutionTime':
          resolutionTime != null ? Timestamp.fromDate(resolutionTime!) : null,
      'rootCause': rootCause,
      'correctiveActions': correctiveActions,
      'preventiveActions': preventiveActions,
      'attachmentUrls': attachmentUrls,
      'tags': tags,
      'relatedIssueIds': relatedIssueIds,
      'metadata': metadata,
    };
  }

  /// Creates a copy of this model with specified fields replaced
  ProductionIssueModel copyWith({
    String? id,
    String? productionOrderId,
    String? title,
    String? description,
    IssueSeverity? severity,
    IssueStatus? status,
    String? reportedById,
    String? reportedByName,
    DateTime? reportTime,
    List<String>? affectedBatches,
    String? issueLocation,
    String? equipment,
    String? product,
    String? assignedToId,
    String? assignedToName,
    String? resolution,
    DateTime? resolutionTime,
    String? rootCause,
    List<String>? correctiveActions,
    List<String>? preventiveActions,
    List<String>? attachmentUrls,
    List<String>? tags,
    List<String>? relatedIssueIds,
    Map<String, dynamic>? metadata,
  }) {
    return ProductionIssueModel(
      id: id ?? this.id,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      reportedById: reportedById ?? this.reportedById,
      reportedByName: reportedByName ?? this.reportedByName,
      reportTime: reportTime ?? this.reportTime,
      affectedBatches: affectedBatches ?? this.affectedBatches,
      issueLocation: issueLocation ?? this.issueLocation,
      equipment: equipment ?? this.equipment,
      product: product ?? this.product,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      resolution: resolution ?? this.resolution,
      resolutionTime: resolutionTime ?? this.resolutionTime,
      rootCause: rootCause ?? this.rootCause,
      correctiveActions: correctiveActions ?? this.correctiveActions,
      preventiveActions: preventiveActions ?? this.preventiveActions,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      tags: tags ?? this.tags,
      relatedIssueIds: relatedIssueIds ?? this.relatedIssueIds,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Checks if the issue is resolved
  bool isResolved() {
    return status == IssueStatus.resolved || status == IssueStatus.closed;
  }

  /// Calculates resolution time in hours (if resolved)
  double? getResolutionTimeInHours() {
    if (resolutionTime == null) return null;
    return resolutionTime!.difference(reportTime).inMinutes / 60;
  }

  /// Determines if this is a high priority issue
  bool isHighPriority() {
    return severity == IssueSeverity.critical ||
        severity == IssueSeverity.major;
  }
}
