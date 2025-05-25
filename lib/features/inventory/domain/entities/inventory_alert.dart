/// Types of inventory alerts
enum AlertType {
  /// Alert for items with low stock level
  lowStock,

  /// Alert for expired items
  expired,

  /// Alert for items that will expire soon
  expiringSoon
}

/// Severity levels for alerts
enum AlertSeverity {
  /// Low severity - informational
  low,

  /// Medium severity - attention needed
  medium,

  /// High severity - immediate action required
  high
}

/// Represents an inventory alert
class InventoryAlert {
  const InventoryAlert({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.alertType,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isAcknowledged = false,
    // Enhanced fields from BOM Phase 2
    this.expectedResolutionDate,
    this.suggestedActions,
    this.alternativeItems,
    this.warehouseStock,
    this.confidenceScore,
  });

  factory InventoryAlert.fromJson(Map<String, dynamic> json) => InventoryAlert(
        id: json['id'] as String,
        itemId: json['itemId'] as String,
        itemName: json['itemName'] as String,
        alertType: AlertType.values[json['alertType'] as int],
        message: json['message'] as String,
        severity: AlertSeverity.values[json['severity'] as int],
        timestamp: DateTime.parse(json['timestamp'] as String),
        isAcknowledged: json['isAcknowledged'] as bool? ?? false,
        // Enhanced fields
        expectedResolutionDate: json['expectedResolutionDate'] != null
            ? DateTime.parse(json['expectedResolutionDate'] as String)
            : null,
        suggestedActions: (json['suggestedActions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        alternativeItems: (json['alternativeItems'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        warehouseStock: (json['warehouseStock'] as Map<String, dynamic>?)
            ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
        confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      );

  /// Unique identifier for this alert
  final String id;

  /// ID of the inventory item related to this alert
  final String itemId;

  /// Name of the inventory item
  final String itemName;

  /// Type of alert
  final AlertType alertType;

  /// Alert message
  final String message;

  /// Alert severity level
  final AlertSeverity severity;

  /// When the alert was generated
  final DateTime timestamp;

  /// Whether the alert has been acknowledged
  final bool isAcknowledged;

  // Enhanced fields from BOM Phase 2
  /// Predicted date when the issue will be resolved
  final DateTime? expectedResolutionDate;

  /// List of suggested actions to resolve the alert
  final List<String>? suggestedActions;

  /// List of alternative items that can be used
  final List<String>? alternativeItems;

  /// Stock levels across different warehouses
  final Map<String, double>? warehouseStock;

  /// Confidence score for predictions (0.0 to 1.0)
  final double? confidenceScore;

  InventoryAlert copyWith({
    String? id,
    String? itemId,
    String? itemName,
    AlertType? alertType,
    String? message,
    AlertSeverity? severity,
    DateTime? timestamp,
    bool? isAcknowledged,
    DateTime? expectedResolutionDate,
    List<String>? suggestedActions,
    List<String>? alternativeItems,
    Map<String, double>? warehouseStock,
    double? confidenceScore,
  }) {
    return InventoryAlert(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      alertType: alertType ?? this.alertType,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      expectedResolutionDate:
          expectedResolutionDate ?? this.expectedResolutionDate,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      alternativeItems: alternativeItems ?? this.alternativeItems,
      warehouseStock: warehouseStock ?? this.warehouseStock,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemName': itemName,
        'alertType': alertType.index,
        'message': message,
        'severity': severity.index,
        'timestamp': timestamp.toIso8601String(),
        'isAcknowledged': isAcknowledged,
        'expectedResolutionDate': expectedResolutionDate?.toIso8601String(),
        'suggestedActions': suggestedActions,
        'alternativeItems': alternativeItems,
        'warehouseStock': warehouseStock,
        'confidenceScore': confidenceScore,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAlert &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemId == other.itemId &&
          itemName == other.itemName &&
          alertType == other.alertType &&
          message == other.message &&
          severity == other.severity &&
          timestamp.isAtSameMomentAs(other.timestamp) &&
          isAcknowledged == other.isAcknowledged;

  @override
  int get hashCode =>
      id.hashCode ^
      itemId.hashCode ^
      itemName.hashCode ^
      alertType.hashCode ^
      message.hashCode ^
      severity.hashCode ^
      timestamp.hashCode ^
      isAcknowledged.hashCode;
}
