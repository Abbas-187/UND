class BatchModel {
  const BatchModel({
    required this.batchNumber,
    required this.quantity,
    this.manufacturingDate,
    this.expiryDate,
    this.supplierName,
    this.supplierBatch,
    this.notes,
    this.qualityStatus,
    this.isQuarantined = false,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchNumber: json['batchNumber'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      manufacturingDate: json['manufacturingDate'] != null
          ? DateTime.parse(json['manufacturingDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      supplierName: json['supplierName'] as String?,
      supplierBatch: json['supplierBatch'] as String?,
      notes: json['notes'] as String?,
      qualityStatus: json['qualityStatus'] as String?,
      isQuarantined: json['isQuarantined'] as bool? ?? false,
    );
  }
  final String batchNumber;
  final double quantity;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final String? supplierName;
  final String? supplierBatch;
  final String? notes;
  final String? qualityStatus;
  final bool isQuarantined;

  Map<String, dynamic> toJson() {
    return {
      'batchNumber': batchNumber,
      'quantity': quantity,
      'manufacturingDate': manufacturingDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'supplierName': supplierName,
      'supplierBatch': supplierBatch,
      'notes': notes,
      'qualityStatus': qualityStatus,
      'isQuarantined': isQuarantined,
    };
  }

  BatchModel copyWith({
    String? batchNumber,
    double? quantity,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    String? supplierName,
    String? supplierBatch,
    String? notes,
    String? qualityStatus,
    bool? isQuarantined,
  }) {
    return BatchModel(
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierName: supplierName ?? this.supplierName,
      supplierBatch: supplierBatch ?? this.supplierBatch,
      notes: notes ?? this.notes,
      qualityStatus: qualityStatus ?? this.qualityStatus,
      isQuarantined: isQuarantined ?? this.isQuarantined,
    );
  }
}
