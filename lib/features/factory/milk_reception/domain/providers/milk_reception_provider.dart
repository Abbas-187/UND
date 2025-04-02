import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/milk_quality_standards_model.dart';
import '../../data/models/milk_reception_model.dart';
import '../../data/models/milk_test_result_model.dart';
import '../../data/repositories/milk_reception_repository.dart';

// Provider for today's milk receptions
final todayMilkReceptionsProvider =
    FutureProvider<List<MilkReceptionModel>>((ref) {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay
      .add(const Duration(days: 1))
      .subtract(const Duration(seconds: 1));

  return repository.getMilkReceptionsByDateRange(
    startDate: startOfDay,
    endDate: endOfDay,
  );
});

// Provider for milk receptions awaiting testing
final receptionsAwaitingTestingProvider =
    FutureProvider<List<MilkReceptionModel>>((ref) async {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  final receptions = await repository.getMilkReceptions();

  return receptions
      .where((reception) =>
          reception.status == ReceptionStatus.received ||
          reception.status == ReceptionStatus.testing)
      .toList();
});

// Provider for specific milk reception
final milkReceptionProvider =
    FutureProvider.family<MilkReceptionModel, String>((ref, receptionId) {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  return repository.getMilkReceptionById(receptionId);
});

// Provider for active milk quality standards
final activeMilkQualityStandardsProvider =
    FutureProvider<List<MilkQualityStandardsModel>>((ref) {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  return repository.getActiveMilkQualityStandards();
});

// Provider for managing milk receptions
final milkReceptionStateProvider = StateNotifierProvider.family<
    MilkReceptionStateNotifier,
    AsyncValue<MilkReceptionModel?>,
    String?>((ref, receptionId) {
  return MilkReceptionStateNotifier(ref, receptionId);
});

class MilkReceptionStateNotifier
    extends StateNotifier<AsyncValue<MilkReceptionModel?>> {
  final Ref _ref;
  final String? _receptionId;
  late final MilkReceptionRepository _repository;

  MilkReceptionStateNotifier(this._ref, this._receptionId)
      : super(const AsyncLoading()) {
    _repository = _ref.watch(milkReceptionRepositoryProvider);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_receptionId == null) {
      state = const AsyncData(null);
      return;
    }

    try {
      final reception = await _repository.getMilkReceptionById(_receptionId!);
      state = AsyncData(reception);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Create a new milk reception
  Future<String> createReception(MilkReceptionModel reception) async {
    state = const AsyncLoading();

    try {
      final id = await _repository.createMilkReception(reception);

      // Invalidate providers
      _ref.invalidate(todayMilkReceptionsProvider);
      _ref.invalidate(receptionsAwaitingTestingProvider);

      // Set state to the newly created reception
      final newReception = await _repository.getMilkReceptionById(id);
      state = AsyncData(newReception);

      return id;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  // Update an existing reception
  Future<void> updateReception(MilkReceptionModel reception) async {
    state = const AsyncLoading();

    try {
      await _repository.updateMilkReception(reception);

      // Invalidate providers
      _ref.invalidate(todayMilkReceptionsProvider);
      _ref.invalidate(receptionsAwaitingTestingProvider);
      _ref.invalidate(milkReceptionProvider(reception.id));

      // Update state
      final updatedReception =
          await _repository.getMilkReceptionById(reception.id);
      state = AsyncData(updatedReception);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  // Add a test result
  Future<void> addTestResult(MilkTestResultModel testResult) async {
    if (_receptionId == null) {
      throw Exception('Reception ID is required');
    }

    state = const AsyncLoading();

    try {
      await _repository.addTestResult(
        receptionId: _receptionId!,
        testResult: testResult,
      );

      // Invalidate providers
      _ref.invalidate(todayMilkReceptionsProvider);
      _ref.invalidate(receptionsAwaitingTestingProvider);
      _ref.invalidate(milkReceptionProvider(_receptionId!));

      // Update state
      final updatedReception =
          await _repository.getMilkReceptionById(_receptionId!);
      state = AsyncData(updatedReception);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  // Calculate pricing tier
  Future<String> calculatePricingTier() async {
    if (_receptionId == null) {
      throw Exception('Reception ID is required');
    }

    try {
      return await _repository.calculatePricingTier(_receptionId!);
    } catch (e) {
      rethrow;
    }
  }
}
