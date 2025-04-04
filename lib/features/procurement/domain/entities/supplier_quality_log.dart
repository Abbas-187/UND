enum QualityStatus { passed, failed, conditionalPass, underReview }

class QualityParameter {
  final String id;
  final String name;
  final String criteria;
  final String? value;
  final bool isPassed;
  final String? notes;

  const QualityParameter({
    required this.id,
    required this.name,
    required this.criteria,
    this.value,
    required this.isPassed,
    this.notes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityParameter &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SupplierQualityLog {
  final String id;
  final String supplierId;
  final String supplierName;
  final String? purchaseOrderId;
  final String? purchaseOrderNumber;
  final DateTime inspectionDate;
  final String inspectedBy;
  final String inspectionType;
  final QualityStatus status;
  final List<QualityParameter> parameters;
  final String? defectDescription;
  final String? actionTaken;
  final DateTime? followUpDate;
  final String? followUpBy;
  final List<String>? evidenceAttachments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupplierQualityLog({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    this.purchaseOrderId,
    this.purchaseOrderNumber,
    required this.inspectionDate,
    required this.inspectedBy,
    required this.inspectionType,
    required this.status,
    required this.parameters,
    this.defectDescription,
    this.actionTaken,
    this.followUpDate,
    this.followUpBy,
    this.evidenceAttachments,
    required this.createdAt,
    this.updatedAt,
  });

  bool get requiresFollowUp =>
      status == QualityStatus.failed || status == QualityStatus.conditionalPass;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierQualityLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
