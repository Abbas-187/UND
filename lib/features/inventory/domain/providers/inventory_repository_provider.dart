import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/logging_service.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../repositories/inventory_repository.dart';

/// Provider for the inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final loggingService = ref.watch(loggingServiceProvider);
  return InventoryRepositoryImpl(loggingService: loggingService);
});
