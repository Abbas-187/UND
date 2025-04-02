import 'order_item_model.dart';
import 'customer_model.dart';

// --- Order Status Enum ---
enum OrderStatus {
  draft,
  pendingApproval,
  confirmed, // Approved
  processing, // In warehouse/fulfillment
  shipped,
  partiallyShipped,
  delivered,
  completed, // Fully delivered and invoiced
  cancelled,
  onHold,
}

// --- Main Order Model ---
class OrderModel {
  final String id;
  final String orderNumber; // e.g., SO-2024-00123
  final DateTime orderDate;
  final String customerId;
  final String customerName;
  final AddressModel billingAddress;
  final AddressModel shippingAddress;
  final OrderStatus status;
  final List<OrderItemModel> items;
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
  final String? paymentStatus; // e.g., 'pending', 'paid', 'failed'
  final List<OrderStatusHistoryModel>? statusHistory;

  const OrderModel({
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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      billingAddress:
          AddressModel.fromJson(json['billingAddress'] as Map<String, dynamic>),
      shippingAddress: AddressModel.fromJson(
          json['shippingAddress'] as Map<String, dynamic>),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.draft,
      ),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      requiredDeliveryDate: json['requiredDeliveryDate'] != null
          ? DateTime.parse(json['requiredDeliveryDate'] as String)
          : null,
      actualShipmentDate: json['actualShipmentDate'] != null
          ? DateTime.parse(json['actualShipmentDate'] as String)
          : null,
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? DateTime.parse(json['actualDeliveryDate'] as String)
          : null,
      shippingMethod: json['shippingMethod'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      statusHistory: json['statusHistory'] != null
          ? (json['statusHistory'] as List<dynamic>)
              .map((e) =>
                  OrderStatusHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'billingAddress': billingAddress.toJson(),
      'shippingAddress': shippingAddress.toJson(),
      'status': status.toString().split('.').last,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'shippingCost': shippingCost,
      'totalAmount': totalAmount,
      if (notes != null) 'notes': notes,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (requiredDeliveryDate != null)
        'requiredDeliveryDate': requiredDeliveryDate!.toIso8601String(),
      if (actualShipmentDate != null)
        'actualShipmentDate': actualShipmentDate!.toIso8601String(),
      if (actualDeliveryDate != null)
        'actualDeliveryDate': actualDeliveryDate!.toIso8601String(),
      if (shippingMethod != null) 'shippingMethod': shippingMethod,
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (statusHistory != null)
        'statusHistory': statusHistory!.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy of this OrderModel but with the given field values replaced
  OrderModel copyWith({
    String? id,
    String? orderNumber,
    DateTime? orderDate,
    String? customerId,
    String? customerName,
    AddressModel? billingAddress,
    AddressModel? shippingAddress,
    OrderStatus? status,
    List<OrderItemModel>? items,
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
    List<OrderStatusHistoryModel>? statusHistory,
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
    );
  }
}

// --- Status History Model ---
class OrderStatusHistoryModel {
  final OrderStatus status;
  final DateTime timestamp;
  final String? userId;
  final String? notes;

  const OrderStatusHistoryModel({
    required this.status,
    required this.timestamp,
    this.userId,
    this.notes,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.draft,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      if (userId != null) 'userId': userId,
      if (notes != null) 'notes': notes,
    };
  }
}
