import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_optimization_model.dart';
import '../models/optimization_result_model.dart' as opt_model;

/// Repository for managing inventory optimization data in Firestore
class InventoryOptimizationRepository {
  InventoryOptimizationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String _collection = 'inventory_optimizations';

  /// Creates a new inventory optimization record in Firestore
  Future<String> createInventoryOptimization(
      InventoryOptimizationModel optimization) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(optimization.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create inventory optimization: $e');
    }
  }

  /// Retrieves a specific inventory optimization by its ID
  Future<InventoryOptimizationModel> getInventoryOptimizationById(
      String optimizationId) async {
    try {
      final docSnap =
          await _firestore.collection(_collection).doc(optimizationId).get();

      if (!docSnap.exists) {
        throw Exception('Optimization with ID $optimizationId does not exist');
      }

      return InventoryOptimizationModel.fromJson(
          docSnap.data()!);
    } catch (e) {
      throw Exception('Failed to fetch inventory optimization: $e');
    }
  }

  /// Retrieves all inventory optimizations, with optional filters
  Future<List<InventoryOptimizationModel>> getInventoryOptimizations({
    String? productId,
    String? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);

      // Apply filters if provided
      if (productId != null) {
        query = query.where('productIds', arrayContains: productId);
      }

      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }

      if (startDate != null) {
        query = query.where('createdDate', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdDate', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => InventoryOptimizationModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory optimizations: $e');
    }
  }

  /// Updates an existing inventory optimization record
  Future<void> updateInventoryOptimization(
      String optimizationId, InventoryOptimizationModel optimization) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(optimizationId)
          .update(optimization.toJson());
    } catch (e) {
      throw Exception('Failed to update inventory optimization: $e');
    }
  }

  /// Deletes an inventory optimization record
  Future<void> deleteInventoryOptimization(String optimizationId) async {
    try {
      await _firestore.collection(_collection).doc(optimizationId).delete();
    } catch (e) {
      throw Exception('Failed to delete inventory optimization: $e');
    }
  }

  /// Gets the latest optimization result for a specific product
  Future<opt_model.OptimizationResultModel?> getLatestOptimizationForProduct(
      String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('productIds', arrayContains: productId)
          .orderBy('createdDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final latestOptimization =
          InventoryOptimizationModel.fromJson(querySnapshot.docs.first.data());

      // Get the result for this product from the results map
      final result = latestOptimization.results[productId];

      if (result == null) {
        return null;
      }

      // Convert the inventory optimization model's result to optimization_result_model
      return opt_model.OptimizationResultModel(
        optimalLevel: result.safetyStockLevel,
        minLevel: result.reorderPoint - result.safetyStockLevel,
        maxLevel: result.reorderPoint + result.economicOrderQuantity,
        reorderPoint: result.reorderPoint,
        orderQuantity: result.economicOrderQuantity,
        safetyStock: result.safetyStockLevel,
        serviceLevel: result.serviceLevel,
        turnoverRate: 0.0, // Default value, not present in original model
        holdingCost: result.holdingCost,
        stockoutCost: 0.0, // Default value, not present in original model
        totalCost: result.holdingCost + result.orderingCost,
      );
    } catch (e) {
      throw Exception('Failed to fetch latest optimization for product: $e');
    }
  }

  /// Gets historical optimization results for a specific product
  Future<List<Map<String, dynamic>>> getHistoricalOptimizationsForProduct(
      String productId,
      {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('productIds', arrayContains: productId)
          .orderBy('createdDate', descending: true)
          .limit(limit)
          .get();

      final results = <Map<String, dynamic>>[];

      for (final doc in querySnapshot.docs) {
        final optimization = InventoryOptimizationModel.fromJson(doc.data());
        final result = optimization.results[productId];

        if (result != null) {
          results.add({
            'optimizationId': doc.id,
            'createdDate': optimization.createdDate,
            'result': result.toJson(),
          });
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to fetch historical optimizations: $e');
    }
  }

  /// Gets optimization statistics across products or warehouses
  Future<Map<String, dynamic>> getOptimizationStatistics({
    String? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);

      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }

      if (startDate != null) {
        query = query.where('createdDate', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdDate', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.get();

      // Process results to calculate statistics
      double totalSafetyStock = 0;
      double totalEOQ = 0;
      int productCount = 0;
      Map<String, int> productFrequency = {};

      for (final doc in querySnapshot.docs) {
        final optimization = InventoryOptimizationModel.fromJson(doc.data());

        for (final productId in optimization.productIds) {
          final result = optimization.results[productId];

          if (result != null) {
            totalSafetyStock += result.safetyStockLevel;
            totalEOQ += result.economicOrderQuantity;
            productCount++;

            productFrequency[productId] =
                (productFrequency[productId] ?? 0) + 1;
          }
        }
      }

      // Find most frequently optimized products
      final sortedProducts = productFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topProducts = sortedProducts
          .take(5)
          .map((e) => {
                'productId': e.key,
                'count': e.value,
              })
          .toList();

      return {
        'totalOptimizations': querySnapshot.docs.length,
        'totalProductsOptimized': productCount,
        'averageSafetyStock':
            productCount > 0 ? totalSafetyStock / productCount : 0,
        'averageEOQ': productCount > 0 ? totalEOQ / productCount : 0,
        'topOptimizedProducts': topProducts,
      };
    } catch (e) {
      throw Exception('Failed to fetch optimization statistics: $e');
    }
  }
}
