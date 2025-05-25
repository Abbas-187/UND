import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/inventory_settings_repository.dart';

final inventorySettingsRepositoryProvider =
    Provider<InventorySettingsRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return InventorySettingsRepository(firestore);
});
