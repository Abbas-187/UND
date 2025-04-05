import 'package:cloud_firestore/cloud_firestore.dart';

class StockCountItemModel {
  const StockCountItemModel({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.expectedQuantity,
    required this.countedQuantity,
    required this.unitOfMeasure,
    this.batchNumber,
    this.locationId,
    this.remarks,
    this.customAttributes,
  });

  factory StockCountItemModel.fromJson(Map<String, dynamic> json) {
    return StockCountItemModel(
      itemId: json['itemId'] as String,
      itemCode: json['itemCode'] as String,
      itemName: json['itemName'] as String,
      expectedQuantity: (json['expectedQuantity'] as num).toDouble(),
      countedQuantity: (json['countedQuantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      batchNumber: json['batchNumber'] as String?,
      locationId: json['locationId'] as String?,
      remarks: json['remarks'] as String?,
      customAttributes: json['customAttributes'] as Map<String, dynamic>?,
    );
  }
  final String itemId;
  final String itemCode;
  final String itemName;
  final double expectedQuantity;
  final double countedQuantity;
  final String unitOfMeasure;
  final String? batchNumber;
  final String? locationId;
  final String? remarks;
  final Map<String, dynamic>? customAttributes;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemCode': itemCode,
      'itemName': itemName,
      'expectedQuantity': expectedQuantity,
      'countedQuantity': countedQuantity,
      'unitOfMeasure': unitOfMeasure,
      'batchNumber': batchNumber,
      'locationId': locationId,
      'remarks': remarks,
      'customAttributes': customAttributes,
    };
  }

  StockCountItemModel copyWith({
    String? itemId,
    String? itemCode,
    String? itemName,
    double? expectedQuantity,
    double? countedQuantity,
    String? unitOfMeasure,
    String? batchNumber,
    String? locationId,
    String? remarks,
    Map<String, dynamic>? customAttributes,
  }) {
    return StockCountItemModel(
      itemId: itemId ?? this.itemId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      batchNumber: batchNumber ?? this.batchNumber,
      locationId: locationId ?? this.locationId,
      remarks: remarks ?? this.remarks,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }
}

class StockCountModel {
  const StockCountModel({
    this.id,
    required this.documentNumber,
    required this.countDate,
    required this.warehouseId,
    this.locationId,
    required this.countedByUserId,
    this.remarks,
    required this.items,
    this.isPosted = false,
    this.postedDate,
    this.postedByUserId,
    required this.countType,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
  });

  factory StockCountModel.fromJson(Map<String, dynamic> json) {
    return StockCountModel(
      id: json['id'] as String?,
      documentNumber: json['documentNumber'] as String,
      countDate: DateTime.parse(json['countDate'] as String),
      warehouseId: json['warehouseId'] as String,
      locationId: json['locationId'] as String?,
      countedByUserId: json['countedByUserId'] as String,
      remarks: json['remarks'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => StockCountItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPosted: json['isPosted'] as bool? ?? false,
      postedDate: json['postedDate'] != null
          ? DateTime.parse(json['postedDate'] as String)
          : null,
      postedByUserId: json['postedByUserId'] as String?,
      countType: json['countType'] as String,
      status: json['status'] as String? ?? 'draft',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  factory StockCountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockCountModel.fromJson({
      'id': doc.id,
      ...data,
      'countDate': (data['countDate'] as Timestamp).toDate(),
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
  final DateTime countDate;
  final String warehouseId;
  final String? locationId;
  final String countedByUserId;
  final String? remarks;
  final List<StockCountItemModel> items;
  final bool isPosted;
  final DateTime? postedDate;
  final String? postedByUserId;
  final String countType;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentNumber': documentNumber,
      'countDate': countDate.toIso8601String(),
      'warehouseId': warehouseId,
      'locationId': locationId,
      'countedByUserId': countedByUserId,
      'remarks': remarks,
      'items': items.map((e) => e.toJson()).toList(),
      'isPosted': isPosted,
      'postedDate': postedDate?.toIso8601String(),
      'postedByUserId': postedByUserId,
      'countType': countType,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'documentNumber': documentNumber,
      'countDate': Timestamp.fromDate(countDate),
      'warehouseId': warehouseId,
      'locationId': locationId,
      'countedByUserId': countedByUserId,
      'remarks': remarks,
      'items': items.map((e) => e.toJson()).toList(),
      'isPosted': isPosted,
      'postedDate': postedDate != null ? Timestamp.fromDate(postedDate!) : null,
      'postedByUserId': postedByUserId,
      'countType': countType,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }

  StockCountModel copyWith({
    String? id,
    String? documentNumber,
    DateTime? countDate,
    String? warehouseId,
    String? locationId,
    String? countedByUserId,
    String? remarks,
    List<StockCountItemModel>? items,
    bool? isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    String? countType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockCountModel(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      countDate: countDate ?? this.countDate,
      warehouseId: warehouseId ?? this.warehouseId,
      locationId: locationId ?? this.locationId,
      countedByUserId: countedByUserId ?? this.countedByUserId,
      remarks: remarks ?? this.remarks,
      items: items ?? this.items,
      isPosted: isPosted ?? this.isPosted,
      postedDate: postedDate ?? this.postedDate,
      postedByUserId: postedByUserId ?? this.postedByUserId,
      countType: countType ?? this.countType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
