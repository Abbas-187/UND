import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';

/// A widget that displays product recommendations for a customer
/// Used in the order creation/edit screen to suggest products based on customer history
class ProductRecommendationWidget extends ConsumerStatefulWidget {
  final String customerId;
  final Function(String productId, String productName, double price)
      onProductSelected;

  const ProductRecommendationWidget({
    Key? key,
    required this.customerId,
    required this.onProductSelected,
  }) : super(key: key);

  @override
  ConsumerState<ProductRecommendationWidget> createState() =>
      _ProductRecommendationWidgetState();
}

class _ProductRecommendationWidgetState
    extends ConsumerState<ProductRecommendationWidget> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recommendations = [];
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void didUpdateWidget(ProductRecommendationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId) {
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    if (widget.customerId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load product recommendations
      final recommendations =
          await _orderService.getProductRecommendations(widget.customerId);

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading product recommendations: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _recommendations.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No recommendations available'),
                    )
                  : _buildRecommendationList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.blue.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recommended Products',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue.shade800),
            onPressed: _loadRecommendations,
            tooltip: 'Refresh recommendations',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recommendations.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final recommendation = _recommendations[index];
        final bool hasDiscount = recommendation['discountPercentage'] != null;
        final String reason = recommendation['reason'] ?? '';

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            recommendation['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reason.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasDiscount)
                Text(
                  '\$${recommendation['originalPrice']?.toStringAsFixed(2)}',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              Text(
                '\$${recommendation['price']?.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasDiscount ? Colors.red : Colors.black,
                ),
              ),
              if (hasDiscount)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${recommendation['discountPercentage']}% OFF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            widget.onProductSelected(
              recommendation['id'] ?? '',
              recommendation['name'] ?? '',
              recommendation['price'] ?? 0.0,
            );
          },
        );
      },
    );
  }
}
