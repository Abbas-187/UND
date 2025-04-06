import 'package:meta/meta.dart';

import 'inventory_movement_item_model.dart';
import 'inventory_movement_type.dart';

@immutable
class InventoryMovementModel {

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) =>
            InventoryMovementItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final referenceDocuments = (json['referenceDocuments'] as List<dynamic>)
        .map((doc) => doc as String)
        .toList();

    return InventoryMovementModel(
      movementId: json['movementId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      movementType: InventoryMovementType.values.firstWhere(
        (e) => e.toString() == 'InventoryMovementType.${json['movementType']}',
        orElse: () => InventoryMovementType.TRANSFER,
      ),
      sourceLocationId: json['sourceLocationId'] as String,
      sourceLocationName: json['sourceLocationName'] as String,
      destinationLocationId: json['destinationLocationId'] as String,
      destinationLocationName: json['destinationLocationName'] as String,
      initiatingEmployeeId: json['initiatingEmployeeId'] as String,
      initiatingEmployeeName: json['initiatingEmployeeName'] as String,
      approvalStatus: ApprovalStatus.values.firstWhere(
        (e) => e.toString() == 'ApprovalStatus.${json['approvalStatus']}',
        orElse: () => ApprovalStatus.PENDING,
      ),
      approverEmployeeId: json['approverEmployeeId'] as String?,
      approverEmployeeName: json['approverEmployeeName'] as String?,
      reasonNotes: json['reasonNotes'] as String,
      referenceDocuments: referenceDocuments,
      items: items,
    );
  }
  const InventoryMovementModel({
    required this.movementId,
    required this.timestamp,
    required this.movementType,
    required this.sourceLocationId,
    required this.sourceLocationName,
    required this.destinationLocationId,
    required this.destinationLocationName,
    required this.initiatingEmployeeId,
    required this.initiatingEmployeeName,
    required this.approvalStatus,
    this.approverEmployeeId,
    this.approverEmployeeName,
    required this.reasonNotes,
    required this.referenceDocuments,
    required this.items,
  });

  final String movementId;
  final DateTime timestamp;
  final InventoryMovementType movementType;
  final String sourceLocationId;
  final String sourceLocationName;
  final String destinationLocationId;
  final String destinationLocationName;
  final String initiatingEmployeeId;
  final String initiatingEmployeeName;
  final ApprovalStatus approvalStatus;
  final String? approverEmployeeId;
  final String? approverEmployeeName;
  final String reasonNotes;
  final List<String> referenceDocuments;
  final List<InventoryMovementItemModel> items;

  Map<String, dynamic> toJson() {
    return {
      'movementId': movementId,
      'timestamp': timestamp.toIso8601String(),
      'movementType': movementType.toString().split('.').last,
      'sourceLocationId': sourceLocationId,
      'sourceLocationName': sourceLocationName,
      'destinationLocationId': destinationLocationId,
      'destinationLocationName': destinationLocationName,
      'initiatingEmployeeId': initiatingEmployeeId,
      'initiatingEmployeeName': initiatingEmployeeName,
      'approvalStatus': approvalStatus.toString().split('.').last,
      'approverEmployeeId': approverEmployeeId,
      'approverEmployeeName': approverEmployeeName,
      'reasonNotes': reasonNotes,
      'referenceDocuments': referenceDocuments,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'InventoryMovementModel(movementId: $movementId, timestamp: $timestamp, '
        'movementType: $movementType, sourceLocationId: $sourceLocationId, '
        'sourceLocationName: $sourceLocationName, destinationLocationId: $destinationLocationId, '
        'destinationLocationName: $destinationLocationName, '
        'initiatingEmployeeId: $initiatingEmployeeId, initiatingEmployeeName: $initiatingEmployeeName, '
        'approvalStatus: $approvalStatus, approverEmployeeId: $approverEmployeeId, '
        'approverEmployeeName: $approverEmployeeName, reasonNotes: $reasonNotes, '
        'referenceDocuments: $referenceDocuments, items count: ${items.length})';
  }
}
