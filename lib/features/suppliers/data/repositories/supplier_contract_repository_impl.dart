import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/supplier_contract.dart';
import '../../domain/repositories/supplier_contract_repository.dart';
import '../models/supplier_contract_model.dart';

class SupplierContractRepositoryImpl implements SupplierContractRepository {
  SupplierContractRepositoryImpl(this._firestore, this._storage);
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collection = 'supplierContracts';

  CollectionReference<Map<String, dynamic>> get _contractsCollection =>
      _firestore.collection(_collection);

  @override
  Future<SupplierContract> getContract(String id) async {
    final doc = await _contractsCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Contract not found');
    }
    return SupplierContractModel.fromFirestore(doc).toDomain();
  }

  @override
  Future<List<SupplierContract>> getAllContracts() async {
    final snapshot = await _contractsCollection.get();
    return snapshot.docs
        .map((doc) => SupplierContractModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<SupplierContract> addContract(SupplierContract contract) async {
    final model = SupplierContractModel.fromDomain(contract);
    final docRef = _contractsCollection.doc();
    final modelWithId = model.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(modelWithId.toJson());
    return modelWithId.toDomain();
  }

  @override
  Future<SupplierContract> updateContract(SupplierContract contract) async {
    final model = SupplierContractModel.fromDomain(contract);
    final updatedModel = model.copyWith(updatedAt: DateTime.now());
    await _contractsCollection.doc(contract.id).update(updatedModel.toJson());
    return updatedModel.toDomain();
  }

  @override
  Future<void> deleteContract(String id) async {
    await _contractsCollection.doc(id).delete();
  }

  @override
  Future<List<SupplierContract>> getContractsBySupplier(
      String supplierId) async {
    final snapshot = await _contractsCollection
        .where('supplierId', isEqualTo: supplierId)
        .get();
    return snapshot.docs
        .map((doc) => SupplierContractModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<SupplierContract>> searchContracts(String query) async {
    final normalizedQuery = query.toLowerCase();
    final snapshot = await _contractsCollection
        .where('searchTerms', arrayContains: normalizedQuery)
        .get();
    return snapshot.docs
        .map((doc) => SupplierContractModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<SupplierContract>> filterContracts({
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    List<String>? contractTypes,
  }) async {
    Query<Map<String, dynamic>> query = _contractsCollection;

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    if (startDateFrom != null) {
      query = query.where('startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDateFrom));
    }

    if (startDateTo != null) {
      query = query.where('startDate',
          isLessThanOrEqualTo: Timestamp.fromDate(startDateTo));
    }

    if (endDateFrom != null) {
      query = query.where('endDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(endDateFrom));
    }

    if (endDateTo != null) {
      query = query.where('endDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDateTo));
    }

    final snapshot = await query.get();
    List<SupplierContract> contracts = snapshot.docs
        .map((doc) => SupplierContractModel.fromFirestore(doc).toDomain())
        .toList();

    // Filter by contract types in-memory if required
    if (contractTypes != null && contractTypes.isNotEmpty) {
      contracts = contracts
          .where((contract) => contractTypes.contains(contract.contractType))
          .toList();
    }

    return contracts;
  }

  @override
  Future<String> addAttachment(
      String contractId, String fileName, dynamic fileData) async {
    // Upload file to Firebase Storage
    final path = 'contracts/$contractId/attachments/$fileName';
    final ref = _storage.ref().child(path);
    await ref.putData(fileData);
    final downloadUrl = await ref.getDownloadURL();

    // Add attachment metadata to contract
    final contract = await getContract(contractId);
    final updatedAttachments = [...contract.attachments];
    updatedAttachments.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': fileName,
      'url': downloadUrl,
      'uploadedAt': DateTime.now().toIso8601String(),
    });

    // Update contract with new attachment
    final updatedContract = contract.copyWith(
      attachments: updatedAttachments,
    );
    await updateContract(updatedContract);

    return downloadUrl;
  }

  @override
  Future<bool> deleteAttachment(String contractId, String attachmentId) async {
    try {
      // Get current contract
      final contract = await getContract(contractId);

      // Find attachment
      final attachmentIndex = contract.attachments
          .indexWhere((attachment) => attachment['id'] == attachmentId);

      if (attachmentIndex == -1) {
        return false;
      }

      // Get attachment details
      final attachment = contract.attachments[attachmentIndex];
      final fileUrl = attachment['url'] as String;

      // Remove from Storage if it's a Firebase Storage URL
      if (fileUrl.contains('firebasestorage.googleapis.com')) {
        try {
          final ref = _storage.refFromURL(fileUrl);
          await ref.delete();
        } catch (e) {
          // Continue even if file deletion fails
          debugPrint('Failed to delete file from storage: $e');
        }
      }

      // Remove from the attachments list
      final updatedAttachments = [...contract.attachments];
      updatedAttachments.removeAt(attachmentIndex);

      // Update contract
      final updatedContract = contract.copyWith(
        attachments: updatedAttachments,
      );
      await updateContract(updatedContract);

      return true;
    } catch (e) {
      debugPrint('Error deleting attachment: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAttachments(String contractId) async {
    final contract = await getContract(contractId);
    return contract.attachments;
  }

  @override
  Future<List<SupplierContract>> getUpcomingRenewals(int daysThreshold) async {
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));

    final snapshot = await _contractsCollection
        .where('autoRenew', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .where('endDate',
            isLessThanOrEqualTo: Timestamp.fromDate(thresholdDate))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    return snapshot.docs
        .map((doc) => SupplierContractModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<SupplierContract>> getExpiringContracts(int daysThreshold) async {
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));

    final snapshot = await _contractsCollection
        .where('isActive', isEqualTo: true)
        .where('endDate',
            isLessThanOrEqualTo: Timestamp.fromDate(thresholdDate))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    return snapshot.docs
        .map((doc) => SupplierContractModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Stream<List<SupplierContract>> watchAllContracts() {
    return _contractsCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => SupplierContractModel.fromFirestore(doc).toDomain())
        .toList());
  }

  @override
  Stream<SupplierContract> watchContract(String id) {
    return _contractsCollection.doc(id).snapshots().map(
          (doc) => SupplierContractModel.fromFirestore(doc).toDomain(),
        );
  }
}
