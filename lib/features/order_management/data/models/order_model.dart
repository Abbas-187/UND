import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.customerId,
    required this.customerName,
    required this.billingAddress,
    required this.shippingAddress,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.totalAmount,
    this.notes,
    this.createdByUserId,
    this.requiredDeliveryDate,
    this.actualShipmentDate,
    this.actualDeliveryDate,
    this.shippingMethod,
    this.trackingNumber,
    this.paymentMethod,
    this.paymentStatus,
    this.statusHistory,
    this.branchId,
    this.partialFulfillment,
    this.backorderedItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromEntity(OrderEntity entity) => OrderModel(
        id: entity.id,
        orderNumber: entity.orderNumber,
        orderDate: entity.orderDate,
        customerId: entity.customerId,
        customerName: entity.customerName,
        billingAddress: entity.billingAddress,
        shippingAddress: entity.shippingAddress,
        status: entity.status,
        items: entity.items,
        subtotal: entity.subtotal,
        taxAmount: entity.taxAmount,
        shippingCost: entity.shippingCost,
        totalAmount: entity.totalAmount,
        notes: entity.notes,
        createdByUserId: entity.createdByUserId,
        requiredDeliveryDate: entity.requiredDeliveryDate,
        actualShipmentDate: entity.actualShipmentDate,
        actualDeliveryDate: entity.actualDeliveryDate,
        shippingMethod: entity.shippingMethod,
        trackingNumber: entity.trackingNumber,
        paymentMethod: entity.paymentMethod,
        paymentStatus: entity.paymentStatus,
        statusHistory: entity.statusHistory,
        branchId: entity.branchId,
        partialFulfillment: entity.partialFulfillment,
        backorderedItems: entity.backorderedItems,
      );

  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final String customerId;
  final String customerName;
  final dynamic billingAddress;
  final dynamic shippingAddress;
  final OrderStatus status;
  final List<dynamic> items;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double totalAmount;
  final String? notes;
  final String? createdByUserId;
  final DateTime? requiredDeliveryDate;
  final DateTime? actualShipmentDate;
  final DateTime? actualDeliveryDate;
  final String? shippingMethod;
  final String? trackingNumber;
  final String? paymentMethod;
  final String? paymentStatus;
  final List<dynamic>? statusHistory;
  final String? branchId;
  final bool? partialFulfillment;
  final List<dynamic>? backorderedItems;

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() => OrderEntity(
        id: id,
        orderNumber: orderNumber,
        orderDate: orderDate,
        customerId: customerId,
        customerName: customerName,
        billingAddress: billingAddress,
        shippingAddress: shippingAddress,
        status: status,
        items: items,
        subtotal: subtotal,
        taxAmount: taxAmount,
        shippingCost: shippingCost,
        totalAmount: totalAmount,
        notes: notes,
        createdByUserId: createdByUserId,
        requiredDeliveryDate: requiredDeliveryDate,
        actualShipmentDate: actualShipmentDate,
        actualDeliveryDate: actualDeliveryDate,
        shippingMethod: shippingMethod,
        trackingNumber: trackingNumber,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        statusHistory: statusHistory,
        branchId: branchId,
        partialFulfillment: partialFulfillment,
        backorderedItems: backorderedItems,
      );

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    DateTime? orderDate,
    String? customerId,
    String? customerName,
    dynamic billingAddress,
    dynamic shippingAddress,
    OrderStatus? status,
    List<dynamic>? items,
    double? subtotal,
    double? taxAmount,
    double? shippingCost,
    double? totalAmount,
    String? notes,
    String? createdByUserId,
    DateTime? requiredDeliveryDate,
    DateTime? actualShipmentDate,
    DateTime? actualDeliveryDate,
    String? shippingMethod,
    String? trackingNumber,
    String? paymentMethod,
    String? paymentStatus,
    List<dynamic>? statusHistory,
    String? branchId,
    bool? partialFulfillment,
    List<dynamic>? backorderedItems,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      orderDate: orderDate ?? this.orderDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      requiredDeliveryDate: requiredDeliveryDate ?? this.requiredDeliveryDate,
      actualShipmentDate: actualShipmentDate ?? this.actualShipmentDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      statusHistory: statusHistory ?? this.statusHistory,
      branchId: branchId ?? this.branchId,
      partialFulfillment: partialFulfillment ?? this.partialFulfillment,
      backorderedItems: backorderedItems ?? this.backorderedItems,
    );
  }
}

class OrderItem {
  OrderItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.productId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        productId: json['productId'] as String,
      );
  final String name;
  final double quantity;
  final String unit;
  final String productId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'productId': productId,
      };
}

/// Robust order status enum for all lifecycle stages
/// Use this throughout the codebase for safety and consistency
enum OrderStatus {
  draft,
  submitted,
  approved,
  fulfilled,
  shipped,
  delivered,
  cancelled,
  backordered,
  expired,
  rejected,
}

class OrderStatusHistoryModel {
  final OrderStatus status;
  final DateTime timestamp;
  final String? userId;
  final String? notes;

  OrderStatusHistoryModel({
    required this.status,
    required this.timestamp,
    this.userId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        if (userId != null) 'userId': userId,
        if (notes != null) 'notes': notes,
      };

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) =>
      OrderStatusHistoryModel(
        status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
        timestamp: DateTime.parse(json['timestamp']),
        userId: json['userId'],
        notes: json['notes'],
      );
}
