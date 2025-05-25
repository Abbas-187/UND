// UseCase: Generates a traceability report for a given batch/lot number.
import '../../inventory/domain/repositories/inventory_repository.dart';

abstract class AnalyticsUseCase<T, P> {
  Future<T> execute(P params);
}

class TraceabilityReportParams {
  TraceabilityReportParams({required this.batchOrLotNumber});
  final String batchOrLotNumber;
}

class TraceabilityReportResult {
  TraceabilityReportResult({required this.events});
  final List<TraceabilityEvent> events;
}

class TraceabilityEvent {
  TraceabilityEvent({
    required this.timestamp,
    required this.movementType,
    required this.quantity,
    required this.location,
    this.documentId,
    this.employeeId,
  });
  final DateTime timestamp;
  final String movementType;
  final double quantity;
  final String location;
  final String? documentId;
  final String? employeeId;
}

class TraceabilityReportUseCase extends AnalyticsUseCase<
    TraceabilityReportResult, TraceabilityReportParams> {
  TraceabilityReportUseCase(this.inventoryRepository);
  final InventoryRepository inventoryRepository;

  @override
  Future<TraceabilityReportResult> execute(
      TraceabilityReportParams params) async {
    // Fetch all movements for the batch/lot number
    final movements = await inventoryRepository
        .getItemMovementHistory(params.batchOrLotNumber);
    final events = movements
        .map((mov) => TraceabilityEvent(
              timestamp: mov.timestamp,
              movementType: mov.movementType.toString(),
              quantity: mov.quantity,
              location: mov.location ?? '',
              documentId: mov.documentId,
              employeeId: mov.employeeId,
            ))
        .toList();
    return TraceabilityReportResult(events: events);
  }
}
