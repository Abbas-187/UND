import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// Represents the status of an order in the system
enum OrderStatus {
  draft,
  pending,
  approved,
  inProduction,
  ready,
  delivered,
  cancelled,
  rejected,
  awaitingProcurement,
  readyForProduction,
  completed,
}

/// Represents the production status of an order
enum ProductionStatus {
  notStarted,
  inProgress,
  onHold,
  completed,
  failed,
}

/// Represents the procurement status for order materials
enum ProcurementStatus {
  notRequired,
  pending,
  ordered,
  partiallyReceived,
  received,
  delayed,
  fulfilled,
  rejected,
}

/// Represents the priority level of an order
enum PriorityLevel {
  low,
  medium,
  high,
  urgent,
}

/// Represents an order in the system
@immutable
class Order {
  final String id;
  final String customer;
  final List<OrderItem> items;
  final String location;
  final OrderStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductionStatus productionStatus;
  final ProcurementStatus procurementStatus;
  final PriorityLevel priorityLevel;
  final Map<String, dynamic>? customerPreferences;
  final List<String>? customerAllergies;
  final String? customerNotes;
  final String? customerTier;
  final String? notes;
  final double? totalAmount;
  final String? assignedTo;
  final DateTime? dueDate;
  final DateTime? deliveryDate;
  final String? recipeId;
  final String? justification;
  final String? cancellationReason;
  final String? cancellationBy;
  final DateTime? cancellationAt;

