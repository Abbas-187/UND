# Phase 4: AI/ML Intelligence & Advanced Features
## Duration: 10-12 weeks | Priority: Medium | Risk: High

### Overview
Phase 4 introduces artificial intelligence and machine learning capabilities to the procurement module. This phase builds upon the automation foundation from Phase 3 and adds predictive analytics, intelligent decision-making, and advanced optimization features.

### Objectives
- Implement demand forecasting using machine learning
- Add intelligent price prediction and market analysis
- Create AI-powered supplier risk assessment
- Implement smart contract optimization
- Add predictive maintenance for procurement processes
- Introduce natural language processing for document analysis

### Technical Approach
- **Leverage TensorFlow Lite** for on-device ML inference
- **Build cloud-based ML pipeline** for training and model updates
- **Extend existing analytics foundation** with predictive capabilities
- **Use existing data structures** for ML feature engineering
- **Maintain system performance** while adding AI capabilities

---

## Week 1-3: Demand Forecasting & Predictive Analytics

### 1.1 ML-Powered Demand Forecasting Service
**File**: `lib/features/procurement/domain/services/demand_forecasting_service.dart`

```dart
class DemandForecastingService {
  final InventoryRepository _inventoryRepository;
  final ProductionRepository _productionRepository;
  final SalesRepository _salesRepository;
  final MLModelService _mlModelService;
  final AnalyticsRepository _analyticsRepository;
  final Logger _logger;

  DemandForecastingService({
    required InventoryRepository inventoryRepository,
    required ProductionRepository productionRepository,
    required SalesRepository salesRepository,
    required MLModelService mlModelService,
    required AnalyticsRepository analyticsRepository,
    required Logger logger,
  }) : _inventoryRepository = inventoryRepository,
       _productionRepository = productionRepository,
       _salesRepository = salesRepository,
       _mlModelService = mlModelService,
       _analyticsRepository = analyticsRepository,
       _logger = logger;

  /// Generate demand forecast for items
  Future<List<DemandForecast>> generateDemandForecast({
    required List<String> itemIds,
    required int forecastHorizonDays,
    required ForecastGranularity granularity,
  }) async {
    final forecasts = <DemandForecast>[];

    for (final itemId in itemIds) {
      try {
        // Prepare feature data
        final features = await _prepareFeatureData(itemId, forecastHorizonDays);
        
        // Get ML model for item category
        final item = await _inventoryRepository.getItem(itemId);
        final model = await _mlModelService.getDemandForecastModel(item?.category ?? 'general');
        
        // Generate prediction
        final prediction = await model.predict(features);
        
        // Create forecast with confidence intervals
        final forecast = DemandForecast(
          itemId: itemId,
          itemName: item?.name ?? 'Unknown',
          forecastPeriod: DateRange(
            DateTime.now(),
            DateTime.now().add(Duration(days: forecastHorizonDays)),
          ),
          granularity: granularity,
          predictions: _generatePredictionPoints(prediction, granularity, forecastHorizonDays),
          confidence: prediction.confidence,
          modelVersion: model.version,
          features: features.featureNames,
          generatedAt: DateTime.now(),
        );

        forecasts.add(forecast);
        
        // Store forecast for future reference
        await _analyticsRepository.storeDemandForecast(forecast);
        
      } catch (error) {
        _logger.e('Failed to generate forecast for item $itemId: $error');
      }
    }

    return forecasts;
  }

  /// Prepare feature data for ML model
  Future<FeatureData> _prepareFeatureData(String itemId, int horizonDays) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 365)); // 1 year of history

    // Historical consumption data
    final consumptionHistory = await _inventoryRepository.getConsumptionHistory(
      itemId: itemId,
      startDate: startDate,
      endDate: endDate,
    );

    // Production schedule data
    final productionSchedule = await _productionRepository.getProductionSchedule(
      startDate: endDate,
      endDate: endDate.add(Duration(days: horizonDays)),
    );

    // Sales forecast data
    final salesForecast = await _salesRepository.getSalesForecast(
      startDate: endDate,
      endDate: endDate.add(Duration(days: horizonDays)),
    );

    // Seasonal patterns
    final seasonalData = await _analyticsRepository.getSeasonalPatterns(itemId);

    // External factors (weather, holidays, etc.)
    final externalFactors = await _getExternalFactors(endDate, horizonDays);

    return FeatureData(
      itemId: itemId,
      features: {
        // Time series features
        'historical_consumption': _extractTimeSeriesFeatures(consumptionHistory),
        'trend': _calculateTrend(consumptionHistory),
        'seasonality': _extractSeasonalFeatures(seasonalData),
        
        // Production features
        'planned_production': _extractProductionFeatures(productionSchedule, itemId),
        'production_capacity': await _getProductionCapacity(itemId),
        
        // Sales features
        'sales_forecast': _extractSalesFeatures(salesForecast, itemId),
        'market_demand': await _getMarketDemand(itemId),
        
        // External features
        'holidays': externalFactors.holidays,
        'weather_impact': externalFactors.weatherImpact,
        'economic_indicators': externalFactors.economicIndicators,
        
        // Item characteristics
        'item_category': await _getItemCategory(itemId),
        'shelf_life': await _getShelfLife(itemId),
        'lead_time': await _getLeadTime(itemId),
      },
      featureNames: [
        'historical_consumption', 'trend', 'seasonality',
        'planned_production', 'production_capacity',
        'sales_forecast', 'market_demand',
        'holidays', 'weather_impact', 'economic_indicators',
        'item_category', 'shelf_life', 'lead_time',
      ],
      timestamp: DateTime.now(),
    );
  }

  /// Generate prediction points based on granularity
  List<DemandPrediction> _generatePredictionPoints(
    MLPrediction prediction,
    ForecastGranularity granularity,
    int horizonDays,
  ) {
    final predictions = <DemandPrediction>[];
    final startDate = DateTime.now();
    
    int intervalDays;
    switch (granularity) {
      case ForecastGranularity.daily:
        intervalDays = 1;
        break;
      case ForecastGranularity.weekly:
        intervalDays = 7;
        break;
      case ForecastGranularity.monthly:
        intervalDays = 30;
        break;
    }

    for (int i = 0; i < horizonDays; i += intervalDays) {
      final date = startDate.add(Duration(days: i));
      final index = i ~/ intervalDays;
      
      if (index < prediction.values.length) {
        predictions.add(DemandPrediction(
          date: date,
          predictedDemand: prediction.values[index],
          lowerBound: prediction.lowerBounds?[index] ?? prediction.values[index] * 0.8,
          upperBound: prediction.upperBounds?[index] ?? prediction.values[index] * 1.2,
          confidence: prediction.confidence,
        ));
      }
    }

    return predictions;
  }

  /// Monitor forecast accuracy and retrain models
  Future<void> monitorForecastAccuracy() async {
    final recentForecasts = await _analyticsRepository.getRecentForecasts(
      daysBack: 30,
    );

    for (final forecast in recentForecasts) {
      final actualDemand = await _getActualDemand(
        forecast.itemId,
        forecast.forecastPeriod.start,
        forecast.forecastPeriod.end,
      );

      final accuracy = _calculateForecastAccuracy(forecast, actualDemand);
      
      await _analyticsRepository.storeForecastAccuracy(
        forecastId: forecast.id,
        accuracy: accuracy,
      );

      // Trigger model retraining if accuracy drops below threshold
      if (accuracy.mape > 0.3) { // 30% MAPE threshold
        await _triggerModelRetraining(forecast.itemId);
      }
    }
  }

  /// Calculate forecast accuracy metrics
  ForecastAccuracy _calculateForecastAccuracy(
    DemandForecast forecast,
    List<ActualDemand> actualDemand,
  ) {
    final predictions = forecast.predictions;
    double totalAbsoluteError = 0;
    double totalActual = 0;
    double totalSquaredError = 0;
    int validPoints = 0;

    for (int i = 0; i < predictions.length && i < actualDemand.length; i++) {
      final predicted = predictions[i].predictedDemand;
      final actual = actualDemand[i].quantity;
      
      if (actual > 0) {
        totalAbsoluteError += (predicted - actual).abs();
        totalSquaredError += (predicted - actual) * (predicted - actual);
        totalActual += actual;
        validPoints++;
      }
    }

    if (validPoints == 0) {
      return ForecastAccuracy.empty();
    }

    final mae = totalAbsoluteError / validPoints;
    final mape = (totalAbsoluteError / totalActual) * 100;
    final rmse = sqrt(totalSquaredError / validPoints);

    return ForecastAccuracy(
      mae: mae,
      mape: mape,
      rmse: rmse,
      validPoints: validPoints,
      calculatedAt: DateTime.now(),
    );
  }
}

@freezed
class DemandForecast with _$DemandForecast {
  const factory DemandForecast({
    required String itemId,
    required String itemName,
    required DateRange forecastPeriod,
    required ForecastGranularity granularity,
    required List<DemandPrediction> predictions,
    required double confidence,
    required String modelVersion,
    required List<String> features,
    required DateTime generatedAt,
    String? id,
  }) = _DemandForecast;

  factory DemandForecast.fromJson(Map<String, dynamic> json) =>
      _$DemandForecastFromJson(json);
}

@freezed
class DemandPrediction with _$DemandPrediction {
  const factory DemandPrediction({
    required DateTime date,
    required double predictedDemand,
    required double lowerBound,
    required double upperBound,
    required double confidence,
  }) = _DemandPrediction;

  factory DemandPrediction.fromJson(Map<String, dynamic> json) =>
      _$DemandPredictionFromJson(json);
}

@freezed
class FeatureData with _$FeatureData {
  const factory FeatureData({
    required String itemId,
    required Map<String, dynamic> features,
    required List<String> featureNames,
    required DateTime timestamp,
  }) = _FeatureData;
}

@freezed
class ForecastAccuracy with _$ForecastAccuracy {
  const factory ForecastAccuracy({
    required double mae, // Mean Absolute Error
    required double mape, // Mean Absolute Percentage Error
    required double rmse, // Root Mean Square Error
    required int validPoints,
    required DateTime calculatedAt,
  }) = _ForecastAccuracy;

  factory ForecastAccuracy.empty() = _ForecastAccuracyEmpty;
}

enum ForecastGranularity { daily, weekly, monthly }
```

