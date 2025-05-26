import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String bomId,
    required String productionOrderId,
    required String itemId,
    required String itemCode,
    required String itemName,
    required double reservedQuantity,
    required String unit,
    required ReservationStatus status,
    required DateTime reservationDate,
    required DateTime expiryDate,
    required String reservedBy,
    String? warehouseId,
    String? batchNumber,
    String? lotNumber,
    DateTime? releaseDate,
    String? releasedBy,
    String? notes,
    int? priority,
    Map<String, dynamic>? metadata,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

@freezed
abstract class ReservationRequest with _$ReservationRequest {
  const factory ReservationRequest({
    required String bomId,
    required String productionOrderId,
    required double batchSize,
    required DateTime requiredDate,
    required String requestedBy,
    String? warehouseId,
    int? priority,
    String? notes,
    Map<String, String>? itemPreferences, // itemId -> preferred batch/lot
  }) = _ReservationRequest;

  factory ReservationRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationRequestFromJson(json);
}

@freezed
abstract class ReservationResult with _$ReservationResult {
  const factory ReservationResult({
    required String requestId,
    required bool isFullyReserved,
    required List<Reservation> reservations,
    required List<ReservationFailure> failures,
    required DateTime processedAt,
    String? notes,
  }) = _ReservationResult;

  factory ReservationResult.fromJson(Map<String, dynamic> json) =>
      _$ReservationResultFromJson(json);
}

@freezed
abstract class ReservationFailure with _$ReservationFailure {
  const factory ReservationFailure({
    required String itemId,
    required String itemCode,
    required double requestedQuantity,
    required double availableQuantity,
    required String reason,
    required FailureType failureType,
    List<String>? suggestedActions,
  }) = _ReservationFailure;

  factory ReservationFailure.fromJson(Map<String, dynamic> json) =>
      _$ReservationFailureFromJson(json);
}

@freezed
abstract class ReservationConflict with _$ReservationConflict {
  const factory ReservationConflict({
    required String itemId,
    required String itemCode,
    required String itemName,
    required double requiredQuantity,
    required double availableQuantity,
    required List<Reservation> conflictingReservations,
    required ConflictType conflictType,
  }) = _ReservationConflict;

  factory ReservationConflict.fromJson(Map<String, dynamic> json) =>
      _$ReservationConflictFromJson(json);
}

@freezed
abstract class ReservationOptimization with _$ReservationOptimization {
  const factory ReservationOptimization({
    required List<OptimizedAllocation> optimizedAllocations,
    required List<ReservationRequest> unallocatedRequests,
    required double optimizationScore,
    required DateTime processedAt,
  }) = _ReservationOptimization;

  factory ReservationOptimization.fromJson(Map<String, dynamic> json) =>
      _$ReservationOptimizationFromJson(json);
}

@freezed
abstract class OptimizedAllocation with _$OptimizedAllocation {
  const factory OptimizedAllocation({
    required ReservationRequest request,
    required ReservationResult result,
    required double allocationScore,
  }) = _OptimizedAllocation;

  factory OptimizedAllocation.fromJson(Map<String, dynamic> json) =>
      _$OptimizedAllocationFromJson(json);
}

enum ReservationStatus {
  active,
  expired,
  released,
  consumed,
  cancelled,
  partial,
}

enum FailureType {
  insufficientStock,
  itemUnavailable,
  qualityIssue,
  expired,
  systemError,
}

enum ConflictType {
  insufficientStock,
  priorityConflict,
  dateConflict,
  qualityIssue,
}
