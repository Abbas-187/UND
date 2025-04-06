import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/milk_reception_model.dart';
import '../repositories/milk_reception_repository.dart';

/// Provider that fetches milk receptions for today
final todayMilkReceptionsProvider =
    FutureProvider<List<MilkReceptionModel>>((ref) async {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  return repository.getTodayReceptions();
});

/// Provider that fetches receptions awaiting testing
final receptionsAwaitingTestingProvider =
    FutureProvider<List<MilkReceptionModel>>((ref) async {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  return repository.getReceptionsByStatus(ReceptionStatus.pendingTesting);
});

/// Provider for a single milk reception by ID
final milkReceptionProvider =
    FutureProvider.family<MilkReceptionModel, String>((ref, id) async {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  return repository.getReception(id);
});

/// Provider for creating a new milk reception
final createMilkReceptionProvider =
    FutureProvider.family<String, MilkReceptionModel>((ref, reception) async {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  return repository.createReception(reception);
});

/// Provider for updating an existing milk reception
final updateMilkReceptionProvider =
    FutureProvider.family<void, MilkReceptionModel>((ref, reception) async {
  final repository = ref.watch(milkReceptionRepositoryProvider);
  return repository.updateReception(reception);
});