### 1.2 ML Model Service
**File**: `lib/features/procurement/domain/services/ml_model_service.dart`

```dart
class MLModelService {
  final TensorFlowLiteService _tfliteService;
  final CloudMLService _cloudMLService;
  final ModelRepository _modelRepository;
  final Logger _logger;

  MLModelService({
    required TensorFlowLiteService tfliteService,
    required CloudMLService cloudMLService,
    required ModelRepository modelRepository,
    required Logger logger,
  }) : _tfliteService = tfliteService,
       _cloudMLService = cloudMLService,
       _modelRepository = modelRepository,
       _logger = logger;

  /// Get demand forecast model for category
  Future<MLModel> getDemandForecastModel(String category) async {
    // Try to get cached model first
    var model = await _modelRepository.getCachedModel('demand_forecast_$category');
    
    if (model == null || _isModelStale(model)) {
      // Download latest model from cloud
      model = await _downloadModel('demand_forecast_$category');
      
      if (model != null) {
        await _modelRepository.cacheModel(model);
      } else {
        // Fallback to general model
        model = await _modelRepository.getCachedModel('demand_forecast_general');
      }
    }

    if (model == null) {
      throw Exception('No demand forecast model available for category: $category');
    }

    return model;
  }

  /// Get price prediction model
  Future<MLModel> getPricePredictionModel(String itemCategory) async {
    var model = await _modelRepository.getCachedModel('price_prediction_$itemCategory');
    
    if (model == null || _isModelStale(model)) {
      model = await _downloadModel('price_prediction_$itemCategory');
      
      if (model != null) {
        await _modelRepository.cacheModel(model);
      }
    }

    return model ?? await _getDefaultPricePredictionModel();
  }

  /// Get supplier risk assessment model
  Future<MLModel> getSupplierRiskModel() async {
    var model = await _modelRepository.getCachedModel('supplier_risk_assessment');
    
    if (model == null || _isModelStale(model)) {
      model = await _downloadModel('supplier_risk_assessment');
      
      if (model != null) {
        await _modelRepository.cacheModel(model);
      }
    }

    return model ?? await _getDefaultRiskModel();
  }

  /// Download model from cloud ML service
  Future<MLModel?> _downloadModel(String modelName) async {
    try {
      final modelData = await _cloudMLService.downloadModel(modelName);
      
      if (modelData != null) {
        // Load model into TensorFlow Lite
        final interpreter = await _tfliteService.loadModel(modelData.bytes);
        
        return MLModel(
          name: modelName,
          version: modelData.version,
          interpreter: interpreter,
          inputShape: modelData.inputShape,
          outputShape: modelData.outputShape,
          downloadedAt: DateTime.now(),
          metadata: modelData.metadata,
        );
      }
    } catch (error) {
      _logger.e('Failed to download model $modelName: $error');
    }
    
    return null;
  }

  /// Check if model needs updating
  bool _isModelStale(MLModel model) {
    final daysSinceDownload = DateTime.now().difference(model.downloadedAt).inDays;
    return daysSinceDownload > 7; // Update models weekly
  }

  /// Trigger model retraining
  Future<void> triggerModelRetraining({
    required String modelName,
    required String itemId,
    required String reason,
  }) async {
    try {
      await _cloudMLService.triggerRetraining(
        modelName: modelName,
        itemId: itemId,
        reason: reason,
        timestamp: DateTime.now(),
      );
      
      _logger.i('Triggered retraining for model $modelName, item $itemId: $reason');
    } catch (error) {
      _logger.e('Failed to trigger retraining for $modelName: $error');
    }
  }
}

@freezed
class MLModel with _$MLModel {
  const factory MLModel({
    required String name,
    required String version,
    required dynamic interpreter, // TensorFlow Lite Interpreter
    required List<int> inputShape,
    required List<int> outputShape,
    required DateTime downloadedAt,
    required Map<String, dynamic> metadata,
  }) = _MLModel;

  /// Make prediction using the model
  Future<MLPrediction> predict(FeatureData features) async {
    try {
      // Prepare input tensor
      final inputTensor = _prepareInputTensor(features);
      
      // Run inference
      interpreter.run(inputTensor, outputTensor);
      
      // Process output
      return _processOutput(outputTensor);
    } catch (error) {
      throw Exception('Prediction failed: $error');
    }
  }

  List<List<double>> _prepareInputTensor(FeatureData features) {
    // Convert feature data to tensor format
    final inputData = <double>[];
    
    for (final featureName in features.featureNames) {
      final value = features.features[featureName];
      if (value is num) {
        inputData.add(value.toDouble());
      } else if (value is List<num>) {
        inputData.addAll(value.map((v) => v.toDouble()));
      }
    }
    
    return [inputData];
  }

  MLPrediction _processOutput(List<List<double>> output) {
    final predictions = output.first;
    
    return MLPrediction(
      values: predictions,
      confidence: _calculateConfidence(predictions),
      lowerBounds: _calculateLowerBounds(predictions),
      upperBounds: _calculateUpperBounds(predictions),
    );
  }
}

@freezed
class MLPrediction with _$MLPrediction {
  const factory MLPrediction({
    required List<double> values,
    required double confidence,
    List<double>? lowerBounds,
    List<double>? upperBounds,
  }) = _MLPrediction;
}
```

