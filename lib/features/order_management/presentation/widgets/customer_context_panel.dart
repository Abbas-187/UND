import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/responsive_builder.dart';

/// A panel that displays customer information and context
class CustomerContextPanel extends ConsumerStatefulWidget {

  const CustomerContextPanel({
    super.key,
    required this.customerId,
    this.showFullProfile = false,
    required this.onClose,
  });
  final String customerId;
  final bool showFullProfile;
  final VoidCallback onClose;

  @override
  ConsumerState<CustomerContextPanel> createState() =>
      _CustomerContextPanelState();
}

class _CustomerContextPanelState extends ConsumerState<CustomerContextPanel> {
  bool _isLoading = true;
  Map<String, dynamic>? _customerData;
  final List<Map<String, dynamic>> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    if (widget.customerId.isEmpty) return;
    setState(() => _isLoading = true);

    // Replace with a placeholder or throw UnimplementedError
    throw UnimplementedError(
        'orderServiceWithIntegrationsProvider is not implemented.');
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      desktop: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border:
              Border(left: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_customerData == null
                      ? const Center(child: Text('Customer info not available'))
                      : _buildCustomerInfo()),
            ),
          ],
        ),
      ),
      tablet: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border:
              Border(left: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_customerData == null
                      ? const Center(child: Text('Customer info not available'))
                      : _buildCustomerInfo()),
            ),
          ],
        ),
      ),
      mobile: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border:
              Border(left: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_customerData == null
                      ? const Center(child: Text('Customer info not available'))
                      : _buildCustomerInfo()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.blue.shade700, boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ]),
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
                child: Text('Customer Info',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))),
            IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onClose),
          ],
        ),
      );

  Widget _buildCustomerInfo() {
    final data = _customerData!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoCard(data),
          const SizedBox(height: 16),
          _buildRecentOrdersCard(),
          if (!widget.showFullProfile) _buildViewProfileButton(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(Map<String, dynamic> data) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['name'] ?? 'N/A',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              if (data['email'] != null)
                Text(data['email'],
                    style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      );

  Widget _buildRecentOrdersCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recent Orders',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._recentOrders
                  .map((o) => Text('Order #${o['id']} - ${o['status']}'))
                  ,
            ],
          ),
        ),
      );

  Widget _buildViewProfileButton() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_search),
          label: const Text('View Full Profile'),
        ),
      );
} // close _CustomerContextPanelState class
