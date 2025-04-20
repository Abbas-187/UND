// lib/features/procurement/data/repositories/purchase_order_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/exceptions/app_exception.dart';

class PurchaseOrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Purchase Order CRUD Operations ---

  // Create Purchase Order
  Future<void> createPurchaseOrder(
      Map<String, dynamic> purchaseOrderData) async {
    try {
      await _firestore.collection('purchaseOrders').add(purchaseOrderData);
    } catch (e) {
      throw AppException(
          message: 'Failed to create purchase order: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Get Purchase Order by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getPurchaseOrder(
      String purchaseOrderId) async {
    try {
      return await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .get();
    } catch (e) {
      throw AppException(
          message: 'Failed to get purchase order: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Update Purchase Order
  Future<void> updatePurchaseOrder(
      String purchaseOrderId, Map<String, dynamic> purchaseOrderData) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .update(purchaseOrderData);
    } catch (e) {
      throw AppException(
          message: 'Failed to update purchase order: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Delete Purchase Order
  Future<void> deletePurchaseOrder(String purchaseOrderId) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .delete();
    } catch (e) {
      throw AppException(
          message: 'Failed to delete purchase order: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Get All Purchase Orders Stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPurchaseOrders() {
    return _firestore.collection('purchaseOrders').snapshots();
  }

  // --- Purchase Order Item CRUD Operations ---

  // Add Item to Purchase Order
  Future<void> addPurchaseOrderItem(
      String purchaseOrderId, Map<String, dynamic> itemData) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .collection('items')
          .add(itemData);
    } catch (e) {
      throw AppException(
          message: 'Failed to add item to purchase order: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Get Purchase Order Item
  Future<DocumentSnapshot<Map<String, dynamic>>> getPurchaseOrderItem(
      String purchaseOrderId, String itemId) async {
    try {
      return await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .collection('items')
          .doc(itemId)
          .get();
    } catch (e) {
      throw AppException(
          message: 'Failed to get purchase order item: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Update Purchase Order Item
  Future<void> updatePurchaseOrderItem(String purchaseOrderId, String itemId,
      Map<String, dynamic> itemData) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .collection('items')
          .doc(itemId)
          .update(itemData);
    } catch (e) {
      throw AppException(
          message: 'Failed to update purchase order item: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Delete Purchase Order Item
  Future<void> deletePurchaseOrderItem(
      String purchaseOrderId, String itemId) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw AppException(
          message: 'Failed to delete purchase order item: $e',
          type: AppExceptionType.unknown);
    }
  }

  // Get All Purchase Order Items Stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPurchaseOrderItems(
      String purchaseOrderId) {
    return _firestore
        .collection('purchaseOrders')
        .doc(purchaseOrderId)
        .collection('items')
        .snapshots();
  }

  // --- Status Transition Methods ---
  Future<void> transitionPurchaseOrderStatus(
      String purchaseOrderId, String newStatus) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .update({'status': newStatus});
    } catch (e) {
      throw AppException(
          message: 'Failed to transition purchase order status: $e',
          type: AppExceptionType.unknown);
    }
  }

  // --- Approval Workflow Handling ---
  Future<void> requestPurchaseOrderApproval(String purchaseOrderId) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .update({'approvalRequested': true, 'status': 'pending_approval'});
    } catch (e) {
      throw AppException(
          message: 'Failed to request purchase order approval: $e',
          type: AppExceptionType.unknown);
    }
  }

  Future<void> approvePurchaseOrder(String purchaseOrderId) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .update({'approved': true, 'status': 'approved'});
    } catch (e) {
      throw AppException(
          message: 'Failed to approve purchase order: $e',
          type: AppExceptionType.unknown);
    }
  }

  Future<void> rejectPurchaseOrder(String purchaseOrderId) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .update({'approved': false, 'status': 'rejected'});
    } catch (e) {
      throw AppException(
          message: 'Failed to reject purchase order: $e',
          type: AppExceptionType.unknown);
    }
  }

  // --- Purchase Order History Tracking (Basic - can be expanded) ---
  Future<void> trackPurchaseOrderHistory(
      String purchaseOrderId, String event, String userId) async {
    try {
      await _firestore
          .collection('purchaseOrders')
          .doc(purchaseOrderId)
          .collection('history')
          .add({
        'event': event,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException(
          message: 'Failed to track purchase order history: $e',
          type: AppExceptionType.unknown);
    }
  }

  // --- Query Methods ---

  // Get Purchase Orders by Supplier
  Stream<QuerySnapshot<Map<String, dynamic>>> getPurchaseOrdersBySupplier(
      String supplierId) {
    return _firestore
        .collection('purchaseOrders')
        .where('supplierId',
            isEqualTo: supplierId) // Assuming 'supplierId' field exists
        .snapshots();
  }

  // Get Purchase Orders by Status
  Stream<QuerySnapshot<Map<String, dynamic>>> getPurchaseOrdersByStatus(
      String status) {
    return _firestore
        .collection('purchaseOrders')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // Get Purchase Orders by Date Range (Created Date)
  Stream<QuerySnapshot<Map<String, dynamic>>> getPurchaseOrdersByDateRange(
      DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('purchaseOrders')
        .where('createdAt',
            isGreaterThanOrEqualTo:
                startDate) // Assuming 'createdAt' timestamp field exists
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .snapshots();
  }

  // --- Transaction Support ---
  Future<void> performTransactionalOperation(
      String purchaseOrderId,
      Map<String, dynamic> purchaseOrderData,
      Map<String, dynamic> itemData) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Update Purchase Order
        final poRef =
            _firestore.collection('purchaseOrders').doc(purchaseOrderId);
        transaction.update(poRef, purchaseOrderData);

        // 2. Add Item to Purchase Order
        final itemCollectionRef = poRef.collection('items');
        transaction.set(itemCollectionRef.doc(),
            itemData); // Example of set, can be add as well
      });
    } catch (e) {
      throw AppException(
          message: 'Transactional operation failed: $e',
          type: AppExceptionType.unknown);
    }
  }
}
