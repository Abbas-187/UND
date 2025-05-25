// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      billingAddress: json['billing_address'],
      shippingAddress: json['shipping_address'],
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      items: json['items'] as List<dynamic>,
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdByUserId: json['created_by_user_id'] as String?,
      requiredDeliveryDate: json['required_delivery_date'] == null
          ? null
          : DateTime.parse(json['required_delivery_date'] as String),
      actualShipmentDate: json['actual_shipment_date'] == null
          ? null
          : DateTime.parse(json['actual_shipment_date'] as String),
      actualDeliveryDate: json['actual_delivery_date'] == null
          ? null
          : DateTime.parse(json['actual_delivery_date'] as String),
      shippingMethod: json['shipping_method'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String?,
      statusHistory: json['status_history'] as List<dynamic>?,
      branchId: json['branch_id'] as String?,
      partialFulfillment: json['partial_fulfillment'] as bool?,
      backorderedItems: json['backordered_items'] as List<dynamic>?,
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'order_date': instance.orderDate.toIso8601String(),
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'billing_address': instance.billingAddress,
      'shipping_address': instance.shippingAddress,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'tax_amount': instance.taxAmount,
      'shipping_cost': instance.shippingCost,
      'total_amount': instance.totalAmount,
      'notes': instance.notes,
      'created_by_user_id': instance.createdByUserId,
      'required_delivery_date':
          instance.requiredDeliveryDate?.toIso8601String(),
      'actual_shipment_date': instance.actualShipmentDate?.toIso8601String(),
      'actual_delivery_date': instance.actualDeliveryDate?.toIso8601String(),
      'shipping_method': instance.shippingMethod,
      'tracking_number': instance.trackingNumber,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'status_history': instance.statusHistory,
      'branch_id': instance.branchId,
      'partial_fulfillment': instance.partialFulfillment,
      'backordered_items': instance.backorderedItems,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.draft: 'draft',
  OrderStatus.submitted: 'submitted',
  OrderStatus.approved: 'approved',
  OrderStatus.fulfilled: 'fulfilled',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.backordered: 'backordered',
  OrderStatus.expired: 'expired',
  OrderStatus.rejected: 'rejected',
};
