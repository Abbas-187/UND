import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/production_plan_model.dart';
import '../models/production_slot_model.dart';
import '../models/resource_allocation_model.dart';

/// Data source for production plans with Firestore implementation
class ProductionPlanDataSource {
  ProductionPlanDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String _plansCollection = 'productionPlans';
  final String _productsCollection = 'products';
  final String _resourcesCollection = 'productionResources';
  final String _forecastsCollection = 'forecasts';

  /// Get a list of all production plans
  Future<List<ProductionPlanModel>> getProductionPlans({
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String? planStatus,
  }) async {
    Query query = _firestore.collection(_plansCollection);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    if (planStatus != null) {
      query = query.where('status', isEqualTo: planStatus);
    }

    if (startDate != null) {
      query = query.where('startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('endDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final Map<String, dynamic> dataMap = data as Map<String, dynamic>;
      return ProductionPlanModel.fromJson({...dataMap, 'id': doc.id});
    }).toList();
  }

  /// Get a specific production plan by ID
  Future<ProductionPlanModel> getProductionPlanById(String id) async {
    final doc = await _firestore.collection(_plansCollection).doc(id).get();

    if (!doc.exists) {
      throw Exception('Production plan not found with ID: $id');
    }

    final data = doc.data();
    if (data == null) {
      throw Exception('Production plan data is null for ID: $id');
    }

    final Map<String, dynamic> dataMap = data;
    return ProductionPlanModel.fromJson({...dataMap, 'id': doc.id});
  }

  /// Create a new production plan
  Future<String> createProductionPlan(ProductionPlanModel plan) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final planId = plan.id ?? const Uuid().v4();
    final createdDate = DateTime.now();

    // Create empty production items list if not provided
    final List<ProductionItemModel> productionItems =
        plan.productionItems.isEmpty ? [] : plan.productionItems;

    // Update plan with metadata
    final updatedPlan = plan.copyWith(
      id: planId,
      createdBy: currentUser.uid,
      createdDate: createdDate,
      lastModifiedBy: currentUser.uid,
      lastModifiedDate: createdDate,
      isActive: true,
      productionItems: productionItems,
    );

    final planData = updatedPlan.toJson();

    // Remove id to avoid duplication in Firestore
    planData.remove('id');

