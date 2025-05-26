import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../widgets/enhanced_ai_dashboard_widgets.dart';
import '../../data/services/ai_dashboard_service.dart';
import '../../data/models/ai_dashboard_models.dart';

class AIDashboardScreen extends StatefulWidget {
  const AIDashboardScreen({super.key});

  @override
  State<AIDashboardScreen> createState() => _AIDashboardScreenState();
}

class _AIDashboardScreenState extends State<AIDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardService = AIDashboardService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Command Center'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Health'),
            Tab(icon: Icon(Icons.trending_up), text: 'Insights'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to AI Settings
            },
          ),
        ],
      ),
      body: ResponseBuilder(
        mobile: (context) => _buildMobileLayout(dashboardService),
        tablet: (context) => _buildTabletLayout(dashboardService),
        desktop: (context) => _buildDesktopLayout(dashboardService),
      ),
    );
  }

  Widget _buildMobileLayout(AIDashboardService dashboardService) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(dashboardService, isMobile: true),
        _buildAnalyticsTab(dashboardService, isMobile: true),
        _buildHealthTab(dashboardService, isMobile: true),
        _buildInsightsTab(dashboardService, isMobile: true),
      ],
    );
  }

  Widget _buildTabletLayout(AIDashboardService dashboardService) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(dashboardService, isMobile: false),
        _buildAnalyticsTab(dashboardService, isMobile: false),
        _buildHealthTab(dashboardService, isMobile: false),
        _buildInsightsTab(dashboardService, isMobile: false),
      ],
    );
  }

  Widget _buildDesktopLayout(AIDashboardService dashboardService) {
    return Row(
      children: [
        // Left sidebar navigation
        Container(
          width: 250,
          color: Theme.of(context).colorScheme.surface,
          child: _buildSidebarNavigation(),
        ),
        // Main content area
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(dashboardService, isMobile: false),
              _buildAnalyticsTab(dashboardService, isMobile: false),
              _buildHealthTab(dashboardService, isMobile: false),
              _buildInsightsTab(dashboardService, isMobile: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarNavigation() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('AI Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _buildSidebarItem(Icons.dashboard, 'Overview', 0),
        _buildSidebarItem(Icons.analytics, 'Analytics', 1),
        _buildSidebarItem(Icons.health_and_safety, 'Health', 2),
        _buildSidebarItem(Icons.trending_up, 'Insights', 3),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final isSelected = _tabController.index == index;
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : null)),
      selected: isSelected,
      onTap: () => _tabController.animateTo(index),
    );
  }

  Widget _buildOverviewTab(AIDashboardService dashboardService,
      {required bool isMobile}) {
    return FutureBuilder<DashboardData>(
      future: dashboardService.generateDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Metrics Cards
              _buildSystemMetricsGrid(data.metrics, isMobile),
              const SizedBox(height: 24),

              // Provider Status Grid
              _buildProviderStatusGrid(data.providers, isMobile),
              const SizedBox(height: 24),

              // Performance Indicators
              AIPerformanceIndicatorsWidget(
                  indicators: data.performanceIndicators),
              const SizedBox(height: 24),

              // Recent Activity
              AIRecentActivityWidget(interactions: data.recentInteractions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(AIDashboardService dashboardService,
      {required bool isMobile}) {
    return FutureBuilder<DashboardData>(
      future: dashboardService.generateDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Usage Analytics
              AIUsageAnalyticsWidget(
                  analytics: data.usageAnalytics, isMobile: isMobile),
              const SizedBox(height: 24),

              // Trends Charts
              AITrendsWidget(trends: data.trends, isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthTab(AIDashboardService dashboardService,
      {required bool isMobile}) {
    return FutureBuilder<DashboardData>(
      future: dashboardService.generateDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Health Monitoring
              AIHealthMonitoringWidget(
                providers: data.providers,
                isMobile: isMobile,
              ),
              const SizedBox(height: 24),

              // Alerts
              AIAlertsWidget(alerts: data.alerts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsTab(AIDashboardService dashboardService,
      {required bool isMobile}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // AI Insights Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'AI-Generated Insights',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                      '• System performance optimal across all providers'),
                  const Text('• Cost efficiency improved by 15% this week'),
                  const Text(
                      '• Response times trending downward - excellent performance'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recommendations Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assistant_photo,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Optimization Recommendations',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                      '• Consider increasing cache size for better performance'),
                  const Text('• Review high-cost queries in OpenAI provider'),
                  const Text('• Schedule maintenance for local AI service'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetricsGrid(SystemMetrics metrics, bool isMobile) {
    final items = [
      _MetricItem(
          'Total Queries', '${metrics.totalQueries}', Icons.query_stats),
      _MetricItem(
          'System Uptime',
          '${(metrics.systemUptime * 100).toStringAsFixed(1)}%',
          Icons.access_time),
      _MetricItem('Cache Hit Rate',
          '${(metrics.cacheHitRate * 100).toStringAsFixed(1)}%', Icons.cached),
      _MetricItem('Daily Cost', '\$${metrics.totalCost.toStringAsFixed(2)}',
          Icons.attach_money),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildMetricCard(items[index]),
    );
  }

  Widget _buildMetricCard(_MetricItem item) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              item.value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              item.title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderStatusGrid(
      List<ProviderStatus> providers, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provider Status',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 3 : 2.5,
          ),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            return AIProviderStatusCard(provider: provider);
          },
        ),
      ],
    );
  }
}

class _MetricItem {
  final String title;
  final String value;
  final IconData icon;

  _MetricItem(this.title, this.value, this.icon);
}

// Placeholder for a provider that would fetch actual dashboard data
// final aiDashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
//   final aiService = ref.watch(universalAIServiceProvider); // Assuming this exists
//   // return await aiService.getDashboardSummary(); // Method to be created in UniversalAIService
//   await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
//   return {};
// });
