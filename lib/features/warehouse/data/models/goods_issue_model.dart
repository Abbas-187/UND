import 'package:cloud_firestore/cloud_firestore.dart';

class GoodsIssueItemModel {
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unitOfMeasure;
  final String? batchNumber;
  final String? locationId;
  final String? remarks;
  final Map<String, dynamic>? customAttributes;

  const GoodsIssueItemModel({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unitOfMeasure,
    this.batchNumber,
    this.locationId,
    this.remarks,
    this.customAttributes,
  });

  factory GoodsIssueItemModel.fromJson(Map<String, dynamic> json) {
    return GoodsIssueItemModel(
      itemId: json['itemId'] as String,
      itemCode: json['itemCode'] as String,
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      batchNumber: json['batchNumber'] as String?,
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
      'locationId': locationId,
      'remarks': remarks,
      'customAttributes': customAttributes,
    };
  }

  GoodsIssueItemModel copyWith({
    String? itemId,
    String? itemCode,
    String? itemName,
    double? quantity,
    String? unitOfMeasure,
    String? batchNumber,
    String? locationId,
    String? remarks,
    Map<String, dynamic>? customAttributes,
  }) {
    return GoodsIssueItemModel(
      itemId: itemId ?? this.itemId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      batchNumber: batchNumber ?? this.batchNumber,
      locationId: locationId ?? this.locationId,
      remarks: remarks ?? this.remarks,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }
}

class GoodsIssueModel {
  final String? id;
  final String documentNumber;
  final DateTime issueDate;
  final String requestedByDepartment;
  final String? requestReference;
  final String warehouseId;
  final String issuedByUserId;
  final String? remarks;
  final List<GoodsIssueItemModel> items;
  final bool isPosted;
  final DateTime? postedDate;
  final String? postedByUserId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GoodsIssueModel({
    this.id,
    required this.documentNumber,
    required this.issueDate,
    required this.requestedByDepartment,
    this.requestReference,
    required this.warehouseId,
    required this.issuedByUserId,
    this.remarks,
    required this.items,
    this.isPosted = false,
    this.postedDate,
    this.postedByUserId,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
  });

  factory GoodsIssueModel.fromJson(Map<String, dynamic> json) {
    return GoodsIssueModel(
      id: json['id'] as String?,
      documentNumber: json['documentNumber'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      requestedByDepartment: json['requestedByDepartment'] as String,
      requestReference: json['requestReference'] as String?,
      warehouseId: json['warehouseId'] as String,
      issuedByUserId: json['issuedByUserId'] as String,
      remarks: json['remarks'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => GoodsIssueItemModel.fromJson(e as Map<String, dynamic>))
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

  factory GoodsIssueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoodsIssueModel.fromJson({
      'id': doc.id,
      ...data,
      'issueDate': (data['issueDate'] as Timestamp).toDate(),
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
      'issueDate': issueDate.toIso8601String(),
      'requestedByDepartment': requestedByDepartment,
      'requestReference': requestReference,
      'warehouseId': warehouseId,
      'issuedByUserId': issuedByUserId,
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
      'issueDate': Timestamp.fromDate(issueDate),
      'requestedByDepartment': requestedByDepartment,
      'requestReference': requestReference,
      'warehouseId': warehouseId,
      'issuedByUserId': issuedByUserId,
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

  GoodsIssueModel copyWith({
    String? id,
    String? documentNumber,
    DateTime? issueDate,
    String? requestedByDepartment,
    String? requestReference,
    String? warehouseId,
    String? issuedByUserId,
    String? remarks,
    List<GoodsIssueItemModel>? items,
    bool? isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoodsIssueModel(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      issueDate: issueDate ?? this.issueDate,
      requestedByDepartment:
          requestedByDepartment ?? this.requestedByDepartment,
      requestReference: requestReference ?? this.requestReference,
      warehouseId: warehouseId ?? this.warehouseId,
      issuedByUserId: issuedByUserId ?? this.issuedByUserId,
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
