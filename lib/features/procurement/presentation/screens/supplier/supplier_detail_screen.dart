import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/supplier.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_layout.dart';

class SupplierDetailScreen extends StatefulWidget {

  const SupplierDetailScreen({super.key, required this.supplier});
  final Supplier supplier;

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supplier: ${widget.supplier.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit supplier
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showActionMenu(context);
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSupplierInfoCard(),
        _buildPerformanceMetrics(),
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildSupplierInfoCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _buildPerformanceMetrics(),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSupplierInfoCard(),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildPerformanceMetrics(),
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierInfoCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    widget.supplier.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.supplier.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.supplier.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(widget.supplier.category),
                        backgroundColor: AppColors.secondary.withOpacity(0.1),
                        labelStyle: TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              _buildContactInfo(Icons.person, 'Contact Person',
                  widget.supplier.contactPerson),
              _buildContactInfo(Icons.email, 'Email', widget.supplier.email),
              _buildContactInfo(Icons.phone, 'Phone', widget.supplier.phone),
              _buildContactInfo(
                  Icons.location_on, 'Address', widget.supplier.address),
              _buildContactInfo(Icons.link, 'Website', widget.supplier.website),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMetricCard(
                  'On-Time Delivery',
                  '${widget.supplier.metrics.onTimeDeliveryRate}%',
                  Colors.green,
                ),
                _buildMetricCard(
                  'Quality Score',
                  '${widget.supplier.metrics.qualityScore}/100',
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Response Time',
                  '${widget.supplier.metrics.responseTime} hrs',
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Quality Trends',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun'
                          ];
                          if (value >= 0 && value < months.length) {
                            return Text(months[value.toInt()]);
                          }
                          return const Text('');
                        },
                        reservedSize: 22,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 80),
                        const FlSpot(1, 75),
                        const FlSpot(2, 82),
                        const FlSpot(3, 90),
                        const FlSpot(4, 88),
                        const FlSpot(5, 92),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: 5,
                  minY: 60,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Contracts'),
            Tab(text: 'Quality Logs'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersTab(),
              _buildContractsTab(),
              _buildQualityLogsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.supplier.orders.length,
      itemBuilder: (context, index) {
        final order = widget.supplier.orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              'Order #${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Date: ${DateFormat('MMM dd, yyyy').format(order.date)}'),
                const SizedBox(height: 2),
                Text('Amount: \$${order.amount.toStringAsFixed(2)}'),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('Status: '),
                    Chip(
                      label: Text(order.status),
                      backgroundColor:
                          _getStatusColor(order.status).withOpacity(0.1),
                      labelStyle:
                          TextStyle(color: _getStatusColor(order.status)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to order details
            },
          ),
        );
      },
    );
  }

  Widget _buildContractsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.supplier.contracts.length,
      itemBuilder: (context, index) {
        final contract = widget.supplier.contracts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              contract.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Contract #: ${contract.id}'),
                const SizedBox(height: 2),
                Text('Value: \$${contract.value.toStringAsFixed(2)}'),
                const SizedBox(height: 2),
                Text(
                  'Period: ${DateFormat('MM/dd/yyyy').format(contract.startDate)} - ${DateFormat('MM/dd/yyyy').format(contract.endDate)}',
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Download contract document
              },
            ),
            onTap: () {
              // Navigate to contract details
            },
          ),
        );
      },
    );
  }

  Widget _buildQualityLogsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const issues = [
                          'Defects',
                          'Delays',
                          'Returns',
                          'Compl.'
                        ];
                        if (value >= 0 && value < issues.length) {
                          return Text(issues[value.toInt()]);
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text('${value.toInt()}'),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 8,
                        color: Colors.red,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 12,
                        color: Colors.orange,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 5,
                        color: Colors.yellow.shade800,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: 3,
                        color: Colors.purple,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.supplier.qualityLogs.length,
            itemBuilder: (context, index) {
              final log = widget.supplier.qualityLogs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getIssueColor(log.issueType),
                    child: Icon(
                      _getIssueIcon(log.issueType),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    log.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(log.date)}'),
                      const SizedBox(height: 2),
                      Text('Severity: ${log.severity}/10'),
                      const SizedBox(height: 4),
                      Text(log.description),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Show quality issue details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Supplier',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              Icons.shopping_cart,
              'New Order',
              () {
                // Create new order action
              },
            ),
            _buildActionButton(
              Icons.description,
              'Create Contract',
              () {
                // Create contract action
              },
            ),
            _buildActionButton(
              Icons.assessment,
              'Quality Assessment',
              () {
                // Quality assessment action
              },
            ),
            _buildActionButton(
              Icons.message,
              'Contact Supplier',
              () {
                // Contact supplier action
              },
            ),
            _buildActionButton(
              Icons.warning_amber,
              'Report Issue',
              () {
                // Report issue action
              },
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getIssueColor(String issueType) {
    switch (issueType.toLowerCase()) {
      case 'defect':
        return Colors.red;
      case 'delay':
        return Colors.orange;
      case 'return':
        return Colors.amber.shade700;
      case 'complaint':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIssueIcon(String issueType) {
    switch (issueType.toLowerCase()) {
      case 'defect':
        return Icons.build_circle;
      case 'delay':
        return Icons.access_time;
      case 'return':
        return Icons.assignment_return;
      case 'complaint':
        return Icons.feedback;
      default:
        return Icons.error;
    }
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.success),
                title: const Text('Approve Supplier'),
                onTap: () {
                  Navigator.pop(context);
                  // Approve supplier action
                },
              ),
              ListTile(
                leading: Icon(Icons.pause_circle_filled, color: Colors.orange),
                title: const Text('Pause Relationship'),
                onTap: () {
                  Navigator.pop(context);
                  // Pause relationship action
                },
              ),
              ListTile(
                leading: Icon(Icons.compare, color: AppColors.primary),
                title: const Text('Compare with Others'),
                onTap: () {
                  Navigator.pop(context);
                  // Compare supplier action
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.blueGrey),
                title: const Text('View Audit History'),
                onTap: () {
                  Navigator.pop(context);
                  // View audit history action
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: const Text('Remove Supplier'),
                onTap: () {
                  Navigator.pop(context);
                  // Remove supplier action
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
