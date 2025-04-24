import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';

/// A panel that displays customer information and context
/// Used in the order creation/edit screen to show customer details
class CustomerContextPanel extends ConsumerStatefulWidget {
  final String customerId;
  final bool showFullProfile;
  final VoidCallback onClose;

  const CustomerContextPanel({
    Key? key,
    required this.customerId,
    this.showFullProfile = false,
    required this.onClose,
  }) : super(key: key);

  @override
  ConsumerState<CustomerContextPanel> createState() =>
      _CustomerContextPanelState();
}

class _CustomerContextPanelState extends ConsumerState<CustomerContextPanel> {
  bool _isLoading = true;
  Map<String, dynamic>? _customerData;
  List<Map<String, dynamic>> _recentOrders = [];
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  @override
  void didUpdateWidget(CustomerContextPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId) {
      _loadCustomerData();
    }
  }

  Future<void> _loadCustomerData() async {
    if (widget.customerId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load customer profile data
      final customerData =
          await _orderService.getCustomerProfile(widget.customerId);

      // Load recent orders
      final recentOrders = await _orderService
          .getCustomerRecentOrders(widget.customerId, limit: 5);

      if (mounted) {
        setState(() {
          _customerData = customerData;
          _recentOrders = recentOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading customer context: $e');
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
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _customerData == null
                    ? const Center(
                        child: Text('Customer information not available'))
                    : _buildCustomerInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Customer Info',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
            tooltip: 'Close panel',
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic customer info card
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        radius: 24,
                        child: Text(
                          _customerData!['name']
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              'C',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customerData!['name'] ?? 'Customer Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_customerData!['email'] != null)
                              Text(
                                _customerData!['email'],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_customerData!['tier'] != null)
                    _buildInfoItem(
                      'Customer Tier',
                      _customerData!['tier'],
                      Icons.star,
                      _getTierColor(_customerData!['tier']),
                    ),
                  if (_customerData!['phone'] != null)
                    _buildInfoItem(
                        'Phone', _customerData!['phone'], Icons.phone),
                  if (_customerData!['address'] != null)
                    _buildInfoItem('Address', _customerData!['address'],
                        Icons.location_on),
                ],
              ),
            ),
          ),

          // Allergies and preferences
          if (_customerData!['allergies'] != null &&
              (_customerData!['allergies'] as List).isNotEmpty)
            _buildAllergyInfo(),

          if (_customerData!['preferences'] != null) _buildPreferencesInfo(),

          // Order history card
          _buildRecentOrdersCard(),

          // Show full profile button
          if (widget.showFullProfile == false)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to full customer profile
                },
                icon: const Icon(Icons.person_search),
                label: const Text('View Full Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon,
      [Color? iconColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyInfo() {
    final allergies = _customerData!['allergies'] as List;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Allergies',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergies.map<Widget>((allergy) {
                return Chip(
                  backgroundColor: Colors.red.shade100,
                  label: Text(
                    allergy.toString(),
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesInfo() {
    final preferences = _customerData!['preferences'] as Map<String, dynamic>;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.thumb_up_outlined),
                SizedBox(width: 8),
                Text(
                  'Preferences',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...preferences.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history),
                SizedBox(width: 8),
                Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentOrders.isEmpty)
              const Text('No recent orders found')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentOrders.length,
                itemBuilder: (context, index) {
                  final order = _recentOrders[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Order #${order['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatDate(order['date'])}, ${order['status']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: Text(
                      '\$${order['total']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to order details
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return Colors.purple;
      case 'gold':
        return Colors.amber.shade800;
      case 'silver':
        return Colors.grey.shade600;
      case 'bronze':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}