---

## Week 4-6: Intelligent Price Prediction & Market Analysis

### 2.1 Price Prediction Service
**File**: `lib/features/procurement/domain/services/price_prediction_service.dart`

```dart
class PricePredictionService {
  final MLModelService _mlModelService;
  final MarketDataService _marketDataService;
  final AnalyticsRepository _analyticsRepository;
  final SupplierRepository _supplierRepository;
  final Logger _logger;

  PricePredictionService({
    required MLModelService mlModelService,
    required MarketDataService marketDataService,
    required AnalyticsRepository analyticsRepository,
    required SupplierRepository supplierRepository,
    required Logger logger,
  }) : _mlModelService = mlModelService,
       _marketDataService = marketDataService,
       _analyticsRepository = analyticsRepository,
       _supplierRepository = supplierRepository,
       _logger = logger;

  /// Predict future prices for items
  Future<List<PricePrediction>> predictPrices({
    required List<String> itemIds,
    required int predictionHorizonDays,
    required List<String> supplierIds,
  }) async {
    final predictions = <PricePrediction>[];

    for (final itemId in itemIds) {
      for (final supplierId in supplierIds) {
        try {
          final prediction = await _predictItemPrice(
            itemId: itemId,
            supplierId: supplierId,
            horizonDays: predictionHorizonDays,
          );
          
          if (prediction != null) {
            predictions.add(prediction);
          }
        } catch (error) {
          _logger.e('Failed to predict price for item $itemId, supplier $supplierId: $error');
        }
      }
    }

    return predictions;
  }

  /// Predict optimal purchase timing
  Future<PurchaseTimingRecommendation> recommendPurchaseTiming({
    required String itemId,
    required double requiredQuantity,
    required DateTime latestRequiredDate,
    required List<String> supplierIds,
  }) async {
    final timingOptions = <PurchaseTimingOption>[];
    
    // Analyze different purchase timing scenarios
    for (int daysFromNow = 0; daysFromNow <= latestRequiredDate.difference(DateTime.now()).inDays; daysFromNow += 7) {
      final purchaseDate = DateTime.now().add(Duration(days: daysFromNow));
      
      // Get price predictions for this date
      final pricePredictions = await predictPrices(
        itemIds: [itemId],
        predictionHorizonDays: daysFromNow + 1,
        supplierIds: supplierIds,
      );

      // Calculate total cost and risk for this timing
      final option = await _calculateTimingOption(
        itemId: itemId,
        quantity: requiredQuantity,
        purchaseDate: purchaseDate,
        pricePredictions: pricePredictions,
      );

      timingOptions.add(option);
    }

    // Find optimal timing
    final optimalOption = _findOptimalTiming(timingOptions);

    return PurchaseTimingRecommendation(
      itemId: itemId,
      requiredQuantity: requiredQuantity,
      latestRequiredDate: latestRequiredDate,
      recommendedTiming: optimalOption,
      allOptions: timingOptions,
      confidence: optimalOption.confidence,
      potentialSavings: _calculatePotentialSavings(timingOptions),
      generatedAt: DateTime.now(),
    );
  }

  /// Analyze market trends and price volatility
  Future<MarketAnalysis> analyzeMarketTrends({
    required String itemCategory,
    required int analysisHorizonDays,
  }) async {
    // Get historical market data
    final marketData = await _marketDataService.getMarketData(
      category: itemCategory,
      startDate: DateTime.now().subtract(Duration(days: 365)),
      endDate: DateTime.now(),
    );

    // Get price volatility data
    final volatility = await _calculatePriceVolatility(marketData);

    // Get trend analysis
    final trends = await _analyzePriceTrends(marketData);

    // Get external factors impact
    const externalFactors = await _analyzeExternalFactors(itemCategory);

    // Generate market forecast
    final forecast = await _generateMarketForecast(
      itemCategory,
      analysisHorizonDays,
      marketData,
    );

    return MarketAnalysis(
      category: itemCategory,
      analysisHorizon: analysisHorizonDays,
      volatility: volatility,
      trends: trends,
      externalFactors: externalFactors,
      forecast: forecast,
      riskLevel: _assessMarketRisk(volatility, trends),
      recommendations: _generateMarketRecommendations(volatility, trends, forecast),
      generatedAt: DateTime.now(),
    );
  }

  /// Predict item price for specific supplier
  Future<PricePrediction?> _predictItemPrice({
    required String itemId,
    required String supplierId,
    required int horizonDays,
  }) async {
    // Get historical price data
    final priceHistory = await _analyticsRepository.getPriceHistory(
      itemId: itemId,
      supplierId: supplierId,
      startDate: DateTime.now().subtract(Duration(days: 365)),
      endDate: DateTime.now(),
    );

    if (priceHistory.isEmpty) return null;

    // Prepare features for ML model
    final features = await _preparePriceFeatures(
      itemId: itemId,
      supplierId: supplierId,
      priceHistory: priceHistory,
      horizonDays: horizonDays,
    );

    // Get ML model
    final item = await _getItemDetails(itemId);
    final model = await _mlModelService.getPricePredictionModel(item.category);

    // Make prediction
    final mlPrediction = await model.predict(features);

    // Get supplier-specific factors
    const supplier = await _supplierRepository.getSupplier(supplierId);
    final supplierFactors = await _getSupplierPriceFactors(supplier);

    // Adjust prediction based on supplier factors
    final adjustedPrediction = _adjustPredictionForSupplier(mlPrediction, supplierFactors);

    return PricePrediction(
      itemId: itemId,
      supplierId: supplierId,
      supplierName: supplier?.name ?? 'Unknown',
      currentPrice: priceHistory.last.price,
      predictedPrice: adjustedPrediction.values.first,
      priceChange: adjustedPrediction.values.first - priceHistory.last.price,
      priceChangePercentage: ((adjustedPrediction.values.first - priceHistory.last.price) / priceHistory.last.price) * 100,
      confidence: adjustedPrediction.confidence,
      predictionDate: DateTime.now().add(Duration(days: horizonDays)),
      factors: features.featureNames,
      generatedAt: DateTime.now(),
    );
  }

  /// Prepare features for price prediction
  Future<FeatureData> _preparePriceFeatures({
    required String itemId,
    required String supplierId,
    required List<PriceHistory> priceHistory,
    required int horizonDays,
  }) async {
    // Historical price features
    final priceFeatures = _extractPriceFeatures(priceHistory);

    // Market features
    final marketFeatures = await _getMarketFeatures(itemId);

    // Supplier features
    final supplierFeatures = await _getSupplierFeatures(supplierId);

    // Seasonal features
    final seasonalFeatures = await _getSeasonalFeatures(itemId);

    // Economic indicators
    final economicFeatures = await _getEconomicIndicators();

    return FeatureData(
      itemId: itemId,
      features: {
        ...priceFeatures,
        ...marketFeatures,
        ...supplierFeatures,
        ...seasonalFeatures,
        ...economicFeatures,
      },
      featureNames: [
        ...priceFeatures.keys,
        ...marketFeatures.keys,
        ...supplierFeatures.keys,
        ...seasonalFeatures.keys,
        ...economicFeatures.keys,
      ],
      timestamp: DateTime.now(),
    );
  }

  /// Calculate optimal purchase timing
  PurchaseTimingOption _findOptimalTiming(List<PurchaseTimingOption> options) {
    // Score each option based on cost, risk, and timing
    double bestScore = double.negativeInfinity;
    PurchaseTimingOption bestOption = options.first;

    for (final option in options) {
      final costScore = 1.0 - (option.totalCost / options.map((o) => o.totalCost).reduce(max));
      final riskScore = 1.0 - option.riskScore;
      final timingScore = option.daysUntilPurchase / options.map((o) => o.daysUntilPurchase).reduce(max);

      // Weighted score (cost: 50%, risk: 30%, timing: 20%)
      final totalScore = (costScore * 0.5) + (riskScore * 0.3) + (timingScore * 0.2);

      if (totalScore > bestScore) {
        bestScore = totalScore;
        bestOption = option;
      }
    }

    return bestOption.copyWith(confidence: bestScore);
  }
}

@freezed
class PricePrediction with _$PricePrediction {
  const factory PricePrediction({
    required String itemId,
    required String supplierId,
    required String supplierName,
    required double currentPrice,
    required double predictedPrice,
    required double priceChange,
    required double priceChangePercentage,
    required double confidence,
    required DateTime predictionDate,
    required List<String> factors,
    required DateTime generatedAt,
  }) = _PricePrediction;

  factory PricePrediction.fromJson(Map<String, dynamic> json) =>
      _$PricePredictionFromJson(json);
}

@freezed
class PurchaseTimingRecommendation with _$PurchaseTimingRecommendation {
  const factory PurchaseTimingRecommendation({
    required String itemId,
    required double requiredQuantity,
    required DateTime latestRequiredDate,
    required PurchaseTimingOption recommendedTiming,
    required List<PurchaseTimingOption> allOptions,
    required double confidence,
    required double potentialSavings,
    required DateTime generatedAt,
  }) = _PurchaseTimingRecommendation;
}

@freezed
class PurchaseTimingOption with _$PurchaseTimingOption {
  const factory PurchaseTimingOption({
    required DateTime purchaseDate,
    required int daysUntilPurchase,
    required double predictedPrice,
    required double totalCost,
    required double riskScore,
    required double confidence,
    required String reasoning,
  }) = _PurchaseTimingOption;
}

@freezed
class MarketAnalysis with _$MarketAnalysis {
  const factory MarketAnalysis({
    required String category,
    required int analysisHorizon,
    required PriceVolatility volatility,
    required List<PriceTrend> trends,
    required List<ExternalFactor> externalFactors,
    required MarketForecast forecast,
    required MarketRiskLevel riskLevel,
    required List<MarketRecommendation> recommendations,
    required DateTime generatedAt,
  }) = _MarketAnalysis;
}

enum MarketRiskLevel { low, medium, high, extreme }
```

