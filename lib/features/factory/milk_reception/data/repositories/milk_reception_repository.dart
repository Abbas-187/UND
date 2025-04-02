import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/firebase_providers.dart';

import '../models/milk_quality_standards_model.dart' hide MilkType;
import '../models/milk_reception_model.dart'
    show MilkReceptionModel, MilkType, ReceptionStatus;
import '../models/milk_test_result_model.dart';

part 'milk_reception_repository.g.dart';

class MilkReceptionRepository {
  MilkReceptionRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collection references
  CollectionReference get _receptionsCollection =>
      _firestore.collection('milkReceptions');

  CollectionReference get _qualityStandardsCollection =>
      _firestore.collection('milkQualityStandards');

  // Get all milk receptions
  Future<List<MilkReceptionModel>> getMilkReceptions() async {
    try {
      final QuerySnapshot snapshot = await _receptionsCollection
          .orderBy('receptionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MilkReceptionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get milk receptions: $e');
    }
  }

  // Get milk receptions by date range
  Future<List<MilkReceptionModel>> getMilkReceptionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final QuerySnapshot snapshot = await _receptionsCollection
          .where('receptionDate', isGreaterThanOrEqualTo: startDate)
          .where('receptionDate', isLessThanOrEqualTo: endDate)
          .orderBy('receptionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MilkReceptionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get milk receptions by date range: $e');
    }
  }

  // Get milk reception by id
  Future<MilkReceptionModel> getMilkReceptionById(String id) async {
    try {
      final DocumentSnapshot doc = await _receptionsCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Milk reception not found');
      }
      return MilkReceptionModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get milk reception: $e');
    }
  }

  // Create milk reception
  Future<String> createMilkReception(MilkReceptionModel reception) async {
    try {
      final String userId = _auth.currentUser?.uid ?? 'unknown';

      final Map<String, dynamic> receptionData = {
        'receptionDate': Timestamp.fromDate(reception.receptionDate),
        'supplierId': reception.supplierId,
        'supplierName': reception.supplierName,
        'quantityLiters': reception.quantityLiters,
        'temperatureCelsius': reception.temperatureCelsius,
        'milkType': reception.milkType.toString().split('.').last,
        'tankId': reception.tankId,
        'receivedBy': userId, // Use the userId here
        'status': reception.status.toString().split('.').last,
        'testResults': reception.testResults.isNotEmpty
            ? reception.testResults
                .map((testResult) => testResult.toMap())
                .toList()
            : [],
        'rejectionReason': reception.rejectionReason,
        'fatPercentage': reception.fatPercentage,
        'proteinPercentage': reception.proteinPercentage,
        'notes': reception.notes,
        'organicCertified': reception.organicCertified,
        'batchNumber': reception.batchNumber,
        'metadata': reception.metadata,
      };

      final DocumentReference docRef =
          await _receptionsCollection.add(receptionData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create milk reception: $e');
    }
  }

  // Update milk reception
  Future<void> updateMilkReception(MilkReceptionModel reception) async {
    try {
      final Map<String, dynamic> receptionData = {
        'receptionDate': Timestamp.fromDate(reception.receptionDate),
        'supplierId': reception.supplierId,
        'supplierName': reception.supplierName,
        'quantityLiters': reception.quantityLiters,
        'temperatureCelsius': reception.temperatureCelsius,
        'milkType': reception.milkType.toString().split('.').last,
        'tankId': reception.tankId,
        'receivedBy': reception.receivedBy,
        'status': reception.status.toString().split('.').last,
        'testResults': reception.testResults.isNotEmpty
            ? reception.testResults
                .map((testResult) => testResult.toMap())
                .toList()
            : [],
        'rejectionReason': reception.rejectionReason,
        'fatPercentage': reception.fatPercentage,
        'proteinPercentage': reception.proteinPercentage,
        'notes': reception.notes,
        'organicCertified': reception.organicCertified,
        'batchNumber': reception.batchNumber,
        'metadata': reception.metadata,
      };

      await _receptionsCollection.doc(reception.id).update(receptionData);
    } catch (e) {
      throw Exception('Failed to update milk reception: $e');
    }
  }

  // Add test result to milk reception
  Future<void> addTestResult({
    required String receptionId,
    required MilkTestResultModel testResult,
  }) async {
    try {
      final String userId = _auth.currentUser?.uid ?? 'unknown';

      // Get current reception
      final reception = await getMilkReceptionById(receptionId);

      // Add test result, ensuring 'testedBy' is set
      final updatedTestResults =
          List<MilkTestResultModel>.from(reception.testResults)
            ..add(testResult.copyWith(testedBy: userId));

      // Update reception status based on test results. Assuming all tests need to pass
      ReceptionStatus newStatus = ReceptionStatus.testing;
      if (updatedTestResults.any((test) => !test.isPassing)) {
        newStatus = ReceptionStatus.rejected;
      } else if (updatedTestResults.length >= 5) {
        // Assuming 5 tests are required
        newStatus = ReceptionStatus.accepted;
      }

      // Update reception
      final updatedReception = reception.copyWith(
        testResults: updatedTestResults,
        status: newStatus,
      );

      await updateMilkReception(updatedReception);
    } catch (e) {
      throw Exception('Failed to add test result: $e');
    }
  }

  // Removed unused utility methods _parseMilkType and _parseReceptionStatus
  // as they are not used anywhere in the code and the model's fromMap constructor
  // already handles the enum parsing

  // Add methods for managing milk quality standards
  Future<void> addMilkQualityStandard(
      MilkQualityStandardsModel standard) async {
    try {
      await _qualityStandardsCollection.add(standard.toMap());
    } catch (e) {
      throw Exception('Failed to add milk quality standard: $e');
    }
  }

  Future<List<MilkQualityStandardsModel>> getMilkQualityStandards() async {
    try {
      final snapshot = await _qualityStandardsCollection.get();
      return snapshot.docs
          .map((doc) => MilkQualityStandardsModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get milk quality standards: $e');
    }
  }

  Future<MilkQualityStandardsModel> getMilkQualityStandardById(
      String id) async {
    try {
      final doc = await _qualityStandardsCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Milk quality standard not found');
      }
      return MilkQualityStandardsModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get milk quality standard by ID: $e');
    }
  }

  Future<void> updateMilkQualityStandard(
      MilkQualityStandardsModel standard) async {
    try {
      await _qualityStandardsCollection
          .doc(standard.id)
          .update(standard.toMap());
    } catch (e) {
      throw Exception('Failed to update milk quality standard: $e');
    }
  }

  Future<void> deleteMilkQualityStandard(String id) async {
    try {
      await _qualityStandardsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete milk quality standard: $e');
    }
  }

  // Set a standard as active - fixed field name to isActive for consistency
  Future<void> setActiveMilkQualityStandard(String id) async {
    try {
      // First, unset the currently active standard, if any
      final currentActive = await _qualityStandardsCollection
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in currentActive.docs) {
        await doc.reference.update({'isActive': false});
      }

      // Then, set the new standard as active
      await _qualityStandardsCollection.doc(id).update({'isActive': true});
    } catch (e) {
      throw Exception('Failed to set active milk quality standard: $e');
    }
  }

  // Get the currently active standard - fixed field name to isActive for consistency
  Future<MilkQualityStandardsModel?> getActiveMilkQualityStandard() async {
    try {
      final snapshot = await _qualityStandardsCollection
          .where('isActive', isEqualTo: true)
          .limit(1) // Assuming only one standard can be active at a time
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MilkQualityStandardsModel.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>,
            snapshot.docs.first.id);
      } else {
        return null; // No active standard
      }
    } catch (e) {
      throw Exception('Failed to get active milk quality standard: $e');
    }
  }

  // Get active milk quality standards
  Future<List<MilkQualityStandardsModel>>
      getActiveMilkQualityStandards() async {
    try {
      final snapshot = await _qualityStandardsCollection
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => MilkQualityStandardsModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active milk quality standards: $e');
    }
  }

  // Get milk quality standards by milk type - already using isActive correctly
  Future<MilkQualityStandardsModel?> getMilkQualityStandardsByType(
      MilkType type) async {
    try {
      final QuerySnapshot snapshot = await _qualityStandardsCollection
          .where('isActive', isEqualTo: true)
          .where('milkType', isEqualTo: type.toString().split('.').last)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return MilkQualityStandardsModel.fromMap(data, snapshot.docs.first.id);
    } catch (e) {
      throw Exception(
          'Failed to get milk quality standards by type ${type.toString().split('.').last}: $e');
    }
  }

  // Calculate pricing tier
  Future<String> calculatePricingTier(String receptionId) async {
    try {
      final reception = await getMilkReceptionById(receptionId);
      final standards = await getActiveMilkQualityStandards();

      if (standards.isEmpty) {
        return 'Standard';
      }

      // Use the first active standard
      final standard = standards.first;
      final premiumTier = standard.pricingTiers['premium'];
      final standardTier = standard.pricingTiers['standard'];

      if (premiumTier != null &&
          reception.fatPercentage >= premiumTier.minFatPercentage &&
          reception.proteinPercentage >= premiumTier.minProteinPercentage) {
        return 'Premium';
      } else if (standardTier != null &&
          reception.fatPercentage >= standardTier.minFatPercentage &&
          reception.proteinPercentage >= standardTier.minProteinPercentage) {
        return 'Standard';
      } else {
        return 'Basic';
      }
    } catch (e) {
      throw Exception('Failed to calculate pricing tier: $e');
    }
  }
}

@Riverpod(keepAlive: true)
MilkReceptionRepository milkReceptionRepository(Ref ref) {
  return MilkReceptionRepository(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  );
}

// Provider for the repository
final milkReceptionRepositoryProvider =
    Provider<MilkReceptionRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  return MilkReceptionRepository(firestore, auth);
});
