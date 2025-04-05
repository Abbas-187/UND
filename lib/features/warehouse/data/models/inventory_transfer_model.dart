import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryTransferItemModel {
  const InventoryTransferItemModel({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unitOfMeasure,
    this.batchNumber,
    required this.sourceLocationId,
    required this.destinationLocationId,
    this.remarks,
    this.customAttributes,
  });

  factory InventoryTransferItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransferItemModel(
      itemId: json['itemId'] as String,
      itemCode: json['itemCode'] as String,
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      batchNumber: json['batchNumber'] as String?,
      sourceLocationId: json['sourceLocationId'] as String,
      destinationLocationId: json['destinationLocationId'] as String,
      remarks: json['remarks'] as String?,
      customAttributes: json['customAttributes'] as Map<String, dynamic>?,
    );
  }
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unitOfMeasure;
  final String? batchNumber;
  final String sourceLocationId;
  final String destinationLocationId;
  final String? remarks;
  final Map<String, dynamic>? customAttributes;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemCode': itemCode,
      'itemName': itemName,
      'quantity': quantity,
      'unitOfMeasure': unitOfMeasure,
      'batchNumber': batchNumber,
      'sourceLocationId': sourceLocationId,
      'destinationLocationId': destinationLocationId,
      'remarks': remarks,
      'customAttributes': customAttributes,
    };
  }

  InventoryTransferItemModel copyWith({
    String? itemId,
    String? itemCode,
    String? itemName,
    double? quantity,
    String? unitOfMeasure,
    String? batchNumber,
    String? sourceLocationId,
    String? destinationLocationId,
    String? remarks,
    Map<String, dynamic>? customAttributes,
  }) {
    return InventoryTransferItemModel(
      itemId: itemId ?? this.itemId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      batchNumber: batchNumber ?? this.batchNumber,
      sourceLocationId: sourceLocationId ?? this.sourceLocationId,
      destinationLocationId:
          destinationLocationId ?? this.destinationLocationId,
      remarks: remarks ?? this.remarks,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }
}

class InventoryTransferModel {
  const InventoryTransferModel({
    this.id,
    required this.documentNumber,
    required this.transferDate,
    required this.sourceWarehouseId,
    required this.destinationWarehouseId,
    required this.transferredByUserId,
    this.remarks,
    required this.items,
    this.isPosted = false,
    this.postedDate,
    this.postedByUserId,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryTransferModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransferModel(
      id: json['id'] as String?,
      documentNumber: json['documentNumber'] as String,
      transferDate: DateTime.parse(json['transferDate'] as String),
      sourceWarehouseId: json['sourceWarehouseId'] as String,
      destinationWarehouseId: json['destinationWarehouseId'] as String,
      transferredByUserId: json['transferredByUserId'] as String,
      remarks: json['remarks'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              InventoryTransferItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPosted: json['isPosted'] as bool? ?? false,
      postedDate: json['postedDate'] != null
          ? DateTime.parse(json['postedDate'] as String)
          : null,
      postedByUserId: json['postedByUserId'] as String?,
      status: json['status'] as String? ?? 'draft',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  factory InventoryTransferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryTransferModel.fromJson({
      'id': doc.id,
      ...data,
      'transferDate': (data['transferDate'] as Timestamp).toDate(),
      'postedDate': data['postedDate'] != null
          ? (data['postedDate'] as Timestamp).toDate()
          : null,
      'createdAt': data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      'updatedAt': data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    });
  }
  final String? id;
  final String documentNumber;
  final DateTime transferDate;
  final String sourceWarehouseId;
  final String destinationWarehouseId;
  final String transferredByUserId;
  final String? remarks;
  final List<InventoryTransferItemModel> items;
  final bool isPosted;
  final DateTime? postedDate;
  final String? postedByUserId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentNumber': documentNumber,
      'transferDate': transferDate.toIso8601String(),
      'sourceWarehouseId': sourceWarehouseId,
      'destinationWarehouseId': destinationWarehouseId,
      'transferredByUserId': transferredByUserId,
      'remarks': remarks,
      'items': items.map((e) => e.toJson()).toList(),
      'isPosted': isPosted,
      'postedDate': postedDate?.toIso8601String(),
      'postedByUserId': postedByUserId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'documentNumber': documentNumber,
      'transferDate': Timestamp.fromDate(transferDate),
      'sourceWarehouseId': sourceWarehouseId,
      'destinationWarehouseId': destinationWarehouseId,
      'transferredByUserId': transferredByUserId,
      'remarks': remarks,
      'items': items.map((e) => e.toJson()).toList(),
      'isPosted': isPosted,
      'postedDate': postedDate != null ? Timestamp.fromDate(postedDate!) : null,
      'postedByUserId': postedByUserId,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }

  InventoryTransferModel copyWith({
    String? id,
    String? documentNumber,
    DateTime? transferDate,
    String? sourceWarehouseId,
    String? destinationWarehouseId,
    String? transferredByUserId,
    String? remarks,
    List<InventoryTransferItemModel>? items,
    bool? isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryTransferModel(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      transferDate: transferDate ?? this.transferDate,
      sourceWarehouseId: sourceWarehouseId ?? this.sourceWarehouseId,
      destinationWarehouseId:
          destinationWarehouseId ?? this.destinationWarehouseId,
      transferredByUserId: transferredByUserId ?? this.transferredByUserId,
      remarks: remarks ?? this.remarks,
      items: items ?? this.items,
      isPosted: isPosted ?? this.isPosted,
      postedDate: postedDate ?? this.postedDate,
      postedByUserId: postedByUserId ?? this.postedByUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