    await _firestore.collection(_plansCollection).doc(planId).set(planData);
    return planId;
  }

  /// Update an existing production plan
  Future<void> updateProductionPlan(ProductionPlanModel plan) async {
    if (plan.id == null) {
      throw Exception('Production plan ID is required for updates');
    }

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Update plan with metadata
    final updatedPlan = plan.copyWith(
      lastModifiedBy: currentUser.uid,
      lastModifiedDate: DateTime.now(),
    );

    final planData = updatedPlan.toJson();

    // Remove id to avoid duplication in Firestore
    planData.remove('id');

    await _firestore
        .collection(_plansCollection)
        .doc(plan.id!)
        .update(planData);
  }

  /// Delete a production plan
  Future<void> deleteProductionPlan(String id) async {
    // Soft delete by updating isActive flag
    await _firestore.collection(_plansCollection).doc(id).update({
      'isActive': false,
      'lastModifiedBy': _auth.currentUser?.uid,
      'lastModifiedDate': FieldValue.serverTimestamp(),
    });
  }

  /// Approve a production plan
  Future<void> approveProductionPlan(String id, String approverId) async {
    final plan = await getProductionPlanById(id);

    if (plan.status == 'approved') {
      throw Exception('Plan is already approved');
    }

    // Update status and approval info
    await _firestore.collection(_plansCollection).doc(id).update({
      'status': 'approved',
      'approvedBy': approverId,
      'approvedDate': FieldValue.serverTimestamp(),
      'lastModifiedBy': _auth.currentUser?.uid,
      'lastModifiedDate': FieldValue.serverTimestamp(),
    });
  }

  /// Generate an optimized production plan based on forecasts and constraints
  Future<ProductionPlanModel> generateOptimizedProductionPlan({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> productIds,
    Map<String, dynamic>? constraints,
    Map<String, dynamic>? resourceAllocation,
  }) async {
    // Validate inputs
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Start date must be before end date');
    }

    if (productIds.isEmpty) {
      throw ArgumentError('At least one product must be specified');
    }

    // Get current user
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Fetch product information for all productIds
      List<Map<String, dynamic>> productData =
          await _fetchProductsData(productIds);

      // Fetch resource capacities
      List<ResourceAllocationModel> resources =
          await _fetchResourceCapacities();

      // Fetch forecasts for these products (if available)
      Map<String, List<Map<String, dynamic>>> forecasts =
          await _fetchForecasts(productIds, startDate, endDate);

      // Generate production slots with optimization algorithm
      List<ProductionSlotModel> slots = await _generateOptimizedSlots(
        productData: productData,
        resources: resources,
        forecasts: forecasts,
        startDate: startDate,
        endDate: endDate,
        constraints: constraints,
      );

      // Create default empty production items
      final List<ProductionItemModel> productionItems =
          productData.map((product) {
        return ProductionItemModel(
          productId: product['id'],
          productName: product['name'] ?? 'Unknown Product',
          quantity: 0.0,
          unitOfMeasure: product['unitOfMeasure'] ?? 'units',
          scheduledDate: startDate,
        );
      }).toList();

      // Create the production plan
      final plan = ProductionPlanModel(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        productIds: productIds,
        status: 'draft',
        slots: slots,
        resourceAllocation: resources,
        constraints: constraints ?? {},
        isActive: true,
        createdBy: currentUser.uid,
        createdByUserId: currentUser.uid,
        createdDate: DateTime.now(),
        lastModifiedBy: currentUser.uid,
        lastModifiedDate: DateTime.now(),
        productionItems: productionItems,
      );

      // Save and return the plan
      final planId = await createProductionPlan(plan);
      return plan.copyWith(id: planId);
    } catch (e) {
      throw Exception('Failed to generate optimized production plan: $e');
    }
  }

  // Helper function to fetch products data
  Future<List<Map<String, dynamic>>> _fetchProductsData(
      List<String> productIds) async {
    List<Map<String, dynamic>> results = [];

    for (final id in productIds) {
      final doc =
          await _firestore.collection(_productsCollection).doc(id).get();

      if (doc.exists) {
        final data = doc.data()!;
        results.add({...data, 'id': doc.id});
      }
    }

    return results;
  }

  // Helper function to fetch resource capacities
  Future<List<ResourceAllocationModel>> _fetchResourceCapacities() async {
    final snapshot = await _firestore.collection(_resourcesCollection).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ResourceAllocationModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  // Helper function to fetch forecasts
  Future<Map<String, List<Map<String, dynamic>>>> _fetchForecasts(
      List<String> productIds, DateTime startDate, DateTime endDate) async {
    Map<String, List<Map<String, dynamic>>> results = {};

    // Get the most recent forecast for each product
    for (final productId in productIds) {
      final snapshot = await _firestore
          .collection(_forecastsCollection)
          .where('productIds', arrayContains: productId)
          .where('endDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('endDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final forecastDoc = snapshot.docs.first;
        final forecastData = forecastDoc.data();

        // Get forecast items for this product
        if (forecastData.containsKey('forecastItems')) {
          final items = (forecastData['forecastItems'] as List)
              .where((item) =>
                  item['productId'] == productId && item['date'] != null)
              .map((item) => item)
              .toList();

          results[productId] = List<Map<String, dynamic>>.from(items);
        }
      }
    }

    return results;
  }

  // Algorithm to generate optimized production slots based on forecasts and constraints
  Future<List<ProductionSlotModel>> _generateOptimizedSlots({
    required List<Map<String, dynamic>> productData,
    required List<ResourceAllocationModel> resources,
    required Map<String, List<Map<String, dynamic>>> forecasts,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? constraints,
  }) async {
    // This is a simplified implementation of the optimization algorithm
    final slots = <ProductionSlotModel>[];
    final uuid = const Uuid();

    // Days in plan period
    final dayCount = endDate.difference(startDate).inDays + 1;

    for (final product in productData) {
      final productId = product['id'];
      final productForecast = forecasts[productId] ?? [];

      // Default production quantity if no forecast
      double totalForecastedQuantity = 0;

      if (productForecast.isNotEmpty) {
        // Sum forecasted quantities for this product
        for (final item in productForecast) {
          final forecastDate = (item['date'] as Timestamp).toDate();

          if (forecastDate
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              forecastDate.isBefore(endDate.add(const Duration(days: 1)))) {
            final forecastValue = item['forecastedValue'];
            totalForecastedQuantity +=
                (forecastValue is num) ? forecastValue.toDouble() : 0.0;
          }
        }
      } else {
        // If no forecast, use a basic estimate
        totalForecastedQuantity = 100; // Default quantity as placeholder
      }

      // Apply safety factor (20% extra)
      final plannedQuantity = totalForecastedQuantity * 1.2;

      // Determine how many slots we need
      final slotCount =
          plannedQuantity > 0 ? (plannedQuantity / 100).ceil() : 1;

      // Distribute production across days
      for (int i = 0; i < slotCount; i++) {
        // Calculate slot quantity
        final slotQuantity = i < slotCount - 1
            ? 100.0
            : // Use standard batch size for all except possibly the last
            plannedQuantity - (100.0 * (slotCount - 1)); // Remainder

        // Determine slot day (simple distribution)
        final slotDay = i % dayCount;
        final slotDate = startDate.add(Duration(days: slotDay));

        // Assign resource (round-robin)
        final resourceIndex = i % resources.length;
        final resource = resources[resourceIndex];

        // Create production slot
        slots.add(ProductionSlotModel(
          id: uuid.v4(),
          productId: productId,
          productName: product['name'] ?? 'Unknown Product',
          plannedQuantity: slotQuantity,
          startDate: slotDate,
          endDate:
              slotDate.add(const Duration(hours: 8)), // Default 8-hour slot
          resourceId: resource.id,
          resourceName: resource.name,
          status: 'planned',
          priority: 1, // Default priority
        ));
      }
    }

    // Sort slots by date
    slots.sort((a, b) => a.startDate.compareTo(b.startDate));

    return slots;
  }
}
