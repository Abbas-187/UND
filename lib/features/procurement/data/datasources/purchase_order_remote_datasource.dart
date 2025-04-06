import 'package:cloud_firestore/cloud_firestore.dart';

/// Exception for purchase order data source operations
class PurchaseOrderDataSourceException implements Exception {

  PurchaseOrderDataSourceException(this.message,
      {this.code, this.originalError});
  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() =>
      'PurchaseOrderDataSourceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Remote data source for purchase order operations using Firestore
class PurchaseOrderRemoteDataSource {

  /// Creates a new instance with the given Firestore instance
  PurchaseOrderRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final String _collection = 'purchaseOrders';

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(_collection);

  /// Get all purchase orders with optional filtering
  Future<List<Map<String, dynamic>>> getPurchaseOrders({
    String? supplierId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _ordersCollection;

      // Apply filters if provided
      if (supplierId != null) {
        query = query.where('supplierId', isEqualTo: supplierId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      // Date range filtering
      if (fromDate != null) {
        query = query.where('orderDate', isGreaterThanOrEqualTo: fromDate);
      }

      if (toDate != null) {
        // Add one day to include the entire end date
        final endDate = toDate.add(Duration(days: 1));
        query = query.where('orderDate', isLessThan: endDate);
      }

      // Text search on order number
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .where('orderNumber', isGreaterThanOrEqualTo: searchQuery)
            .where('orderNumber', isLessThanOrEqualTo: '$searchQuery\uf8ff');
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
      throw PurchaseOrderDataSourceException('Failed to fetch purchase orders',
          code: e.code, originalError: e);
    } catch (e) {
      throw PurchaseOrderDataSourceException('Failed to fetch purchase orders',
          originalError: e);
    }
  }

  /// Get a purchase order by ID
  Future<Map<String, dynamic>> getPurchaseOrderById(String id) async {
    try {
      final docSnapshot = await _ordersCollection.doc(id).get();

      if (!docSnapshot.exists) {
        throw PurchaseOrderDataSourceException('Purchase order not found',
            code: 'not-found');
      }

      return {
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      };
    } on FirebaseException catch (e) {
      throw PurchaseOrderDataSourceException(
          'Failed to fetch purchase order with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      if (e is PurchaseOrderDataSourceException) rethrow;
      throw PurchaseOrderDataSourceException(
          'Failed to fetch purchase order with ID: $id',
          originalError: e);
    }
  }

  /// Create a new purchase order
  Future<Map<String, dynamic>> createPurchaseOrder(
      Map<String, dynamic> data) async {
    try {
      // Generate a unique order number if not provided
      if (!data.containsKey('orderNumber') || data['orderNumber'] == null) {
        data['orderNumber'] =
            'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';
      }

      // Add server timestamp
      final orderData = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Remove any ID from the data before creating
      orderData.remove('id');

      final docRef = await _ordersCollection.add(orderData);

      // Fetch the created document to get server-side values like timestamps
      final createdDoc = await docRef.get();

      return {
        'id': docRef.id,
        ...createdDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw PurchaseOrderDataSourceException('Failed to create purchase order',
          code: e.code, originalError: e);
    } catch (e) {
      throw PurchaseOrderDataSourceException('Failed to create purchase order',
          originalError: e);
    }
  }

  /// Update an existing purchase order
  Future<Map<String, dynamic>> updatePurchaseOrder(
      String id, Map<String, dynamic> data) async {
    try {
      // Add update timestamp
      final orderData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove ID from data to avoid overwriting it
      orderData.remove('id');

      await _ordersCollection.doc(id).update(orderData);

      // Fetch the updated document to get the latest data
      final updatedDoc = await _ordersCollection.doc(id).get();

      if (!updatedDoc.exists) {
        throw PurchaseOrderDataSourceException(
            'Purchase order not found after update',
            code: 'not-found');
      }

      return {
        'id': updatedDoc.id,
        ...updatedDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw PurchaseOrderDataSourceException(
          'Failed to update purchase order with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      if (e is PurchaseOrderDataSourceException) rethrow;
      throw PurchaseOrderDataSourceException(
          'Failed to update purchase order with ID: $id',
          originalError: e);
    }
  }

  /// Update purchase order status
  Future<Map<String, dynamic>> updatePurchaseOrderStatus(
      String id, String status) async {
    try {
      // Get current document to ensure it exists
      final docSnapshot = await _ordersCollection.doc(id).get();

      if (!docSnapshot.exists) {
        throw PurchaseOrderDataSourceException('Purchase order not found',
            code: 'not-found');
      }

      // Update only the status field and add timestamps
      final orderData = {
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add appropriate date fields based on status
      if (status == 'approved') {
        orderData['approvalDate'] = FieldValue.serverTimestamp();
      } else if (status == 'received') {
        orderData['receivedDate'] = FieldValue.serverTimestamp();
      } else if (status == 'closed') {
        orderData['closedDate'] = FieldValue.serverTimestamp();
      }

      await _ordersCollection.doc(id).update(orderData);

      // Fetch the updated document
      final updatedDoc = await _ordersCollection.doc(id).get();

      return {
        'id': updatedDoc.id,
        ...updatedDoc.data()!,
      };
    } on FirebaseException catch (e) {
      throw PurchaseOrderDataSourceException(
          'Failed to update purchase order status for ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      if (e is PurchaseOrderDataSourceException) rethrow;
      throw PurchaseOrderDataSourceException(
          'Failed to update purchase order status for ID: $id',
          originalError: e);
    }
  }

  /// Delete a purchase order
  Future<void> deletePurchaseOrder(String id) async {
    try {
      await _ordersCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw PurchaseOrderDataSourceException(
          'Failed to delete purchase order with ID: $id',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw PurchaseOrderDataSourceException(
          'Failed to delete purchase order with ID: $id',
          originalError: e);
    }
  }
}
