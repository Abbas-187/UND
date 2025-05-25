// Data model for cycle count item (line in a sheet)
class CycleCountItem {
  CycleCountItem({
    required this.countItemId,
    required this.sheetId,
    required this.inventoryItemId,
    this.batchLotNumber,
    required this.expectedQuantity,
    this.countedQuantity,
    this.countTimestamp,
    this.discrepancyQuantity,
    this.discrepancyReasonCodeId,
    required this.status,
    this.adjustmentMovementId,
  });
  final String countItemId;
  final String sheetId;
  final String inventoryItemId;
  final String? batchLotNumber;
  final double expectedQuantity;
  final double? countedQuantity;
  final DateTime? countTimestamp;
  final double? discrepancyQuantity;
  final String? discrepancyReasonCodeId;
  final String status; // Pending Count, Counted, Requires Review, Adjusted
  final String? adjustmentMovementId;

  CycleCountItem copyWith({
    String? countItemId,
    String? sheetId,
    String? inventoryItemId,
    String? batchLotNumber,
    double? expectedQuantity,
    double? countedQuantity,
    DateTime? countTimestamp,
    double? discrepancyQuantity,
    String? discrepancyReasonCodeId,
    String? status,
    String? adjustmentMovementId,
  }) {
    return CycleCountItem(
      countItemId: countItemId ?? this.countItemId,
      sheetId: sheetId ?? this.sheetId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      batchLotNumber: batchLotNumber ?? this.batchLotNumber,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      countTimestamp: countTimestamp ?? this.countTimestamp,
      discrepancyQuantity: discrepancyQuantity ?? this.discrepancyQuantity,
      discrepancyReasonCodeId:
          discrepancyReasonCodeId ?? this.discrepancyReasonCodeId,
      status: status ?? this.status,
      adjustmentMovementId: adjustmentMovementId ?? this.adjustmentMovementId,
    );
  }
}
