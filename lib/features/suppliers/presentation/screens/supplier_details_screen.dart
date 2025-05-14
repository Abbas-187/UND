import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/detail_appbar.dart';
import '../../../../core/routes/app_go_router.dart';
import '../../domain/entities/supplier.dart';
import '../providers/supplier_provider.dart';

class SupplierDetailsScreen extends ConsumerWidget {
  const SupplierDetailsScreen({
    super.key,
    required this.supplierId,
  });
  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsyncValue = ref.watch(supplierProvider(supplierId));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        GoRouter.of(context).go(AppRoutes.suppliers);
      },
      child: Scaffold(
        appBar: DetailAppBar(
          title: 'Supplier Details',
          actions: [
            supplierAsyncValue.when(
              data: (supplier) => IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.push(AppRoutes.supplierEdit,
                      extra: SupplierEditArgs(supplier: supplier));
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        body: supplierAsyncValue.when(
          data: (supplier) => _buildSupplierDetails(context, supplier),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildSupplierDetails(BuildContext context, Supplier supplier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, supplier),
          const SizedBox(height: 24),
          _buildContactInfo(context, supplier),
          const SizedBox(height: 24),
          _buildAddressInfo(context, supplier),
          const SizedBox(height: 24),
          _buildProductCategories(context, supplier),
          const SizedBox(height: 24),
          _buildAdditionalInfo(context, supplier),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Supplier supplier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    supplier.name.isNotEmpty
                        ? supplier.name.substring(0, 1).toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildRatingStars(supplier.rating),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Last Updated: ${DateFormat.yMMMd().format(supplier.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Supplier supplier) {
    return _buildSection(
      context,
      'Contact Information',
      Icons.contact_phone,
      [
        _buildInfoRow(context, 'Contact Person', supplier.contactPerson),
        _buildInfoRow(context, 'Email', supplier.email),
        _buildInfoRow(context, 'Phone', supplier.phone),
        if (supplier.website.isNotEmpty)
          _buildInfoRow(context, 'Website', supplier.website),
      ],
    );
  }

  Widget _buildAddressInfo(BuildContext context, Supplier supplier) {
    return _buildSection(
      context,
      'Address',
      Icons.location_on,
      [
        _buildInfoRow(context, 'Street', supplier.address.street),
        _buildInfoRow(context, 'City', supplier.address.city),
        _buildInfoRow(context, 'State', supplier.address.state),
        _buildInfoRow(context, 'Zip Code', supplier.address.zipCode),
        _buildInfoRow(context, 'Country', supplier.address.country),
      ],
    );
  }

  Widget _buildProductCategories(BuildContext context, Supplier supplier) {
    return _buildSection(
      context,
      'Product Categories',
      Icons.category,
      [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: supplier.productCategories.map((category) {
            return Chip(
              label: Text(category),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, Supplier supplier) {
    final items = <Widget>[];

    if (supplier.notes.isNotEmpty) {
      items.add(_buildInfoRow(context, 'Notes', supplier.notes));
    }

    if (supplier.taxId.isNotEmpty) {
      items.add(_buildInfoRow(context, 'Tax ID', supplier.taxId));
    }

    if (supplier.paymentTerms.isNotEmpty) {
      items.add(_buildInfoRow(context, 'Payment Terms', supplier.paymentTerms));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      context,
      'Additional Information',
      Icons.info_outline,
      items,
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
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

class SupplierEditArgs {
  SupplierEditArgs({required this.supplier});
  final Supplier supplier;
}
