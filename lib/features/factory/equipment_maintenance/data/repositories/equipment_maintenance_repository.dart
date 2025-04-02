import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/equipment_model.dart';
import '../models/maintenance_models.dart';
import '../models/maintenance_record_model.dart';

part 'equipment_maintenance_repository.g.dart';

class EquipmentMaintenanceRepository {
  EquipmentMaintenanceRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collection references
  CollectionReference get _equipmentCollection =>
      _firestore.collection('equipment');

  CollectionReference get _maintenanceRecordsCollection =>
      _firestore.collection('maintenanceRecords');

  // Get all equipment
  Future<List<EquipmentModel>> getAllEquipment() async {
    try {
      final QuerySnapshot snapshot = await _equipmentCollection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EquipmentModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get equipment: $e');
    }
  }

  // Get equipment by type
  Future<List<EquipmentModel>> getEquipmentByType(EquipmentType type) async {
    try {
      final QuerySnapshot snapshot = await _equipmentCollection
          .where('type', isEqualTo: type.toString().split('.').last)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EquipmentModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get equipment by type: $e');
    }
  }

  // Get equipment by status
  Future<List<EquipmentModel>> getEquipmentByStatus(
      EquipmentStatus status) async {
    try {
      final QuerySnapshot snapshot = await _equipmentCollection
          .where('status', isEqualTo: status.toString().split('.').last)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EquipmentModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get equipment by status: $e');
    }
  }

  // Get equipment requiring maintenance
  Future<List<EquipmentModel>> getEquipmentRequiringMaintenance() async {
    try {
      final now = DateTime.now();

      final QuerySnapshot snapshot = await _equipmentCollection
          .where('nextMaintenanceDate', isLessThanOrEqualTo: now)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EquipmentModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get equipment requiring maintenance: $e');
    }
  }

