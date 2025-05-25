import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/location_optimization_criteria.dart';
import '../providers/location_optimization_provider.dart';
import '../utilities/warehouse_location_generator.dart';

/// Screen for optimizing warehouse item locations
class LocationOptimizationScreen extends ConsumerStatefulWidget {
  const LocationOptimizationScreen({super.key});

  @override
  ConsumerState<LocationOptimizationScreen> createState() =>
      _LocationOptimizationScreenState();
}

class _LocationOptimizationScreenState
    extends ConsumerState<LocationOptimizationScreen> {
  // Dropdown values
  String? _selectedWarehouse;
  String? _selectedCategory;
  String _selectedCriteriaType = 'default';

  @override
  void initState() {
    super.initState();
    _selectedWarehouse = 'wh1'; // Default warehouse
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationOptimizationProvider);
    final notifier = ref.read(locationOptimizationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Location Optimization'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOptimizationStatus(state),
                  const SizedBox(height: 16),
                  _buildOptimizationForm(state, notifier),
                  const SizedBox(height: 24),
                  _buildActionButtons(notifier),
                  const SizedBox(height: 24),
                  _buildOptimizationPreview(state),
                ],
              ),
            ),
    );
  }

  Widget _buildOptimizationStatus(LocationOptimizationState state) {
    // Show status, including last optimization date if available
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Optimization Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.lastOptimizationDate != null)
                  Text(
                    'Last Run: ${DateFormat('MMM d, yyyy').format(state.lastOptimizationDate!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red[50],
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              )
            else if (state.optimizedItemCount > 0)
              Text(
                'Items to optimize: ${state.optimizedItemCount}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text(
                'Run optimization to see results',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationForm(
    LocationOptimizationState state,
    LocationOptimizationNotifier notifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Optimization Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Warehouse Selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Warehouse',
                border: OutlineInputBorder(),
              ),
              value: _selectedWarehouse,
              items: [
                DropdownMenuItem(
                  value: 'wh1',
                  child: const Text('Main Warehouse'),
                ),
                DropdownMenuItem(
                  value: 'wh2',
                  child: const Text('Distribution Center'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedWarehouse = value;
                });
                if (value != null) {
                  notifier.setWarehouse(value);
                }
              },
            ),
            const SizedBox(height: 16),
            // Category Filter
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category Filter (Optional)',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                DropdownMenuItem(
                  value: 'dairy',
                  child: const Text('Dairy Products'),
                ),
                DropdownMenuItem(
                  value: 'ingredients',
                  child: const Text('Ingredients'),
                ),
                DropdownMenuItem(
                  value: 'packaging',
                  child: const Text('Packaging Materials'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                notifier.setCategoryFilter(value);
              },
            ),
            const SizedBox(height: 16),
            // Optimization Criteria
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Optimization Focus',
                border: OutlineInputBorder(),
              ),
              value: _selectedCriteriaType,
              items: const [
                DropdownMenuItem(
                  value: 'default',
                  child: Text('Balanced'),
                ),
                DropdownMenuItem(
                  value: 'picking',
                  child: Text('Optimize for Picking Efficiency'),
                ),
                DropdownMenuItem(
                  value: 'expiration',
                  child: Text('Optimize for Expiry Management'),
                ),
                DropdownMenuItem(
                  value: 'temperature',
                  child: Text('Optimize for Temperature Requirements'),
                ),
                DropdownMenuItem(
                  value: 'equal',
                  child: Text('Equal Weighting'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCriteriaType = value ?? 'default';
                });

                // Set the criteria based on selection
                LocationOptimizationCriteria criteria;
                switch (_selectedCriteriaType) {
                  case 'picking':
                    criteria = LocationOptimizationCriteria.pickingFocus();
                    break;
                  case 'expiration':
                    criteria = LocationOptimizationCriteria.expirationFocus();
                    break;
                  case 'temperature':
                    criteria = LocationOptimizationCriteria.temperatureFocus();
                    break;
                  case 'equal':
                    criteria = LocationOptimizationCriteria.equal();
                    break;
                  default:
                    criteria = const LocationOptimizationCriteria();
                }

                notifier.setCriteria(criteria);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LocationOptimizationNotifier notifier) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.preview),
              label: const Text('Preview Optimization'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => notifier.previewOptimization(),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Apply Optimization'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _showConfirmationDialog(notifier),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.add_location),
          label: const Text('Generate Test Locations'),
          onPressed: () => _generateSampleLocations(),
        )
      ],
    );
  }

  void _showConfirmationDialog(LocationOptimizationNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Location Optimization'),
        content: const Text(
          'This will update the storage locations of inventory items based on the optimization criteria. Would you like to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.applyOptimization();
            },
            child: const Text('Apply Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationPreview(LocationOptimizationState state) {
    // If no preview items, show a message
    if (state.previewItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Run preview to see suggested location changes'),
        ),
      );
    }

    // Otherwise show a list of preview items
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Location Changes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: state.previewItems.length,
              itemBuilder: (context, index) {
                final item = state.previewItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(item.item.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current: ${item.currentLocationName}'),
                        Text('Suggested: ${item.suggestedLocationName}'),
                      ],
                    ),
                    trailing: CircleAvatar(
                      backgroundColor:
                          _getImprovementColor(item.improvementScore),
                      child: Text(
                        '${(item.improvementScore * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getImprovementColor(double improvementScore) {
    if (improvementScore < 0.25) {
      return Colors.grey;
    } else if (improvementScore < 0.5) {
      return Colors.orange;
    } else if (improvementScore < 0.75) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  /// Generate sample warehouse locations for testing
  Future<void> _generateSampleLocations() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating sample warehouse locations...'),
          ],
        ),
      ),
    );

    try {
      // Get the generator
      final generator = ref.read(warehouseLocationGeneratorProvider);

      // Generate sample locations
      final createdIds = await generator.createSampleLocations();

      // Close the loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created ${createdIds.length} sample locations'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close the loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sample locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
