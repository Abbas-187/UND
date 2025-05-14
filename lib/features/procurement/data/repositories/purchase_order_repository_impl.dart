import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/exceptions/result.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../models/purchase_order_model.dart' as models;

/// Implementation of [PurchaseOrderRepository] that works with Firestore
class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  /// Creates a new instance with the given firestore interface and supplier repository
  PurchaseOrderRepositoryImpl(this._firestore, this._supplierRepository);

  final FirebaseFirestore _firestore;
  final SupplierRepository _supplierRepository;

  @override
  Future<Result<List<PurchaseOrder>>> getPurchaseOrders({
    String? supplierId,
    dynamic status,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) async {
    try {
      final statusStr = status?.toString().split('.').last;
      // Use Query type for filtered queries
      Query<Map<String, dynamic>> query =
          _firestore.collection('purchase_orders');
      if (supplierId != null) {
        query = query.where('supplierId', isEqualTo: supplierId);
      }
      if (statusStr != null) {
        query = query.where('status', isEqualTo: statusStr);
      }
      if (fromDate != null) {
        query = query.where('requestDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }
      if (toDate != null) {
        query = query.where('requestDate',
            isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }
      final snapshot = await query.get();
      final docs = snapshot.docs;
      final filteredDocs = searchQuery != null && searchQuery.isNotEmpty
          ? docs.where((doc) {
              final data = doc.data();
              final poNumber = data['poNumber'] as String? ?? '';
              return poNumber.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList()
          : docs;
      final purchaseOrders = await _convertDocsToPurchaseOrders(filteredDocs);
      return Result.success(purchaseOrders);
    } on Exception catch (e) {
      return Result.failure(
        ServerFailure('Failed to get purchase orders', details: e.toString()),
      );
    }
  }

  @override
  Future<models.PurchaseOrderModel?> getPurchaseOrderById(String id) async {
    try {
      final doc = await _firestore.collection('purchase_orders').doc(id).get();
      if (!doc.exists) return null;
      return models.PurchaseOrderModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Result<PurchaseOrder>> getPurchaseOrderByIdResult(String id) async {
    try {
      final doc = await _firestore.collection('purchase_orders').doc(id).get();
      if (!doc.exists) {
        return Result.failure(
          NotFoundFailure('Purchase order with ID: $id not found'),
        );
      }

      final purchaseOrder = await _convertDocToPurchaseOrder(doc);
      return Result.success(purchaseOrder);
    } on Exception catch (e) {
      return Result.failure(
        ServerFailure('Failed to get purchase order with ID: $id',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<PurchaseOrder>> createPurchaseOrder(PurchaseOrder order) async {
    try {
      // Convert domain entity to data map
      final orderMap = _convertPurchaseOrderToMap(order);

      // Generate a new document ID if none exists
      final docRef = order.id.isEmpty
          ? _firestore.collection('purchase_orders').doc()
          : _firestore.collection('purchase_orders').doc(order.id);

      // Add created timestamp
      final dataWithTimestamps = {
        ...orderMap,
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await docRef.set(dataWithTimestamps);

      // Fetch the created document to return
      final docSnapshot = await docRef.get();
      final createdOrder = await _convertDocToPurchaseOrder(docSnapshot);

      return Result.success(createdOrder);
    } on Exception catch (e) {
      return Result.failure(
        ServerFailure('Failed to create purchase order', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<PurchaseOrder>> updatePurchaseOrder(PurchaseOrder order) async {
    try {
      // Validate ID
      if (order.id.isEmpty) {
        return Result.failure(
          ValidationFailure('Purchase order ID is required for update'),
        );
      }

      // Convert domain entity to data map
      final orderMap = _convertPurchaseOrderToMap(order);

      // Add updated timestamp
      final dataWithTimestamp = {
        ...orderMap,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in Firestore
      final docRef = _firestore.collection('purchase_orders').doc(order.id);
      await docRef.update(dataWithTimestamp);

      // Fetch the updated document to return
      final docSnapshot = await docRef.get();
      final updatedOrder = await _convertDocToPurchaseOrder(docSnapshot);

      return Result.success(updatedOrder);
    } on Exception catch (e) {
      return Result.failure(
        ServerFailure('Failed to update purchase order', details: e.toString()),
      );
    }
  }

  @override
  Future<Result<PurchaseOrder>> updatePurchaseOrderStatus(
      String id, dynamic status) async {
    try {
      // Convert enum to string for Firestore
      final statusStr = status.toString().split('.').last;

      // Update status in Firestore
      final docRef = _firestore.collection('purchase_orders').doc(id);
      await docRef.update({
        'status': statusStr,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If it's an approval status, update the approval fields
      if (statusStr == 'approved') {
        await docRef.update({
          'approvalDate': FieldValue.serverTimestamp(),
          // Note: In a real app, you'd use the current user's ID
          'approvedBy': 'current_user_id',
        });
      }

      // Fetch the updated document to return
      final docSnapshot = await docRef.get();
      final updatedOrder = await _convertDocToPurchaseOrder(docSnapshot);

      return Result.success(updatedOrder);
    } on Exception catch (e) {
      return Result.failure(
        ServerFailure('Failed to update purchase order status',
            details: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deletePurchaseOrder(String id) async {
    try {
      await _firestore.collection('purchase_orders').doc(id).delete();
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        ServerFailure('Failed to delete purchase order', details: e.toString()),
      );
    }
  }

  @override
  Future<List<models.PurchaseOrderModel>> getAllPurchaseOrders() async {
    try {
      final snapshot = await _firestore.collection('purchase_orders').get();
      return snapshot.docs
          .map((doc) => models.PurchaseOrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Helper method to convert a list of documents to domain entities
  Future<List<PurchaseOrder>> _convertDocsToPurchaseOrders(
      List<DocumentSnapshot> docs) async {
    return Future.wait(docs.map((doc) => _convertDocToPurchaseOrder(doc)));
  }

  // Helper method to convert a document to a domain entity
  Future<PurchaseOrder> _convertDocToPurchaseOrder(DocumentSnapshot doc) async {
    final map = doc.data() as Map<String, dynamic>;

    // Fetch supplier info from supplier module
    Supplier? supplier;
    String supplierName = map['supplierName'] ?? '';
    String supplierId = map['supplierId'] ?? '';
    if (supplierId.isNotEmpty) {
      try {
        supplier = await _supplierRepository.getSupplier(supplierId);
        supplierName = supplier.name;
      } catch (_) {
        // Supplier not found, fallback to map value
      }
    }

    // Convert timestamps to DateTime
    DateTime? requestDate;
    if (map['requestDate'] is Timestamp) {
      requestDate = (map['requestDate'] as Timestamp).toDate();
    }

    DateTime? approvalDate;
    if (map['approvalDate'] is Timestamp) {
      approvalDate = (map['approvalDate'] as Timestamp).toDate();
    }

    DateTime? deliveryDate;
    if (map['deliveryDate'] is Timestamp) {
      deliveryDate = (map['deliveryDate'] as Timestamp).toDate();
    }

    DateTime? completionDate;
    if (map['completionDate'] is Timestamp) {
      completionDate = (map['completionDate'] as Timestamp).toDate();
    }

    // Convert item maps to domain entities
    final itemMaps =
        (map['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final items = itemMaps.map((itemMap) {
      DateTime? requiredByDate;
      if (itemMap['requiredByDate'] is Timestamp) {
        requiredByDate = (itemMap['requiredByDate'] as Timestamp).toDate();
      }

      return PurchaseOrderItem(
        id: itemMap['id'] ?? '',
        itemId: itemMap['itemId'] ?? '',
        itemName: itemMap['itemName'] ?? '',
        quantity: (itemMap['quantity'] ?? 0).toDouble(),
        unit: itemMap['unit'] ?? '',
        unitPrice: (itemMap['unitPrice'] ?? 0).toDouble(),
        totalPrice: (itemMap['totalPrice'] ?? 0).toDouble(),
        requiredByDate: requiredByDate ?? DateTime.now(),
        notes: itemMap['notes'],
      );
    }).toList();

    // Create supporting documents list
    final supportingDocMaps = (map['supportingDocuments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final supportingDocuments = supportingDocMaps.map((docMap) {
      DateTime? uploadDate;
      if (docMap['uploadDate'] is Timestamp) {
        uploadDate = (docMap['uploadDate'] as Timestamp).toDate();
      }

      return SupportingDocument(
        id: docMap['id'] ?? '',
        name: docMap['name'] ?? '',
        type: docMap['type'] ?? '',
        url: docMap['url'] ?? '',
        uploadDate: uploadDate ?? DateTime.now(),
      );
    }).toList();

    return PurchaseOrder(
      id: doc.id,
      procurementPlanId: map['procurementPlanId'] ?? '',
      poNumber: map['poNumber'] ?? '',
      requestDate: requestDate ?? DateTime.now(),
      requestedBy: map['requestedBy'] ?? '',
      supplierId: supplierId,
      supplierName: supplierName,
      status: _mapStringToPurchaseOrderStatus(map['status'] ?? 'draft'),
      items: items,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      reasonForRequest: map['reasonForRequest'] ?? '',
      intendedUse: map['intendedUse'] ?? '',
      quantityJustification: map['quantityJustification'] ?? '',
      supportingDocuments: supportingDocuments,
      approvalDate: approvalDate,
      approvedBy: map['approvedBy'],
      deliveryDate: deliveryDate,
      completionDate: completionDate,
    );
  }

  // Helper method to convert a domain entity to a map
  Map<String, dynamic> _convertPurchaseOrderToMap(PurchaseOrder order) {
    // Convert items to maps
    final itemMaps = order.items.map((item) {
      return {
        'id': item.id,
        'itemId': item.itemId,
        'itemName': item.itemName,
        'quantity': item.quantity,
        'unit': item.unit,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
        'requiredByDate': item.requiredByDate,
        'notes': item.notes,
      };
    }).toList();

    return {
      'procurementPlanId': order.procurementPlanId,
      'poNumber': order.poNumber,
      'requestDate': order.requestDate,
      'requestedBy': order.requestedBy,
      'supplierId': order.supplierId,
      'supplierName': order.supplierName,
      'status': order.status.toString().split('.').last,
      'items': itemMaps,
      'totalAmount': order.totalAmount,
      'reasonForRequest': order.reasonForRequest,
      'intendedUse': order.intendedUse,
      'quantityJustification': order.quantityJustification,
      'supportingDocuments': order.supportingDocuments
          .map((doc) => {
                'id': doc.id,
                'name': doc.name,
                'type': doc.type,
                'url': doc.url,
                'uploadDate': doc.uploadDate,
              })
          .toList(),
      'approvalDate': order.approvalDate,
      'approvedBy': order.approvedBy,
      'deliveryDate': order.deliveryDate,
      'completionDate': order.completionDate,
    };
  }

  // Helper method to map string to PurchaseOrderStatus enum
  PurchaseOrderStatus _mapStringToPurchaseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return PurchaseOrderStatus.draft;
      case 'pending':
        return PurchaseOrderStatus.pending;
      case 'approved':
        return PurchaseOrderStatus.approved;
      case 'declined':
        return PurchaseOrderStatus.declined;
      case 'inprogress':
        return PurchaseOrderStatus.inProgress;
      case 'delivered':
        return PurchaseOrderStatus.delivered;
      case 'completed':
        return PurchaseOrderStatus.completed;
      case 'canceled':
        return PurchaseOrderStatus.canceled;
      default:
        return PurchaseOrderStatus.draft;
    }
  }
}
