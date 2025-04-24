// Procurement request model to represent procurement requests in the system
// This model is used by the ProcurementService to manage procurement requests

import '../../../core/errors/exceptions.dart';
import 'procurement_status.dart';

/// Represents a procurement request in the system
class ProcurementRequest {
  final String id;
  final String orderId;
  final String location;
  final List<ProcurementRequestItem> items;
  final String requestedBy;
  final DateTime requestDate;
  final ProcurementRequestStatus status;
  final String? notes;
  final DateTime? fulfilledAt;
  final String? fulfilledBy;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime? updatedAt;

  /// Creates a new procurement request
  ProcurementRequest({
    required this.id,
    required this.orderId,
    required this.location,
    required this.items,
    required this.requestedBy,
    required this.requestDate,
    required this.status,
    this.notes,
    this.fulfilledAt,
    this.fulfilledBy,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.updatedAt,
  });

  /// Creates a copy of this procurement request with the given fields replaced
  ProcurementRequest copyWith({
    String? id,
    String? orderId,
    String? location,
    List<ProcurementRequestItem>? items,
    String? requestedBy,
    DateTime? requestDate,
    ProcurementRequestStatus? status,
    String? notes,
    DateTime? fulfilledAt,
    String? fulfilledBy,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    DateTime? updatedAt,
  }) {
    return ProcurementRequest(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      location: location ?? this.location,
      items: items ?? this.items,
      requestedBy: requestedBy ?? this.requestedBy,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      fulfilledAt: fulfilledAt ?? this.fulfilledAt,
      fulfilledBy: fulfilledBy ?? this.fulfilledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a procurement request from a JSON map
  factory ProcurementRequest.fromJson(Map<String, dynamic> json) {
    try {
      return ProcurementRequest(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        location: json['location'] as String,
        items: (json['items'] as List)
            .map((item) => ProcurementRequestItem.fromJson(item))
            .toList(),
        requestedBy: json['requestedBy'] as String,
        requestDate: DateTime.parse(json['requestDate'] as String),
        status: ProcurementRequestStatus.fromString(json['status'] as String),
        notes: json['notes'] as String?,
        fulfilledAt: json['fulfilledAt'] != null
            ? DateTime.parse(json['fulfilledAt'] as String)
            : null,
        fulfilledBy: json['fulfilledBy'] as String?,
        cancelledAt: json['cancelledAt'] != null
            ? DateTime.parse(json['cancelledAt'] as String)
            : null,
        cancelledBy: json['cancelledBy'] as String?,
        cancellationReason: json['cancellationReason'] as String?,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      throw DataParsingException(
          'Error parsing procurement request: ${e.toString()}');
    }
  }

  /// Converts this procurement request to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'location': location,
      'items': items.map((item) => item.toJson()).toList(),
      'requestedBy': requestedBy,
      'requestDate': requestDate.toIso8601String(),
      'status': status.toString(),
      if (notes != null) 'notes': notes,
      if (fulfilledAt != null) 'fulfilledAt': fulfilledAt!.toIso8601String(),
      if (fulfilledBy != null) 'fulfilledBy': fulfilledBy,
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Calculate the total estimated value of all items in this procurement request
  double get totalEstimatedValue {
    return items.fold(
        0, (sum, item) => sum + (item.estimatedPrice ?? 0) * item.quantity);
  }

  /// Check if this procurement request is in a state where it can be fulfilled
  bool get canBeFulfilled {
    return status == ProcurementRequestStatus.pending ||
        status == ProcurementRequestStatus.inProgress;
  }

  /// Check if this procurement request is in a state where it can be cancelled
  bool get canBeCancelled {
    return status == ProcurementRequestStatus.pending ||
        status == ProcurementRequestStatus.inProgress;
  }
}

/// Represents an item in a procurement request
class ProcurementRequestItem {
  final String name;
  final double quantity;
  final String unit;
  final String? productId;
  final double? estimatedPrice;
  final double? actualQuantityReceived;

  /// Creates a new procurement request item
  ProcurementRequestItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.productId,
    this.estimatedPrice,
    this.actualQuantityReceived,
  });

  /// Creates a procurement request item from a JSON map
  factory ProcurementRequestItem.fromJson(Map<String, dynamic> json) {
    try {
      return ProcurementRequestItem(
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        productId: json['productId'] as String?,
        estimatedPrice: json['estimatedPrice'] != null
            ? (json['estimatedPrice'] as num).toDouble()
            : null,
        actualQuantityReceived: json['actualQuantityReceived'] != null
            ? (json['actualQuantityReceived'] as num).toDouble()
            : null,
      );
    } catch (e) {
      throw DataParsingException(
          'Error parsing procurement request item: ${e.toString()}');
    }
  }

  /// Converts this procurement request item to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      if (productId != null) 'productId': productId,
      if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
      if (actualQuantityReceived != null)
        'actualQuantityReceived': actualQuantityReceived,
    };
  }

  /// Creates a copy of this procurement request item with the given fields replaced
  ProcurementRequestItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? productId,
    double? estimatedPrice,
    double? actualQuantityReceived,
  }) {
    return ProcurementRequestItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      productId: productId ?? this.productId,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualQuantityReceived:
          actualQuantityReceived ?? this.actualQuantityReceived,
    );
  }
}
