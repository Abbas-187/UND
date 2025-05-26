import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../widgets/real_time_insights_widget.dart';
import '../widgets/interactive_charts_widget.dart';
import '../widgets/ai_metrics_widget.dart';
import '../widgets/enhanced_chat_widget.dart';
import '../providers/ai_service_provider.dart';

class EnhancedAIDashboard extends ConsumerStatefulWidget {
  @override
  _EnhancedAIDashboardState createState() => _EnhancedAIDashboardState();
}

class _EnhancedAIDashboardState extends ConsumerState<EnhancedAIDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildQuickStats(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildInsightsTab(),
                  _buildAnalyticsTab(),
                  _buildChatTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.purple[400]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Intelligence Hub',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Universal AI for Dairy Management',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _buildProviderStatusIndicator(),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => _openAISettings(),
        ),
      ],
    );
  }

  Widget _buildProviderStatusIndicator() {
    return Consumer(
      builder: (context, ref, child) {
        // Assuming aiServiceProvider is correctly defined and provides UniversalAIService
        // For demonstration, let's assume a placeholder for checkProviderHealth
        // final universalAIService = ref.watch(aiServiceProvider);
        // In a real app, you'd use your actual provider:
        // final universalAIService = ref.watch(universalAIServiceProvider);

        // Placeholder future for demonstration
        Future<Map<String, bool>> mockHealthCheck() async {
          await Future.delayed(Duration(seconds: 1));
          return {'Claude 3': true, 'Gemini Pro': true, 'Local AI': false};
        }

        return FutureBuilder<Map<String, bool>>(
          // future: universalAIService.checkProviderHealth(), // Use this in real app
          future: mockHealthCheck(), // Using mock for now
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                width: 24, height: 24, // Give some size to the indicator
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                child: Icon(Icons.error_outline, color: Colors.red, size: 20),
              );
            }

            final healthStatus = snapshot.data!;
            final healthyProviders = healthStatus.values.where((v) => v).length;
            final totalProviders = healthStatus.length;

            return Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: healthyProviders == totalProviders
                    ? Colors.green[100]
                    : (healthyProviders > 0
                        ? Colors.orange[100]
                        : Colors.red[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    healthyProviders == totalProviders
                        ? Icons.check_circle
                        : (healthyProviders > 0 ? Icons.warning : Icons.error),
                    size: 16,
                    color: healthyProviders == totalProviders
                        ? Colors.green[700]
                        : (healthyProviders > 0
                            ? Colors.orange[700]
                            : Colors.red[700]),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$healthyProviders/$totalProviders',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: healthyProviders == totalProviders
                          ? Colors.green[700]
                          : (healthyProviders > 0
                              ? Colors.orange[700]
                              : Colors.red[700]),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
              child: _buildStatCard('Active Providers', '2/3', Icons.hub,
                  Colors.blue)), // Example data
          SizedBox(width: 12),
          Expanded(
              child: _buildStatCard(
                  'Today\'s Queries', '247', Icons.chat, Colors.green)),
          SizedBox(width: 12),
          Expanded(
              child: _buildStatCard(
                  'Avg Response', '1.2s', Icons.speed, Colors.orange)),
          SizedBox(width: 12),
          Expanded(
              child: _buildStatCard(
                  'Accuracy', '94%', Icons.verified, Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center content horizontally
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4), // Added space for better visual separation
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.purple[400]!],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'Insights'),
          Tab(text: 'Analytics'),
          Tab(text: 'Chat'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Module Intelligence',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildModuleGrid(),
          SizedBox(height: 24),
          Text(
            'Recent AI Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildModuleGrid() {
    final modules = [
      {
        'name': 'Inventory',
        'icon': Icons.inventory,
        'color': Colors.blue,
        'insights': 12
      },
      {
        'name': 'Production',
        'icon': Icons.factory,
        'color': Colors.green,
        'insights': 8
      },
      {
        'name': 'Milk Reception',
        'icon': Icons.local_drink,
        'color': Colors.orange,
        'insights': 15
      },
      {
        'name': 'CRM',
        'icon': Icons.people,
        'color': Colors.purple,
        'insights': 6
      },
      {
        'name': 'Procurement',
        'icon': Icons.shopping_cart,
        'color': Colors.red,
        'insights': 9
      },
      {
        'name': 'Quality',
        'icon': Icons.verified,
        'color': Colors.teal,
        'insights': 11
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600
            ? 3
            : 2, // Responsive cross axis count
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _buildModuleCard(module);
      },
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Ensure content fills card
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (module['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  module['icon'],
                  color: module['color'],
                  size: 20,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${module['insights']} insights',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // SizedBox(height: 12), // Use Spacer or MainAxisAlignment.spaceBetween
          Text(
            module['name'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // SizedBox(height: 4),
          Text(
            'AI-powered insights',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          // Spacer(), // Use Spacer or MainAxisAlignment.spaceBetween
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: Colors.green),
              SizedBox(width: 4),
              Text(
                '+12% efficiency', // Example data
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    // Placeholder for actual data fetching
    final activities = [
      {
        'title': 'Inventory optimization completed',
        'description':
            'Gemini Pro analyzed stock levels and suggested reorder points',
        'time': '2 min ago',
        'icon': Icons.inventory,
        'color': Colors.blue,
      },
      {
        'title': 'Production schedule optimized',
        'description': 'Claude 3 improved efficiency by 15% for next week',
        'time': '15 min ago',
        'icon': Icons.factory,
        'color': Colors.green,
      },
      {
        'title': 'Milk quality anomaly detected',
        'description': 'AI identified unusual patterns in Farmer #247 delivery',
        'time': '1 hour ago',
        'icon': Icons.warning_amber_rounded, // More specific warning icon
        'color': Colors.orange,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(
            activity['title'] as String,
            activity['description'] as String,
            activity['time'] as String,
            activity['icon'] as IconData,
            activity['color'] as Color,
          );
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1, indent: 72), // Indent divider
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
      onTap: () {
        // Handle tap on activity item, e.g., navigate to details
      },
    );
  }

  Widget _buildInsightsTab() {
    // Assuming RealTimeInsightsWidget and AIMetricsWidget are defined elsewhere
    // and correctly imported.
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          RealTimeInsightsWidget(), // Placeholder
          SizedBox(height: 16),
          AIMetricsWidget(), // Placeholder
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    // Assuming InteractiveChartsWidget is defined elsewhere
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          InteractiveChartsWidget(), // Placeholder
          SizedBox(height: 16),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    // Assuming EnhancedChatWidget is defined elsewhere
    return EnhancedChatWidget(
      // Placeholder
      module: 'general',
      showModuleSelector: true,
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              // Placeholder for actual data fetching
              // final metricsFuture = ref.watch(universalAIServiceProvider).getSystemMetrics();
              Future<Map<String, dynamic>> mockMetrics() async {
                await Future.delayed(Duration(milliseconds: 500));
                return {
                  'total_requests': 1250,
                  'avg_response_time': 1150.5, // ms
                  'success_rate': 98.5, // %
                  'cost_per_request': 0.0025, // $
                };
              }

              return FutureBuilder<Map<String, dynamic>>(
                future: mockMetrics(), // Using mock for now
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.hasError) {
                    return Center(child: Text('Error loading metrics.'));
                  }

                  final metrics = snapshot.data!;
                  return Column(
                    children: [
                      _buildMetricRow('Total Requests',
                          '${metrics['total_requests'] ?? 0}'),
                      _buildMetricRow('Average Response Time',
                          '${(metrics['avg_response_time'] ?? 0).toStringAsFixed(1)}ms'),
                      _buildMetricRow('Success Rate',
                          '${(metrics['success_rate'] ?? 0).toStringAsFixed(1)}%'),
                      _buildMetricRow('Cost Per Request',
                          '\$${(metrics['cost_per_request'] ?? 0).toStringAsFixed(4)}'),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _openQuickAIChat(),
      backgroundColor: Colors.blue[600], // Slightly darker blue
      icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
      label: Text('Quick AI', style: TextStyle(color: Colors.white)),
      elevation: 4.0,
    );
  }

  void _openAISettings() {
    // Navigate to AI settings screen
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AISettingsScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to AI Settings (Not Implemented)')),
    );
  }

  void _openQuickAIChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8, // Start at 80% of screen height
        minChildSize: 0.4, // Min at 40%
        maxChildSize: 0.95, // Max at 95%
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[50], // Match dashboard background
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: EnhancedChatWidget(
              // Placeholder
              module: 'general',
              isModal: true,
              scrollController:
                  scrollController, // Pass scroll controller if needed by chat widget
            ),
          );
        },
      ),
    );
  }
}

// Placeholder for ai_service_provider.dart if not already defined
// This should be in lib/features/ai/presentation/providers/ai_service_provider.dart

// final universalAIServiceProvider = Provider<UniversalAIService>((ref) {
//   // Return your UniversalAIService instance
  // throw UnimplementedError('universalAIServiceProvider not implemented');
//   // Example: return UniversalAIService(apiKey: "YOUR_API_KEY_HERE", /* other dependencies */);
// });

// Placeholder for UniversalAIService class
// class UniversalAIService {
//   Future<Map<String, bool>> checkProviderHealth() async {
//     await Future.delayed(Duration(seconds: 1));
//     return {'Claude 3': true, 'Gemini Pro': true, 'Local AI': false};
//   }
//   Future<Map<String, dynamic>> getSystemMetrics() async {
//     await Future.delayed(Duration(milliseconds: 500));
//     return {
//       'total_requests': 1250,
//       'avg_response_time': 1150.5,
 //       'success_rate': 98.5,
//       'cost_per_request': 0.0025,
//     };
//   }
// }