  // Get equipment requiring sanitization
  Future<List<EquipmentModel>> getEquipmentRequiringSanitization() async {
    try {
      final now = DateTime.now();

      // Get all equipment that requires sanitization
      final QuerySnapshot snapshot = await _equipmentCollection
          .where('requiresSanitization', isEqualTo: true)
          .get();

      final allEquipment = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EquipmentModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();

      // Filter only those that need sanitization now
      return allEquipment.where((equipment) {
        if (equipment.lastSanitizationDate == null) {
          return true; // Never sanitized
        }

        final sanitizationInterval =
            Duration(hours: equipment.sanitizationIntervalHours);
        final nextSanitizationDate =
            equipment.lastSanitizationDate!.add(sanitizationInterval);

        return nextSanitizationDate.isBefore(now);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get equipment requiring sanitization: $e');
    }
  }

  // Get equipment by ID
  Future<EquipmentModel> getEquipmentById(String id) async {
    try {
      final DocumentSnapshot doc = await _equipmentCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Equipment not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return EquipmentModel.fromJson({
        ...data,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to get equipment: $e');
    }
  }

  // Create equipment
  Future<String> createEquipment(EquipmentModel equipment) async {
    try {
      final equipmentJson = equipment.toJson();
      equipmentJson.remove('id');

      final DocumentReference docRef =
          await _equipmentCollection.add(equipmentJson);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create equipment: $e');
    }
  }

  // Update equipment
  Future<void> updateEquipment(EquipmentModel equipment) async {
    try {
      final equipmentJson = equipment.toJson();
      equipmentJson.remove('id');

      await _equipmentCollection.doc(equipment.id).update(equipmentJson);
    } catch (e) {
      throw Exception('Failed to update equipment: $e');
    }
  }

  // Update equipment status
  Future<void> updateEquipmentStatus({
    required String equipmentId,
    required EquipmentStatus status,
  }) async {
    try {
      await _equipmentCollection.doc(equipmentId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update equipment status: $e');
    }
  }

  // Get maintenance records for equipment
  Future<List<MaintenanceRecordModel>> getMaintenanceRecordsForEquipment(
      String equipmentId) async {
    try {
      final QuerySnapshot snapshot = await _maintenanceRecordsCollection
          .where('equipmentId', isEqualTo: equipmentId)
          .orderBy('scheduledDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MaintenanceRecordModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get maintenance records: $e');
    }
  }

  // Get upcoming maintenance records.  MaintenanceStatus.delayed does not exist
  Future<List<MaintenanceRecordModel>> getUpcomingMaintenanceRecords() async {
    try {
      final now = DateTime.now();

      final QuerySnapshot snapshot = await _maintenanceRecordsCollection
          .where('scheduledDate', isGreaterThanOrEqualTo: now)
          .where('status', whereIn: [
            MaintenanceStatus.scheduled.toString().split('.').last,
            MaintenanceStatus.inProgress.toString().split('.').last,
          ])
          .orderBy('scheduledDate')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MaintenanceRecordModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming maintenance records: $e');
    }
  }

  // Get maintenance record by ID
  Future<MaintenanceRecordModel> getMaintenanceRecordById(String id) async {
    try {
      final DocumentSnapshot doc =
          await _maintenanceRecordsCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Maintenance record not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return MaintenanceRecordModel.fromJson({
        ...data,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to get maintenance record: $e');
    }
  }

  // Create maintenance record
  Future<String> createMaintenanceRecord(MaintenanceRecordModel record) async {
    try {
      final recordJson = record.toJson();
      recordJson.remove('id');

      final DocumentReference docRef =
          await _maintenanceRecordsCollection.add(recordJson);

      // Update the equipment's last and next maintenance dates if needed
      if (record.maintenanceType != MaintenanceType.preventive) {
        final equipment = await getEquipmentById(record.equipmentId);
        final nextMaintenanceDate = DateTime.now()
            .add(Duration(days: equipment.maintenanceIntervalDays));

        await _equipmentCollection.doc(record.equipmentId).update({
          'nextMaintenanceDate': nextMaintenanceDate,
          'lastMaintenanceDate': FieldValue.serverTimestamp(),
        });
      } else {
        // If it's a sanitization record, update the sanitization date
        await _equipmentCollection.doc(record.equipmentId).update({
          'lastSanitizationDate': FieldValue.serverTimestamp(),
        });
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create maintenance record: $e');
    }
  }

  // Update maintenance record
  Future<void> updateMaintenanceRecord(MaintenanceRecordModel record) async {
    try {
      final recordJson = record.toJson();
      recordJson.remove('id');

      await _maintenanceRecordsCollection.doc(record.id).update(recordJson);

      // If record is marked as completed, update the equipment
      if (record.status == MaintenanceStatus.completed &&
          record.completionDate != null) {
        final equipment = await getEquipmentById(record.equipmentId);

        if (record.maintenanceType == MaintenanceType.preventive) {
          // Update maintenance dates
          final nextMaintenanceDate = record.completionDate!
              .add(Duration(days: equipment.maintenanceIntervalDays));
          await _equipmentCollection.doc(record.equipmentId).update({
            'lastMaintenanceDate': record.completionDate!.toIso8601String(),
            'nextMaintenanceDate': nextMaintenanceDate.toIso8601String(),
            'status': EquipmentStatus.operational.toString().split('.').last,
          });
        } else {
          // Update sanitization date
          await _equipmentCollection.doc(record.equipmentId).update({
            'lastSanitizationDate': record.completionDate!.toIso8601String(),
            'status': EquipmentStatus.operational.toString().split('.').last,
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update maintenance record: $e');
    }
  }

  // Create scheduled maintenance for all equipment
  Future<List<String>> createScheduledMaintenanceForAll() async {
    try {
      final equipment = await getAllEquipment();
      final List<String> createdRecordIds = [];
      final currentUser = _auth.currentUser;

      for (final equip in equipment) {
        // Skip equipment already scheduled for maintenance
        final existing = await _maintenanceRecordsCollection
            .where('equipmentId', isEqualTo: equip.id)
            .where('status', whereIn: [
          MaintenanceStatus.scheduled.toString().split('.').last,
          MaintenanceStatus.inProgress.toString().split('.').last,
        ]).get();

        if (existing.docs.isNotEmpty) {
          continue;
        }

        // Create preventive maintenance record
        final record = MaintenanceRecordModel(
          id: '',
          equipmentId: equip.id,
          equipmentName: equip.name,
          equipmentType: equip.type,
          scheduledDate: equip.nextMaintenanceDate ??
              DateTime.now().add(const Duration(days: 7)),
          completionDate: null,
          maintenanceType: MaintenanceType.preventive,
          description: 'Scheduled preventive maintenance for ${equip.name}',
          status: MaintenanceStatus.scheduled,
          performedById: equip.responsiblePersonId ?? currentUser?.uid ?? '',
          performedByName: equip.responsiblePersonName ??
              currentUser?.displayName ??
              'Maintenance Staff',
          notes: 'Automatically scheduled maintenance',
          partsReplaced: [],
          downtimeHours: null,
          metadata: {},
        );

        final id = await createMaintenanceRecord(record);
        createdRecordIds.add(id);
      }

      return createdRecordIds;
    } catch (e) {
      throw Exception('Failed to create scheduled maintenance: $e');
    }
  }
}

@riverpod
EquipmentMaintenanceRepository equipmentMaintenanceRepository(
    EquipmentMaintenanceRepositoryRef ref) {
  return EquipmentMaintenanceRepository();
}
