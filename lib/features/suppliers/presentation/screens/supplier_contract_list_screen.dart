import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/supplier_contract.dart';
import '../providers/supplier_contract_provider.dart';

class SupplierContractListScreen extends ConsumerStatefulWidget {
  const SupplierContractListScreen({super.key, this.supplierId});
  final String? supplierId;

  @override
  ConsumerState<SupplierContractListScreen> createState() =>
      _SupplierContractListScreenState();
}

class _SupplierContractListScreenState
    extends ConsumerState<SupplierContractListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref
        .read(contractFilterNotifierProvider.notifier)
        .updateSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final contractsProvider = widget.supplierId != null
        ? supplierContractsProvider(widget.supplierId!)
        : filteredContractsProvider;

    final contracts = ref.watch(contractsProvider);
    final filterNotifier = ref.watch(contractFilterNotifierProvider.notifier);
    final filter = ref.watch(contractFilterNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Contracts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotifications(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contracts',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (filter.isActive != null ||
              filter.startDateFrom != null ||
              filter.endDateFrom != null ||
              (filter.contractTypes != null &&
                  filter.contractTypes!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (filter.isActive != null)
                            _buildFilterChip(
                              'Status: ${filter.isActive! ? 'Active' : 'Inactive'}',
                              () => filterNotifier.setActiveFilter(null),
                            ),
                          if (filter.startDateFrom != null)
                            _buildFilterChip(
                              'Start: ${DateFormat('dd/MM/yyyy').format(filter.startDateFrom!)}',
                              () => filterNotifier.setDateRanges(
                                  startDateFrom: null),
                            ),
                          if (filter.endDateFrom != null)
                            _buildFilterChip(
                              'End: ${DateFormat('dd/MM/yyyy').format(filter.endDateFrom!)}',
                              () => filterNotifier.setDateRanges(
                                  endDateFrom: null),
                            ),
                          if (filter.contractTypes != null &&
                              filter.contractTypes!.isNotEmpty)
                            _buildFilterChip(
                              'Types: ${filter.contractTypes!.join(', ')}',
                              () => filterNotifier.setContractTypes(null),
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      filterNotifier.resetFilters();
                      _searchController.clear();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: contracts.when(
              data: (contractsList) {
                if (contractsList.isEmpty) {
                  return const Center(
                    child: Text('No contracts found'),
                  );
                }
                return ListView.builder(
                  itemCount: contractsList.length,
                  itemBuilder: (context, index) {
                    final contract = contractsList[index];
                    return _buildContractCard(context, contract);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/suppliers/contracts/detail');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onRemove,
      ),
    );
  }

  Widget _buildContractCard(BuildContext context, SupplierContract contract) {
    final formatter = NumberFormat.currency(symbol: contract.currency);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Determine status color
    Color statusColor;
    switch (contract.status) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Expiring Soon':
        statusColor = Colors.orange;
        break;
      case 'Expired':
        statusColor = Colors.red;
        break;
      case 'Pending':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          context.go('/suppliers/contracts/detail',
              extra: {'contractId': contract.id});
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      contract.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1 * 255),
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      contract.status,
                      style: textTheme.bodySmall?.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Contract #${contract.contractNumber}',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    contract.contractType,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Supplier: ${contract.supplierName}',
                      style: textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatter.format(contract.value),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4.0),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(contract.startDate)} - ${DateFormat('dd/MM/yyyy').format(contract.endDate)}',
                    style: textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (contract.attachments.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 16),
                        const SizedBox(width: 4.0),
                        Text(
                          '${contract.attachments.length} attachment${contract.attachments.length > 1 ? 's' : ''}',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
              if (contract.tags.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: contract.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1 * 255),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        tag,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return ContractFilterBottomSheet();
      },
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const ContractNotificationsDialog();
      },
    );
  }
}

class ContractFilterBottomSheet extends ConsumerStatefulWidget {
  const ContractFilterBottomSheet({super.key});

  @override
  ConsumerState<ContractFilterBottomSheet> createState() =>
      _ContractFilterBottomSheetState();
}

class _ContractFilterBottomSheetState
    extends ConsumerState<ContractFilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  bool? isActive;
  List<String> selectedTypes = [];
  final List<String> availableTypes = [
    'Purchase',
    'Service',
    'Distribution',
    'Manufacturing',
    'License',
    'Consulting',
    'Maintenance',
  ];

  @override
  void initState() {
    super.initState();
    final filter = ref.read(contractFilterNotifierProvider);
    startDate = filter.startDateFrom;
    endDate = filter.endDateFrom;
    isActive = filter.isActive;
    selectedTypes = filter.contractTypes?.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter Contracts',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref
                      .read(contractFilterNotifierProvider.notifier)
                      .resetFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Active'),
                selected: isActive == true,
                onSelected: (selected) {
                  setState(() {
                    isActive = selected ? true : null;
                  });
                },
              ),
              const SizedBox(width: 8.0),
              ChoiceChip(
                label: const Text('Inactive'),
                selected: isActive == false,
                onSelected: (selected) {
                  setState(() {
                    isActive = selected ? false : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Start Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                      });
                    }
                  },
                  child: Text(
                    startDate != null
                        ? DateFormat('dd/MM/yyyy').format(startDate!)
                        : 'Select Date',
                  ),
                ),
              ),
              if (startDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      startDate = null;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'End Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        endDate = picked;
                      });
                    }
                  },
                  child: Text(
                    endDate != null
                        ? DateFormat('dd/MM/yyyy').format(endDate!)
                        : 'Select Date',
                  ),
                ),
              ),
              if (endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      endDate = null;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Contract Types',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: availableTypes.map((type) {
              return FilterChip(
                label: Text(type),
                selected: selectedTypes.contains(type),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedTypes.add(type);
                    } else {
                      selectedTypes.remove(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final filterNotifier =
                    ref.read(contractFilterNotifierProvider.notifier);
                filterNotifier.setActiveFilter(isActive);
                filterNotifier.setDateRanges(
                  startDateFrom: startDate,
                  endDateFrom: endDate,
                );
                filterNotifier.setContractTypes(
                  selectedTypes.isEmpty ? null : selectedTypes,
                );
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class ContractNotificationsDialog extends ConsumerWidget {
  const ContractNotificationsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(contractNotificationsProvider);

    return AlertDialog(
      title: const Text('Contract Notifications'),
      content: SizedBox(
        width: double.maxFinite,
        child: notifications.when(
          data: (contracts) {
            if (contracts.isEmpty) {
              return const Center(
                child: Text('No notifications at this time'),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final contract = contracts[index];
                final daysLeft =
                    contract.endDate.difference(DateTime.now()).inDays;

                String message;
                IconData icon;
                Color color;

                if (contract.needsRenewalNotice()) {
                  message = 'Renewal notice needed ($daysLeft days left)';
                  icon = Icons.autorenew;
                  color = Colors.blue;
                } else {
                  message = 'Expiring in $daysLeft days';
                  icon = Icons.warning;
                  color = Colors.orange;
                }

                return ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(contract.title),
                  subtitle: Text(message),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/suppliers/contracts/detail',
                        extra: {'contractId': contract.id});
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
