import 'package:meta/meta.dart';
import 'quality_status.dart';

enum MovementItemStatus { IN_TRANSIT, RECEIVED, REJECTED, DAMAGED, LOST }

@immutable
class InventoryMovementItemModel {
  const InventoryMovementItemModel({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.batchLotNumber,
    required this.quantity,
    required this.unitOfMeasurement,
    required this.status,
    required this.productionDate,
    required this.expirationDate,
    required this.qualityStatus,
  });

  final String itemId;
  final String productId;
  final String productName;
  final String batchLotNumber;
  final double quantity;
  final String unitOfMeasurement;
  final MovementItemStatus status;
  final DateTime productionDate;
  final DateTime expirationDate;
  final QualityStatus qualityStatus;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'productId': productId,
      'productName': productName,
      'batchLotNumber': batchLotNumber,
      'quantity': quantity,
      'unitOfMeasurement': unitOfMeasurement,
      'status': status.toString().split('.').last,
      'productionDate': productionDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'qualityStatus': qualityStatus.toString().split('.').last,
    };
  }

  factory InventoryMovementItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementItemModel(
      itemId: json['itemId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      batchLotNumber: json['batchLotNumber'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasurement: json['unitOfMeasurement'] as String,
      status: MovementItemStatus.values.firstWhere(
        (e) => e.toString() == 'MovementItemStatus.${json['status']}',
        orElse: () => MovementItemStatus.IN_TRANSIT,
      ),
      productionDate: DateTime.parse(json['productionDate'] as String),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      qualityStatus: QualityStatus.values.firstWhere(
        (e) => e.toString() == 'QualityStatus.${json['qualityStatus']}',
        orElse: () => QualityStatus.excellent,
      ),
    );
  }
}
