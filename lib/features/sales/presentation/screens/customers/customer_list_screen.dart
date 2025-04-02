import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/providers/customer_provider.dart';
import '../../../../../common/widgets/custom_search_bar.dart';
import '../../../../sales/data/models/customer_model.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  String _searchQuery = '';
  String? _selectedCustomerType;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final customersProvider = ref.watch(filteredCustomersProvider(
      status: _selectedStatus,
      customerType: _selectedCustomerType,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(filteredCustomersProvider(
              status: _selectedStatus,
              customerType: _selectedCustomerType,
            )),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hint: 'Search customers...',
              onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: customersProvider.when(
              data: (customers) {
                // Filter by search query if provided
                final filteredCustomers = _searchQuery.isEmpty
                    ? customers
                    : customers
                        .where((customer) =>
                            customer.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            customer.code
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text('No customers found',
                        style: TextStyle(fontSize: 16)),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getCustomerTypeColor(customer.customerType),
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code: ${customer.code}'),
                            if (customer.contactPerson != null)
                              Text('Contact: ${customer.contactPerson}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(customer.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                customer.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/sales/customers/details',
                          arguments: customer.id,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () =>
            Navigator.pushNamed(context, '/sales/customers/create'),
      ),
    );
  }

  Color _getCustomerTypeColor(String? customerType) {
    switch (customerType?.toLowerCase()) {
      case 'retail':
        return Colors.blue;
      case 'wholesale':
        return Colors.green;
      case 'distributor':
        return Colors.purple;
      case 'corporate':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Customers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Customer Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCustomerType,
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Types'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'retail',
                    child: Text('Retail'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'wholesale',
                    child: Text('Wholesale'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'distributor',
                    child: Text('Distributor'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'corporate',
                    child: Text('Corporate'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCustomerType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'inactive',
                    child: Text('Inactive'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'blocked',
                    child: Text('Blocked'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              OverflowBar(
                children: [
                  TextButton(
                    child: const Text('CLEAR FILTERS'),
                    onPressed: () {
                      setState(() {
                        _selectedCustomerType = null;
                        _selectedStatus = null;
                      });
                      this.setState(() {
                        _selectedCustomerType = null;
                        _selectedStatus = null;
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text('APPLY'),
                    onPressed: () {
                      Navigator.pop(context);
                      this.setState(() {}); // Refresh the main screen
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
