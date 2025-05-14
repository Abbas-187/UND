import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/remote/inventory_remote_datasource.dart';

/// Concrete implementation delegating inventory operations to remote datasource
class InventoryRepositoryImpl implements InventoryRepository {

  InventoryRepositoryImpl({required this.remoteDataSource});
  final InventoryRemoteDataSource remoteDataSource;

  @override
  Future<InventoryItem> getInventory(String productId) {
    return remoteDataSource.fetchInventory(productId);
  }

  @override
  Future<void> reserveInventory(String productId, double quantity) {
    return remoteDataSource.reserve(productId, quantity);
  }

  @override
  Future<void> releaseInventory(String productId, double quantity) {
    return remoteDataSource.release(productId, quantity);
  }
}
