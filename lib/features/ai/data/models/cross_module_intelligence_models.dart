// filepath: c:\FlutterProjects\und\lib\features\ai\data\models\cross_module_intelligence_models.dart

import 'ai_dashboard_models.dart';

/// Data models for Cross-Module Intelligence

// Inventory Intelligence Models
class InventoryIntelligence {
  final StockAnalysis stockLevels;
  final Map<String, double> turnoverRates;
  final CostAnalysis costAnalysis;
  final Map<String, double> trends;
  final List<SystemAlert> alerts;

  InventoryIntelligence({
    required this.stockLevels,
    required this.turnoverRates,
    required this.costAnalysis,
    required this.trends,
    required this.alerts,
  });
}

class StockAnalysis {
  final int optimalItems;
  final int understockedItems;
  final int overstockedItems;
  final int criticalItems;

  StockAnalysis({
    required this.optimalItems,
    required this.understockedItems,
    required this.overstockedItems,
    required this.criticalItems,
  });
}

class CostAnalysis {
  final double totalInventoryValue;
  final double monthlyConsumption;
  final double carryingCosts;
  final double potentialSavings;

  CostAnalysis({
    required this.totalInventoryValue,
    required this.monthlyConsumption,
    required this.carryingCosts,
    required this.potentialSavings,
  });
}

// Production Intelligence Models
class ProductionIntelligence {
  final EfficiencyMetrics efficiency;
  final List<Bottleneck> bottlenecks;
  final CapacityAnalysis capacityAnalysis;
  final MaintenanceInsights maintenanceInsights;

  ProductionIntelligence({
    required this.efficiency,
    required this.bottlenecks,
    required this.capacityAnalysis,
    required this.maintenanceInsights,
  });
}

class EfficiencyMetrics {
  final double overallEfficiency;
  final double equipmentUtilization;
  final double laborProductivity;
  final double qualityYield;

  EfficiencyMetrics({
    required this.overallEfficiency,
    required this.equipmentUtilization,
    required this.laborProductivity,
    required this.qualityYield,
  });
}

class Bottleneck {
  final String station;
  final double utilizationRate;
  final int waitTime; // in minutes
  final String impact;

  Bottleneck({
    required this.station,
    required this.utilizationRate,
    required this.waitTime,
    required this.impact,
  });
}

class CapacityAnalysis {
  final double currentCapacity;
  final double plannedCapacity;
  final int bottleneckStations;
  final double improvementPotential;

  CapacityAnalysis({
    required this.currentCapacity,
    required this.plannedCapacity,
    required this.bottleneckStations,
    required this.improvementPotential,
  });
}

class MaintenanceInsights {
  final int scheduledMaintenance;
  final int unplannedDowntime;
  final double maintenanceCosts;
  final int predictiveOpportunities;

  MaintenanceInsights({
    required this.scheduledMaintenance,
    required this.unplannedDowntime,
    required this.maintenanceCosts,
    required this.predictiveOpportunities,
  });
}

// Procurement Intelligence Models
class ProcurementIntelligence {
  final Map<String, SupplierPerformance> supplierPerformance;
  final CostTrends costTrends;
  final ContractAnalysis contractAnalysis;
  final MarketIntelligence marketIntelligence;

  ProcurementIntelligence({
    required this.supplierPerformance,
    required this.costTrends,
    required this.contractAnalysis,
    required this.marketIntelligence,
  });
}

class SupplierPerformance {
  final double onTimeDelivery;
  final double qualityScore;
  final double costCompetitiveness;
  final double responsiveness;

  SupplierPerformance({
    required this.onTimeDelivery,
    required this.qualityScore,
    required this.costCompetitiveness,
    required this.responsiveness,
  });
}

class CostTrends {
  final double materialCostInflation;
  final double energyCostTrend;
  final double transportationCosts;
  final double totalSavingsOpportunity;

  CostTrends({
    required this.materialCostInflation,
    required this.energyCostTrend,
    required this.transportationCosts,
    required this.totalSavingsOpportunity,
  });
}

class ContractAnalysis {
  final int expiringContracts;
  final int renewalOpportunities;
  final double renegotiationPotential;
  final double complianceRisk;

