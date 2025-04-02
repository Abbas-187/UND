import 'package:cloud_firestore/cloud_firestore.dart';

class GoodsReceiptItemModel {
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unitOfMeasure;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? locationId;
  final String? remarks;
  final Map<String, dynamic>? customAttributes;

  const GoodsReceiptItemModel({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unitOfMeasure,
    this.batchNumber,
    this.expiryDate,
    this.locationId,
    this.remarks,
    this.customAttributes,
  });

  factory GoodsReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptItemModel(
      itemId: json['itemId'] as String,
      itemCode: json['itemCode'] as String,
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      locationId: json['locationId'] as String?,
      remarks: json['remarks'] as String?,
      customAttributes: json['customAttributes'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemCode': itemCode,
      'itemName': itemName,
      'quantity': quantity,
      'unitOfMeasure': unitOfMeasure,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'locationId': locationId,
      'remarks': remarks,
      'customAttributes': customAttributes,
    };
  }

  GoodsReceiptItemModel copyWith({
    String? itemId,
    String? itemCode,
    String? itemName,
    double? quantity,
    String? unitOfMeasure,
    String? batchNumber,
    DateTime? expiryDate,
    String? locationId,
    String? remarks,
    Map<String, dynamic>? customAttributes,
  }) {
    return GoodsReceiptItemModel(
      itemId: itemId ?? this.itemId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      locationId: locationId ?? this.locationId,
      remarks: remarks ?? this.remarks,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }
}

class GoodsReceiptModel {
  final String? id;
  final String documentNumber;
  final DateTime receiptDate;
  final String supplierName;
  final String? supplierReference;
  final String warehouseId;
  final String receivedByUserId;
  final String? remarks;
  final List<GoodsReceiptItemModel> items;
  final bool isPosted;
  final DateTime? postedDate;
  final String? postedByUserId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GoodsReceiptModel({
    this.id,
    required this.documentNumber,
    required this.receiptDate,
    required this.supplierName,
    this.supplierReference,
    required this.warehouseId,
    required this.receivedByUserId,
    this.remarks,
    required this.items,
    this.isPosted = false,
    this.postedDate,
    this.postedByUserId,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
  });

  factory GoodsReceiptModel.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptModel(
      id: json['id'] as String?,
      documentNumber: json['documentNumber'] as String,
      receiptDate: DateTime.parse(json['receiptDate'] as String),
      supplierName: json['supplierName'] as String,
      supplierReference: json['supplierReference'] as String?,
      warehouseId: json['warehouseId'] as String,
      receivedByUserId: json['receivedByUserId'] as String,
      remarks: json['remarks'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => GoodsReceiptItemModel.fromJson(e as Map<String, dynamic>))
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

  factory GoodsReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoodsReceiptModel.fromJson({
      'id': doc.id,
      ...data,
      'receiptDate': (data['receiptDate'] as Timestamp).toDate(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentNumber': documentNumber,
      'receiptDate': receiptDate.toIso8601String(),
      'supplierName': supplierName,
      'supplierReference': supplierReference,
      'warehouseId': warehouseId,
      'receivedByUserId': receivedByUserId,
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
      'receiptDate': Timestamp.fromDate(receiptDate),
      'supplierName': supplierName,
      'supplierReference': supplierReference,
      'warehouseId': warehouseId,
      'receivedByUserId': receivedByUserId,
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

  GoodsReceiptModel copyWith({
    String? id,
    String? documentNumber,
    DateTime? receiptDate,
    String? supplierName,
    String? supplierReference,
    String? warehouseId,
    String? receivedByUserId,
    String? remarks,
    List<GoodsReceiptItemModel>? items,
    bool? isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoodsReceiptModel(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      receiptDate: receiptDate ?? this.receiptDate,
      supplierName: supplierName ?? this.supplierName,
      supplierReference: supplierReference ?? this.supplierReference,
      warehouseId: warehouseId ?? this.warehouseId,
      receivedByUserId: receivedByUserId ?? this.receivedByUserId,
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
