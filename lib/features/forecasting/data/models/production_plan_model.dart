import 'package:cloud_firestore/cloud_firestore.dart';
import 'production_slot_model.dart';
import 'resource_allocation_model.dart';

/// Model representing a production plan
class ProductionPlanModel {

  const ProductionPlanModel({
    this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.createdByUserId,
    this.createdBy,
    required this.startDate,
    required this.endDate,
    required this.productionItems,
    this.productIds,
    this.slots,
    this.resourceAllocation,
    this.constraints,
    this.status = 'draft',
    this.approvedDate,
    this.approvedByUserId,
    this.approvedBy,
    this.isActive,
    this.lastModifiedDate,
    this.lastModifiedBy,
  });

  factory ProductionPlanModel.fromJson(Map<String, dynamic> json) {
    return ProductionPlanModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      createdDate: json['createdDate'] is Timestamp
          ? (json['createdDate'] as Timestamp).toDate()
          : DateTime.parse(json['createdDate'].toString()),
      createdByUserId: json['createdByUserId'] as String,
      createdBy: json['createdBy'] as String?,
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.parse(json['startDate'].toString()),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.parse(json['endDate'].toString()),
      productionItems: json['productionItems'] != null
          ? (json['productionItems'] as List<dynamic>)
              .map((e) =>
                  ProductionItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      productIds: json['productIds'] != null
          ? List<String>.from(json['productIds'] as List)
          : null,
      slots: json['slots'] != null
          ? (json['slots'] as List<dynamic>)
              .map((e) =>
                  ProductionSlotModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      resourceAllocation: json['resourceAllocation'] != null
          ? (json['resourceAllocation'] as List<dynamic>)
              .map((e) =>
                  ResourceAllocationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      constraints: json['constraints'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'draft',
      approvedDate: json['approvedDate'] != null
          ? (json['approvedDate'] as Timestamp).toDate()
          : null,
      approvedByUserId: json['approvedByUserId'] as String?,
      approvedBy: json['approvedBy'] as String?,
      isActive: json['isActive'] as bool?,
      lastModifiedDate: json['lastModifiedDate'] != null
          ? (json['lastModifiedDate'] as Timestamp).toDate()
          : null,
      lastModifiedBy: json['lastModifiedBy'] as String?,
    );
  }
  final String? id;
  final String name;
  final String description;
  final DateTime createdDate;
  final String? createdBy;
  final String createdByUserId;
  final DateTime startDate;
  final DateTime endDate;
  final List<ProductionItemModel> productionItems;
  final List<String>? productIds;
  final List<ProductionSlotModel>? slots;
  final List<ResourceAllocationModel>? resourceAllocation;
  final Map<String, dynamic>? constraints;
  final String status;
  final DateTime? approvedDate;
  final String? approvedByUserId;
  final String? approvedBy;
  final bool? isActive;
  final DateTime? lastModifiedDate;
  final String? lastModifiedBy;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'createdDate': Timestamp.fromDate(createdDate),
      'createdByUserId': createdByUserId,
      'createdBy': createdBy,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'productionItems': productionItems.map((e) => e.toJson()).toList(),
      'productIds': productIds,
      'slots': slots?.map((e) => e.toJson()).toList(),
      'resourceAllocation': resourceAllocation?.map((e) => e.toJson()).toList(),
      'constraints': constraints,
      'status': status,
      'approvedDate':
          approvedDate != null ? Timestamp.fromDate(approvedDate!) : null,
      'approvedByUserId': approvedByUserId,
      'approvedBy': approvedBy,
      'isActive': isActive,
      'lastModifiedDate': lastModifiedDate != null
          ? Timestamp.fromDate(lastModifiedDate!)
          : null,
      'lastModifiedBy': lastModifiedBy,
    };
  }

  ProductionPlanModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdDate,
    String? createdByUserId,
    String? createdBy,
    DateTime? startDate,
    DateTime? endDate,
    List<ProductionItemModel>? productionItems,
    List<String>? productIds,
    List<ProductionSlotModel>? slots,
    List<ResourceAllocationModel>? resourceAllocation,
    Map<String, dynamic>? constraints,
    String? status,
    DateTime? approvedDate,
    String? approvedByUserId,
    String? approvedBy,
    bool? isActive,
    DateTime? lastModifiedDate,
    String? lastModifiedBy,
  }) {
    return ProductionPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productionItems: productionItems ?? this.productionItems,
      productIds: productIds ?? this.productIds,
      slots: slots ?? this.slots,
      resourceAllocation: resourceAllocation ?? this.resourceAllocation,
      constraints: constraints ?? this.constraints,
      status: status ?? this.status,
      approvedDate: approvedDate ?? this.approvedDate,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedBy: approvedBy ?? this.approvedBy,
      isActive: isActive ?? this.isActive,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }
}

/// Model representing an item in a production plan
class ProductionItemModel {

  const ProductionItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitOfMeasure,
    required this.scheduledDate,
    this.resourceRequirements,
    this.status = 'pending',
  });

  factory ProductionItemModel.fromJson(Map<String, dynamic> json) {
    return ProductionItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      scheduledDate: json['scheduledDate'] is Timestamp
          ? (json['scheduledDate'] as Timestamp).toDate()
          : DateTime.parse(json['scheduledDate'].toString()),
      resourceRequirements: json['resourceRequirements'] != null
          ? Map<String, double>.from(json['resourceRequirements'] as Map)
          : null,
      status: json['status'] as String? ?? 'pending',
    );
  }
  final String productId;
  final String productName;
  final double quantity;
  final String unitOfMeasure;
  final DateTime scheduledDate;
  final Map<String, double>? resourceRequirements;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitOfMeasure': unitOfMeasure,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'resourceRequirements': resourceRequirements,
      'status': status,
    };
  }

  ProductionItemModel copyWith({
    String? productId,
    String? productName,
    double? quantity,
    String? unitOfMeasure,
    DateTime? scheduledDate,
    Map<String, double>? resourceRequirements,
    String? status,
  }) {
    return ProductionItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      resourceRequirements: resourceRequirements ?? this.resourceRequirements,
      status: status ?? this.status,
    );
  }
}