  ContractAnalysis({
    required this.expiringContracts,
    required this.renewalOpportunities,
    required this.renegotiationPotential,
    required this.complianceRisk,
  });
}

class MarketIntelligence {
  final Map<String, double> commodityPrices;
  final List<String> marketTrends;
  final List<String> riskFactors;

  MarketIntelligence({
    required this.commodityPrices,
    required this.marketTrends,
    required this.riskFactors,
  });
}

// BOM Intelligence Models
class BOMIntelligence {
  final ComponentAnalysis componentAnalysis;
  final BOMCostOptimization costOptimization;
  final StandardizationAnalysis standardization;

  BOMIntelligence({
    required this.componentAnalysis,
    required this.costOptimization,
    required this.standardization,
  });
}

class ComponentAnalysis {
  final int totalComponents;
  final int standardizedComponents;
  final int customComponents;
  final int obsoleteComponents;

  ComponentAnalysis({
    required this.totalComponents,
    required this.standardizedComponents,
    required this.customComponents,
    required this.obsoleteComponents,
  });
}

class BOMCostOptimization {
  final double currentCosts;
  final double optimizedCosts;
  final double potentialSavings;
  final int substitutionOpportunities;

  BOMCostOptimization({
    required this.currentCosts,
    required this.optimizedCosts,
    required this.potentialSavings,
    required this.substitutionOpportunities,
  });
}

class StandardizationAnalysis {
  final double standardizationRate;
  final int duplicateComponents;
  final int consolidationOpportunities;
  final double estimatedSavings;

  StandardizationAnalysis({
    required this.standardizationRate,
    required this.duplicateComponents,
    required this.consolidationOpportunities,
    required this.estimatedSavings,
  });
}

// Quality Intelligence Models
class QualityIntelligence {
  final QualityMetrics overallQuality;
  final DefectAnalysis defectAnalysis;
  final CorrectiveActions corrective;

  QualityIntelligence({
    required this.overallQuality,
    required this.defectAnalysis,
    required this.corrective,
  });
}

class QualityMetrics {
  final double defectRate;
  final double customerSatisfaction;
  final double returnRate;
  final double qualityScore;

  QualityMetrics({
    required this.defectRate,
    required this.customerSatisfaction,
    required this.returnRate,
    required this.qualityScore,
  });
}

class DefectAnalysis {
  final Map<String, double> topDefectTypes;
  final String trendDirection;
  final List<String> rootCauses;

  DefectAnalysis({
    required this.topDefectTypes,
    required this.trendDirection,
    required this.rootCauses,
  });
}

class CorrectiveActions {
  final int openActions;
  final int overdueTasks;
  final int averageResolutionTime;
  final double effectiveness;

  CorrectiveActions({
    required this.openActions,
    required this.overdueTasks,
    required this.averageResolutionTime,
    required this.effectiveness,
  });
}

// Cross-Module Analysis Models
class CrossModuleCorrelation {
  final String moduleA;
  final String moduleB;
  final String correlationType;
  final double strength;
  final String insight;
  final String recommendation;

  CrossModuleCorrelation({
    required this.moduleA,
    required this.moduleB,
    required this.correlationType,
    required this.strength,
    required this.insight,
    required this.recommendation,
  });
}

class PredictiveInsight {
  final String category;
  final String prediction;
  final double confidence;
  final String timeframe;
  final String impact;
  final List<String> basedOn;

  PredictiveInsight({
    required this.category,
    required this.prediction,
    required this.confidence,
    required this.timeframe,
    required this.impact,
    required this.basedOn,
  });
}

class BusinessRisk {
  final String category;
  final String description;
  final String severity;
  final double probability;
  final String impact;
  final String mitigation;
  final List<String> modules;

  BusinessRisk({
    required this.category,
    required this.description,
    required this.severity,
    required this.probability,
    required this.impact,
    required this.mitigation,
    required this.modules,
  });
}

class OptimizationRecommendation {
  final String title;
  final String description;
  final String priority;
  final double estimatedSavings;
  final String implementationTime;
  final List<String> modules;
  final List<String> kpis;
  final List<String> steps;

  OptimizationRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedSavings,
    required this.implementationTime,
    required this.modules,
    required this.kpis,
    required this.steps,
  });
}

// Import SystemAlert from ai_dashboard_models.dart to avoid duplication
