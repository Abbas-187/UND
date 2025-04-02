import 'package:cloud_firestore/cloud_firestore.dart';

// Define TransactionType enum
enum TransactionType {
  receipt,
  issue,
  transfer,
  return_,
  count,
  adjustment,
  other
}

class InventoryTransactionModel {
  final String? id;
  final String materialId;
  final String materialName;
  final String warehouseId;
  final TransactionType transactionType;
  final double quantity;
  final String uom;
  final String? batchNumber;
  final String? sourceLocationId;
  final String? destinationLocationId;
  final String? referenceNumber;
  final String? referenceType;
  final String? reason;
  final String? notes;
  final DateTime? transactionDate;
  final String? performedBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final bool isApproved;
  final bool isPending;
  final DateTime? createdAt;

  const InventoryTransactionModel({
    this.id,
    required this.materialId,
    required this.materialName,
    required this.warehouseId,
    required this.transactionType,
    required this.quantity,
    required this.uom,
    this.batchNumber,
    this.sourceLocationId,
    this.destinationLocationId,
    this.referenceNumber,
    this.referenceType,
    this.reason,
    this.notes,
    this.transactionDate,
    this.performedBy,
    this.approvedBy,
    this.approvedAt,
    this.isApproved = false,
    this.isPending = false,
    this.createdAt,
  });

  factory InventoryTransactionModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionModel(
      id: json['id'] as String?,
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      warehouseId: json['warehouseId'] as String,
      transactionType: TransactionType.values.firstWhere(
        (e) => e.toString() == json['transactionType'],
        orElse: () => TransactionType.receipt,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      uom: json['uom'] as String,
      batchNumber: json['batchNumber'] as String?,
      sourceLocationId: json['sourceLocationId'] as String?,
      destinationLocationId: json['destinationLocationId'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      referenceType: json['referenceType'] as String?,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'] as String)
          : null,
      performedBy: json['performedBy'] as String?,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      isApproved: json['isApproved'] as bool? ?? false,
      isPending: json['isPending'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'materialName': materialName,
      'warehouseId': warehouseId,
      'transactionType': transactionType.toString(),
      'quantity': quantity,
      'uom': uom,
      'batchNumber': batchNumber,
      'sourceLocationId': sourceLocationId,
      'destinationLocationId': destinationLocationId,
      'referenceNumber': referenceNumber,
      'referenceType': referenceType,
      'reason': reason,
      'notes': notes,
      'transactionDate': transactionDate?.toIso8601String(),
      'performedBy': performedBy,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'isApproved': isApproved,
      'isPending': isPending,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'warehouseId': warehouseId,
      'transactionType': transactionType.toString(),
      'quantity': quantity,
      'uom': uom,
      'batchNumber': batchNumber,
      'sourceLocationId': sourceLocationId,
      'destinationLocationId': destinationLocationId,
      'referenceNumber': referenceNumber,
      'referenceType': referenceType,
      'reason': reason,
      'notes': notes,
      'transactionDate': transactionDate != null
          ? Timestamp.fromDate(transactionDate!)
          : Timestamp.now(),
      'performedBy': performedBy,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'isApproved': isApproved,
      'isPending': isPending,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
    };
  }

  InventoryTransactionModel copyWith({
    String? id,
    String? materialId,
    String? materialName,
    String? warehouseId,
    TransactionType? transactionType,
    double? quantity,
    String? uom,
    String? batchNumber,
    String? sourceLocationId,
    String? destinationLocationId,
    String? referenceNumber,
    String? referenceType,
    String? reason,
    String? notes,
    DateTime? transactionDate,
    String? performedBy,
    String? approvedBy,
    DateTime? approvedAt,
    bool? isApproved,
    bool? isPending,
    DateTime? createdAt,
  }) {
    return InventoryTransactionModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      warehouseId: warehouseId ?? this.warehouseId,
      transactionType: transactionType ?? this.transactionType,
      quantity: quantity ?? this.quantity,
      uom: uom ?? this.uom,
      batchNumber: batchNumber ?? this.batchNumber,
      sourceLocationId: sourceLocationId ?? this.sourceLocationId,
      destinationLocationId:
          destinationLocationId ?? this.destinationLocationId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      referenceType: referenceType ?? this.referenceType,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      performedBy: performedBy ?? this.performedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      isApproved: isApproved ?? this.isApproved,
      isPending: isPending ?? this.isPending,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
