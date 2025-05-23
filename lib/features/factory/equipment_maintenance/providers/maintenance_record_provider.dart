import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/maintenance_record_model.dart';

final maintenanceRecordProvider = StateNotifierProvider<
    MaintenanceRecordNotifier, AsyncValue<List<MaintenanceRecordModel>>>((ref) {
  final repository = ref.watch(maintenanceRecordRepositoryProvider);
  return MaintenanceRecordNotifier(repository);
});

class MaintenanceRecordNotifier
    extends StateNotifier<AsyncValue<List<MaintenanceRecordModel>>> {

  MaintenanceRecordNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadMaintenanceRecords();
  }
  final MaintenanceRecordRepository _repository;

  Future<void> _loadMaintenanceRecords() async {
    try {
      final records = await _repository.getMaintenanceRecords();
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createMaintenanceRecord(MaintenanceRecordModel record) async {
    try {
      await _repository.createMaintenanceRecord(record);
      _loadMaintenanceRecords();
    } catch (e) {
      rethrow;
    }
  }
}

final maintenanceRecordRepositoryProvider =
    Provider<MaintenanceRecordRepository>((ref) {
  // Implement the actual repository here
  return MaintenanceRecordRepository();
});

class MaintenanceRecordRepository {
  // Implement the actual repository methods here
  Future<List<MaintenanceRecordModel>> getMaintenanceRecords() async {
    // Fetch maintenance records from the data source
    throw UnimplementedError();
  }

  Future<void> createMaintenanceRecord(MaintenanceRecordModel record) async {
    // Create a new maintenance record in the data source
    throw UnimplementedError();
  }
}
