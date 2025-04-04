import 'package:cloud_firestore/cloud_firestore.dart';

/// Exception for supplier contract data source operations
class SupplierContractDataSourceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  SupplierContractDataSourceException(this.message,
      {this.code, this.originalError});

  @override
  String toString() =>
      'SupplierContractDataSourceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Remote data source for supplier contract operations using Firestore
class SupplierContractRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'supplierContracts';

  /// Creates a new instance with the given Firestore instance
  SupplierContractRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get _contractsCollection =>
      _firestore.collection(_collection);

  /// Get all supplier contracts with optional filtering
  Future<List<Map<String, dynamic>>> getSupplierContracts({
    String? supplierId,
    String? status,
    DateTime? activeDate,
    String? contractType,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _contractsCollection;

      // Apply filters if provided
      if (supplierId != null) {
        query = query.where('supplierId', isEqualTo: supplierId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (contractType != null) {
        query = query.where('contractType', isEqualTo: contractType);
      }

      // If activeDate is provided, find contracts that are active on that date
      if (activeDate != null) {
        query = query
            .where('startDate', isLessThanOrEqualTo: activeDate)
            .where('endDate', isGreaterThanOrEqualTo: activeDate);
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
      throw SupplierContractDataSourceException(
          'Failed to fetch supplier contracts',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to fetch supplier contracts',
          originalError: e);
    }
  }

  /// Get a supplier contract by ID
  Future<Map<String, dynamic>> getSupplierContractById(String id) async {
    try {
      final docSnapshot = await _contractsCollection.doc(id).get();

      if (!docSnapshot.exists) {
        throw SupplierContractDataSourceException('Supplier contract not found',
            code: 'not-found');
      }

      return {
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      };
    } on FirebaseException catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to fetch supplier contract with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      if (e is SupplierContractDataSourceException) rethrow;
      throw SupplierContractDataSourceException(
          'Failed to fetch supplier contract with ID: $id',
          originalError: e);
    }
  }

  /// Create a new supplier contract
  Future<Map<String, dynamic>> createSupplierContract(
      Map<String, dynamic> data) async {
    try {
      // Generate a contract number if not provided
      if (!data.containsKey('contractNumber') ||
          data['contractNumber'] == null) {
        data['contractNumber'] =
            'SC-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';
      }

      // Add server timestamp
      final contractData = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Remove any ID from the data before creating
      contractData.remove('id');

      final docRef = await _contractsCollection.add(contractData);

      // Fetch the created document to get server-side values like timestamps
      final createdDoc = await docRef.get();

      return {
        'id': docRef.id,
        ...createdDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to create supplier contract',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to create supplier contract',
          originalError: e);
    }
  }

  /// Update an existing supplier contract
  Future<Map<String, dynamic>> updateSupplierContract(
      String id, Map<String, dynamic> data) async {
    try {
      // Add update timestamp
      final contractData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove ID from data to avoid overwriting it
      contractData.remove('id');

      await _contractsCollection.doc(id).update(contractData);

      // Fetch the updated document to get the latest data
      final updatedDoc = await _contractsCollection.doc(id).get();

      if (!updatedDoc.exists) {
        throw SupplierContractDataSourceException(
            'Supplier contract not found after update',
            code: 'not-found');
      }

      return {
        'id': updatedDoc.id,
        ...updatedDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to update supplier contract with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      if (e is SupplierContractDataSourceException) rethrow;
      throw SupplierContractDataSourceException(
          'Failed to update supplier contract with ID: $id',
          originalError: e);
    }
  }

  /// Update supplier contract status
  Future<Map<String, dynamic>> updateSupplierContractStatus(
      String id, String status) async {
    try {
      // Get current document to ensure it exists
      final docSnapshot = await _contractsCollection.doc(id).get();

      if (!docSnapshot.exists) {
        throw SupplierContractDataSourceException('Supplier contract not found',
            code: 'not-found');
      }

      // Update only the status field and add timestamps
      final contractData = {
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _contractsCollection.doc(id).update(contractData);

      // Fetch the updated document
      final updatedDoc = await _contractsCollection.doc(id).get();

      return {
        'id': updatedDoc.id,
        ...updatedDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to update supplier contract status for ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      if (e is SupplierContractDataSourceException) rethrow;
      throw SupplierContractDataSourceException(
          'Failed to update supplier contract status for ID: $id',
          originalError: e);
    }
  }

  /// Delete a supplier contract
  Future<void> deleteSupplierContract(String id) async {
    try {
      await _contractsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to delete supplier contract with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to delete supplier contract with ID: $id',
          originalError: e);
    }
  }

  /// Get active contracts for a supplier
  Future<List<Map<String, dynamic>>> getActiveContractsForSupplier(
      String supplierId) async {
    try {
      final now = DateTime.now();

      final query = _contractsCollection
          .where('supplierId', isEqualTo: supplierId)
          .where('status', isEqualTo: 'active')
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } on FirebaseException catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to fetch active contracts for supplier ID: $supplierId',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to fetch active contracts for supplier ID: $supplierId',
          originalError: e);
    }
  }

  /// Check for contracts expiring soon
  Future<List<Map<String, dynamic>>> getContractsExpiringSoon(
      int daysThreshold) async {
    try {
      final now = DateTime.now();
      final thresholdDate = now.add(Duration(days: daysThreshold));

      final query = _contractsCollection
          .where('status', isEqualTo: 'active')
          .where('endDate', isGreaterThanOrEqualTo: now)
          .where('endDate', isLessThanOrEqualTo: thresholdDate);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } on FirebaseException catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to fetch contracts expiring soon',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw SupplierContractDataSourceException(
          'Failed to fetch contracts expiring soon',
          originalError: e);
    }
  }
}
