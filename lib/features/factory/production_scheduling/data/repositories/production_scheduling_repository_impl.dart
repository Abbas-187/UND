import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/production_scheduling_repository.dart';
import '../models/production_line_allocation_model.dart';
import '../models/production_schedule_model.dart';
import '../models/production_slot_model.dart';

class ProductionSchedulingRepositoryImpl
    implements ProductionSchedulingRepository {
  ProductionSchedulingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collection references
  CollectionReference get _schedulesCollection =>
      _firestore.collection('production_schedules');
  CollectionReference get _productionLinesCollection =>
      _firestore.collection('production_lines');

  @override
  Future<List<ProductionScheduleModel>> getSchedules(
      {DateTime? startDate, DateTime? endDate}) async {
    Query query = _schedulesCollection.where('isActive', isEqualTo: true);

    if (startDate != null) {
      query = query.where('scheduleDate', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('scheduleDate', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProductionScheduleModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Future<ProductionScheduleModel> getScheduleById(String id) async {
    final doc = await _schedulesCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Production schedule not found');
    }
    final data = doc.data() as Map<String, dynamic>;
    return ProductionScheduleModel.fromJson({...data, 'id': doc.id});
  }

  @override
  Future<List<ProductionScheduleModel>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _schedulesCollection
        .where('scheduleDate', isGreaterThanOrEqualTo: startDate)
        .where('scheduleDate', isLessThanOrEqualTo: endDate)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProductionScheduleModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Future<List<ProductionScheduleModel>> getSchedulesByStatus(
    List<String> statuses,
  ) async {
    final snapshot = await _schedulesCollection
        .where('status', whereIn: statuses)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProductionScheduleModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Future<String> createSchedule(ProductionScheduleModel schedule) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Ensure we have an ID
    final scheduleId = schedule.id.isEmpty ? const Uuid().v4() : schedule.id;

    // Update created fields
    final updatedSchedule = schedule.copyWith(
      id: scheduleId,
      createdBy: user.uid,
      createdDate: DateTime.now(),
    );

    final scheduleData = updatedSchedule.toJson();

    // Remove id from data to avoid duplication
    scheduleData.remove('id');

    await _schedulesCollection.doc(scheduleId).set(scheduleData);
    return scheduleId;
  }

  @override
  Future<void> updateSchedule(ProductionScheduleModel schedule) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (schedule.id.isEmpty) {
      throw Exception('Schedule ID is required for updates');
    }

    // Update modified fields
    final updatedSchedule = schedule.copyWith(
      lastModifiedBy: user.uid,
      lastModifiedDate: DateTime.now(),
    );

    final scheduleData = updatedSchedule.toJson();

    // Remove id from data to avoid duplication
    scheduleData.remove('id');

    await _schedulesCollection.doc(schedule.id).update(scheduleData);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    // Soft delete by updating isActive field
    await _schedulesCollection.doc(id).update({'isActive': false});
  }

  @override
  Future<void> updateSlotStatus(
    String scheduleId,
    String slotId,
    SlotStatus newStatus,
  ) async {
    // Get the current schedule
    final schedule = await getScheduleById(scheduleId);

    // Find and update the target slot
    final updatedSlots = schedule.slots.map((slot) {
      if (slot.id == slotId) {
        return slot.copyWith(status: newStatus);
      }
      return slot;
    }).toList();

    // Update the schedule with the new slots
    final updatedSchedule = schedule.copyWith(slots: updatedSlots);
    await updateSchedule(updatedSchedule);
  }

  @override
  Future<void> addSlot(String scheduleId, ProductionSlotModel slot) async {
    // Get the current schedule
    final schedule = await getScheduleById(scheduleId);

    // Add the new slot
    final updatedSlots = [...schedule.slots, slot];

    // Update the schedule with the new slots
    final updatedSchedule = schedule.copyWith(slots: updatedSlots);
    await updateSchedule(updatedSchedule);
  }

  @override
  Future<void> updateSlot(String scheduleId, ProductionSlotModel slot) async {
    // Get the current schedule
    final schedule = await getScheduleById(scheduleId);

    // Find and update the target slot
    final updatedSlots = schedule.slots.map((s) {
      if (s.id == slot.id) {
        return slot;
      }
      return s;
    }).toList();

    // Update the schedule with the new slots
    final updatedSchedule = schedule.copyWith(slots: updatedSlots);
    await updateSchedule(updatedSchedule);
  }

  @override
  Future<void> deleteSlot(String scheduleId, String slotId) async {
    // Get the current schedule
    final schedule = await getScheduleById(scheduleId);

    // Remove the slot
    final updatedSlots = schedule.slots.where((s) => s.id != slotId).toList();

    // Update the schedule with the new slots
    final updatedSchedule = schedule.copyWith(slots: updatedSlots);
    await updateSchedule(updatedSchedule);
  }

  @override
  Future<List<ProductionLineAllocationModel>> getAvailableProductionLines(
    DateTime date,
  ) async {
    // Get all production lines
    final linesSnapshot = await _productionLinesCollection.get();

    // Transform to production line allocations
    List<ProductionLineAllocationModel> lines = linesSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Create a default time block for the entire day
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        8, // Start at 8 AM
        0,
      );

      final endTime = DateTime(
        date.year,
        date.month,
        date.day,
        17, // End at 5 PM
        0,
      );

      final timeBlock = TimeBlock(
        startTime: startTime,
        endTime: endTime,
        isAllocated: false,
      );

      return ProductionLineAllocationModel(
        id: const Uuid().v4(),
        lineId: doc.id,
        lineName: data['name'] ?? 'Unnamed Line',
        capacity: (data['capacity'] as num?)?.toDouble() ?? 100.0,
        availableTimeBlocks: [timeBlock],
        isAvailable: data['isAvailable'] ?? true,
        unavailabilityReason: data['unavailabilityReason'],
        metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      );
    }).toList();

    // Get all schedules for the same date to check for conflicts
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    final schedules = await getSchedulesByDateRange(dayStart, dayEnd);

    // Mark allocated time blocks
    for (final schedule in schedules) {
      for (final slot in schedule.slots) {
        final lineIndex =
            lines.indexWhere((line) => line.lineId == slot.lineId);
        if (lineIndex >= 0) {
          // Update time blocks for this line to reflect allocation
          final line = lines[lineIndex];
          List<TimeBlock> updatedBlocks = [];

          for (final block in line.availableTimeBlocks) {
            if (slot.startTime.isBefore(block.endTime) &&
                slot.endTime.isAfter(block.startTime)) {
              // There's an overlap, split the block if needed

              // Add block before the slot if it exists
              if (block.startTime.isBefore(slot.startTime)) {
                updatedBlocks.add(TimeBlock(
                  startTime: block.startTime,
                  endTime: slot.startTime,
                  isAllocated: false,
                ));
              }

              // Add the allocated block
              updatedBlocks.add(TimeBlock(
                startTime: slot.startTime.isAfter(block.startTime)
                    ? slot.startTime
                    : block.startTime,
                endTime: slot.endTime.isBefore(block.endTime)
                    ? slot.endTime
                    : block.endTime,
                isAllocated: true,
                allocationId: schedule.id,
                allocationName: schedule.name,
              ));

              // Add block after the slot if it exists
              if (block.endTime.isAfter(slot.endTime)) {
                updatedBlocks.add(TimeBlock(
                  startTime: slot.endTime,
                  endTime: block.endTime,
                  isAllocated: false,
                ));
              }
            } else {
              // No overlap, keep the original block
              updatedBlocks.add(block);
            }
          }

          // Replace the line with updated time blocks
          lines[lineIndex] = line.copyWith(
            availableTimeBlocks: updatedBlocks,
          );
        }
      }
    }

    return lines;
  }
}

extension on ProductionLineAllocationModel {
  ProductionLineAllocationModel copyWith({
    String? id,
    String? lineId,
    String? lineName,
    double? capacity,
    List<TimeBlock>? availableTimeBlocks,
    bool? isAvailable,
    String? unavailabilityReason,
    Map<String, dynamic>? metadata,
  }) {
    return ProductionLineAllocationModel(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      lineName: lineName ?? this.lineName,
      capacity: capacity ?? this.capacity,
      availableTimeBlocks: availableTimeBlocks ?? this.availableTimeBlocks,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailabilityReason: unavailabilityReason ?? this.unavailabilityReason,
      metadata: metadata ?? this.metadata,
    );
  }
}
