import '../datasources/logistics_datasource.dart';
import '../models/delivery_model.dart';

class DeliveryRepository {
  final LogisticsDataSource _dataSource;

  DeliveryRepository({LogisticsDataSource? dataSource})
      : _dataSource = dataSource ?? LogisticsDataSource();

  Future<List<DeliveryModel>> getAllDeliveries() async {
    try {
      return await _dataSource.getDeliveries();
    } catch (e) {
      throw Exception('Failed to get deliveries: $e');
    }
  }

  Future<DeliveryModel> getDeliveryById(String id) async {
    try {
      return await _dataSource.getDeliveryById(id);
    } catch (e) {
      throw Exception('Failed to get delivery: $e');
    }
  }

  Future<String> createDelivery(DeliveryModel delivery) async {
    try {
      return await _dataSource.createDelivery(delivery);
    } catch (e) {
      throw Exception('Failed to create delivery: $e');
    }
  }

  Future<void> updateDelivery(DeliveryModel delivery) async {
    try {
      await _dataSource.updateDelivery(delivery);
    } catch (e) {
      throw Exception('Failed to update delivery: $e');
    }
  }
}
