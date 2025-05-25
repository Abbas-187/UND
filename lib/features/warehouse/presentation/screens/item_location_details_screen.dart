import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/entities/inventory_item.dart';
import '../../domain/providers/warehouse_location_repository_provider.dart';
import '../../domain/usecases/optimize_item_locations_usecase.dart';

/// Screen to show detailed optimization information for a specific item
class ItemLocationDetailsScreen extends ConsumerStatefulWidget {
  const ItemLocationDetailsScreen({
    super.key,
    required this.item,
  });

  final InventoryItem item;

  @override
  ConsumerState<ItemLocationDetailsScreen> createState() =>
      _ItemLocationDetailsScreenState();
}

class _ItemLocationDetailsScreenState
    extends ConsumerState<ItemLocationDetailsScreen> {
  bool _isLoading = false;
  String? _optimizedLocation;
  String? _errorMessage;
  Map<String, dynamic>? _locationDetails;
  double _overallScore = 0.0;
  List<Map<String, dynamic>> _scoringFactors = [];

  @override
  void initState() {
    super.initState();
    _loadOptimizedLocation();
  }

  // Load optimized location for the item
  Future<void> _loadOptimizedLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get optimize location usecase
      final optimizeUseCase = ref.read(optimizeItemLocationsUseCaseProvider);

      // Run optimization for just this item
      await optimizeUseCase.execute(
        itemIds: [widget.item.id],
        applyChanges: false,
      );

      // For demo purposes, we'll create a simulated optimized location
      // In a real implementation, we would get this from the optimization results
      final locationRepository = ref.read(warehouseLocationRepositoryProvider);

      // Simulate getting location details
      await Future.delayed(const Duration(milliseconds: 500));

      final needsRefrigeration =
          widget.item.additionalAttributes?['needsRefrigeration'] as bool? ??
              false;
      final isFrozen =
          widget.item.additionalAttributes?['isFrozen'] as bool? ?? false;

      // Create a plausible new location based on item characteristics
      String? newLocation;
      if (isFrozen) {
        newLocation = 'wh1/zone-c/aisle2/rack3/bin2';
      } else if (needsRefrigeration) {
        newLocation = 'wh1/zone-b/aisle1/rack2/bin4';
      } else {
        newLocation = 'wh1/zone-a/aisle3/rack1/bin5';
      }

      // If the new location is the same as current, use a different one for demo
      if (newLocation == widget.item.location) {
        newLocation = 'wh1/zone-a/aisle2/rack4/bin1';
      }

      // Set location details
      _locationDetails = {
        'zone': newLocation.split('/')[1],
        'aisle': newLocation.split('/')[2],
        'rack': newLocation.split('/')[3],
        'bin': newLocation.split('/')[4],
        'temperatureRange': isFrozen
            ? '-18°C to -22°C'
            : needsRefrigeration
                ? '2°C to 6°C'
                : '15°C to 25°C',
        'humidityRange': '45% to 55%',
        'capacity': '85%',
      };

      // Set scoring factors
      _scoringFactors = [
        {
          'name': 'Picking Frequency',
          'score': 0.75,
          'weight': 0.4,
          'description': 'Based on order history and pick frequency',
        },
        {
          'name': 'Turnover Rate',
          'score': 0.65,
          'weight': 0.3,
          'description': 'Based on inventory movement patterns',
        },
        {
          'name': 'Travel Distance',
          'score': 0.80,
          'weight': 0.2,
          'description': 'Proximity to receiving/shipping areas',
        },
        {
          'name': 'Temperature Compatibility',
          'score': 1.0,
          'weight': 0.1,
          'description': 'Suitable for item temperature requirements',
        },
      ];

      // Calculate overall score
      _overallScore = _scoringFactors.fold<double>(
        0.0,
        (sum, factor) =>
            sum + (factor['score'] as double) * (factor['weight'] as double),
      );

      setState(() {
        _optimizedLocation = newLocation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error calculating optimized location: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Details: ${widget.item.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildItemInfo(),
                      const SizedBox(height: 16),
                      _buildLocationComparison(),
                      const SizedBox(height: 24),
                      _buildOptimizationScores(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildItemInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[700],
                  child: Icon(
                    _getItemIcon(),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Category: ${widget.item.category}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  'Quantity',
                  '${widget.item.quantity} ${widget.item.unit}',
                  Colors.blue[100]!,
                ),
                _buildInfoChip(
                  'Reorder Point',
                  widget.item.reorderPoint.toString(),
                  Colors.orange[100]!,
                ),
                _buildInfoChip(
                  'Temperature',
                  _getTemperatureRequirement(),
                  Colors.green[100]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildLocationComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item.location,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _parseLocationDetails(widget.item.location),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey[400],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optimized Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _optimizedLocation ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _locationDetails != null
                          ? _buildLocationDetails(_locationDetails!)
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _parseLocationDetails(String location) {
    // Try to parse location string into parts
    final parts = location.split('/');
    if (parts.length >= 4) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zone: ${parts[1]}'),
          Text('Aisle: ${parts[2]}'),
          Text('Rack: ${parts[3]}'),
          if (parts.length > 4) Text('Bin: ${parts[4]}'),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildLocationDetails(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Zone: ${details['zone']}'),
        Text('Aisle: ${details['aisle']}'),
        Text('Rack: ${details['rack']}'),
        Text('Bin: ${details['bin']}'),
        Text('Temperature: ${details['temperatureRange']}'),
      ],
    );
  }

  Widget _buildOptimizationScores() {
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
                  'Optimization Factors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: _getScoreColor(_overallScore),
                  child: Text(
                    '${(_overallScore * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._scoringFactors.map((factor) => _buildScoringFactor(factor)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringFactor(Map<String, dynamic> factor) {
    final score = factor['score'] as double;
    final weight = factor['weight'] as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                factor['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Weight: ${(weight * 100).round()}%',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: score,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(score * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            factor['description'] as String,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Apply Recommended Location'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _optimizedLocation == null
              ? null
              : () => _applyOptimizedLocation(),
        ),
      ],
    );
  }

  Future<void> _applyOptimizedLocation() async {
    if (_optimizedLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get optimize location usecase
      final optimizeUseCase = ref.read(optimizeItemLocationsUseCaseProvider);

      // Run optimization for just this item with apply changes = true
      await optimizeUseCase.execute(
        itemIds: [widget.item.id],
        applyChanges: true,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Return to previous screen
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error applying optimized location: $e';
        _isLoading = false;
      });
    }
  }

  IconData _getItemIcon() {
    final needsRefrigeration =
        widget.item.additionalAttributes?['needsRefrigeration'] as bool? ??
            false;
    final isFrozen =
        widget.item.additionalAttributes?['isFrozen'] as bool? ?? false;

    if (isFrozen) {
      return Icons.ac_unit;
    } else if (needsRefrigeration) {
      return Icons.kitchen;
    } else {
      return Icons.inventory;
    }
  }

  String _getTemperatureRequirement() {
    final needsRefrigeration =
        widget.item.additionalAttributes?['needsRefrigeration'] as bool? ??
            false;
    final isFrozen =
        widget.item.additionalAttributes?['isFrozen'] as bool? ?? false;

    if (isFrozen) {
      return 'Frozen';
    } else if (needsRefrigeration) {
      return 'Refrigerated';
    } else {
      return 'Ambient';
    }
  }

  Color _getScoreColor(double score) {
    if (score < 0.3) {
      return Colors.red;
    } else if (score < 0.6) {
      return Colors.orange;
    } else if (score < 0.8) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }
}
