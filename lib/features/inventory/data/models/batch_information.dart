import 'package:meta/meta.dart';

/// Model for detailed batch information, suitable for inventory traceability and compliance.
@immutable
class BatchInformation {
  factory BatchInformation.fromJson(Map<String, dynamic> json) {
    return BatchInformation(
      batchId: json['batchId'] as String,
      productionDate: DateTime.parse(json['productionDate'] as String),
      sourceId: json['sourceId'] as String,
      sourceDetails: Map<String, dynamic>.from(json['sourceDetails'] as Map),
      isApproved: json['isApproved'] as bool,
      approvalDate: DateTime.parse(json['approvalDate'] as String),
      notes: json['notes'] as String?,
    );
  }
  const BatchInformation({
    required this.batchId,
    required this.productionDate,
    required this.sourceId,
    required this.sourceDetails,
    required this.isApproved,
    required this.approvalDate,
    this.notes,
  });

  /// Unique batch or lot identifier
  final String batchId;

  /// Date and time of production or batch creation
  final DateTime productionDate;

  /// ID of the source event (e.g., reception, production, transfer)
  final String sourceId;

  /// Map of additional source details (supplier, vehicle, etc.)
  final Map<String, dynamic> sourceDetails;

  /// Whether the batch is approved for use
  final bool isApproved;

  /// Date and time of approval
  final DateTime approvalDate;

  /// Optional notes or comments
  final String? notes;

  BatchInformation copyWith({
    String? batchId,
    DateTime? productionDate,
    String? sourceId,
    Map<String, dynamic>? sourceDetails,
    bool? isApproved,
    DateTime? approvalDate,
    String? notes,
  }) {
    return BatchInformation(
      batchId: batchId ?? this.batchId,
      productionDate: productionDate ?? this.productionDate,
      sourceId: sourceId ?? this.sourceId,
      sourceDetails:
          sourceDetails ?? Map<String, dynamic>.from(this.sourceDetails),
      isApproved: isApproved ?? this.isApproved,
      approvalDate: approvalDate ?? this.approvalDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'productionDate': productionDate.toIso8601String(),
      'sourceId': sourceId,
      'sourceDetails': sourceDetails,
      'isApproved': isApproved,
      'approvalDate': approvalDate.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchInformation &&
          runtimeType == other.runtimeType &&
          batchId == other.batchId &&
          productionDate == other.productionDate &&
          sourceId == other.sourceId &&
          _mapEquals(sourceDetails, other.sourceDetails) &&
          isApproved == other.isApproved &&
          approvalDate == other.approvalDate &&
          notes == other.notes;

  @override
  int get hashCode =>
      batchId.hashCode ^
      productionDate.hashCode ^
      sourceId.hashCode ^
      sourceDetails.hashCode ^
      isApproved.hashCode ^
      approvalDate.hashCode ^
      (notes?.hashCode ?? 0);

  static bool _mapEquals(Map a, Map b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
