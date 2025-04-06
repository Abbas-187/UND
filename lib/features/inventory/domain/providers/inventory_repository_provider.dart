import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/inventory_repository_impl.dart';
import '../repositories/inventory_repository.dart';

/// Provider for inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl();
});
