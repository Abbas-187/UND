import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../inventory/domain/providers/inventory_repository_provider.dart';
import '../../../../inventory/domain/usecases/update_inventory_quality_status_usecase.dart';
import 'factory_quality_control_inventory_integration.dart';

final factoryQualityControlInventoryIntegrationProvider =
    Provider<FactoryQualityControlInventoryIntegration>((ref) {
  final inventoryRepository = ref.watch(inventoryRepositoryProvider);
  final updateInventoryQualityStatusUseCase =
      UpdateInventoryQualityStatusUseCase(inventoryRepository);
  return FactoryQualityControlInventoryIntegration(
      updateInventoryQualityStatusUseCase);
});
