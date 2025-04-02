import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

part 'customer_provider.g.dart';

// --- Base provider to fetch all customers ---
@riverpod
Future<List<CustomerModel>> allCustomers(AllCustomersRef ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomers();
}

// --- Provider for filtering logic ---
// Using family to pass filter parameters
@riverpod
Future<List<CustomerModel>> filteredCustomers(
  FilteredCustomersRef ref, {
  String? status,
  String? customerType,
}) async {
  final repository = ref.watch(customerRepositoryProvider);
  // Fetch with filters applied directly at the repository/datasource level
  return repository.getCustomers(status: status, customerType: customerType);
}

// --- Provider for a single customer details ---
@riverpod
Future<CustomerModel> customerDetails(
    CustomerDetailsRef ref, String customerId) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerById(customerId);
}

// --- StateNotifier for managing customer creation/update/delete ---
// This allows UI to call methods and handle loading/error states
@riverpod
class CustomerActions extends _$CustomerActions {
  @override
  AsyncValue<void> build() =>
      const AsyncData(null); // Initial state, no action running

  Future<void> createCustomer(CustomerModel customer) async {
    final repository = ref.read(customerRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.createCustomer(customer);
      ref.invalidate(allCustomersProvider); // Invalidate list to refresh
      ref.invalidate(filteredCustomersProvider); // Invalidate filtered list
    });
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final repository = ref.read(customerRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.updateCustomer(customer);
      ref.invalidate(allCustomersProvider);
      ref.invalidate(filteredCustomersProvider);
      // Safely handle null id
      final customerId = customer.id;
      if (customerId != null) {
        ref.invalidate(customerDetailsProvider(customerId));
      }
    });
  }

  Future<void> deleteCustomer(String customerId) async {
    final repository = ref.read(customerRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.deleteCustomer(customerId);
      ref.invalidate(allCustomersProvider);
      ref.invalidate(filteredCustomersProvider);
    });
  }
}
