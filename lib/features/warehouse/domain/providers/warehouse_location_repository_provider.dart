import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_warehouse_location_repository.dart';
import '../../domain/repositories/warehouse_location_repository.dart';

/// Provider for warehouse location repository
final warehouseLocationRepositoryProvider =
    Provider<WarehouseLocationRepository>((ref) {
  return FirestoreWarehouseLocationRepository();
});
