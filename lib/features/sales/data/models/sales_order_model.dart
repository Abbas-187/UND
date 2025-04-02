import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a sales order item
class SalesOrderItemModel {
  SalesOrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.category,
    this.imageUrl,
    this.discount = 0,
    this.taxRate = 0,
  });

  factory SalesOrderItemModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderItemModel(
      productId: json['productId'],
      productName: json['productName'],
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      imageUrl: json['imageUrl'],
      discount:
          json['discount'] != null ? (json['discount'] as num).toDouble() : 0,
      taxRate:
          json['taxRate'] != null ? (json['taxRate'] as num).toDouble() : 0,
    );
  }

  final String productId;
  final String productName;
  final double quantity;
  final double price;
  final String? category;
  final String? imageUrl;
  final double discount;
  final double taxRate;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'discount': discount,
      'taxRate': taxRate,
    };
  }

  /// Calculate subtotal (price * quantity)
  double get subtotal => price * quantity;

  /// Calculate total discount amount
  double get discountAmount => subtotal * (discount / 100);

  /// Calculate total after discount
  double get totalAfterDiscount => subtotal - discountAmount;

  /// Calculate tax amount
  double get taxAmount => totalAfterDiscount * (taxRate / 100);

  /// Calculate total amount with tax
  double get totalAmount => totalAfterDiscount + taxAmount;

  /// Create a copy with optional new values
  SalesOrderItemModel copyWith({
    String? productId,
    String? productName,
    double? quantity,
    double? price,
    String? category,
    String? imageUrl,
    double? discount,
    double? taxRate,
  }) {
    return SalesOrderItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

/// Model for a sales order
class SalesOrderModel {
  SalesOrderModel({
    this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.items,
    this.status = 'pending',
    this.shippingAddress,
    this.billingAddress,
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.notes,
    this.shippingAmount = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    // Parse items
    final itemsList = (json['items'] as List).map((item) {
      return SalesOrderItemModel.fromJson(item);
    }).toList();

    return SalesOrderModel(
      id: json['id'],
      orderNumber: json['orderNumber'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      orderDate: (json['orderDate'] is Timestamp)
          ? (json['orderDate'] as Timestamp).toDate()
          : DateTime.parse(json['orderDate'].toString()),
      items: itemsList,
      status: json['status'] ?? 'pending',
      shippingAddress: json['shippingAddress'],
      billingAddress: json['billingAddress'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      notes: json['notes'],
      shippingAmount: json['shippingAmount'] != null
          ? (json['shippingAmount'] as num).toDouble()
          : 0,
      taxAmount:
          json['taxAmount'] != null ? (json['taxAmount'] as num).toDouble() : 0,
      discountAmount: json['discountAmount'] != null
          ? (json['discountAmount'] as num).toDouble()
          : 0,
    );
  }

  final String? id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final List<SalesOrderItemModel> items;
  final String status;
  final String? shippingAddress;
  final String? billingAddress;
  final String? paymentMethod;
  final String paymentStatus;
  final String? notes;
  final double shippingAmount;
  final double taxAmount;
  final double discountAmount;

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'orderDate': Timestamp.fromDate(orderDate),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'shippingAmount': shippingAmount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'subtotal': subtotal,
      'totalAmount': totalAmount,
    };
  }

  /// Calculate subtotal (sum of all item subtotals)
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Calculate total amount
  double get totalAmount {
    return subtotal - discountAmount + taxAmount + shippingAmount;
  }

  /// Check if order is paid
  bool get isPaid => paymentStatus == 'paid';

  /// Check if order is completed
  bool get isCompleted => status == 'completed';

  /// Check if order is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Create a copy with optional new values
  SalesOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    DateTime? orderDate,
    List<SalesOrderItemModel>? items,
    String? status,
    String? shippingAddress,
    String? billingAddress,
    String? paymentMethod,
    String? paymentStatus,
    String? notes,
    double? shippingAmount,
    double? taxAmount,
    double? discountAmount,
  }) {
    return SalesOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      items: items ?? this.items,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}
