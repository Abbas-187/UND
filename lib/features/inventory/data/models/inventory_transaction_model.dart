import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_transaction_model.freezed.dart';
part 'inventory_transaction_model.g.dart';

// Define TransactionType enum
enum TransactionType {
  receipt,
  issue,
  transfer,
  return_,
  count,
  adjustment,
  other
}

/// Model representing an inventory transaction
@freezed
abstract class InventoryTransactionModel with _$InventoryTransactionModel {
  const InventoryTransactionModel._(); // Added for custom methods

  const factory InventoryTransactionModel({
    String? id,
    required String materialId,
    required String materialName,
    required String warehouseId,
    required TransactionType transactionType,
    required double quantity,
    required String uom,
    String? batchNumber,
    String? sourceLocationId,
    String? destinationLocationId,
    String? referenceNumber,
    String? referenceType,
    String? reason,
    String? notes,
    DateTime? transactionDate,
    String? performedBy,
    String? approvedBy,
    DateTime? approvedAt,
    @Default(false) bool isApproved,
    @Default(false) bool isPending,
    DateTime? createdAt,
  }) = _InventoryTransactionModel;

  /// Create from JSON
  factory InventoryTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryTransactionModelFromJson(json);

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime to Timestamp for Firestore
    if (transactionDate != null) {
      json['transactionDate'] = Timestamp.fromDate(transactionDate!);
    } else {
      json['transactionDate'] = Timestamp.now();
    }

    if (approvedAt != null) {
      json['approvedAt'] = Timestamp.fromDate(approvedAt!);
    }

    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    } else {
      json['createdAt'] = Timestamp.now();
    }

    return json;
  }
}