---

## Week 7-9: AI-Powered Supplier Risk Assessment

### 3.1 Intelligent Risk Assessment Service
**File**: `lib/features/procurement/domain/services/ai_risk_assessment_service.dart`

```dart
class AIRiskAssessmentService {
  final MLModelService _mlModelService;
  final SupplierRepository _supplierRepository;
  final ExternalDataService _externalDataService;
  final AnalyticsRepository _analyticsRepository;
  final Logger _logger;

  AIRiskAssessmentService({
    required MLModelService mlModelService,
    required SupplierRepository supplierRepository,
    required ExternalDataService externalDataService,
    required AnalyticsRepository analyticsRepository,
    required Logger logger,
  }) : _mlModelService = mlModelService,
       _supplierRepository = supplierRepository,
       _externalDataService = externalDataService,
       _analyticsRepository = analyticsRepository,
       _logger = logger;

  /// Comprehensive AI-powered supplier risk assessment
  Future<SupplierRiskAssessment> assessSupplierRisk({
    required String supplierId,
    required RiskAssessmentScope scope,
  }) async {
    final supplier = await _supplierRepository.getSupplier(supplierId);
    if (supplier == null) {
      throw Exception('Supplier not found: $supplierId');
    }

    // Gather risk data from multiple sources
    final riskData = await _gatherRiskData(supplier, scope);

    // Prepare features for ML model
    final features = await _prepareRiskFeatures(supplier, riskData);

    // Get AI risk model
    final model = await _mlModelService.getSupplierRiskModel();

    // Generate AI risk prediction
    final aiPrediction = await model.predict(features);

    // Calculate individual risk categories
    final financialRisk = await _assessFinancialRisk(supplier, riskData);
    final operationalRisk = await _assessOperationalRisk(supplier, riskData);
    final complianceRisk = await _assessComplianceRisk(supplier, riskData);
    final geopoliticalRisk = await _assessGeopoliticalRisk(supplier, riskData);
    final reputationalRisk = await _assessReputationalRisk(supplier, riskData);
    final cyberSecurityRisk = await _assessCyberSecurityRisk(supplier, riskData);

    // Combine AI prediction with rule-based assessments
    final overallRisk = _combineRiskAssessments(
      aiPrediction,
      [financialRisk, operationalRisk, complianceRisk, geopoliticalRisk, reputationalRisk, cyberSecurityRisk],
    );

    // Generate risk mitigation recommendations
    final mitigationStrategies = await _generateMitigationStrategies(
      supplier,
      overallRisk,
      [financialRisk, operationalRisk, complianceRisk, geopoliticalRisk, reputationalRisk, cyberSecurityRisk],
    );

    // Calculate risk trend
    final riskTrend = await _calculateRiskTrend(supplierId);

    return SupplierRiskAssessment(
      supplier: supplier,
      overallRiskScore: overallRisk.score,
      riskLevel: overallRisk.level,
      confidence: aiPrediction.confidence,
      riskCategories: {
        'financial': financialRisk,
        'operational': operationalRisk,
        'compliance': complianceRisk,
        'geopolitical': geopoliticalRisk,
        'reputational': reputationalRisk,
        'cybersecurity': cyberSecurityRisk,
      },
      riskTrend: riskTrend,
      mitigationStrategies: mitigationStrategies,
      dataQuality: riskData.quality,
      lastUpdated: DateTime.now(),
      nextAssessmentDate: DateTime.now().add(Duration(days: 30)),
      alerts: await _generateRiskAlerts(supplier, overallRisk),
    );
  }

  /// Real-time risk monitoring
  Stream<List<RiskAlert>> watchRiskAlerts() {
    return Stream.periodic(Duration(hours: 6), (_) async {
      final alerts = <RiskAlert>[];
      final suppliers = await _supplierRepository.getActiveSuppliers();

      for (final supplier in suppliers) {
        try {
          // Check for new risk indicators
          final newRisks = await _checkNewRiskIndicators(supplier);
          alerts.addAll(newRisks);

          // Check external risk sources
          final externalRisks = await _checkExternalRiskSources(supplier);
          alerts.addAll(externalRisks);

          // Check performance degradation
          final performanceRisks = await _checkPerformanceDegradation(supplier);
          alerts.addAll(performanceRisks);

        } catch (error) {
          _logger.e('Error monitoring risk for supplier ${supplier.id}: $error');
        }
      }

      return alerts;
    }).asyncMap((future) => future);
  }

  /// Gather comprehensive risk data
  Future<RiskData> _gatherRiskData(Supplier supplier, RiskAssessmentScope scope) async {
    final data = RiskData(supplierId: supplier.id);

    // Financial data
    if (scope.includeFinancial) {
      data.financialData = await _externalDataService.getFinancialData(supplier);
    }

    // Credit ratings
    if (scope.includeCreditRating) {
      data.creditRating = await _externalDataService.getCreditRating(supplier);
    }

    // News and media sentiment
    if (scope.includeMediaSentiment) {
      data.mediaSentiment = await _externalDataService.getMediaSentiment(supplier);
    }

    // Regulatory compliance
    if (scope.includeCompliance) {
      data.complianceRecords = await _externalDataService.getComplianceRecords(supplier);
    }

    // Geopolitical factors
    if (scope.includeGeopolitical) {
      data.geopoliticalFactors = await _externalDataService.getGeopoliticalFactors(supplier.location);
    }

    // Cybersecurity posture
    if (scope.includeCybersecurity) {
      data.cybersecurityData = await _externalDataService.getCybersecurityData(supplier);
    }

    // Historical performance
    data.performanceHistory = await _analyticsRepository.getSupplierPerformanceHistory(supplier.id);

    // Supply chain dependencies
    data.supplyChainData = await _analyzeSupplyChainDependencies(supplier);

    return data;
  }

  /// Assess financial risk using AI and traditional metrics
  Future<RiskCategory> _assessFinancialRisk(Supplier supplier, RiskData riskData) async {
    final indicators = <RiskIndicator>[];
    double totalScore = 0.0;

    // Credit rating analysis
    if (riskData.creditRating != null) {
      final creditScore = _evaluateCreditRating(riskData.creditRating!);
      indicators.add(RiskIndicator(
        name: 'Credit Rating',
        score: creditScore,
        weight: 0.3,
        description: 'Credit rating from external agencies',
      ));
      totalScore += creditScore * 0.3;
    }

    // Financial ratios analysis
    if (riskData.financialData != null) {
      final ratiosScore = _evaluateFinancialRatios(riskData.financialData!);
      indicators.add(RiskIndicator(
        name: 'Financial Ratios',
        score: ratiosScore,
        weight: 0.25,
        description: 'Liquidity, profitability, and leverage ratios',
      ));
      totalScore += ratiosScore * 0.25;
    }

    // Payment history analysis
    final paymentScore = await _evaluatePaymentHistory(supplier.id);
    indicators.add(RiskIndicator(
      name: 'Payment History',
      score: paymentScore,
      weight: 0.2,
      description: 'Historical payment behavior and disputes',
    ));
    totalScore += paymentScore * 0.2;

    // Market position analysis
    final marketScore = await _evaluateMarketPosition(supplier);
    indicators.add(RiskIndicator(
      name: 'Market Position',
      score: marketScore,
      weight: 0.15,
      description: 'Market share and competitive position',
    ));
    totalScore += marketScore * 0.15;

    // Revenue concentration risk
    final concentrationScore = await _evaluateRevenueConcentration(supplier);
    indicators.add(RiskIndicator(
      name: 'Revenue Concentration',
      score: concentrationScore,
      weight: 0.1,
      description: 'Customer concentration and dependency risk',
    ));
    totalScore += concentrationScore * 0.1;

    return RiskCategory(
      name: 'Financial Risk',
      score: totalScore,
      level: _scoreToRiskLevel(totalScore),
      indicators: indicators,
      trend: await _calculateCategoryTrend(supplier.id, 'financial'),
      lastUpdated: DateTime.now(),
    );
  }

  /// Generate AI-powered mitigation strategies
  Future<List<RiskMitigationStrategy>> _generateMitigationStrategies(
    Supplier supplier,
    RiskAssessment overallRisk,
    List<RiskCategory> riskCategories,
  ) async {
    final strategies = <RiskMitigationStrategy>[];

    // High-risk categories need immediate attention
    final highRiskCategories = riskCategories.where((cat) => cat.level == RiskLevel.high || cat.level == RiskLevel.critical);

    for (final category in highRiskCategories) {
      switch (category.name.toLowerCase()) {
        case 'financial':
          strategies.addAll(await _generateFinancialMitigationStrategies(supplier, category));
          break;
        case 'operational':
          strategies.addAll(await _generateOperationalMitigationStrategies(supplier, category));
          break;
        case 'compliance':
          strategies.addAll(await _generateComplianceMitigationStrategies(supplier, category));
          break;
        case 'geopolitical':
          strategies.addAll(await _generateGeopoliticalMitigationStrategies(supplier, category));
          break;
        case 'reputational':
          strategies.addAll(await _generateReputationalMitigationStrategies(supplier, category));
          break;
        case 'cybersecurity':
          strategies.addAll(await _generateCybersecurityMitigationStrategies(supplier, category));
          break;
      }
    }

    // AI-generated strategies based on similar suppliers
    final aiStrategies = await _generateAIMitigationStrategies(supplier, overallRisk);
    strategies.addAll(aiStrategies);

    // Prioritize and rank strategies
    return _prioritizeStrategies(strategies);
  }

  /// Generate financial mitigation strategies
  Future<List<RiskMitigationStrategy>> _generateFinancialMitigationStrategies(
    Supplier supplier,
    RiskCategory financialRisk,
  ) async {
    final strategies = <RiskMitigationStrategy>[];

    // Credit insurance
    if (financialRisk.score > 0.7) {
      strategies.add(RiskMitigationStrategy(
        type: MitigationType.insurance,
        title: 'Credit Insurance',
        description: 'Obtain credit insurance to protect against supplier default',
        priority: MitigationPriority.high,
        estimatedCost: 'Low',
        timeframe: '2-4 weeks',
        effectiveness: 0.8,
        actions: [
          'Research credit insurance providers',
          'Obtain quotes for supplier coverage',
          'Implement credit insurance policy',
        ],
      ));
    }

    // Payment terms adjustment
    strategies.add(RiskMitigationStrategy(
      type: MitigationType.contractual,
      title: 'Adjust Payment Terms',
      description: 'Modify payment terms to reduce financial exposure',
      priority: MitigationPriority.medium,
      estimatedCost: 'None',
      timeframe: '1-2 weeks',
      effectiveness: 0.6,
      actions: [
        'Negotiate shorter payment terms',
        'Implement milestone-based payments',
        'Require performance guarantees',
      ],
    ));

    // Diversification strategy
    strategies.add(RiskMitigationStrategy(
      type: MitigationType.diversification,
      title: 'Supplier Diversification',
      description: 'Reduce dependency by identifying alternative suppliers',
      priority: MitigationPriority.medium,
      estimatedCost: 'Medium',
      timeframe: '4-8 weeks',
      effectiveness: 0.9,
      actions: [
        'Identify alternative suppliers',
        'Qualify backup suppliers',
        'Implement dual sourcing strategy',
      ],
    ));

    return strategies;
  }
}

@freezed
class SupplierRiskAssessment with _$SupplierRiskAssessment {
  const factory SupplierRiskAssessment({
    required Supplier supplier,
    required double overallRiskScore,
    required RiskLevel riskLevel,
    required double confidence,
    required Map<String, RiskCategory> riskCategories,
    required RiskTrend riskTrend,
    required List<RiskMitigationStrategy> mitigationStrategies,
    required DataQuality dataQuality,
    required DateTime lastUpdated,
    required DateTime nextAssessmentDate,
    required List<RiskAlert> alerts,
  }) = _SupplierRiskAssessment;

  factory SupplierRiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$SupplierRiskAssessmentFromJson(json);
}

@freezed
class RiskCategory with _$RiskCategory {
  const factory RiskCategory({
    required String name,
    required double score,
    required RiskLevel level,
    required List<RiskIndicator> indicators,
    required RiskTrend trend,
    required DateTime lastUpdated,
  }) = _RiskCategory;
}

@freezed
class RiskMitigationStrategy with _$RiskMitigationStrategy {
  const factory RiskMitigationStrategy({
    required MitigationType type,
    required String title,
    required String description,
    required MitigationPriority priority,
    required String estimatedCost,
    required String timeframe,
    required double effectiveness,
    required List<String> actions,
  }) = _RiskMitigationStrategy;
}

enum RiskLevel { low, medium, high, critical }
enum RiskTrend { improving, stable, deteriorating }
enum MitigationType { contractual, insurance, diversification, monitoring, operational }
enum MitigationPriority { low, medium, high, urgent }
```

