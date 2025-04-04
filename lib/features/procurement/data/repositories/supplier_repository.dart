// lib/features/procurement/data/repositories/supplier_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:und_app/core/services/firestore_service.dart'; // Assuming firestore_service.dart exists

class SupplierRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Supplier
  Future<void> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      await _firestore.collection('suppliers').add(supplierData);
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  // Get Supplier by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getSupplier(
      String supplierId) async {
    try {
      return await _firestore.collection('suppliers').doc(supplierId).get();
    } catch (e) {
      throw Exception('Failed to get supplier: $e');
    }
  }

  // Update Supplier
  Future<void> updateSupplier(
      String supplierId, Map<String, dynamic> supplierData) async {
    try {
      await _firestore
          .collection('suppliers')
          .doc(supplierId)
          .update(supplierData);
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  // Delete Supplier
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _firestore.collection('suppliers').doc(supplierId).delete();
    } catch (e) {
      throw Exception('Failed to delete supplier: $e');
    }
  }

  // Get All Suppliers Stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllSuppliers() {
    return _firestore.collection('suppliers').snapshots();
  }

  // Filter Suppliers by Name
  Stream<QuerySnapshot<Map<String, dynamic>>> filterSuppliersByName(
      String name) {
    try {
      return _firestore
          .collection('suppliers')
          .where('name',
              isEqualTo: name) // Assuming 'name' is a field in supplier data
          .snapshots();
    } catch (e) {
      throw Exception('Failed to filter suppliers by name: $e');
    }
  }

  // Search Suppliers by Keywords (basic - can be improved with more advanced search)
  Stream<QuerySnapshot<Map<String, dynamic>>> searchSuppliers(String keywords) {
    try {
      return _firestore
          .collection('suppliers')
          .where('keywords',
              arrayContains: keywords) // Assuming 'keywords' is an array field
          .snapshots();
    } catch (e) {
      throw Exception('Failed to search suppliers: $e');
    }
  }

  // Supplier Evaluation Calculation (Placeholder - needs specific logic)
  Future<double> calculateSupplierRating(String supplierId) async {
    // TODO: Implement supplier evaluation logic based on required criteria
    // This is just a placeholder, you need to define how supplier rating is calculated
    await Future.delayed(
        Duration(milliseconds: 500)); // Simulate some async work
    return 4.5; // Placeholder rating
  }
}
