import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

/// Extended OrderEntity to support advanced order fields for create/edit screens
class OrderEntity extends Equatable {
  const OrderEntity({
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

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        orderDate,
        customerId,
        customerName,
        billingAddress,
        shippingAddress,
        status,
        items,
        subtotal,
        taxAmount,
        shippingCost,
        totalAmount,
        notes,
        createdByUserId,
        requiredDeliveryDate,
        actualShipmentDate,
        actualDeliveryDate,
        shippingMethod,
        trackingNumber,
        paymentMethod,
        paymentStatus,
        statusHistory,
        branchId,
        partialFulfillment,
        backorderedItems,
      ];

  OrderEntity copyWith({
    List<dynamic>? items,
    bool? partialFulfillment,
    List<dynamic>? backorderedItems,
  }) {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      orderDate: orderDate,
      customerId: customerId,
      customerName: customerName,
      billingAddress: billingAddress,
      shippingAddress: shippingAddress,
      status: status,
      items: items ?? this.items,
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
      partialFulfillment: partialFulfillment ?? this.partialFulfillment,
      backorderedItems: backorderedItems ?? this.backorderedItems,
    );
  }
}
