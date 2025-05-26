/// Enhanced quality status enum for Phase 3 Quality Control Integration
enum QualityStatus {
  // Standard quality statuses for inventory management
  available('AVAILABLE', 'Fit for use/sale', true),
  pendingInspection('PENDING_INSPECTION', 'Awaiting QC assessment', false),
  rejected('REJECTED', 'Failed QC, not usable', false),
  rework('REWORK', 'Failed QC but can be reworked', false),
  blocked('BLOCKED', 'Temporarily not usable', false),

  // Legacy statuses for backward compatibility
  excellent('EXCELLENT', 'Excellent quality', true),
  good('GOOD', 'Good quality', true),
  acceptable('ACCEPTABLE', 'Acceptable quality', true),
  warning('WARNING', 'Warning quality', false),
  critical('CRITICAL', 'Critical quality', false);

  const QualityStatus(this.code, this.description, this.isAvailableForUse);

  /// Status code for database storage
  final String code;

  /// Human-readable description
  final String description;

  /// Whether items with this status can be used/allocated
  final bool isAvailableForUse;

  /// Get all statuses that are available for use/allocation
  static List<QualityStatus> get availableStatuses =>
      QualityStatus.values.where((status) => status.isAvailableForUse).toList();

  /// Get all statuses that are not available for use/allocation
  static List<QualityStatus> get unavailableStatuses => QualityStatus.values
      .where((status) => !status.isAvailableForUse)
      .toList();

  /// Parse quality status from string code
  static QualityStatus fromCode(String code) {
    return QualityStatus.values.firstWhere(
      (status) => status.code == code.toUpperCase(),
      orElse: () => QualityStatus.pendingInspection,
    );
  }

  /// Parse quality status from legacy string values
  static QualityStatus fromLegacyString(String value) {
    switch (value.toLowerCase()) {
      case 'excellent':
        return QualityStatus.excellent;
      case 'good':
        return QualityStatus.good;
      case 'acceptable':
        return QualityStatus.acceptable;
      case 'warning':
        return QualityStatus.warning;
      case 'critical':
        return QualityStatus.critical;
      case 'rejected':
        return QualityStatus.rejected;
      case 'available':
        return QualityStatus.available;
      case 'pending_inspection':
      case 'pendingInspection':
        return QualityStatus.pendingInspection;
      case 'rework':
        return QualityStatus.rework;
      case 'blocked':
        return QualityStatus.blocked;
      default:
        return QualityStatus.pendingInspection;
    }
  }

  /// Check if this status requires immediate attention
  bool get requiresAttention =>
      this == QualityStatus.critical ||
      this == QualityStatus.rejected ||
      this == QualityStatus.blocked;

  /// Check if this status allows quality improvement
  bool get canBeImproved =>
      this == QualityStatus.rework ||
      this == QualityStatus.warning ||
      this == QualityStatus.pendingInspection;

  /// Get color representation for UI
  String get colorCode {
    switch (this) {
      case QualityStatus.available:
      case QualityStatus.excellent:
        return '#4CAF50'; // Green
      case QualityStatus.good:
        return '#8BC34A'; // Light Green
      case QualityStatus.acceptable:
        return '#2196F3'; // Blue
      case QualityStatus.warning:
        return '#FF9800'; // Orange
      case QualityStatus.critical:
        return '#F44336'; // Red
      case QualityStatus.rejected:
        return '#D32F2F'; // Dark Red
      case QualityStatus.pendingInspection:
        return '#9E9E9E'; // Grey
      case QualityStatus.rework:
        return '#FF5722'; // Deep Orange
      case QualityStatus.blocked:
        return '#795548'; // Brown
    }
  }

  /// Get priority level for sorting (lower number = higher priority)
  int get priority {
    switch (this) {
      case QualityStatus.critical:
        return 1;
      case QualityStatus.rejected:
        return 2;
      case QualityStatus.blocked:
        return 3;
      case QualityStatus.rework:
        return 4;
      case QualityStatus.warning:
        return 5;
      case QualityStatus.pendingInspection:
        return 6;
      case QualityStatus.acceptable:
        return 7;
      case QualityStatus.good:
        return 8;
      case QualityStatus.excellent:
      case QualityStatus.available:
        return 9;
    }
  }
}

/// Quality status change record for audit trail
class QualityStatusChange {

  factory QualityStatusChange.fromJson(Map<String, dynamic> json) {
    return QualityStatusChange(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      batchLotNumber: json['batchLotNumber'] as String?,
      fromStatus: QualityStatus.fromCode(json['fromStatus'] as String),
      toStatus: QualityStatus.fromCode(json['toStatus'] as String),
      reason: json['reason'] as String,
      changedBy: json['changedBy'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
      referenceDocumentId: json['referenceDocumentId'] as String?,
      notes: json['notes'] as String?,
    );
  }
  const QualityStatusChange({
    required this.id,
    required this.itemId,
    this.batchLotNumber,
    required this.fromStatus,
    required this.toStatus,
    required this.reason,
    required this.changedBy,
    required this.changedAt,
    this.referenceDocumentId,
    this.notes,
  });

  final String id;
  final String itemId;
  final String? batchLotNumber;
  final QualityStatus fromStatus;
  final QualityStatus toStatus;
  final String reason;
  final String changedBy;
  final DateTime changedAt;
  final String? referenceDocumentId;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'batchLotNumber': batchLotNumber,
      'fromStatus': fromStatus.code,
      'toStatus': toStatus.code,
      'reason': reason,
      'changedBy': changedBy,
      'changedAt': changedAt.toIso8601String(),
      'referenceDocumentId': referenceDocumentId,
      'notes': notes,
    };
  }
}