  const Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.location,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.productionStatus,
    required this.procurementStatus,
    this.priorityLevel = PriorityLevel.medium,
    this.customerPreferences,
    this.customerAllergies,
    this.customerNotes,
    this.customerTier,
    this.notes,
    this.totalAmount,
    this.assignedTo,
    this.dueDate,
    this.deliveryDate,
    this.recipeId,
    this.justification,
    this.cancellationReason,
    this.cancellationBy,
    this.cancellationAt,
  });

  /// Creates an order with default values for new orders
  factory Order.create({
    required String customer,
    required String location,
    required String createdBy,
    String? id,
    List<OrderItem> items = const [],
  }) {
    final now = DateTime.now();
    return Order(
      id: id ?? const Uuid().v4(),
      customer: customer,
      items: items,
      location: location,
      status: OrderStatus.draft,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      productionStatus: ProductionStatus.notStarted,
      procurementStatus: ProcurementStatus.notRequired,
    );
  }

  // Provides immutable access to items
  List<OrderItem> get itemsList => List.unmodifiable(items);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.customer == customer &&
        listEquals(other.items, items) &&
        other.location == location &&
        other.status == status &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.productionStatus == productionStatus &&
        other.procurementStatus == procurementStatus &&
        other.priorityLevel == priorityLevel &&
        mapEquals(other.customerPreferences, customerPreferences) &&
        listEquals(other.customerAllergies, customerAllergies) &&
        other.customerNotes == customerNotes &&
        other.customerTier == customerTier &&
        other.notes == notes &&
        other.totalAmount == totalAmount &&
        other.assignedTo == assignedTo &&
        other.dueDate == dueDate &&
        other.deliveryDate == deliveryDate &&
        other.recipeId == recipeId &&
        other.justification == justification &&
        other.cancellationReason == cancellationReason &&
        other.cancellationBy == cancellationBy &&
        other.cancellationAt == cancellationAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        customer,
        Object.hashAll(items),
        location,
        status,
        createdBy,
        createdAt,
        updatedAt,
        productionStatus,
        procurementStatus,
        priorityLevel,
        customerPreferences != null
            ? Object.hashAll(customerPreferences!.entries)
            : null,
        customerAllergies != null ? Object.hashAll(customerAllergies!) : null,
        customerNotes,
        customerTier,
        notes,
        totalAmount,
        assignedTo,
        dueDate,
        deliveryDate,
        recipeId,
        justification,
        cancellationReason,
        cancellationBy,
        cancellationAt,
      ]);

  // Creates a copy with modified fields
  Order copyWith({
    String? id,
    String? customer,
    List<OrderItem>? items,
    String? location,
    OrderStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductionStatus? productionStatus,
    ProcurementStatus? procurementStatus,
    PriorityLevel? priorityLevel,
    Map<String, dynamic>? customerPreferences,
    List<String>? customerAllergies,
    String? customerNotes,
    String? customerTier,
    String? notes,
    double? totalAmount,
    String? assignedTo,
    DateTime? dueDate,
    DateTime? deliveryDate,
    String? recipeId,
    String? justification,
    String? cancellationReason,
    String? cancellationBy,
    DateTime? cancellationAt,
  }) {
    return Order(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      location: location ?? this.location,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productionStatus: productionStatus ?? this.productionStatus,
      procurementStatus: procurementStatus ?? this.procurementStatus,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      customerPreferences: customerPreferences ?? this.customerPreferences,
      customerAllergies: customerAllergies ?? this.customerAllergies,
      customerNotes: customerNotes ?? this.customerNotes,
      customerTier: customerTier ?? this.customerTier,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      recipeId: recipeId ?? this.recipeId,
      justification: justification ?? this.justification,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationBy: cancellationBy ?? this.cancellationBy,
      cancellationAt: cancellationAt ?? this.cancellationAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'items': items.map((item) => item.toJson()).toList(),
      'location': location,
      'status': status.name,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'productionStatus': productionStatus.name,
      'procurementStatus': procurementStatus.name,
      'priorityLevel': priorityLevel.name,
      'customerPreferences': customerPreferences,
      'customerAllergies': customerAllergies,
      'customerNotes': customerNotes,
      'customerTier': customerTier,
      'notes': notes,
      'totalAmount': totalAmount,
      'assignedTo': assignedTo,
      'dueDate': dueDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'recipeId': recipeId,
      'justification': justification,
      'cancellationReason': cancellationReason,
      'cancellationBy': cancellationBy,
      'cancellationAt': cancellationAt?.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customer: json['customer'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      location: json['location'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.draft,
      ),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productionStatus: ProductionStatus.values.firstWhere(
        (e) => e.name == json['productionStatus'],
        orElse: () => ProductionStatus.notStarted,
      ),
      procurementStatus: ProcurementStatus.values.firstWhere(
        (e) => e.name == json['procurementStatus'],
        orElse: () => ProcurementStatus.notRequired,
      ),
      priorityLevel: json['priorityLevel'] != null
          ? PriorityLevel.values.firstWhere(
              (e) => e.name == json['priorityLevel'],
              orElse: () => PriorityLevel.medium,
            )
          : PriorityLevel.medium,
      customerPreferences: json['customerPreferences'] != null
          ? Map<String, dynamic>.from(json['customerPreferences'])
          : null,
      customerAllergies: json['customerAllergies'] != null
          ? List<String>.from(json['customerAllergies'])
          : null,
      customerNotes: json['customerNotes'],
      customerTier: json['customerTier'],
      notes: json['notes'],
      totalAmount: json['totalAmount'],
      assignedTo: json['assignedTo'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      recipeId: json['recipeId'],
      justification: json['justification'],
      cancellationReason: json['cancellationReason'],
      cancellationBy: json['cancellationBy'],
      cancellationAt: json['cancellationAt'] != null
          ? DateTime.parse(json['cancellationAt'])
          : null,
    );
  }
}

/// Represents an item in an order
@immutable
class OrderItem {
  final String name;
  final int quantity;
  final String unit;
  final String? notes;
  final double? unitPrice;
  final String? productId;
  final String? category;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.notes,
    this.unitPrice,
    this.productId,
    this.category,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.notes == notes &&
        other.unitPrice == unitPrice &&
        other.productId == productId &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        quantity,
        unit,
        notes,
        unitPrice,
        productId,
        category,
      ]);

  OrderItem copyWith({
    String? name,
    int? quantity,
    String? unit,
    String? notes,
    double? unitPrice,
    String? productId,
    String? category,
  }) {
    return OrderItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      unitPrice: unitPrice ?? this.unitPrice,
      productId: productId ?? this.productId,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'unitPrice': unitPrice,
      'productId': productId,
      'category': category,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      notes: json['notes'],
      unitPrice: json['unitPrice'],
      productId: json['productId'],
      category: json['category'],
    );
  }
}