---

## Week 10-12: Smart Contract Optimization & NLP

### 4.1 Contract Intelligence Service
**File**: `lib/features/procurement/domain/services/contract_intelligence_service.dart`

```dart
class ContractIntelligenceService {
  final NLPService _nlpService;
  final MLModelService _mlModelService;
  final ContractRepository _contractRepository;
  final LegalKnowledgeBase _legalKB;
  final Logger _logger;

  ContractIntelligenceService({
    required NLPService nlpService,
    required MLModelService mlModelService,
    required ContractRepository contractRepository,
    required LegalKnowledgeBase legalKB,
    required Logger logger,
  }) : _nlpService = nlpService,
       _mlModelService = mlModelService,
       _contractRepository = contractRepository,
       _legalKB = legalKB,
       _logger = logger;

  /// Analyze contract using NLP and AI
  Future<ContractAnalysis> analyzeContract({
    required String contractId,
    required Uint8List contractDocument,
    required String documentType,
  }) async {
    // Extract text from document
    final extractedText = await _nlpService.extractText(contractDocument, documentType);

    // Perform NLP analysis
    final nlpAnalysis = await _nlpService.analyzeContract(extractedText);

    // Extract key terms and clauses
    final keyTerms = await _extractKeyTerms(extractedText);
    final clauses = await _extractClauses(extractedText);

    // Risk analysis
    final riskAnalysis = await _analyzeContractRisks(extractedText, clauses);

    // Compliance check
    final complianceAnalysis = await _checkCompliance(extractedText, clauses);

    // Generate recommendations
    final recommendations = await _generateContractRecommendations(
      keyTerms,
      clauses,
      riskAnalysis,
      complianceAnalysis,
    );

    // Calculate contract score
    final contractScore = _calculateContractScore(riskAnalysis, complianceAnalysis);

    return ContractAnalysis(
      contractId: contractId,
      extractedText: extractedText,
      keyTerms: keyTerms,
      clauses: clauses,
      riskAnalysis: riskAnalysis,
      complianceAnalysis: complianceAnalysis,
      recommendations: recommendations,
      contractScore: contractScore,
      nlpConfidence: nlpAnalysis.confidence,
      analyzedAt: DateTime.now(),
    );
  }

  /// Extract key terms using NLP
  Future<List<ContractTerm>> _extractKeyTerms(String contractText) async {
    final terms = <ContractTerm>[];

    // Use NLP to identify key terms
    final entities = await _nlpService.extractNamedEntities(contractText);

    for (final entity in entities) {
      switch (entity.type) {
        case EntityType.money:
          terms.add(ContractTerm(
            type: TermType.financial,
            name: 'Contract Value',
            value: entity.text,
            confidence: entity.confidence,
            position: entity.position,
          ));
          break;
        case EntityType.date:
          terms.add(ContractTerm(
            type: TermType.temporal,
            name: 'Important Date',
            value: entity.text,
            confidence: entity.confidence,
            position: entity.position,
          ));
          break;
        case EntityType.organization:
          terms.add(ContractTerm(
            type: TermType.party,
            name: 'Organization',
            value: entity.text,
            confidence: entity.confidence,
            position: entity.position,
          ));
          break;
        case EntityType.location:
          terms.add(ContractTerm(
            type: TermType.location,
            name: 'Location',
            value: entity.text,
            confidence: entity.confidence,
            position: entity.position,
          ));
          break;
      }
    }

    // Extract payment terms
    final paymentTerms = await _extractPaymentTerms(contractText);
    terms.addAll(paymentTerms);

    // Extract delivery terms
    final deliveryTerms = await _extractDeliveryTerms(contractText);
    terms.addAll(deliveryTerms);

    return terms;
  }

  /// Extract contract clauses
  Future<List<ContractClause>> _extractClauses(String contractText) async {
    final clauses = <ContractClause>[];

    // Use ML model to identify clause types
    final clauseModel = await _mlModelService.getContractClauseModel();
    final sentences = await _nlpService.splitIntoSentences(contractText);

    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i];
      
      // Classify clause type
      final classification = await clauseModel.classifyClause(sentence);
      
      if (classification.confidence > 0.7) {
        clauses.add(ContractClause(
          type: classification.clauseType,
          text: sentence,
          position: i,
          confidence: classification.confidence,
          riskLevel: await _assessClauseRisk(sentence, classification.clauseType),
          suggestions: await _generateClauseSuggestions(sentence, classification.clauseType),
        ));
      }
    }

    return clauses;
  }

  /// Analyze contract risks using AI
  Future<ContractRiskAnalysis> _analyzeContractRisks(
    String contractText,
    List<ContractClause> clauses,
  ) async {
    final risks = <ContractRisk>[];

    // Analyze each clause for risks
    for (final clause in clauses) {
      final clauseRisks = await _analyzeClauseRisks(clause);
      risks.addAll(clauseRisks);
    }

    // Overall contract risk assessment
    final overallRisk = await _assessOverallContractRisk(contractText, risks);

    // Risk mitigation suggestions
    final mitigations = await _generateRiskMitigations(risks);

    return ContractRiskAnalysis(
      overallRiskScore: overallRisk.score,
      riskLevel: overallRisk.level,
      identifiedRisks: risks,
      mitigationSuggestions: mitigations,
      riskCategories: _categorizeRisks(risks),
      confidence: overallRisk.confidence,
    );
  }

  /// Check contract compliance
  Future<ContractComplianceAnalysis> _checkCompliance(
    String contractText,
    List<ContractClause> clauses,
  ) async {
    final complianceIssues = <ComplianceIssue>[];

    // Check against legal requirements
    final legalRequirements = await _legalKB.getApplicableRequirements();
    
    for (final requirement in legalRequirements) {
      final compliance = await _checkRequirementCompliance(contractText, requirement);
      
      if (!compliance.isCompliant) {
        complianceIssues.add(ComplianceIssue(
          requirement: requirement,
          severity: compliance.severity,
          description: compliance.description,
          suggestedFix: compliance.suggestedFix,
        ));
      }
    }

    // Check industry standards
    final industryStandards = await _legalKB.getIndustryStandards();
    
    for (final standard in industryStandards) {
      final compliance = await _checkStandardCompliance(clauses, standard);
      
      if (!compliance.isCompliant) {
        complianceIssues.add(ComplianceIssue(
          requirement: standard,
          severity: compliance.severity,
          description: compliance.description,
          suggestedFix: compliance.suggestedFix,
        ));
      }
    }

    final overallCompliance = _calculateOverallCompliance(complianceIssues);

    return ContractComplianceAnalysis(
      overallComplianceScore: overallCompliance.score,
      complianceLevel: overallCompliance.level,
      identifiedIssues: complianceIssues,
      requiredActions: _generateRequiredActions(complianceIssues),
      confidence: overallCompliance.confidence,
    );
  }

  /// Generate intelligent contract recommendations
  Future<List<ContractRecommendation>> _generateContractRecommendations(
    List<ContractTerm> keyTerms,
    List<ContractClause> clauses,
    ContractRiskAnalysis riskAnalysis,
    ContractComplianceAnalysis complianceAnalysis,
  ) async {
    final recommendations = <ContractRecommendation>[];

    // Risk-based recommendations
    for (final risk in riskAnalysis.identifiedRisks) {
      if (risk.severity == RiskSeverity.high || risk.severity == RiskSeverity.critical) {
        recommendations.add(ContractRecommendation(
          type: RecommendationType.riskMitigation,
          priority: RecommendationPriority.high,
          title: 'Mitigate ${risk.type} Risk',
          description: risk.description,
          suggestedAction: risk.mitigation,
          expectedBenefit: 'Reduce contract risk exposure',
          implementationEffort: 'Medium',
        ));
      }
    }

    // Compliance-based recommendations
    for (final issue in complianceAnalysis.identifiedIssues) {
      recommendations.add(ContractRecommendation(
        type: RecommendationType.compliance,
        priority: _severityToPriority(issue.severity),
        title: 'Address Compliance Issue',
        description: issue.description,
        suggestedAction: issue.suggestedFix,
        expectedBenefit: 'Ensure regulatory compliance',
        implementationEffort: 'Low',
      ));
    }

    // Optimization recommendations
    final optimizations = await _generateOptimizationRecommendations(keyTerms, clauses);
    recommendations.addAll(optimizations);

    // Best practice recommendations
    final bestPractices = await _generateBestPracticeRecommendations(clauses);
    recommendations.addAll(bestPractices);

    return _prioritizeRecommendations(recommendations);
  }

  /// Smart contract template generation
  Future<ContractTemplate> generateSmartTemplate({
    required String contractType,
    required Map<String, dynamic> parameters,
    required List<String> requiredClauses,
  }) async {
    // Get base template
    final baseTemplate = await _legalKB.getContractTemplate(contractType);

    // Customize template based on parameters
    final customizedTemplate = await _customizeTemplate(baseTemplate, parameters);

    // Add AI-recommended clauses
    final recommendedClauses = await _recommendAdditionalClauses(
      contractType,
      parameters,
      requiredClauses,
    );

    // Optimize clause language
    final optimizedClauses = await _optimizeClauseLanguage(
      customizedTemplate.clauses + recommendedClauses,
    );

    // Generate final template
    return ContractTemplate(
      type: contractType,
      version: '${baseTemplate.version}_ai_optimized',
      clauses: optimizedClauses,
      parameters: parameters,
      metadata: {
        'generated_by': 'ai_contract_intelligence',
        'base_template': baseTemplate.id,
        'optimization_level': 'high',
        'generated_at': DateTime.now().toIso8601String(),
      },
      riskScore: await _calculateTemplateRiskScore(optimizedClauses),
      complianceScore: await _calculateTemplateComplianceScore(optimizedClauses),
    );
  }
}

@freezed
class ContractAnalysis with _$ContractAnalysis {
  const factory ContractAnalysis({
    required String contractId,
    required String extractedText,
    required List<ContractTerm> keyTerms,
    required List<ContractClause> clauses,
    required ContractRiskAnalysis riskAnalysis,
    required ContractComplianceAnalysis complianceAnalysis,
    required List<ContractRecommendation> recommendations,
    required double contractScore,
    required double nlpConfidence,
    required DateTime analyzedAt,
  }) = _ContractAnalysis;
}

@freezed
class ContractTerm with _$ContractTerm {
  const factory ContractTerm({
    required TermType type,
    required String name,
    required String value,
    required double confidence,
    required int position,
  }) = _ContractTerm;
}

@freezed
class ContractClause with _$ContractClause {
  const factory ContractClause({
    required ClauseType type,
    required String text,
    required int position,
    required double confidence,
    required RiskLevel riskLevel,
    required List<String> suggestions,
  }) = _ContractClause;
}

enum TermType { financial, temporal, party, location, performance, penalty }
enum ClauseType { payment, delivery, warranty, liability, termination, dispute, force_majeure }
enum RiskSeverity { low, medium, high, critical }
```

