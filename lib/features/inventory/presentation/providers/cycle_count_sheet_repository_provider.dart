import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/cycle_count_sheet_repository_impl.dart';
import '../../domain/repositories/cycle_count_sheet_repository.dart';

final cycleCountSheetRepositoryProvider =
    Provider<CycleCountSheetRepository>((ref) {
  return CycleCountSheetRepositoryImpl();
});
