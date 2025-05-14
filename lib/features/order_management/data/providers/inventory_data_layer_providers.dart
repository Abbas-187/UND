import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../shared/constants/api_endpoints.dart';
import '../datasources/remote/inventory_remote_datasource.dart';
import '../repositories/inventory_repository_impl.dart';

/// Provides remote datasource for inventory
final inventoryRemoteDataSourceProvider =
    Provider<InventoryRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final baseUrl = ApiEndpoints.inventory;
  return InventoryRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
});

/// Provides concrete InventoryRepository implementation
final inventoryRepositoryProvider = Provider<InventoryRepositoryImpl>((ref) {
  final remote = ref.watch(inventoryRemoteDataSourceProvider);
  return InventoryRepositoryImpl(remoteDataSource: remote);
});
