import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/cycle_count_schedule_repository_impl.dart';
import '../../domain/repositories/cycle_count_schedule_repository.dart';

final cycleCountScheduleRepositoryProvider =
    Provider<CycleCountScheduleRepository>((ref) {
  return CycleCountScheduleRepositoryImpl();
});
