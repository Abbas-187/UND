import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../order_management/data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

// --- Base provider to fetch all customers ---
final allCustomersProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomers();
});

// --- Provider for filtering logic ---
final filteredCustomersProvider =
    FutureProvider.family<List<CustomerModel>, Map<String, String?>>(
        (ref, params) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomers(
      status: params['status'], customerType: params['customerType']);
});

// --- Provider for a single customer details ---
final customerDetailsProvider =
    FutureProvider.family<CustomerModel, String>((ref, customerId) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerById(customerId);
});
