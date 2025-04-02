import '../../data/models/production_schedule_model.dart';
import '../../data/models/production_slot_model.dart';
import '../../data/models/production_line_allocation_model.dart';

abstract class ProductionSchedulingRepository {
  Future<List<ProductionScheduleModel>> getSchedules(
      {DateTime? startDate, DateTime? endDate});
  Future<ProductionScheduleModel> getScheduleById(String id);
  Future<List<ProductionScheduleModel>> getSchedulesByDateRange(
      DateTime startDate, DateTime endDate);
  Future<List<ProductionScheduleModel>> getSchedulesByStatus(
      List<String> statuses);

  Future<String> createSchedule(ProductionScheduleModel schedule);
  Future<void> updateSchedule(ProductionScheduleModel schedule);
  Future<void> deleteSchedule(String id);

  // Slot management
  Future<void> updateSlotStatus(
      String scheduleId, String slotId, SlotStatus newStatus);
  Future<void> addSlot(String scheduleId, ProductionSlotModel slot);
  Future<void> updateSlot(String scheduleId, ProductionSlotModel slot);
  Future<void> deleteSlot(String scheduleId, String slotId);

  // Production lines
  Future<List<ProductionLineAllocationModel>> getAvailableProductionLines(
      DateTime date);
}
