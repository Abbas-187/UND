import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/maintenance_models.dart';
import '../../data/models/maintenance_record_model.dart';
import '../../data/repositories/equipment_maintenance_repository.dart';

part 'equipment_maintenance_provider.g.dart';

// Provider for all equipment
@riverpod
Future<List<EquipmentModel>> allEquipment(AllEquipmentRef ref) {
  final repository = ref.read(equipmentMaintenanceRepositoryProvider);
  return repository.getAllEquipment();
}

// Provider for equipment requiring maintenance
@riverpod
Future<List<EquipmentModel>> equipmentRequiringMaintenance(
    EquipmentRequiringMaintenanceRef ref) {
  final repository = ref.read(equipmentMaintenanceRepositoryProvider);
  return repository.getEquipmentRequiringMaintenance();
}

// Provider for equipment requiring sanitization
@riverpod
Future<List<EquipmentModel>> equipmentRequiringSanitization(
    EquipmentRequiringSanitizationRef ref) {
  final repository = ref.read(equipmentMaintenanceRepositoryProvider);
  return repository.getEquipmentRequiringSanitization();
}

// Provider for specific equipment
@riverpod
Future<EquipmentModel> equipment(EquipmentRef ref, String equipmentId) {
  final repository = ref.read(equipmentMaintenanceRepositoryProvider);
  return repository.getEquipmentById(equipmentId);
}

// Provider for equipment maintenance records
@riverpod
Future<List<MaintenanceRecordModel>> equipmentMaintenanceRecords(
    EquipmentMaintenanceRecordsRef ref, String equipmentId) {
  final repository = ref.read(equipmentMaintenanceRepositoryProvider);
  return repository.getMaintenanceRecordsForEquipment(equipmentId);
}

// Provider for upcoming maintenance records
@riverpod
Future<List<MaintenanceRecordModel>> upcomingMaintenanceRecords(
    UpcomingMaintenanceRecordsRef ref) {
  final repository = ref.read(equipmentMaintenanceRepositoryProvider);
  return repository.getUpcomingMaintenanceRecords();
}

// Provider for managing equipment
@Riverpod(keepAlive: true)
class EquipmentState extends _$EquipmentState {
  @override
  AsyncValue<EquipmentModel?> build(String? equipmentId) {
    _loadEquipment(equipmentId);
    return const AsyncValue.loading();
  }

  Future<void> _loadEquipment(String? equipmentId) async {
    if (equipmentId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      final equipment = await repository.getEquipmentById(equipmentId);
      state = AsyncValue.data(equipment);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Create a new equipment
  Future<String> createEquipment(EquipmentModel equipment) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      final id = await repository.createEquipment(equipment);

      // Invalidate providers
      ref.invalidate(allEquipmentProvider);

      // Update state if we're managing this specific equipment
      final updatedEquipment = await repository.getEquipmentById(id);
      state = AsyncValue.data(updatedEquipment);

      return id;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Update an existing equipment
  Future<void> updateEquipment(EquipmentModel equipment) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      await repository.updateEquipment(equipment);

      // Invalidate providers
      ref.invalidate(allEquipmentProvider);
      ref.invalidate(equipmentProvider(equipment.id));

      // If equipment needs maintenance, invalidate that provider too
      if (equipment.nextMaintenanceDate != null &&
          equipment.nextMaintenanceDate!.isBefore(DateTime.now())) {
        ref.invalidate(equipmentRequiringMaintenanceProvider);
      }

      // If equipment needs sanitization, invalidate that provider too
      if (equipment.requiresSanitization &&
          equipment.lastSanitizationDate != null) {
        final sanitizationInterval =
            Duration(hours: equipment.sanitizationIntervalHours);
        final nextSanitizationDate =
            equipment.lastSanitizationDate!.add(sanitizationInterval);

        if (nextSanitizationDate.isBefore(DateTime.now())) {
          ref.invalidate(equipmentRequiringSanitizationProvider);
        }
      }

      // Update state
      state = AsyncValue.data(equipment);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Update equipment status
  Future<void> updateStatus(String equipmentId, EquipmentStatus status) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      await repository.updateEquipmentStatus(
        equipmentId: equipmentId,
        status: status,
      );

      // Invalidate providers
      ref.invalidate(allEquipmentProvider);
      ref.invalidate(equipmentProvider(equipmentId));

      // Update state
      final updatedEquipment = await repository.getEquipmentById(equipmentId);
      state = AsyncValue.data(updatedEquipment);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

// Provider for managing maintenance records
@Riverpod(keepAlive: true)
class MaintenanceRecordState extends _$MaintenanceRecordState {
  @override
  AsyncValue<MaintenanceRecordModel?> build(String? recordId) {
    _loadRecord(recordId);
    return const AsyncValue.loading();
  }

  Future<void> _loadRecord(String? recordId) async {
    if (recordId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      final record = await repository.getMaintenanceRecordById(recordId);
      state = AsyncValue.data(record);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Create a new maintenance record
  Future<String> createRecord(MaintenanceRecordModel record) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      final id = await repository.createMaintenanceRecord(record);

      // Invalidate providers
      ref.invalidate(equipmentMaintenanceRecordsProvider(record.equipmentId));
      ref.invalidate(upcomingMaintenanceRecordsProvider);
      ref.invalidate(equipmentProvider(record.equipmentId));
      ref.invalidate(equipmentRequiringMaintenanceProvider);

      if (record.maintenanceType == MaintenanceType.preventive) {
        ref.invalidate(equipmentRequiringSanitizationProvider);
      }

      // Update state if we're managing this specific record
      final updatedRecord = await repository.getMaintenanceRecordById(id);
      state = AsyncValue.data(updatedRecord);

      return id;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Update an existing maintenance record
  Future<void> updateRecord(MaintenanceRecordModel record) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      await repository.updateMaintenanceRecord(record);

      // Invalidate providers
      ref.invalidate(equipmentMaintenanceRecordsProvider(record.equipmentId));
      ref.invalidate(upcomingMaintenanceRecordsProvider);
      ref.invalidate(equipmentProvider(record.equipmentId));

      if (record.status == MaintenanceStatus.completed) {
        ref.invalidate(equipmentRequiringMaintenanceProvider);
      }
      // Update state
      state = AsyncValue.data(record);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Schedule maintenance for all equipment
  Future<List<String>> scheduleMaintenanceForAll() async {
    try {
      final repository = ref.read(equipmentMaintenanceRepositoryProvider);
      final ids = await repository.createScheduledMaintenanceForAll();

      // Invalidate providers
      ref.invalidate(upcomingMaintenanceRecordsProvider);
      ref.invalidate(allEquipmentProvider);
      ref.invalidate(equipmentRequiringMaintenanceProvider);

      return ids;
    } catch (e) {
      rethrow;
    }
  }
}
