class MaterialRequisitionItemModel {
  const MaterialRequisitionItemModel({
    required this.materialId,
    required this.quantity,
    required this.unit,
    this.notes,
  });

  factory MaterialRequisitionItemModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequisitionItemModel(
      materialId: json['materialId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
    );
  }

  final String materialId;
  final double quantity;
  final String unit;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }

  MaterialRequisitionItemModel copyWith({
    String? materialId,
    double? quantity,
    String? unit,
    String? notes,
  }) {
    return MaterialRequisitionItemModel(
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'MaterialRequisitionItemModel(materialId: $materialId, quantity: $quantity, unit: $unit, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaterialRequisitionItemModel &&
        other.materialId == materialId &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return materialId.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        notes.hashCode;
  }
}