---

## Testing & Deployment

### AI/ML Model Testing
**File**: `test/ai_ml/model_performance_test.dart`

```dart
void main() {
  group('AI/ML Model Performance Tests', () {
    test('demand forecasting model accuracy should be >80%', () async {
      final service = DemandForecastingService(
        inventoryRepository: MockInventoryRepository(),
        productionRepository: MockProductionRepository(),
        salesRepository: MockSalesRepository(),
        mlModelService: MockMLModelService(),
        analyticsRepository: MockAnalyticsRepository(),
        logger: MockLogger(),
      );

      // Test with historical data
      final forecasts = await service.generateDemandForecast(
        itemIds: ['test_item_1', 'test_item_2'],
        forecastHorizonDays: 30,
        granularity: ForecastGranularity.daily,
      );

      // Verify accuracy against known outcomes
      for (final forecast in forecasts) {
        expect(forecast.confidence, greaterThan(0.8));
        expect(forecast.predictions.isNotEmpty, true);
      }
    });

    test('price prediction model should complete within 2 seconds', () async {
      final service = PricePredictionService(
        mlModelService: MockMLModelService(),
        marketDataService: MockMarketDataService(),
        analyticsRepository: MockAnalyticsRepository(),
        supplierRepository: MockSupplierRepository(),
        logger: MockLogger(),
      );

      final stopwatch = Stopwatch()..start();
      
      await service.predictPrices(
        itemIds: ['item_1'],
        predictionHorizonDays: 7,
        supplierIds: ['supplier_1'],
      );
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('supplier risk assessment should identify high-risk suppliers', () async {
      final service = AIRiskAssessmentService(
        mlModelService: MockMLModelService(),
        supplierRepository: MockSupplierRepository(),
        externalDataService: MockExternalDataService(),
        analyticsRepository: MockAnalyticsRepository(),
        logger: MockLogger(),
      );

      final assessment = await service.assessSupplierRisk(
        supplierId: 'high_risk_supplier',
        scope: RiskAssessmentScope.comprehensive(),
      );

      expect(assessment.riskLevel, equals(RiskLevel.high));
      expect(assessment.mitigationStrategies.isNotEmpty, true);
    });

    test('contract analysis should extract key terms accurately', () async {
      final service = ContractIntelligenceService(
        nlpService: MockNLPService(),
        mlModelService: MockMLModelService(),
        contractRepository: MockContractRepository(),
        legalKB: MockLegalKnowledgeBase(),
        logger: MockLogger(),
      );

      final contractBytes = await loadTestContract();
      final analysis = await service.analyzeContract(
        contractId: 'test_contract',
        contractDocument: contractBytes,
        documentType: 'pdf',
      );

      expect(analysis.keyTerms.isNotEmpty, true);
      expect(analysis.clauses.isNotEmpty, true);
      expect(analysis.contractScore, greaterThan(0.0));
    });
  });
}
```

