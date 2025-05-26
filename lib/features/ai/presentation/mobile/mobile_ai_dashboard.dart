import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../../data/services/universal_ai_service.dart';
import '../../../data/services/holistic_insights_service.dart';
import '../../../data/services/predictive_supply_chain.dart';
import '../../../data/services/decision_support_ai.dart';

/// Mobile-optimized AI dashboard providing comprehensive business intelligence
/// with touch-friendly interface and gesture-based navigation
class MobileAIDashboard extends StatefulWidget {
  const MobileAIDashboard({Key? key}) : super(key: key);

  @override
  State<MobileAIDashboard> createState() => _MobileAIDashboardState();
}

class _MobileAIDashboardState extends State<MobileAIDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final UniversalAIService _aiService = UniversalAIService();
  final HolisticInsightsService _insightsService = HolisticInsightsService();
  final PredictiveSupplyChain _supplyChainService = PredictiveSupplyChain();
  final DecisionSupportAI _decisionSupport = DecisionSupportAI();

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  // Dashboard data
  Map<String, dynamic> _dashboardData = {};
  List<AIInsight> _recentInsights = [];
  List<PredictiveAlert> _alerts = [];
  bool _isLoading = true;
  String? _error;

  // Refresh control
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDashboardData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final futures = await Future.wait([
        _loadOverviewData(),
        _loadInsights(),
        _loadAlerts(),
        _loadPerformanceMetrics(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load dashboard data: $e';
      });
    }
  }

  Future<void> _loadOverviewData() async {
    final insights = await _insightsService.generateHolisticInsights();
    final supplyChainData =
        await _supplyChainService.generateSupplyChainDashboard();

    _dashboardData = {
      'kpis': insights.kpis,
      'trends': insights.trends,
      'supplyChain': supplyChainData,
      'lastUpdated': DateTime.now(),
    };
  }

  Future<void> _loadInsights() async {
    final insights = await _insightsService.generateHolisticInsights();
    _recentInsights = [
      AIInsight(
        id: '1',
        title: 'Inventory Optimization Opportunity',
        description:
            'AI identified 15% cost reduction potential in warehouse operations',
        priority: InsightPriority.high,
        category: 'Operations',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionable: true,
      ),
      AIInsight(
        id: '2',
        title: 'Supply Chain Risk Alert',
        description: 'Potential disruption detected in shipping routes',
        priority: InsightPriority.medium,
        category: 'Supply Chain',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        actionable: true,
      ),
      AIInsight(
        id: '3',
        title: 'Customer Satisfaction Trend',
        description: 'Customer satisfaction improving by 8% this quarter',
        priority: InsightPriority.low,
        category: 'Customer',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        actionable: false,
      ),
    ];
  }

  Future<void> _loadAlerts() async {
    _alerts = [
      PredictiveAlert(
        id: '1',
        type: 'Inventory',
        message: 'Stock levels for Product A expected to be critical in 3 days',
        severity: AlertSeverity.high,
        timestamp: DateTime.now(),
        recommendedAction: 'Initiate emergency procurement',
      ),
      PredictiveAlert(
        id: '2',
        type: 'Production',
        message: 'Equipment maintenance required within 5 days',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        recommendedAction: 'Schedule maintenance window',
      ),
    ];
  }

  Future<void> _loadPerformanceMetrics() async {
    // Load performance metrics for the mobile dashboard
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _loadDashboardData();
      }
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildDashboard(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading AI Dashboard...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_error != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _onRefresh,
      color: const Color(0xFF00E5FF),
      backgroundColor: const Color(0xFF1A1F2E),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPageIndex = index;
            });
            HapticFeedback.selectionClick();
          },
          children: [
            _buildOverviewPage(),
            _buildInsightsPage(),
            _buildAlertsPage(),
            _buildAnalyticsPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildKPICards(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showSettingsBottomSheet();
                },
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${_formatTimestamp(DateTime.now())}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    final kpis = _dashboardData['kpis'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Performance Indicators',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _getKPIItems().length,
            itemBuilder: (context, index) {
              final kpi = _getKPIItems()[index];
              return _buildKPICard(kpi);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(KPIItem kpi) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2F3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(kpi.icon, color: kpi.color, size: 24),
              Icon(
                kpi.trend > 0 ? Icons.trending_up : Icons.trending_down,
                color: kpi.trend > 0 ? Colors.green : Colors.red,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            kpi.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kpi.title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Ask AI',
              Icons.chat_bubble_outline,
              const Color(0xFF00E5FF),
              () => _showAIChat(),
            ),
            _buildActionCard(
              'Generate Report',
              Icons.analytics_outlined,
              const Color(0xFF4CAF50),
              () => _generateReport(),
            ),
            _buildActionCard(
              'Predictions',
              Icons.trending_up,
              const Color(0xFFFF9800),
              () => _showPredictions(),
            ),
            _buildActionCard(
              'Optimize',
              Icons.auto_fix_high,
              const Color(0xFF9C27B0),
              () => _showOptimizations(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ..._recentInsights
            .take(3)
            .map((insight) => _buildActivityItem(insight)),
      ],
    );
  }

  Widget _buildActivityItem(AIInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2F3E)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(insight.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(insight.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._recentInsights
              .map((insight) => _buildDetailedInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildDetailedInsightCard(AIInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _getPriorityColor(insight.priority).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(insight.priority).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  insight.priority.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(insight.priority),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                insight.category,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              if (insight.actionable)
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _takeAction(insight);
                  },
                  child: const Text(
                    'Take Action',
                    style: TextStyle(color: Color(0xFF00E5FF)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Alerts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (_alerts.isEmpty)
            _buildEmptyState('No active alerts')
          else
            ..._alerts.map((alert) => _buildAlertCard(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(PredictiveAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _getAlertSeverityColor(alert.severity).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getAlertIcon(alert.type),
                color: _getAlertSeverityColor(alert.severity),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alert.type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getAlertSeverityColor(alert.severity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert.severity.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getAlertSeverityColor(alert.severity),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF00E5FF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recommended: ${alert.recommendedAction}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsChart(),
          const SizedBox(height: 24),
          _buildTrendAnalysis(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F3E)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                'Interactive Chart Placeholder',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trend Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTrendItem(
              'Revenue Growth', '+12.5%', Icons.trending_up, Colors.green),
          _buildTrendItem('Operational Efficiency', '+8.3%', Icons.trending_up,
              Colors.green),
          _buildTrendItem('Customer Satisfaction', '+15.2%', Icons.trending_up,
              Colors.green),
          _buildTrendItem(
              'Supply Chain Costs', '-4.1%', Icons.trending_down, Colors.red),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
      String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white60,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2F3E)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.dashboard_outlined, 'Overview'),
          _buildNavItem(1, Icons.lightbulb_outline, 'Insights'),
          _buildNavItem(2, Icons.warning_amber_outlined, 'Alerts'),
          _buildNavItem(3, Icons.analytics_outlined, 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentPageIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white60,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<KPIItem> _getKPIItems() {
    return [
      KPIItem(
        title: 'Revenue',
        value: '\$2.4M',
        trend: 0.12,
        icon: Icons.attach_money,
        color: const Color(0xFF4CAF50),
      ),
      KPIItem(
        title: 'Efficiency',
        value: '92.5%',
        trend: 0.08,
        icon: Icons.speed,
        color: const Color(0xFF00E5FF),
      ),
      KPIItem(
        title: 'Orders',
        value: '1,247',
        trend: 0.15,
        icon: Icons.shopping_cart,
        color: const Color(0xFFFF9800),
      ),
      KPIItem(
        title: 'Alerts',
        value: '3',
        trend: -0.25,
        icon: Icons.warning,
        color: const Color(0xFFF44336),
      ),
    ];
  }

  Color _getPriorityColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.high:
        return const Color(0xFFF44336);
      case InsightPriority.medium:
        return const Color(0xFFFF9800);
      case InsightPriority.low:
        return const Color(0xFF4CAF50);
    }
  }

  Color _getAlertSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return const Color(0xFFF44336);
      case AlertSeverity.high:
        return const Color(0xFFFF5722);
      case AlertSeverity.medium:
        return const Color(0xFFFF9800);
      case AlertSeverity.low:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'inventory':
        return Icons.inventory;
      case 'production':
        return Icons.precision_manufacturing;
      case 'supply chain':
        return Icons.local_shipping;
      case 'customer':
        return Icons.person;
      default:
        return Icons.warning;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dashboard Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.white70),
              title: const Text('Auto Refresh',
                  style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF00E5FF),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.white70),
              title: const Text('Push Notifications',
                  style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF00E5FF),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.white70),
              title: const Text('Dark Mode',
                  style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF00E5FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAIChat() {
    // Navigate to AI chat interface
  }

  void _generateReport() {
    // Generate AI report
  }

  void _showPredictions() {
    // Show AI predictions
  }

  void _showOptimizations() {
    // Show AI optimizations
  }

  void _takeAction(AIInsight insight) {
    // Handle insight action
  }
}

// Data Models
class KPIItem {
  final String title;
  final String value;
  final double trend;
  final IconData icon;
  final Color color;

  KPIItem({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });
}

class AIInsight {
  final String id;
  final String title;
  final String description;
  final InsightPriority priority;
  final String category;
  final DateTime timestamp;
  final bool actionable;

  AIInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.timestamp,
    required this.actionable,
  });
}

enum InsightPriority { low, medium, high }

class PredictiveAlert {
  final String id;
  final String type;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String recommendedAction;

  PredictiveAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.recommendedAction,
  });
}

enum AlertSeverity { low, medium, high, critical }
