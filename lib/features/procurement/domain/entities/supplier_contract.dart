enum ContractStatus {
  draft,
  active,
  expired,
  terminated,
  onHold,
  pendingRenewal,
  renewed
}

class SupplierContract {
  final String id;
  final String contractNumber;
  final String supplierId;
  final String supplierName;
  final DateTime startDate;
  final DateTime endDate;
  final ContractStatus status;
  final String contractType;
  final String? terms;
  final double? value;
  final String? paymentTerms;
  final String? deliveryTerms;
  final String? qualityRequirements;
  final List<String>? attachments;
  final String? signedBy;
  final DateTime? signedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupplierContract({
    required this.id,
    required this.contractNumber,
    required this.supplierId,
    required this.supplierName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.contractType,
    this.terms,
    this.value,
    this.paymentTerms,
    this.deliveryTerms,
    this.qualityRequirements,
    this.attachments,
    this.signedBy,
    this.signedDate,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isActive => status == ContractStatus.active && !isExpired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierContract &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
