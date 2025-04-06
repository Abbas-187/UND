import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/supplier.dart';
import '../providers/supplier_provider.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSuppliers = ref.watch(filteredSuppliersProvider);
    final filter = ref.watch(supplierFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.supplierEdit,
                arguments: SupplierEditArgs(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search suppliers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              onChanged: (value) {
                ref.read(supplierFilterProvider.notifier).state =
                    filter.copyWith(searchQuery: value);
              },
            ),
          ),

          // Status filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Status:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter.isActive == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(supplierFilterProvider.notifier).state =
                          filter.copyWith(isActive: null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Active'),
                  selected: filter.isActive == true,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(supplierFilterProvider.notifier).state =
                          filter.copyWith(isActive: true);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Inactive'),
                  selected: filter.isActive == false,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(supplierFilterProvider.notifier).state =
                          filter.copyWith(isActive: false);
                    }
                  },
                ),
              ],
            ),
          ),

          // Suppliers list
          Expanded(
            child: filteredSuppliers.when(
              data: (suppliers) => _buildSuppliersList(context, suppliers),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersList(BuildContext context, List<Supplier> suppliers) {
    if (suppliers.isEmpty) {
      return const Center(
        child: Text('No suppliers found'),
      );
    }

    return ListView.builder(
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return _buildSupplierCard(context, supplier);
      },
    );
  }

  Widget _buildSupplierCard(BuildContext context, Supplier supplier) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.supplierDetails,
            arguments: SupplierDetailsArgs(supplierId: supplier.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          supplier.contactPerson,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: supplier.isActive
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      supplier.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: supplier.isActive
                            ? Colors.green.shade900
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email: ${supplier.email}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Phone: ${supplier.phone}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _buildRatingStars(supplier.rating),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: supplier.productCategories.map((category) {
                  return Chip(
                    label: Text(
                      category,
                      style: const TextStyle(fontSize: 12),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}
