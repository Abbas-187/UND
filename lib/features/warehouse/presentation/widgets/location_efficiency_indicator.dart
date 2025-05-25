import 'package:flutter/material.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../routes/location_optimization_routes.dart';

/// Widget to display location efficiency information for an inventory item
class LocationEfficiencyIndicator extends StatelessWidget {
  const LocationEfficiencyIndicator({
    super.key,
    required this.item,
    this.onOptimized,
  });

  final InventoryItem item;
  final Function(bool)? onOptimized;

  @override
  Widget build(BuildContext context) {
    // Calculate location efficiency score (mock implementation)
    final score = _calculateLocationScore();

    return GestureDetector(
      onTap: () async {
        final optimized = await Navigator.of(context).push<bool>(
          LocationOptimizationRoutes.itemLocationDetailsScreen(item: item),
        );

        if (optimized == true && onOptimized != null) {
          onOptimized!(true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _getScoreColor(score),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${(score * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Efficiency',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _getScoreDescription(score),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate a mock location efficiency score
  double _calculateLocationScore() {
    // This would use a real algorithm in production
    // For demo, generate a score based on some item properties

    final needsRefrigeration =
        item.additionalAttributes?['needsRefrigeration'] as bool? ?? false;
    final isFrozen = item.additionalAttributes?['isFrozen'] as bool? ?? false;

    // Check if current location seems appropriate (basic check)
    final location = item.location.toLowerCase();
    bool locationMatch = false;

    if (isFrozen &&
        (location.contains('freezer') || location.contains('zone-c'))) {
      locationMatch = true;
    } else if (needsRefrigeration &&
        (location.contains('refrigerated') ||
            location.contains('cold') ||
            location.contains('zone-b'))) {
      locationMatch = true;
    } else if (!isFrozen &&
        !needsRefrigeration &&
        (location.contains('ambient') ||
            location.contains('dry') ||
            location.contains('zone-a'))) {
      locationMatch = true;
    }

    // Base score depending on location match
    double baseScore = locationMatch ? 0.75 : 0.4;

    // Add some randomness to make it interesting
    baseScore += (item.id.hashCode % 30) / 100; // +/- 0.3

    return baseScore.clamp(0.0, 1.0);
  }

  /// Get appropriate color for the score
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

  /// Get description text based on the score
  String _getScoreDescription(double score) {
    if (score < 0.3) {
      return 'Poor location - consider relocating';
    } else if (score < 0.6) {
      return 'Suboptimal location - improvements possible';
    } else if (score < 0.8) {
      return 'Good location - minor improvements possible';
    } else {
      return 'Optimal location - well placed';
    }
  }
}
