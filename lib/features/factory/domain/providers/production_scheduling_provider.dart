import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../production_scheduling/data/models/production_schedule_model.dart';
import '../../production_scheduling/data/models/production_slot_model.dart';
import '../../production_scheduling/data/models/production_line_allocation_model.dart';
import '../../production_scheduling/data/repositories/production_scheduling_repository_impl.dart';
import '../../production_scheduling/domain/repositories/production_scheduling_repository.dart';

// Repository provider
final productionSchedulingRepositoryProvider =
    Provider<ProductionSchedulingRepository>((ref) {
  return ProductionSchedulingRepositoryImpl();
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Weekly production schedules provider
final weekProductionSchedulesProvider =
    FutureProvider<List<ProductionScheduleModel>>((ref) async {
  final repository = ref.watch(productionSchedulingRepositoryProvider);

  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  return repository.getSchedulesByDateRange(
    DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
    DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
  );
});

// Production schedule by ID provider
final productionScheduleProvider =
    FutureProvider.family<ProductionScheduleModel, String>((ref, id) async {
  final repository = ref.watch(productionSchedulingRepositoryProvider);
  return repository.getScheduleById(id);
});

// Production schedules by status provider
final productionSchedulesByStatusProvider =
    FutureProvider.family<List<ProductionScheduleModel>, List<String>>(
        (ref, statuses) async {
  final repository = ref.watch(productionSchedulingRepositoryProvider);
  return repository.getSchedulesByStatus(statuses);
});

// Available production lines provider
final availableProductionLinesProvider =
    FutureProvider.family<List<ProductionLineAllocationModel>, DateTime>(
        (ref, date) async {
  final repository = ref.watch(productionSchedulingRepositoryProvider);
  return repository.getAvailableProductionLines(date);
});

// Production scheduling state notifier
class ProductionSchedulingNotifier
    extends StateNotifier<AsyncValue<List<ProductionScheduleModel>>> {
  ProductionSchedulingNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadSchedules();
  }

  final ProductionSchedulingRepository _repository;

  Future<void> loadSchedules() async {
    try {
      state = const AsyncValue.loading();
      final schedules = await _repository.getSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<String> createSchedule(ProductionScheduleModel schedule) async {
    try {
      final scheduleId = await _repository.createSchedule(schedule);
      loadSchedules(); // Refresh the schedules list
      return scheduleId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSchedule(ProductionScheduleModel schedule) async {
    try {
      await _repository.updateSchedule(schedule);

      // Update local state
      state.whenData((schedules) {
        final index = schedules.indexWhere((s) => s.id == schedule.id);
        if (index >= 0) {
          final updated = [...schedules];
          updated[index] = schedule;
          state = AsyncValue.data(updated);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateScheduleStatus(
      String scheduleId, ScheduleStatus newStatus) async {
    try {
      // Get the current schedule
      final schedule =
          state.asData?.value.firstWhere((s) => s.id == scheduleId);
      if (schedule == null) {
        throw Exception('Schedule not found');
      }

      // Update the schedule
      final updatedSchedule = schedule.copyWith(status: newStatus);
      await updateSchedule(updatedSchedule);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _repository.deleteSchedule(scheduleId);

      // Update local state
      state.whenData((schedules) {
        final updated = schedules.where((s) => s.id != scheduleId).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      rethrow;
    }
  }

  // Slot management
  Future<void> updateSlotStatus(
      String scheduleId, String slotId, SlotStatus newStatus) async {
    try {
      await _repository.updateSlotStatus(scheduleId, slotId, newStatus);

      // Update local state
      state.whenData((schedules) {
        final index = schedules.indexWhere((s) => s.id == scheduleId);
        if (index >= 0) {
          final schedule = schedules[index];
          final updatedSlots = schedule.slots.map((slot) {
            if (slot.id == slotId) {
              return slot.copyWith(status: newStatus);
            }
            return slot;
          }).toList();

          final updatedSchedule = schedule.copyWith(slots: updatedSlots);
          final updated = [...schedules];
          updated[index] = updatedSchedule;
          state = AsyncValue.data(updated);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProductionSlot(
      String scheduleId, ProductionSlotModel slot) async {
    try {
      // Ensure slot has an ID
      final slotWithId =
          slot.id.isEmpty ? slot.copyWith(id: const Uuid().v4()) : slot;

      await _repository.addSlot(scheduleId, slotWithId);

      // Update local state
      state.whenData((schedules) {
        final index = schedules.indexWhere((s) => s.id == scheduleId);
        if (index >= 0) {
          final schedule = schedules[index];
          final updatedSlots = [...schedule.slots, slotWithId];
          final updatedSchedule = schedule.copyWith(slots: updatedSlots);

          final updated = [...schedules];
          updated[index] = updatedSchedule;
          state = AsyncValue.data(updated);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductionSlot(
      String scheduleId, ProductionSlotModel slot) async {
    try {
      await _repository.updateSlot(scheduleId, slot);

      // Update local state
      state.whenData((schedules) {
        final index = schedules.indexWhere((s) => s.id == scheduleId);
        if (index >= 0) {
          final schedule = schedules[index];
          final updatedSlots = schedule.slots.map((s) {
            if (s.id == slot.id) {
              return slot;
            }
            return s;
          }).toList();

          final updatedSchedule = schedule.copyWith(slots: updatedSlots);
          final updated = [...schedules];
          updated[index] = updatedSchedule;
          state = AsyncValue.data(updated);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProductionSlot(String scheduleId, String slotId) async {
    try {
      await _repository.deleteSlot(scheduleId, slotId);

      // Update local state
      state.whenData((schedules) {
        final index = schedules.indexWhere((s) => s.id == scheduleId);
        if (index >= 0) {
          final schedule = schedules[index];
          final updatedSlots =
              schedule.slots.where((s) => s.id != slotId).toList();
          final updatedSchedule = schedule.copyWith(slots: updatedSlots);

          final updated = [...schedules];
          updated[index] = updatedSchedule;
          state = AsyncValue.data(updated);
        }
      });
    } catch (e) {
      rethrow;
    }
  }
}

// Production scheduling notifier provider
final productionSchedulingNotifierProvider = StateNotifierProvider<
    ProductionSchedulingNotifier,
    AsyncValue<List<ProductionScheduleModel>>>((ref) {
  final repository = ref.watch(productionSchedulingRepositoryProvider);
  return ProductionSchedulingNotifier(repository);
});

// Production slots for specific schedule
final productionSlotsProvider =
    Provider.family<List<ProductionSlotModel>, String>((ref, scheduleId) {
  final schedulesAsync = ref.watch(productionSchedulingNotifierProvider);

  return schedulesAsync.when(
    data: (schedules) {
      final schedule = schedules.firstWhere(
        (s) => s.id == scheduleId,
        orElse: () => ProductionScheduleModel.empty(),
      );
      return schedule.slots;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Filtered production schedules by date range
final filteredSchedulesProvider =
    Provider.family<List<ProductionScheduleModel>, CustomDateTimeRange>(
        (ref, dateRange) {
  final schedulesAsync = ref.watch(productionSchedulingNotifierProvider);

  return schedulesAsync.when(
    data: (schedules) {
      return schedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.scheduleDate.year,
          schedule.scheduleDate.month,
          schedule.scheduleDate.day,
        );

        final startDate = DateTime(
          dateRange.start.year,
          dateRange.start.month,
          dateRange.start.day,
        );

        final endDate = DateTime(
          dateRange.end.year,
          dateRange.end.month,
          dateRange.end.day,
        );

        return (scheduleDate.isAtSameMomentAs(startDate) ||
                scheduleDate.isAfter(startDate)) &&
            (scheduleDate.isAtSameMomentAs(endDate) ||
                scheduleDate.isBefore(endDate));
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Class to hold date range
class CustomDateTimeRange {
  const CustomDateTimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
