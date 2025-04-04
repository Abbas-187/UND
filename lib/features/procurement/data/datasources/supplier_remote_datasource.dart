import 'package:cloud_firestore/cloud_firestore.dart';

/// Exception for supplier data source operations
class SupplierDataSourceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  SupplierDataSourceException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'SupplierDataSourceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Remote data source for supplier operations using Firestore
class SupplierRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'suppliers';

  /// Creates a new instance with the given Firestore instance
  SupplierRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get _suppliersCollection =>
      _firestore.collection(_collection);

  /// Get all suppliers with optional filtering
  Future<List<Map<String, dynamic>>> getSuppliers({
    String? type,
    String? status,
    String? searchQuery,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _suppliersCollection;

      // Apply filters if provided
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      // Search query is applied on name and code
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Firestore doesn't support native text search, we would implement this client-side
        // In a production app, consider using Algolia or other search service
        // For simplicity we'll use a startsWith query on name (limited but works for demo)
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } on FirebaseException catch (e) {
      throw SupplierDataSourceException('Failed to fetch suppliers',
          code: e.code, originalError: e);
    } catch (e) {
      throw SupplierDataSourceException('Failed to fetch suppliers',
          originalError: e);
    }
  }

  /// Get a supplier by ID
  Future<Map<String, dynamic>> getSupplierById(String id) async {
    try {
      final docSnapshot = await _suppliersCollection.doc(id).get();

      if (!docSnapshot.exists) {
        throw SupplierDataSourceException('Supplier not found',
            code: 'not-found');
      }

      return {
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      };
    } on FirebaseException catch (e) {
      throw SupplierDataSourceException('Failed to fetch supplier with ID: $id',
          code: e.code, originalError: e);
    } catch (e) {
      if (e is SupplierDataSourceException) rethrow;
      throw SupplierDataSourceException('Failed to fetch supplier with ID: $id',
          originalError: e);
    }
  }

  /// Create a new supplier
  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data) async {
    try {
      // Add server timestamp
      final supplierData = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Remove any ID from the data before creating
      supplierData.remove('id');

      final docRef = await _suppliersCollection.add(supplierData);

      // Fetch the created document to get server-side values like timestamps
      final createdDoc = await docRef.get();

      return {
        'id': docRef.id,
        ...createdDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw SupplierDataSourceException('Failed to create supplier',
          code: e.code, originalError: e);
    } catch (e) {
      throw SupplierDataSourceException('Failed to create supplier',
          originalError: e);
    }
  }

  /// Update an existing supplier
  Future<Map<String, dynamic>> updateSupplier(
      String id, Map<String, dynamic> data) async {
    try {
      // Add update timestamp
      final supplierData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove ID from data to avoid overwriting it
      supplierData.remove('id');

      await _suppliersCollection.doc(id).update(supplierData);

      // Fetch the updated document to get the latest data
      final updatedDoc = await _suppliersCollection.doc(id).get();

      if (!updatedDoc.exists) {
        throw SupplierDataSourceException('Supplier not found after update',
            code: 'not-found');
      }

      return {
        'id': updatedDoc.id,
        ...updatedDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw SupplierDataSourceException(
          'Failed to update supplier with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      if (e is SupplierDataSourceException) rethrow;
      throw SupplierDataSourceException(
          'Failed to update supplier with ID: $id',
          originalError: e);
    }
  }

  /// Delete a supplier
  Future<void> deleteSupplier(String id) async {
    try {
      await _suppliersCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw SupplierDataSourceException(
          'Failed to delete supplier with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw SupplierDataSourceException(
          'Failed to delete supplier with ID: $id',
          originalError: e);
    }
  }
}
