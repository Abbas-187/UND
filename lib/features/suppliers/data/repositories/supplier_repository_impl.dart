import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_interface.dart';
import '../../../../core/firebase/firebase_mock.dart';
import '../../../../core/firebase/firebase_module.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(this._firestoreInstance);
  final dynamic _firestoreInstance;
  final String _collection = 'suppliers';

  CollectionReference<Map<String, dynamic>> get _suppliersCollection {
    if (useMockFirebase) {
      return (_firestoreInstance as FirestoreInterface).collection(_collection)
          as CollectionReference<Map<String, dynamic>>;
    } else {
      return (_firestoreInstance as FirebaseFirestore).collection(_collection);
    }
  }

  @override
  Future<Supplier> getSupplier(String id) async {
    final doc = await _suppliersCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Supplier not found');
    }
    return SupplierModel.fromFirestore(doc).toDomain();
  }

  @override
  Future<List<Supplier>> getAllSuppliers() async {
    final snapshot = await _suppliersCollection.get();
    return snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<Supplier> addSupplier(Supplier supplier) async {
    final model = SupplierModel.fromDomain(supplier);
    final docRef = _suppliersCollection.doc();
    final modelWithId = model.copyWith(
      id: docRef.id,
      lastUpdated: DateTime.now(),
    );
    await docRef.set(modelWithId.toJson());
    return modelWithId.toDomain();
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    final model = SupplierModel.fromDomain(supplier);
    final updatedModel = model.copyWith(lastUpdated: DateTime.now());
    await _suppliersCollection.doc(supplier.id).update(updatedModel.toJson());
    return updatedModel.toDomain();
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _suppliersCollection.doc(id).delete();
  }

  @override
  Future<List<Supplier>> getSuppliersByCategory(String category) async {
    final snapshot = await _suppliersCollection
        .where('productCategories', arrayContains: category)
        .get();
    return snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<Supplier>> searchSuppliers(String query) async {
    final normalizedQuery = query.toLowerCase();
    final snapshot = await _suppliersCollection
        .where('searchTerms', arrayContains: normalizedQuery)
        .get();
    return snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<Supplier>> filterSuppliers({
    bool? isActive,
    double? minRating,
    List<String>? categories,
  }) async {
    Query<Map<String, dynamic>> query = _suppliersCollection;

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    if (minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    // Note: Firestore doesn't support OR queries across different fields
    // For complex filtering with categories, we need to fetch and filter in-memory

    final snapshot = await query.get();
    List<Supplier> suppliers = snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc).toDomain())
        .toList();

    // Filter by categories in-memory if required
    if (categories != null && categories.isNotEmpty) {
      suppliers = suppliers
          .where((supplier) => supplier.productCategories
              .any((category) => categories.contains(category)))
          .toList();
    }

    return suppliers;
  }

  @override
  Future<Map<String, int>> getSuppliersCountByCategory() async {
    final suppliers = await getAllSuppliers();

    final Map<String, int> result = {};
    for (final supplier in suppliers) {
      for (final category in supplier.productCategories) {
        result[category] = (result[category] ?? 0) + 1;
      }
    }

    return result;
  }

  @override
  Future<List<Supplier>> getTopRatedSuppliers(int limit) async {
    final snapshot = await _suppliersCollection
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<Supplier>> getRecentlyUpdatedSuppliers(int limit) async {
    final snapshot = await _suppliersCollection
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Stream<List<Supplier>> watchAllSuppliers() {
    return _suppliersCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc).toDomain())
        .toList());
  }

  @override
  Stream<Supplier> watchSupplier(String id) {
    return _suppliersCollection.doc(id).snapshots().map(
          (doc) => SupplierModel.fromFirestore(doc).toDomain(),
        );
  }
}
