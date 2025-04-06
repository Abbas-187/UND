import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/inventory_item_model.dart';
import '../usecases/calculate_inventory_aging_usecase.dart';

part 'inventory_aging_provider.g.dart';

@riverpod
class InventoryAging extends _$InventoryAging {
  late final CalculateInventoryAgingUsecase _usecase;

  @override
  Future<Map<AgeBracket, List<InventoryItemModel>>> build(String warehouseId) {
    _usecase = CalculateInventoryAgingUsecase();
    return _usecase.execute(warehouseId);
  }

  /// Gets count of items expiring soon (critical and warning brackets)
  int getExpiringSoonCount() {
    if (!state.hasValue) return 0;

    final data = state.value!;
    return (data[AgeBracket.critical]?.length ?? 0) +
        (data[AgeBracket.warning]?.length ?? 0);
  }

  /// Gets count of already expired items
  int getExpiredCount() {
    if (!state.hasValue) return 0;

    final data = state.value!;
    return data[AgeBracket.expiredItems]?.length ?? 0;
  }

  /// Gets the total value of inventory by age bracket
  Map<AgeBracket, double> getTotalValueByBracket() {
    if (!state.hasValue) {
      return {};
    }

    final result = <AgeBracket, double>{};

    for (final entry in state.value!.entries) {
      final bracket = entry.key;
      final items = entry.value;

      double total = 0;
      for (final item in items) {
        total += (item.cost ?? 0) * item.quantity;
      }

      result[bracket] = total;
    }

    return result;
  }
}
