// filepath: c:\FlutterProjects\und\lib\features\ai\presentation\widgets\cross_module_intelligence_widgets.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../data/models/cross_module_intelligence_models.dart';
import '../../data/services/cross_module_intelligence_service.dart';

/// Widget for displaying unified business intelligence insights
class UnifiedIntelligenceWidget extends StatefulWidget {
  final CrossModuleIntelligenceService intelligenceService;

  const UnifiedIntelligenceWidget({
    super.key,
    required this.intelligenceService,
  });

  @override
  State<UnifiedIntelligenceWidget> createState() =>
      _UnifiedIntelligenceWidgetState();
}

class _UnifiedIntelligenceWidgetState extends State<UnifiedIntelligenceWidget> {
  UnifiedBusinessIntelligence? _intelligence;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntelligence();
  }

  Future<void> _loadIntelligence() async {
    try {
      final intelligence =
          await widget.intelligenceService.generateBusinessIntelligence();
      setState(() {
        _intelligence = intelligence;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_intelligence == null) {
      return const Center(child: Text('Failed to load intelligence data'));
    }

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictiveInsightsCard(),
          const SizedBox(height: 16),
          _buildCorrelationsCard(),
          const SizedBox(height: 16),
          _buildRisksCard(),
          const SizedBox(height: 16),
          _buildOptimizationsCard(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPredictiveInsightsCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildCorrelationsCard()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRisksCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildOptimizationsCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPredictiveInsightsCard()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildCorrelationsCard()),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRisksCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildOptimizationsCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveInsightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Predictive Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._intelligence!.predictiveInsights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInsightTile(insight),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(PredictiveInsight insight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.left(
          width: 4,
          color: _getInsightColor(insight.impact),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  insight.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(insight.confidence),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(insight.confidence * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.prediction),
          const SizedBox(height: 4),
          Text(
            'Timeframe: ${insight.timeframe} | Impact: ${insight.impact}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Module Correlations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._intelligence!.crossModuleCorrelations
                .map((correlation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCorrelationTile(correlation),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationTile(CrossModuleCorrelation correlation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                correlation.moduleA,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
              Text(
                correlation.moduleB,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${(correlation.strength * 100).toInt()}%',
                style: TextStyle(
                  color: _getCorrelationColor(correlation.strength),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            correlation.insight,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            correlation.recommendation,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRisksCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Business Risks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._intelligence!.businessRisks.map((risk) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRiskTile(risk),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTile(BusinessRisk risk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.left(
          width: 4,
          color: _getRiskColor(risk.severity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  risk.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRiskColor(risk.severity),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  risk.severity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(risk.description),
          const SizedBox(height: 4),
          Text(
            'Probability: ${(risk.probability * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mitigation: ${risk.mitigation}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  'Optimization Opportunities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._intelligence!.optimizationRecommendations
                .map((optimization) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptimizationTile(optimization),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationTile(OptimizationRecommendation optimization) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.left(
          width: 4,
          color: _getPriorityColor(optimization.priority),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  optimization.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(optimization.priority),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  optimization.priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(optimization.description),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Savings: \$${optimization.estimatedSavings.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Timeline: ${optimization.implementationTime}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getCorrelationColor(double strength) {
    if (strength > 0.7) return Colors.green;
    if (strength > 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getRiskColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

/// Widget for displaying module-specific intelligence insights
class ModuleIntelligenceWidget extends StatelessWidget {
  final String moduleTitle;
  final Widget child;
  final IconData icon;
  final Color color;

  const ModuleIntelligenceWidget({
    super.key,
    required this.moduleTitle,
    required this.child,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  moduleTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying inventory intelligence
class InventoryIntelligenceWidget extends StatelessWidget {
  final InventoryIntelligence intelligence;

  const InventoryIntelligenceWidget({
    super.key,
    required this.intelligence,
  });

  @override
  Widget build(BuildContext context) {
    return ModuleIntelligenceWidget(
      moduleTitle: 'Inventory Intelligence',
      icon: Icons.inventory,
      color: Colors.blue,
      child: Column(
        children: [
          _buildStockAnalysis(),
          const SizedBox(height: 16),
          _buildTurnoverRates(),
          const SizedBox(height: 16),
          _buildCostAnalysis(),
        ],
      ),
    );
  }

  Widget _buildStockAnalysis() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stock Level Analysis',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStockMetric('Optimal',
                  intelligence.stockLevels.optimalItems, Colors.green),
              _buildStockMetric('Understocked',
                  intelligence.stockLevels.understockedItems, Colors.orange),
              _buildStockMetric('Overstocked',
                  intelligence.stockLevels.overstockedItems, Colors.red),
              _buildStockMetric('Critical',
                  intelligence.stockLevels.criticalItems, Colors.red[800]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockMetric(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTurnoverRates() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Turnover Rates',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...intelligence.turnoverRates.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      '${entry.value.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCostAnalysis() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Analysis',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Value:'),
              Text(
                '\$${intelligence.costAnalysis.totalInventoryValue.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Consumption:'),
              Text(
                '\$${intelligence.costAnalysis.monthlyConsumption.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Potential Savings:'),
              Text(
                '\$${intelligence.costAnalysis.potentialSavings.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
