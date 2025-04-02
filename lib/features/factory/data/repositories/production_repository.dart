import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/factory_datasource.dart';
import '../models/production_order_model.dart';

class ProductionRepository {
  ProductionRepository({FactoryDatasource? datasource})
      : _datasource = datasource ?? FactoryDatasource();
  final FactoryDatasource _datasource;

  Future<List<ProductionOrderModel>> getProductionOrders() async {
    return await _datasource.getProductionOrders();
  }

  Future<ProductionOrderModel> getProductionOrderById(String id) async {
    return await _datasource.getProductionOrderById(id);
  }

  Future<String> createProductionOrder(ProductionOrderModel order) async {
    return await _datasource.createProductionOrder(order);
  }

  Future<void> updateProductionOrder(ProductionOrderModel order) async {
    await _datasource.updateProductionOrder(order);
  }

  Future<void> deleteProductionOrder(String id) async {
    await _datasource.deleteProductionOrder(id);
  }

  Future<void> updateProductionOrderStatus(String id, String status) async {
    await _datasource.updateProductionOrderStatus(id, status);
  }
}

// Manual provider implementation instead of code generation
final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  return ProductionRepository();
});
