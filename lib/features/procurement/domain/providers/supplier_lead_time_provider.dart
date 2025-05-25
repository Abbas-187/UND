import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supplier_lead_time_repository_impl.dart';
import '../repositories/supplier_lead_time_repository.dart';

/// Provider for the supplier lead time repository
final supplierLeadTimeRepositoryProvider =
    Provider<SupplierLeadTimeRepository>((ref) {
  return SupplierLeadTimeRepositoryImpl();
});
