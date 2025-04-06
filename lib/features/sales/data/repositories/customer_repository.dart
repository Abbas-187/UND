import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/sales_data_source.dart';
import '../models/customer_model.dart';

part 'customer_repository.g.dart';

// Interface
abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers({
    String? status,
    String? customerType,
  });
  Future<CustomerModel> getCustomerById(String id);
  Future<String> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
  Future<List<CustomerModel>> searchCustomers(String query);
}

// Implementation
class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dataSource);
  final SalesDataSource _dataSource;

  @override
  Future<List<CustomerModel>> getCustomers({
    String? status,
    String? customerType,
  }) =>
      _dataSource.getCustomers(status: status, customerType: customerType);

  @override
  Future<CustomerModel> getCustomerById(String id) =>
      _dataSource.getCustomerById(id);

  @override
  Future<String> createCustomer(CustomerModel customer) =>
      _dataSource.createCustomer(customer);

  @override
  Future<void> updateCustomer(CustomerModel customer) =>
      _dataSource.updateCustomer(customer);

  @override
  Future<void> deleteCustomer(String customerId) =>
      _dataSource.deleteCustomer(customerId);

  @override
  Future<List<CustomerModel>> searchCustomers(String query) =>
      _dataSource.searchCustomers(query);
}

// Provider for the data source (assuming Firestore implementation)
@riverpod
SalesDataSource salesDataSource(SalesDataSourceRef ref) {
  return FirestoreSalesDataSource();
}

// Provider for the repository
@riverpod
CustomerRepository customerRepository(CustomerRepositoryRef ref) {
  final dataSource = ref.watch(salesDataSourceProvider);
  return CustomerRepositoryImpl(dataSource);
}
