import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../entities/bill_of_materials.dart';
import '../entities/bom_item.dart';
import '../entities/quality_entities.dart';
import '../repositories/bom_repository.dart';
import '../../presentation/providers/bom_providers.dart';
import '../../../inventory/domain/providers/inventory_repository_provider.dart'
    as inventory_provider;
import '../../../suppliers/presentation/providers/supplier_provider.dart'
    as supplier_provider;

/// Quality Integration Service - Implements quality-driven BOM intelligence
class QualityIntegrationService {
  QualityIntegrationService({
    required this.bomRepository,
    required this.inventoryRepository,
    required this.supplierRepository,
    required this.logger,
  });

  final BomRepository bomRepository;
  final InventoryRepository inventoryRepository;
  final SupplierRepository supplierRepository;
  final Logger logger;

  /// Analyze quality impact for a specific BOM
  Future<QualityImpactAnalysis> analyzeQualityImpact(String bomId) async {
    try {
      logger.i('Analyzing quality impact for BOM: $bomId');

      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        throw Exception('BOM not found: $bomId');
      }

      // Calculate material quality scores
      final materialQualityScores = <String, QualityScore>{};
      final supplierQualityScores = <String, double>{};
      final qualityRisks = <QualityAlert>[];
      final criticalMaterials = <String>[];

      for (final bomItem in bom.items.where((item) => item.isActive)) {
        // Get material quality score
        final qualityScore = await _calculateMaterialQualityScore(bomItem);
        materialQualityScores[bomItem.itemId] = qualityScore;

        // Track supplier quality
        if (bomItem.supplierCode != null) {
          final supplierScore =
              await _getSupplierQualityScore(bomItem.supplierCode!);
          supplierQualityScores[bomItem.supplierCode!] = supplierScore;
        }

        // Identify quality risks
        final risks = await _identifyQualityRisks(bomItem, qualityScore);
        qualityRisks.addAll(risks);

        // Mark critical materials
        if (!qualityScore.isAcceptable) {
          criticalMaterials.add(bomItem.itemId);
        }
      }

      // Calculate overall quality score
      final overallScore = _calculateOverallQualityScore(materialQualityScores);

      // Calculate quality cost impact
      final costImpact =
          await _calculateQualityCostImpact(bom, materialQualityScores);

      // Calculate defect probability
      final defectProbability =
          _calculateDefectProbability(materialQualityScores);

      final analysis = QualityImpactAnalysis(
        bomId: bomId,
        overallQualityScore: overallScore,
        materialQualityScores: materialQualityScores,
        qualityRisks: qualityRisks,
        criticalMaterials: criticalMaterials,
        supplierQualityScores: supplierQualityScores,
        qualityCostImpact: costImpact,
        defectProbability: defectProbability,
        analysisDate: DateTime.now(),
        analysisMetrics: {
          'totalMaterials': bom.items.length,
          'criticalMaterialsCount': criticalMaterials.length,
          'qualityRisksCount': qualityRisks.length,
          'averageSupplierScore': supplierQualityScores.values.isNotEmpty
              ? supplierQualityScores.values.reduce((a, b) => a + b) /
                  supplierQualityScores.length
              : 0.0,
        },
      );

      logger.i('Quality impact analysis completed for BOM: $bomId');
      return analysis;
    } catch (e, stackTrace) {
      logger.e('Error analyzing quality impact',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Generate quality alerts for a BOM
  Future<List<QualityAlert>> generateQualityAlerts(String bomId) async {
    try {
      logger.i('Generating quality alerts for BOM: $bomId');

      final analysis = await analyzeQualityImpact(bomId);
      final alerts = <QualityAlert>[];

      // Add existing quality risks
      alerts.addAll(analysis.qualityRisks);

      // Check for supplier quality issues
      for (final entry in analysis.supplierQualityScores.entries) {
        if (entry.value < 70.0) {
          alerts.add(QualityAlert(
            id: 'supplier_quality_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
            materialId: '',
            materialCode: '',
            alertType: 'supplier_quality',
            severity: entry.value < 50.0 ? 'critical' : 'high',
            message:
                'Supplier ${entry.key} has low quality score: ${entry.value.toStringAsFixed(1)}%',
            alertDate: DateTime.now(),
            impactScore: 100 - entry.value,
            supplierId: entry.key,
            bomId: bomId,
            recommendedAction:
                'Review supplier performance and consider alternatives',
          ));
        }
      }

      // Check for certification expiry
      alerts.addAll(await _checkCertificationExpiry(bomId));

      // Check for quality trends
      alerts.addAll(await _checkQualityTrends(bomId));

      logger.i('Generated ${alerts.length} quality alerts for BOM: $bomId');
      return alerts;
    } catch (e, stackTrace) {
      logger.e('Error generating quality alerts',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Generate quality optimization recommendations
  Future<QualityOptimization> optimizeForQuality(String bomId) async {
    try {
      logger.i('Optimizing quality for BOM: $bomId');

      final analysis = await analyzeQualityImpact(bomId);
      final optimizations = <QualityOptimization>[];

      // Supplier optimization
      if (analysis.supplierQualityScores.values.any((score) => score < 80.0)) {
        optimizations.add(QualityOptimization(
          id: 'supplier_opt_${DateTime.now().millisecondsSinceEpoch}',
          bomId: bomId,
          optimizationType: 'supplier_upgrade',
          description:
              'Upgrade to higher quality suppliers for critical materials',
          expectedImprovement: 15.0,
          implementationCost: 5000.0,
          implementationDays: 30,
          priority: 'high',
          affectedMaterials: analysis.criticalMaterials,
          optimizationData: {
            'currentSuppliers': analysis.supplierQualityScores.keys.toList(),
            'recommendedSuppliers':
                await _getRecommendedSuppliers(analysis.criticalMaterials),
          },
          riskLevel: 0.2,
          confidenceScore: 0.85,
          createdAt: DateTime.now(),
        ));
      }

      // Material substitution optimization
      if (analysis.criticalMaterials.isNotEmpty) {
        optimizations.add(QualityOptimization(
          id: 'material_sub_${DateTime.now().millisecondsSinceEpoch}',
          bomId: bomId,
          optimizationType: 'material_substitution',
          description:
              'Substitute low-quality materials with higher-grade alternatives',
          expectedImprovement: 20.0,
          implementationCost: 8000.0,
          implementationDays: 45,
          priority: 'medium',
          affectedMaterials: analysis.criticalMaterials,
          optimizationData: {
            'substitutionOptions':
                await _getMaterialSubstitutions(analysis.criticalMaterials),
          },
          riskLevel: 0.3,
          confidenceScore: 0.75,
          createdAt: DateTime.now(),
        ));
      }

      // Quality control enhancement
      if (analysis.defectProbability > 0.05) {
        optimizations.add(QualityOptimization(
          id: 'qc_enhance_${DateTime.now().millisecondsSinceEpoch}',
          bomId: bomId,
          optimizationType: 'quality_control_enhancement',
          description: 'Implement enhanced quality control measures',
          expectedImprovement: 25.0,
          implementationCost: 12000.0,
          implementationDays: 60,
          priority: 'high',
          affectedMaterials: analysis.materialQualityScores.keys.toList(),
          optimizationData: {
            'recommendedControls': [
              'Incoming inspection enhancement',
              'In-process quality monitoring',
              'Supplier audit program',
            ],
          },
          riskLevel: 0.1,
          confidenceScore: 0.9,
          createdAt: DateTime.now(),
        ));
      }

      // Return the highest priority optimization
      optimizations.sort((a, b) =>
          _getOptimizationPriority(b).compareTo(_getOptimizationPriority(a)));

      logger.i('Quality optimization completed for BOM: $bomId');
      return optimizations.isNotEmpty
          ? optimizations.first
          : QualityOptimization(
              id: 'no_opt_${DateTime.now().millisecondsSinceEpoch}',
              bomId: bomId,
              optimizationType: 'no_optimization',
              description:
                  'No quality optimization needed - BOM meets quality standards',
              expectedImprovement: 0.0,
              implementationCost: 0.0,
              implementationDays: 0,
              priority: 'low',
              affectedMaterials: [],
              optimizationData: {},
              createdAt: DateTime.now(),
            );
    } catch (e, stackTrace) {
      logger.e('Error optimizing quality', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get supplier quality performance
  Future<SupplierQualityPerformance> getSupplierQualityPerformance(
      String supplierId) async {
    try {
      logger.i('Getting quality performance for supplier: $supplierId');

      // Get supplier information
      final supplier = await supplierRepository.getSupplier(supplierId);

      // Calculate quality metrics (simplified implementation)
      final materialQualityScores =
          await _getSupplierMaterialQualityScores(supplierId);
      final overallScore = materialQualityScores.values.isNotEmpty
          ? materialQualityScores.values.reduce((a, b) => a + b) /
              materialQualityScores.length
          : 0.0;

      // Get recent quality issues
      final recentIssues = await _getSupplierQualityIssues(supplierId);

      final performance = SupplierQualityPerformance(
        supplierId: supplierId,
        supplierName: supplier.name,
        overallQualityScore: overallScore,
        materialQualityScores: materialQualityScores,
        totalDeliveries: 100, // Mock data
        qualityIssues: recentIssues.length,
        defectRate: recentIssues.length / 100.0,
        onTimeDeliveryRate: 0.95, // Mock data
        recentIssues: recentIssues,
        improvementTrend: 2.5, // Mock data
        performanceTrend: 'improving',
        lastEvaluationDate: DateTime.now(),
        performanceMetrics: {
          'qualityTrend': 'stable',
          'deliveryTrend': 'improving',
          'costTrend': 'stable',
        },
      );

      logger.i('Supplier quality performance retrieved for: $supplierId');
      return performance;
    } catch (e, stackTrace) {
      logger.e('Error getting supplier quality performance',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Private helper methods

  Future<QualityScore> _calculateMaterialQualityScore(BomItem bomItem) async {
    // Simplified quality score calculation
    // In real implementation, this would analyze historical quality data

    final baseScore = 85.0; // Base quality score
    final randomVariation =
        (DateTime.now().millisecondsSinceEpoch % 20) - 10; // -10 to +10
    final finalScore = (baseScore + randomVariation).clamp(0.0, 100.0);

    return QualityScore(
      materialId: bomItem.itemId,
      materialCode: bomItem.itemCode,
      materialName: bomItem.itemName,
      overallScore: finalScore,
      parameterScores: {
        'purity': finalScore + 2,
        'consistency': finalScore - 1,
        'packaging': finalScore + 1,
      },
      totalTests: 50,
      passedTests: (50 * finalScore / 100).round(),
      failedTests: (50 * (100 - finalScore) / 100).round(),
      defectCount: ((100 - finalScore) / 10).round(),
      defectRate: (100 - finalScore) / 100,
      calculatedAt: DateTime.now(),
      supplierId: bomItem.supplierCode,
      qualityMetrics: {
        'lastTestDate': DateTime.now().subtract(const Duration(days: 7)),
        'testFrequency': 'weekly',
      },
    );
  }

  Future<double> _getSupplierQualityScore(String supplierCode) async {
    // Simplified supplier quality score
    final baseScore = 80.0;
    final variation = (supplierCode.hashCode % 30) - 15; // -15 to +15
    return (baseScore + variation).clamp(0.0, 100.0);
  }

  Future<List<QualityAlert>> _identifyQualityRisks(
      BomItem bomItem, QualityScore qualityScore) async {
    final risks = <QualityAlert>[];

    if (qualityScore.overallScore < 70.0) {
      risks.add(QualityAlert(
        id: 'quality_risk_${DateTime.now().millisecondsSinceEpoch}_${bomItem.itemId}',
        materialId: bomItem.itemId,
        materialCode: bomItem.itemCode,
        alertType: 'low_quality',
        severity: qualityScore.overallScore < 50.0 ? 'critical' : 'high',
        message:
            'Material ${bomItem.itemName} has low quality score: ${qualityScore.overallScore.toStringAsFixed(1)}%',
        alertDate: DateTime.now(),
        impactScore: 100 - qualityScore.overallScore,
        supplierId: bomItem.supplierCode,
        recommendedAction:
            'Review material specifications and supplier performance',
      ));
    }

    if (qualityScore.defectRate > 0.05) {
      risks.add(QualityAlert(
        id: 'defect_risk_${DateTime.now().millisecondsSinceEpoch}_${bomItem.itemId}',
        materialId: bomItem.itemId,
        materialCode: bomItem.itemCode,
        alertType: 'high_defect_rate',
        severity: 'medium',
        message:
            'Material ${bomItem.itemName} has high defect rate: ${(qualityScore.defectRate * 100).toStringAsFixed(1)}%',
        alertDate: DateTime.now(),
        impactScore: qualityScore.defectRate * 100,
        supplierId: bomItem.supplierCode,
        recommendedAction: 'Implement additional quality controls',
      ));
    }

    return risks;
  }

  double _calculateOverallQualityScore(
      Map<String, QualityScore> materialScores) {
    if (materialScores.isEmpty) return 0.0;

    final totalScore = materialScores.values
        .map((score) => score.overallScore)
        .reduce((a, b) => a + b);

    return totalScore / materialScores.length;
  }

  Future<double> _calculateQualityCostImpact(
    BillOfMaterials bom,
    Map<String, QualityScore> materialScores,
  ) async {
    double totalImpact = 0.0;

    for (final bomItem in bom.items) {
      final qualityScore = materialScores[bomItem.itemId];
      if (qualityScore != null && qualityScore.overallScore < 80.0) {
        // Calculate cost impact based on quality deficiency
        final qualityDeficiency = 80.0 - qualityScore.overallScore;
        final itemCost = bomItem.costPerUnit * bomItem.quantity;
        final impact =
            itemCost * (qualityDeficiency / 100) * 0.5; // 50% impact factor
        totalImpact += impact;
      }
    }

    return totalImpact;
  }

  double _calculateDefectProbability(Map<String, QualityScore> materialScores) {
    if (materialScores.isEmpty) return 0.0;

    final averageDefectRate = materialScores.values
            .map((score) => score.defectRate)
            .reduce((a, b) => a + b) /
        materialScores.length;

    return averageDefectRate;
  }

  Future<List<QualityAlert>> _checkCertificationExpiry(String bomId) async {
    // Simplified certification check
    return [];
  }

  Future<List<QualityAlert>> _checkQualityTrends(String bomId) async {
    // Simplified quality trend check
    return [];
  }

  Future<List<String>> _getRecommendedSuppliers(
      List<String> materialIds) async {
    // Simplified supplier recommendation
    return ['SUPPLIER_A', 'SUPPLIER_B', 'SUPPLIER_C'];
  }

  Future<Map<String, List<String>>> _getMaterialSubstitutions(
      List<String> materialIds) async {
    // Simplified material substitution options
    final substitutions = <String, List<String>>{};
    for (final materialId in materialIds) {
      substitutions[materialId] = [
        '${materialId}_PREMIUM',
        '${materialId}_ALTERNATIVE'
      ];
    }
    return substitutions;
  }

  int _getOptimizationPriority(QualityOptimization optimization) {
    switch (optimization.priority) {
      case 'critical':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  Future<Map<String, double>> _getSupplierMaterialQualityScores(
      String supplierId) async {
    // Simplified supplier material quality scores
    return {
      'MATERIAL_001': 85.0,
      'MATERIAL_002': 78.0,
      'MATERIAL_003': 92.0,
    };
  }

  Future<List<QualityAlert>> _getSupplierQualityIssues(
      String supplierId) async {
    // Simplified quality issues retrieval
    return [];
  }
}

/// Provider for Quality Integration Service
final qualityIntegrationServiceProvider =
    Provider<QualityIntegrationService>((ref) {
  return QualityIntegrationService(
    bomRepository: ref.watch(bomRepositoryProvider),
    inventoryRepository:
        ref.watch(inventory_provider.inventoryRepositoryProvider),
    supplierRepository: ref.watch(supplier_provider.supplierRepositoryProvider),
    logger: Logger(),
  );
});