### Integration Tests
**File**: `integration_test/phase4_ai_integration_test.dart`

```dart
void main() {
  group('Phase 4 AI Integration Tests', () {
    testWidgets('should generate accurate demand forecasts', (tester) async {
      await setupTestData();
      
      await tester.pumpWidget(MyApp());
      
      // Navigate to demand forecasting
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Demand Forecast'));
      await tester.pumpAndSettle();
      
      // Generate forecast
      await tester.tap(find.text('Generate Forecast'));
      await tester.pumpAndSettle();
      
      // Verify forecast display
      expect(find.text('Forecast Generated'), findsOneWidget);
      expect(find.byType(Chart), findsAtLeastNWidgets(1));
    });

    testWidgets('should display price predictions', (tester) async {
      await setupPriceData();
      
      await tester.pumpWidget(MyApp());
      
      // Navigate to price predictions
      await tester.tap(find.text('Price Intelligence'));
      await tester.pumpAndSettle();
      
      // Verify price predictions are shown
      expect(find.text('Price Predictions'), findsOneWidget);
      expect(find.textContaining('Predicted Price'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show supplier risk assessments', (tester) async {
      await setupSupplierRiskData();
      
      await tester.pumpWidget(MyApp());
      
      // Navigate to supplier risk
      await tester.tap(find.text('Supplier Risk'));
      await tester.pumpAndSettle();
      
      // Verify risk assessment display
      expect(find.text('Risk Assessment'), findsOneWidget);
      expect(find.textContaining('Risk Level'), findsAtLeastNWidgets(1));
    });
  });
}
```

---

## Success Criteria

### Technical Metrics
- [ ] Demand forecasting accuracy >80% MAPE
- [ ] Price prediction models complete in <2 seconds
- [ ] Risk assessment processes 100+ suppliers in <5 minutes
- [ ] Contract analysis extracts key terms with >90% accuracy
- [ ] ML models update automatically with <1% performance degradation

### Business Metrics
- [ ] 60% improvement in demand planning accuracy
- [ ] 25% reduction in price volatility impact
- [ ] 40% faster supplier risk identification
- [ ] 70% reduction in contract review time
- [ ] 90% automation of routine risk assessments

### AI/ML Quality
- [ ] Model confidence scores >80% for all predictions
- [ ] Real-time inference latency <500ms
- [ ] Automated model retraining based on performance
- [ ] Explainable AI recommendations for all decisions
- [ ] Continuous learning from user feedback

---

*Phase 4 transforms procurement into an intelligent, predictive system that leverages AI and machine learning to make smarter decisions, reduce risks, and optimize outcomes.* 