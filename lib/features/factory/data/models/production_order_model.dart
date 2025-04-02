class ProductionOrderModel {
  const ProductionOrderModel({
    this.id,
    required this.orderNumber,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.scheduledDate,
    required this.dueDate,
    this.status = 'pending',
    this.assignedToUserId,
    this.startTime,
    this.endTime,
    this.relatedSalesOrderIds,
    this.notes,
    required this.createdAt,
    this.createdByUserId,
    this.updatedAt,
    this.requiredMaterials,
    this.ingredientsUsed,
    this.quantityProduced,
    this.batchNumber,
    this.completionDate,
    this.expiryDate,
    this.destinationLocationId,
  });

  factory ProductionOrderModel.fromJson(Map<String, dynamic> json) {
    return ProductionOrderModel(
      id: json['id'] as String?,
      orderNumber: json['orderNumber'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String? ?? 'pending',
      assignedToUserId: json['assignedToUserId'] as String?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      relatedSalesOrderIds: (json['relatedSalesOrderIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByUserId: json['createdByUserId'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      requiredMaterials: json['requiredMaterials'] != null
          ? (json['requiredMaterials'] as List<dynamic>)
              .map((e) => ProductionOrderRequiredMaterial.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      ingredientsUsed: json['ingredientsUsed'] != null
          ? (json['ingredientsUsed'] as List<dynamic>)
              .map((e) => ProductionOrderIngredientUsed.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : null,
      quantityProduced: json['quantityProduced'] == null
          ? null
          : (json['quantityProduced'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      completionDate: json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      destinationLocationId: json['destinationLocationId'] as String?,
    );
  }

  final String? id;
  final String orderNumber;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final DateTime scheduledDate;
  final DateTime dueDate;
  final String status;
  final String? assignedToUserId;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String>? relatedSalesOrderIds;
  final String? notes;
  final DateTime createdAt;
  final String? createdByUserId;
  final DateTime? updatedAt;
  final List<ProductionOrderRequiredMaterial>? requiredMaterials;
  final List<ProductionOrderIngredientUsed>? ingredientsUsed;
  final double? quantityProduced;
  final String? batchNumber;
  final DateTime? completionDate;
  final DateTime? expiryDate;
  final String? destinationLocationId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'scheduledDate': scheduledDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'assignedToUserId': assignedToUserId,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'relatedSalesOrderIds': relatedSalesOrderIds,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdByUserId': createdByUserId,
      'updatedAt': updatedAt?.toIso8601String(),
      'requiredMaterials': requiredMaterials?.map((e) => e.toJson()).toList(),
      'ingredientsUsed': ingredientsUsed?.map((e) => e.toJson()).toList(),
      'quantityProduced': quantityProduced,
      'batchNumber': batchNumber,
      'completionDate': completionDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'destinationLocationId': destinationLocationId,
    };
  }

  ProductionOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? productId,
    String? productName,
    double? quantity,
    String? unit,
    DateTime? scheduledDate,
    DateTime? dueDate,
    String? status,
    String? assignedToUserId,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? relatedSalesOrderIds,
    String? notes,
    DateTime? createdAt,
    String? createdByUserId,
    DateTime? updatedAt,
    List<ProductionOrderRequiredMaterial>? requiredMaterials,
    List<ProductionOrderIngredientUsed>? ingredientsUsed,
    double? quantityProduced,
    String? batchNumber,
    DateTime? completionDate,
    DateTime? expiryDate,
    String? destinationLocationId,
  }) {
    return ProductionOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      relatedSalesOrderIds: relatedSalesOrderIds ?? this.relatedSalesOrderIds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedAt: updatedAt ?? this.updatedAt,
      requiredMaterials: requiredMaterials ?? this.requiredMaterials,
      ingredientsUsed: ingredientsUsed ?? this.ingredientsUsed,
      quantityProduced: quantityProduced ?? this.quantityProduced,
      batchNumber: batchNumber ?? this.batchNumber,
      completionDate: completionDate ?? this.completionDate,
      expiryDate: expiryDate ?? this.expiryDate,
      destinationLocationId:
          destinationLocationId ?? this.destinationLocationId,
    );
  }

  @override
  String toString() {
    return 'ProductionOrderModel(id: $id, orderNumber: $orderNumber, productId: $productId, productName: $productName, quantity: $quantity, unit: $unit, scheduledDate: $scheduledDate, dueDate: $dueDate, status: $status, assignedToUserId: $assignedToUserId, startTime: $startTime, endTime: $endTime, relatedSalesOrderIds: $relatedSalesOrderIds, notes: $notes, createdAt: $createdAt, createdByUserId: $createdByUserId, updatedAt: $updatedAt, requiredMaterials: $requiredMaterials, ingredientsUsed: $ingredientsUsed, quantityProduced: $quantityProduced, batchNumber: $batchNumber, completionDate: $completionDate, expiryDate: $expiryDate, destinationLocationId: $destinationLocationId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductionOrderModel &&
        other.id == id &&
        other.orderNumber == orderNumber &&
        other.productId == productId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.scheduledDate == scheduledDate &&
        other.dueDate == dueDate &&
        other.status == status &&
        other.assignedToUserId == assignedToUserId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.relatedSalesOrderIds == relatedSalesOrderIds &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.createdByUserId == createdByUserId &&
        other.updatedAt == updatedAt &&
        other.requiredMaterials == requiredMaterials &&
        other.ingredientsUsed == ingredientsUsed &&
        other.quantityProduced == quantityProduced &&
        other.batchNumber == batchNumber &&
        other.completionDate == completionDate &&
        other.expiryDate == expiryDate &&
        other.destinationLocationId == destinationLocationId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderNumber.hashCode ^
        productId.hashCode ^
        productName.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        scheduledDate.hashCode ^
        dueDate.hashCode ^
        status.hashCode ^
        assignedToUserId.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        relatedSalesOrderIds.hashCode ^
        notes.hashCode ^
        createdAt.hashCode ^
        createdByUserId.hashCode ^
        updatedAt.hashCode ^
        requiredMaterials.hashCode ^
        ingredientsUsed.hashCode ^
        quantityProduced.hashCode ^
        batchNumber.hashCode ^
        completionDate.hashCode ^
        expiryDate.hashCode ^
        destinationLocationId.hashCode;
  }
}

class ProductionOrderRequiredMaterial {
  const ProductionOrderRequiredMaterial({
    required this.materialId,
    required this.requiredQuantity,
  });

  factory ProductionOrderRequiredMaterial.fromJson(Map<String, dynamic> json) {
    return ProductionOrderRequiredMaterial(
      materialId: json['materialId'] as String,
      requiredQuantity: (json['requiredQuantity'] as num).toDouble(),
    );
  }

  final String materialId;
  final double requiredQuantity;

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'requiredQuantity': requiredQuantity,
    };
  }

  ProductionOrderRequiredMaterial copyWith({
    String? materialId,
    double? requiredQuantity,
  }) {
    return ProductionOrderRequiredMaterial(
      materialId: materialId ?? this.materialId,
      requiredQuantity: requiredQuantity ?? this.requiredQuantity,
    );
  }

  @override
  String toString() =>
      'ProductionOrderRequiredMaterial(materialId: $materialId, requiredQuantity: $requiredQuantity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductionOrderRequiredMaterial &&
        other.materialId == materialId &&
        other.requiredQuantity == requiredQuantity;
  }

  @override
  int get hashCode => materialId.hashCode ^ requiredQuantity.hashCode;
}

class ProductionOrderIngredientUsed {
  const ProductionOrderIngredientUsed({
    required this.materialId,
    required this.quantityUsed,
  });

  factory ProductionOrderIngredientUsed.fromJson(Map<String, dynamic> json) {
    return ProductionOrderIngredientUsed(
      materialId: json['materialId'] as String,
      quantityUsed: (json['quantityUsed'] as num).toDouble(),
    );
  }

  final String materialId;
  final double quantityUsed;

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'quantityUsed': quantityUsed,
    };
  }

  ProductionOrderIngredientUsed copyWith({
    String? materialId,
    double? quantityUsed,
  }) {
    return ProductionOrderIngredientUsed(
      materialId: materialId ?? this.materialId,
      quantityUsed: quantityUsed ?? this.quantityUsed,
    );
  }

  @override
  String toString() =>
      'ProductionOrderIngredientUsed(materialId: $materialId, quantityUsed: $quantityUsed)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductionOrderIngredientUsed &&
        other.materialId == materialId &&
        other.quantityUsed == quantityUsed;
  }

  @override
  int get hashCode => materialId.hashCode ^ quantityUsed.hashCode;
}
