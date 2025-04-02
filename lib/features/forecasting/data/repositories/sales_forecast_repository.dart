import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sales_forecast_model.dart';

/// Repository for managing sales forecasts in Firestore
class SalesForecastRepository {
  SalesForecastRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String _collection = 'sales_forecasts';

  /// Create a new sales forecast in Firestore
  Future<String> createSalesForecast(SalesForecastModel forecast) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(forecast.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create sales forecast: $e');
    }
  }

  /// Retrieve a specific sales forecast by ID
  Future<SalesForecastModel> getSalesForecastById(String forecastId) async {
    try {
      final docSnap =
          await _firestore.collection(_collection).doc(forecastId).get();

      if (!docSnap.exists) {
        throw Exception('Forecast with ID $forecastId does not exist');
      }

      return SalesForecastModel.fromJson(docSnap.data()!);
    } catch (e) {
      throw Exception('Failed to fetch sales forecast: $e');
    }
  }

  /// Retrieve sales forecasts with optional filters
  Future<List<SalesForecastModel>> getSalesForecasts({
    String? productId,
    String? methodName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);

      // Apply filters
      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }

      if (methodName != null) {
        query = query.where('methodName', isEqualTo: methodName);
      }

      if (startDate != null) {
        query = query.where('createdDate', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdDate', isLessThanOrEqualTo: endDate);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdDate', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Add the ID to the data
        data['id'] = doc.id;
        return SalesForecastModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch sales forecasts: $e');
    }
  }

  /// Update an existing sales forecast
  Future<void> updateSalesForecast(
      String forecastId, SalesForecastModel forecast) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(forecastId)
          .update(forecast.toJson());
    } catch (e) {
      throw Exception('Failed to update sales forecast: $e');
    }
  }

  /// Delete a sales forecast
  Future<void> deleteSalesForecast(String forecastId) async {
    try {
      await _firestore.collection(_collection).doc(forecastId).delete();
    } catch (e) {
      throw Exception('Failed to delete sales forecast: $e');
    }
  }

  /// Get the latest forecast for a product
  Future<SalesForecastModel?> getLatestForecastForProduct(
      String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .orderBy('createdDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      return SalesForecastModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch latest forecast for product: $e');
    }
  }

  /// Compare forecasts from different methods for the same product
  Future<Map<String, dynamic>> compareForecasts(String productId) async {
    try {
      final forecasts = await getSalesForecasts(productId: productId);

      if (forecasts.isEmpty) {
        return {
          'productId': productId,
          'methodComparisons': [],
          'bestMethod': null,
        };
      }

      // Group forecasts by method
      final methodForecasts = <String, List<SalesForecastModel>>{};
      for (final forecast in forecasts) {
        if (!methodForecasts.containsKey(forecast.methodName)) {
          methodForecasts[forecast.methodName] = [];
        }
        methodForecasts[forecast.methodName]!.add(forecast);
      }

      // Get the latest forecast for each method
      final latestForecasts = <String, SalesForecastModel>{};
      methodForecasts.forEach((method, methodList) {
        methodList.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        latestForecasts[method] = methodList.first;
      });

      // Create comparison data
      final methodComparisons = latestForecasts.entries.map((entry) {
        return {
          'method': entry.key,
          'forecastId': entry.value.id,
          'createdDate': entry.value.createdDate,
          'accuracy': entry.value.accuracy,
        };
      }).toList();

      // Find the method with the best accuracy (lowest MAPE)
      String? bestMethod;
      double lowestMape = double.infinity;

      for (final entry in latestForecasts.entries) {
        final mape = entry.value.accuracy['mape'] ?? double.infinity;
        if (mape < lowestMape) {
          lowestMape = mape;
          bestMethod = entry.key;
        }
      }

      return {
        'productId': productId,
        'methodComparisons': methodComparisons,
        'bestMethod': bestMethod,
      };
    } catch (e) {
      throw Exception('Failed to compare forecasts: $e');
    }
  }
}
