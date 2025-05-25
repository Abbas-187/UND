import '../entities/cycle_count_schedule.dart';

abstract class CycleCountScheduleRepository {
  Future<List<CycleCountSchedule>> getSchedules();
  Future<CycleCountSchedule?> getSchedule(String scheduleId);
  Future<CycleCountSchedule> createSchedule(CycleCountSchedule schedule);
  Future<void> updateSchedule(CycleCountSchedule schedule);
  Future<void> deleteSchedule(String scheduleId);
}
