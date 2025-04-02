import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supplier_provider.dart';

class SupplierStatisticsCard extends ConsumerWidget {
  const SupplierStatisticsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersCountByCategory =
        ref.watch(suppliersCountByCategoryProvider);
    final allSuppliers = ref.watch(allSuppliersProvider);
    final topRatedSuppliers = ref.watch(topRatedSuppliersProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supplier Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    'Total Suppliers',
                    allSuppliers.when(
                      data: (suppliers) => suppliers.length.toString(),
                      loading: () => '-',
                      error: (_, __) => '0',
                    ),
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatTile(
                    context,
                    'Active Suppliers',
                    allSuppliers.when(
                      data: (suppliers) => suppliers
                          .where((supplier) => supplier.isActive)
                          .length
                          .toString(),
                      loading: () => '-',
                      error: (_, __) => '0',
                    ),
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatTile(
                    context,
                    'Top Rated',
                    topRatedSuppliers.when(
                      data: (suppliers) => suppliers.isNotEmpty
                          ? suppliers.first.rating.toString()
                          : '-',
                      loading: () => '-',
                      error: (_, __) => '-',
                    ),
                    Icons.star,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            suppliersCountByCategory.when(
              data: (categoryCounts) {
                if (categoryCounts.isEmpty) {
                  return const Center(child: Text('No categories yet'));
                }

                // Get the top 3 categories
                final sortedCategories = categoryCounts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final topCategories = sortedCategories.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Categories',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...topCategories.map((entry) => _buildCategoryItem(
                          context,
                          entry.key,
                          entry.value,
                          categoryCounts.values
                                  .reduce((a, b) => a > b ? a : b) +
                              0.0,
                        )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading categories'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String category,
    int count,
    double maxCount,
  ) {
    final percentage = count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
