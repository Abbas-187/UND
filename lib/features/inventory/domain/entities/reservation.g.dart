// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
      id: json['id'] as String,
      bomId: json['bom_id'] as String,
      productionOrderId: json['production_order_id'] as String,
      itemId: json['item_id'] as String,
      itemCode: json['item_code'] as String,
      itemName: json['item_name'] as String,
      reservedQuantity: (json['reserved_quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      reservationDate: DateTime.parse(json['reservation_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      reservedBy: json['reserved_by'] as String,
      warehouseId: json['warehouse_id'] as String?,
      batchNumber: json['batch_number'] as String?,
      lotNumber: json['lot_number'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : DateTime.parse(json['release_date'] as String),
      releasedBy: json['released_by'] as String?,
      notes: json['notes'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bom_id': instance.bomId,
      'production_order_id': instance.productionOrderId,
      'item_id': instance.itemId,
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'reserved_quantity': instance.reservedQuantity,
      'unit': instance.unit,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'reservation_date': instance.reservationDate.toIso8601String(),
      'expiry_date': instance.expiryDate.toIso8601String(),
      'reserved_by': instance.reservedBy,
      'warehouse_id': instance.warehouseId,
      'batch_number': instance.batchNumber,
      'lot_number': instance.lotNumber,
      'release_date': instance.releaseDate?.toIso8601String(),
      'released_by': instance.releasedBy,
      'notes': instance.notes,
      'priority': instance.priority,
      'metadata': instance.metadata,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.active: 'active',
  ReservationStatus.expired: 'expired',
  ReservationStatus.released: 'released',
  ReservationStatus.consumed: 'consumed',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.partial: 'partial',
};

_ReservationRequest _$ReservationRequestFromJson(Map<String, dynamic> json) =>
    _ReservationRequest(
      bomId: json['bom_id'] as String,
      productionOrderId: json['production_order_id'] as String,
      batchSize: (json['batch_size'] as num).toDouble(),
      requiredDate: DateTime.parse(json['required_date'] as String),
      requestedBy: json['requested_by'] as String,
      warehouseId: json['warehouse_id'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      itemPreferences: (json['item_preferences'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ReservationRequestToJson(_ReservationRequest instance) =>
    <String, dynamic>{
      'bom_id': instance.bomId,
      'production_order_id': instance.productionOrderId,
      'batch_size': instance.batchSize,
      'required_date': instance.requiredDate.toIso8601String(),
      'requested_by': instance.requestedBy,
      'warehouse_id': instance.warehouseId,
      'priority': instance.priority,
      'notes': instance.notes,
      'item_preferences': instance.itemPreferences,
    };

_ReservationResult _$ReservationResultFromJson(Map<String, dynamic> json) =>
    _ReservationResult(
      requestId: json['request_id'] as String,
      isFullyReserved: json['is_fully_reserved'] as bool,
      reservations: (json['reservations'] as List<dynamic>)
          .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
          .toList(),
      failures: (json['failures'] as List<dynamic>)
          .map((e) => ReservationFailure.fromJson(e as Map<String, dynamic>))
          .toList(),
      processedAt: DateTime.parse(json['processed_at'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ReservationResultToJson(_ReservationResult instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'is_fully_reserved': instance.isFullyReserved,
      'reservations': instance.reservations.map((e) => e.toJson()).toList(),
      'failures': instance.failures.map((e) => e.toJson()).toList(),
      'processed_at': instance.processedAt.toIso8601String(),
      'notes': instance.notes,
    };

_ReservationFailure _$ReservationFailureFromJson(Map<String, dynamic> json) =>
    _ReservationFailure(
      itemId: json['item_id'] as String,
      itemCode: json['item_code'] as String,
      requestedQuantity: (json['requested_quantity'] as num).toDouble(),
      availableQuantity: (json['available_quantity'] as num).toDouble(),
      reason: json['reason'] as String,
      failureType: $enumDecode(_$FailureTypeEnumMap, json['failure_type']),
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ReservationFailureToJson(_ReservationFailure instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'item_code': instance.itemCode,
      'requested_quantity': instance.requestedQuantity,
      'available_quantity': instance.availableQuantity,
      'reason': instance.reason,
      'failure_type': _$FailureTypeEnumMap[instance.failureType]!,
      'suggested_actions': instance.suggestedActions,
    };

const _$FailureTypeEnumMap = {
  FailureType.insufficientStock: 'insufficientStock',
  FailureType.itemUnavailable: 'itemUnavailable',
  FailureType.qualityIssue: 'qualityIssue',
  FailureType.expired: 'expired',
  FailureType.systemError: 'systemError',
};

_ReservationConflict _$ReservationConflictFromJson(Map<String, dynamic> json) =>
    _ReservationConflict(
      itemId: json['item_id'] as String,
      itemCode: json['item_code'] as String,
      itemName: json['item_name'] as String,
      requiredQuantity: (json['required_quantity'] as num).toDouble(),
      availableQuantity: (json['available_quantity'] as num).toDouble(),
      conflictingReservations:
          (json['conflicting_reservations'] as List<dynamic>)
              .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
              .toList(),
      conflictType: $enumDecode(_$ConflictTypeEnumMap, json['conflict_type']),
    );

Map<String, dynamic> _$ReservationConflictToJson(
        _ReservationConflict instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'required_quantity': instance.requiredQuantity,
      'available_quantity': instance.availableQuantity,
      'conflicting_reservations':
          instance.conflictingReservations.map((e) => e.toJson()).toList(),
      'conflict_type': _$ConflictTypeEnumMap[instance.conflictType]!,
    };

const _$ConflictTypeEnumMap = {
  ConflictType.insufficientStock: 'insufficientStock',
  ConflictType.priorityConflict: 'priorityConflict',
  ConflictType.dateConflict: 'dateConflict',
  ConflictType.qualityIssue: 'qualityIssue',
};

_ReservationOptimization _$ReservationOptimizationFromJson(
        Map<String, dynamic> json) =>
    _ReservationOptimization(
      optimizedAllocations: (json['optimized_allocations'] as List<dynamic>)
          .map((e) => OptimizedAllocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      unallocatedRequests: (json['unallocated_requests'] as List<dynamic>)
          .map((e) => ReservationRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      optimizationScore: (json['optimization_score'] as num).toDouble(),
      processedAt: DateTime.parse(json['processed_at'] as String),
    );

Map<String, dynamic> _$ReservationOptimizationToJson(
        _ReservationOptimization instance) =>
    <String, dynamic>{
      'optimized_allocations':
          instance.optimizedAllocations.map((e) => e.toJson()).toList(),
      'unallocated_requests':
          instance.unallocatedRequests.map((e) => e.toJson()).toList(),
      'optimization_score': instance.optimizationScore,
      'processed_at': instance.processedAt.toIso8601String(),
    };

_OptimizedAllocation _$OptimizedAllocationFromJson(Map<String, dynamic> json) =>
    _OptimizedAllocation(
      request:
          ReservationRequest.fromJson(json['request'] as Map<String, dynamic>),
      result:
          ReservationResult.fromJson(json['result'] as Map<String, dynamic>),
      allocationScore: (json['allocation_score'] as num).toDouble(),
    );

Map<String, dynamic> _$OptimizedAllocationToJson(
        _OptimizedAllocation instance) =>
    <String, dynamic>{
      'request': instance.request.toJson(),
      'result': instance.result.toJson(),
      'allocation_score': instance.allocationScore,
    };
