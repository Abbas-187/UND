import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/procurement_plan_model.dart';

/// Data source for procurement planning data operations
class ProcurementDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a list of all procurement plans
  Future<List<ProcurementPlanModel>> getProcurementPlans() async {
    try {
      final snapshot = await _firestore.collection('procurementPlans').get();
      return snapshot.docs
          .map((doc) => ProcurementPlanModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id))
          .toList();
    } catch (e) {
      throw Exception(
          'Failed to get procurement plans from Firestore: ${e.toString()}');
    }
  }

  /// Get a specific procurement plan by ID
  Future<ProcurementPlanModel> getProcurementPlanById(String id) async {
    try {
      final doc = await _firestore.collection('procurementPlans').doc(id).get();
      if (!doc.exists) {
        throw Exception('Procurement plan not found with id: $id');
      }
      return ProcurementPlanModel.fromJson(doc.data() as Map<String, dynamic>,
          id: doc.id);
    } catch (e) {
      throw Exception(
          'Failed to get procurement plan from Firestore: ${e.toString()}');
    }
  }

  /// Create a new procurement plan
  Future<String> createProcurementPlan(ProcurementPlanModel plan) async {
    try {
      final docRef =
          await _firestore.collection('procurementPlans').add(plan.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception(
          'Failed to create procurement plan in Firestore: ${e.toString()}');
    }
  }

  /// Update an existing procurement plan
  Future<void> updateProcurementPlan(ProcurementPlanModel plan) async {
    try {
      await _firestore
          .collection('procurementPlans')
          .doc(plan.id)
          .update(plan.toJson());
    } catch (e) {
      throw Exception(
          'Failed to update procurement plan in Firestore: ${e.toString()}');
    }
  }

  /// Delete a procurement plan
  Future<void> deleteProcurementPlan(String id) async {
    try {
      await _firestore.collection('procurementPlans').doc(id).delete();
    } catch (e) {
      throw Exception(
          'Failed to delete procurement plan from Firestore: ${e.toString()}');
    }
  }

  /// Approve a procurement plan
  Future<void> approveProcurementPlan(String id, String approverId) async {
    try {
      await _firestore.collection('procurementPlans').doc(id).update({
        'status': 'approved',
        'approvedDate': FieldValue.serverTimestamp(),
        'approvedByUserId': approverId,
      });
    } catch (e) {
      throw Exception(
          'Failed to approve procurement plan in Firestore: ${e.toString()}');
    }
  }

  /// Generate a procurement plan based on production plans and inventory levels
  Future<ProcurementPlanModel> generateProcurementPlan({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> productionPlanIds,
    double? budgetLimit,
  }) async {
    // Dummy implementation - replace with actual logic
    await Future.delayed(Duration(seconds: 1));
    return ProcurementPlanModel(
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      createdByUserId: 'system', // Or fetch current user ID if available
      createdDate: DateTime.now(),
      procurementItems: [], // Replace with actual generated items
    );
  }
}
