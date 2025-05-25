import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/approve_cycle_count_adjustment_usecase.dart';
import '../../domain/usecases/process_cycle_count_results_usecase.dart';
import 'cycle_count_sheet_repository_provider.dart';

final processCycleCountResultsUseCaseProvider =
    Provider<ProcessCycleCountResultsUseCase>((ref) {
  final sheetRepo = ref.watch(cycleCountSheetRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return ProcessCycleCountResultsUseCase(
    sheetRepository: sheetRepo,
    inventoryRepository: inventoryRepo,
  );
});

final approveCycleCountAdjustmentUseCaseProvider =
    Provider<ApproveCycleCountAdjustmentUseCase>((ref) {
  final sheetRepo = ref.watch(cycleCountSheetRepositoryProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  return ApproveCycleCountAdjustmentUseCase(
    sheetRepository: sheetRepo,
    inventoryRepository: inventoryRepo,
  );
});
