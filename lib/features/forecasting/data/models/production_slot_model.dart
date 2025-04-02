import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a production slot
class ProductionSlotModel {
  final String? id;
  final String productId;
  final String productName;
  final double plannedQuantity;
  final double? actualQuantity;
  final DateTime startDate;
  final DateTime endDate;
  final String? resourceId;
  final String? resourceName;
  final String status;
  final int priority;
  final Map<String, dynamic>? metadata;

  const ProductionSlotModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.plannedQuantity,
    this.actualQuantity,
    required this.startDate,
    required this.endDate,
    this.resourceId,
    this.resourceName,
    required this.status,
    required this.priority,
    this.metadata,
  });

  factory ProductionSlotModel.fromJson(Map<String, dynamic> json) {
    return ProductionSlotModel(
      id: json['id'] as String?,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      plannedQuantity: (json['plannedQuantity'] as num).toDouble(),
      actualQuantity: json['actualQuantity'] != null
          ? (json['actualQuantity'] as num).toDouble()
          : null,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      resourceId: json['resourceId'] as String?,
      resourceName: json['resourceName'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'plannedQuantity': plannedQuantity,
      'actualQuantity': actualQuantity,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'resourceId': resourceId,
      'resourceName': resourceName,
      'status': status,
      'priority': priority,
      'metadata': metadata,
    };
  }

  ProductionSlotModel copyWith({
    String? id,
    String? productId,
    String? productName,
    double? plannedQuantity,
    double? actualQuantity,
    DateTime? startDate,
    DateTime? endDate,
    String? resourceId,
    String? resourceName,
    String? status,
    int? priority,
    Map<String, dynamic>? metadata,
  }) {
    return ProductionSlotModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
    );
  }
}
