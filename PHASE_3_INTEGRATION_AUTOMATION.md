# Phase 3: Advanced Integration & Automation
## Duration: 8-10 weeks | Priority: Medium | Risk: Medium

### Overview
Phase 3 focuses on advanced integration capabilities and intelligent automation features. This phase builds upon the enhanced workflows from Phase 2 and introduces deep integration with other modules, automated processes, and intelligent decision-making capabilities.

### Objectives
- Implement deep integration with inventory, production, and supplier modules
- Add intelligent automation for routine procurement tasks
- Create advanced vendor management and evaluation systems
- Implement automated reordering and demand forecasting integration
- Add contract management and compliance automation

### Technical Approach
- **Leverage existing module integrations** and extend them
- **Build on current event-driven architecture** for real-time updates
- **Use existing background processing** for automation tasks
- **Extend current analytics foundation** with predictive capabilities
- **Maintain system performance** while adding complex integrations

---

## Week 1-2: Deep Module Integration

### 1.1 Inventory Integration Enhancement
**File**: `lib/features/procurement/domain/services/inventory_integration_service.dart`

```dart
class InventoryIntegrationService {
  final InventoryRepository _inventoryRepository;
  final PurchaseOrderRepository _poRepository;
  final UnifiedDataManager _dataManager;
  final Logger _logger;

  InventoryIntegrationService({
    required InventoryRepository inventoryRepository,
    required PurchaseOrderRepository poRepository,
    required UnifiedDataManager dataManager,
    required Logger logger,
  }) : _inventoryRepository = inventoryRepository,
       _poRepository = poRepository,
       _dataManager = dataManager,
       _logger = logger;

  /// Automatically create POs based on inventory levels
  Future<List<PurchaseOrder>> generateAutomaticPurchaseOrders() async {
    final lowStockItems = await _inventoryRepository.getLowStockItems();
    final generatedPOs = <PurchaseOrder>[];

    // Group items by preferred supplier
    final itemsBySupplier = _groupItemsBySupplier(lowStockItems);

    for (final entry in itemsBySupplier.entries) {
      final supplierId = entry.key;
      final items = entry.value;

      try {
        final po = await _createPOForSupplier(supplierId, items);
        generatedPOs.add(po);
        
        // Emit domain event
        await _dataManager.publishEvent(
          ProcurementEvent.autoPoGenerated(
            poId: po.id,
            supplierId: supplierId,
            itemCount: items.length,
            totalValue: po.totalAmount,
          ),
        );
      } catch (error) {
        _logger.e('Failed to create auto PO for supplier $supplierId: $error');
      }
    }

    return generatedPOs;
  }

  /// Update inventory reservations when PO is approved
  Future<void> updateInventoryReservations(PurchaseOrder purchaseOrder) async {
    if (purchaseOrder.status != PurchaseOrderStatus.approved) return;

    for (final item in purchaseOrder.items) {
      try {
        await _inventoryRepository.createReservation(
          Reservation(
            id: '',
            itemId: item.itemId,
            quantity: item.quantity,
            reservationType: ReservationType.purchaseOrder,
            referenceId: purchaseOrder.id,
            expectedDate: purchaseOrder.deliveryDate,
            status: ReservationStatus.active,
            createdAt: DateTime.now(),
          ),
        );
      } catch (error) {
        _logger.e('Failed to create reservation for item ${item.itemId}: $error');
      }
    }
  }

  /// Process goods receipt and update inventory
  Future<void> processGoodsReceipt({
    required String purchaseOrderId,
    required List<GoodsReceiptItem> receivedItems,
    required String receivedBy,
    required DateTime receivedAt,
  }) async {
    final po = await _poRepository.getPurchaseOrderById(purchaseOrderId);
    if (po == null) throw Exception('Purchase order not found');

    // Create inventory movements for received items
    final movements = <InventoryMovement>[];
    
    for (final receivedItem in receivedItems) {
      final poItem = po.items.firstWhere(
        (item) => item.itemId == receivedItem.itemId,
        orElse: () => throw Exception('Item not found in PO'),
      );

      // Create goods receipt movement
      final movement = InventoryMovement(
        id: null,
        documentNumber: 'GR-${DateTime.now().millisecondsSinceEpoch}',
        movementDate: receivedAt,
        movementType: InventoryMovementType.purchaseReceipt,
        warehouseId: receivedItem.warehouseId,
        referenceNumber: po.poNumber,
        referenceType: 'purchase_order',
        reasonNotes: 'Goods receipt for PO ${po.poNumber}',
        items: [
          InventoryMovementItem(
            itemId: receivedItem.itemId,
            quantity: receivedItem.receivedQuantity,
            unit: poItem.unit,
            unitCost: poItem.unitPrice,
            totalCost: poItem.unitPrice * receivedItem.receivedQuantity,
            batchNumber: receivedItem.batchNumber,
            expiryDate: receivedItem.expiryDate,
            qualityStatus: receivedItem.qualityStatus,
          ),
        ],
        status: InventoryMovementStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        initiatingEmployeeId: receivedBy,
      );

      movements.add(movement);

      // Update inventory levels
      await _inventoryRepository.updateItemQuantity(
        receivedItem.itemId,
        receivedItem.receivedQuantity,
        InventoryMovementType.purchaseReceipt,
      );

      // Release reservations
      await _inventoryRepository.releaseReservation(
        itemId: receivedItem.itemId,
        referenceId: purchaseOrderId,
        quantity: receivedItem.receivedQuantity,
      );
    }

    // Create batch inventory movements
    await _inventoryRepository.createBatchMovements(movements);

    // Update PO status if fully received
    final isFullyReceived = _checkIfFullyReceived(po, receivedItems);
    if (isFullyReceived) {
      await _poRepository.updatePurchaseOrderStatus(
        purchaseOrderId,
        PurchaseOrderStatus.delivered,
      );
    }

    // Emit domain event
    await _dataManager.publishEvent(
      InventoryEvent.goodsReceived(
        poId: purchaseOrderId,
        items: receivedItems,
        receivedBy: receivedBy,
        receivedAt: receivedAt,
      ),
    );
  }

  /// Monitor inventory levels and suggest reorders
  Stream<List<ReorderSuggestion>> watchReorderSuggestions() {
    return _inventoryRepository.watchLowStockItems().map((lowStockItems) {
      return lowStockItems.map((item) {
        return ReorderSuggestion(
          itemId: item.id,
          itemName: item.name,
          currentQuantity: item.quantity,
          reorderPoint: item.reorderPoint,
          suggestedQuantity: _calculateSuggestedQuantity(item),
          preferredSupplierId: item.supplier,
          estimatedCost: _estimateReorderCost(item),
          urgency: _calculateUrgency(item),
          lastOrderDate: _getLastOrderDate(item.id),
        );
      }).toList();
    });
  }

  Map<String, List<InventoryItem>> _groupItemsBySupplier(
    List<InventoryItem> items
  ) {
    final grouped = <String, List<InventoryItem>>{};
    
    for (final item in items) {
      final supplierId = item.supplier ?? 'unknown';
      grouped.putIfAbsent(supplierId, () => []).add(item);
    }
    
    return grouped;
  }

  Future<PurchaseOrder> _createPOForSupplier(
    String supplierId,
    List<InventoryItem> items,
  ) async {
    final supplier = await _getSupplierDetails(supplierId);
    final poItems = items.map((item) {
      return PurchaseOrderItem(
        id: '',
        itemId: item.id,
        itemName: item.name,
        quantity: _calculateOrderQuantity(item),
        unit: item.unit,
        unitPrice: _getLastPurchasePrice(item.id) ?? 0.0,
        totalPrice: 0.0, // Will be calculated
        requiredByDate: DateTime.now().add(Duration(days: 7)),
        notes: 'Auto-generated based on low stock',
      );
    }).toList();

    // Calculate total amount
    final totalAmount = poItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    final po = PurchaseOrder(
      id: '',
      procurementPlanId: '',
      poNumber: 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
      requestDate: DateTime.now(),
      requestedBy: 'system_auto_reorder',
      supplierId: supplierId,
      supplierName: supplier?.name ?? 'Unknown Supplier',
      status: PurchaseOrderStatus.draft,
      items: poItems,
      totalAmount: totalAmount,
      reasonForRequest: 'Automatic reorder based on low stock levels',
      intendedUse: 'Inventory replenishment',
      quantityJustification: 'Items below reorder point',
      supportingDocuments: [],
    );

    return await _poRepository.createPurchaseOrder(po).then(
      (result) => result.data!,
    );
  }
}

@freezed
class GoodsReceiptItem with _$GoodsReceiptItem {
  const factory GoodsReceiptItem({
    required String itemId,
    required double receivedQuantity,
    required String warehouseId,
    String? batchNumber,
    DateTime? expiryDate,
    @Default(QualityStatus.pending) QualityStatus qualityStatus,
    String? notes,
  }) = _GoodsReceiptItem;

  factory GoodsReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$GoodsReceiptItemFromJson(json);
}

@freezed
class ReorderSuggestion with _$ReorderSuggestion {
  const factory ReorderSuggestion({
    required String itemId,
    required String itemName,
    required double currentQuantity,
    required double reorderPoint,
    required double suggestedQuantity,
    String? preferredSupplierId,
    required double estimatedCost,
    required ReorderUrgency urgency,
    DateTime? lastOrderDate,
  }) = _ReorderSuggestion;

  factory ReorderSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ReorderSuggestionFromJson(json);
}

enum ReorderUrgency { low, medium, high, critical }
```

### 1.2 Production Integration Service
**File**: `lib/features/procurement/domain/services/production_integration_service.dart`

```dart
class ProductionIntegrationService {
  final ProductionRepository _productionRepository;
  final BOMRepository _bomRepository;
  final ProcurementPlanRepository _procurementPlanRepository;
  final UnifiedDataManager _dataManager;

  ProductionIntegrationService({
    required ProductionRepository productionRepository,
    required BOMRepository bomRepository,
    required ProcurementPlanRepository procurementPlanRepository,
    required UnifiedDataManager dataManager,
  }) : _productionRepository = productionRepository,
       _bomRepository = bomRepository,
       _procurementPlanRepository = procurementPlanRepository,
       _dataManager = dataManager;

  /// Generate procurement plan from production schedule
  Future<ProcurementPlan> generateProcurementPlanFromProduction({
    required String productionPlanId,
    required DateTime planStartDate,
    required DateTime planEndDate,
  }) async {
    final productionPlan = await _productionRepository.getProductionPlan(productionPlanId);
    final procurementItems = <ProcurementPlanItem>[];

    for (final productionItem in productionPlan.items) {
      // Get BOM for the product
      final bom = await _bomRepository.getBOMByProductId(productionItem.productId);
      if (bom == null) continue;

      // Calculate material requirements
      final materialRequirements = _calculateMaterialRequirements(
        bom,
        productionItem.plannedQuantity,
      );

      for (final requirement in materialRequirements) {
        // Check current inventory levels
        final currentStock = await _getCurrentStock(requirement.materialId);
        final netRequirement = requirement.requiredQuantity - currentStock;

        if (netRequirement > 0) {
          final procurementItem = ProcurementPlanItem(
            id: '',
            itemId: requirement.materialId,
            itemName: requirement.materialName,
            quantity: netRequirement,
            unit: requirement.unit,
            preferredSupplierId: requirement.preferredSupplierId ?? '',
            preferredSupplierName: requirement.preferredSupplierName ?? '',
            estimatedUnitCost: requirement.estimatedCost,
            estimatedTotalCost: requirement.estimatedCost * netRequirement,
            requiredByDate: productionItem.plannedStartDate.subtract(
              Duration(days: requirement.leadTimeDays),
            ),
            urgency: _determineUrgency(productionItem.priority),
            productionPlanReference: productionPlanId,
            inventoryLevel: currentStock,
          );

          procurementItems.add(procurementItem);
        }
      }
    }

    // Create procurement plan
    final procurementPlan = ProcurementPlan(
      id: '',
      name: 'Production Plan ${productionPlan.name} - Procurement',
      creationDate: DateTime.now(),
      createdBy: 'system_production_integration',
      status: ProcurementPlanStatus.draft,
      items: procurementItems,
      estimatedTotalCost: procurementItems.fold<double>(
        0.0,
        (sum, item) => sum + item.estimatedTotalCost,
      ),
      notes: 'Auto-generated from production plan ${productionPlan.name}',
      requiredByDate: planStartDate,
    );

    final result = await _procurementPlanRepository.createProcurementPlan(procurementPlan);
    
    // Emit domain event
    await _dataManager.publishEvent(
      ProcurementEvent.planGeneratedFromProduction(
        procurementPlanId: result.id,
        productionPlanId: productionPlanId,
        itemCount: procurementItems.length,
        totalValue: procurementPlan.estimatedTotalCost,
      ),
    );

    return result;
  }

  /// Monitor production schedule changes and update procurement
  Stream<List<ProcurementAdjustment>> watchProductionChanges() {
    return _productionRepository.watchProductionScheduleChanges().asyncMap(
      (changes) async {
        final adjustments = <ProcurementAdjustment>[];

        for (final change in changes) {
          switch (change.type) {
            case ProductionChangeType.quantityIncrease:
              final adjustment = await _handleQuantityIncrease(change);
              if (adjustment != null) adjustments.add(adjustment);
              break;
            case ProductionChangeType.quantityDecrease:
              final adjustment = await _handleQuantityDecrease(change);
              if (adjustment != null) adjustments.add(adjustment);
              break;
            case ProductionChangeType.scheduleDelay:
              final adjustment = await _handleScheduleDelay(change);
              if (adjustment != null) adjustments.add(adjustment);
              break;
            case ProductionChangeType.scheduleAdvance:
              final adjustment = await _handleScheduleAdvance(change);
              if (adjustment != null) adjustments.add(adjustment);
              break;
          }
        }

        return adjustments;
      },
    );
  }

  /// Calculate material requirements from BOM
  List<MaterialRequirement> _calculateMaterialRequirements(
    BillOfMaterials bom,
    double productionQuantity,
  ) {
    final requirements = <MaterialRequirement>[];

    for (final bomItem in bom.items) {
      if (!bomItem.isActive) continue;

      final requiredQuantity = (bomItem.quantity * productionQuantity) / bom.baseQuantity;
      
      requirements.add(
        MaterialRequirement(
          materialId: bomItem.itemId,
          materialName: bomItem.itemName,
          requiredQuantity: requiredQuantity,
          unit: bomItem.unit,
          estimatedCost: bomItem.unitCost ?? 0.0,
          preferredSupplierId: bomItem.supplierCode,
          preferredSupplierName: bomItem.supplierName,
          leadTimeDays: bomItem.leadTimeDays ?? 7,
        ),
      );
    }

    return requirements;
  }

  Future<ProcurementAdjustment?> _handleQuantityIncrease(
    ProductionScheduleChange change,
  ) async {
    // Calculate additional material requirements
    final additionalMaterials = await _calculateAdditionalMaterials(
      change.productId,
      change.quantityDelta,
    );

    if (additionalMaterials.isEmpty) return null;

    return ProcurementAdjustment(
      type: ProcurementAdjustmentType.increaseQuantity,
      productionChangeId: change.id,
      affectedItems: additionalMaterials,
      reason: 'Production quantity increased by ${change.quantityDelta}',
      urgency: _determineAdjustmentUrgency(change),
      requiredByDate: change.newScheduledDate,
    );
  }
}

@freezed
class MaterialRequirement with _$MaterialRequirement {
  const factory MaterialRequirement({
    required String materialId,
    required String materialName,
    required double requiredQuantity,
    required String unit,
    required double estimatedCost,
    String? preferredSupplierId,
    String? preferredSupplierName,
    @Default(7) int leadTimeDays,
  }) = _MaterialRequirement;
}

@freezed
class ProcurementAdjustment with _$ProcurementAdjustment {
  const factory ProcurementAdjustment({
    required ProcurementAdjustmentType type,
    required String productionChangeId,
    required List<MaterialRequirement> affectedItems,
    required String reason,
    required AdjustmentUrgency urgency,
    required DateTime requiredByDate,
  }) = _ProcurementAdjustment;
}

enum ProcurementAdjustmentType {
  increaseQuantity,
  decreaseQuantity,
  advanceSchedule,
  delaySchedule,
}

enum AdjustmentUrgency { low, medium, high, critical }
```

---

## Week 3-4: Intelligent Automation

### 2.1 Smart Procurement Automation Engine
**File**: `lib/features/procurement/domain/services/smart_automation_service.dart`

```dart
class SmartProcurementAutomationService {
  final PurchaseOrderRepository _poRepository;
  final SupplierRepository _supplierRepository;
  final InventoryRepository _inventoryRepository;
  final AnalyticsRepository _analyticsRepository;
  final NotificationService _notificationService;
  final Logger _logger;

  SmartProcurementAutomationService({
    required PurchaseOrderRepository poRepository,
    required SupplierRepository supplierRepository,
    required InventoryRepository inventoryRepository,
    required AnalyticsRepository analyticsRepository,
    required NotificationService notificationService,
    required Logger logger,
  }) : _poRepository = poRepository,
       _supplierRepository = supplierRepository,
       _inventoryRepository = inventoryRepository,
       _analyticsRepository = analyticsRepository,
       _notificationService = notificationService,
       _logger = logger;

  /// Intelligent supplier selection based on multiple criteria
  Future<SupplierRecommendation> recommendSupplier({
    required String itemId,
    required double quantity,
    required DateTime requiredDate,
    required ProcurementPriority priority,
  }) async {
    final suppliers = await _supplierRepository.getSuppliersForItem(itemId);
    final recommendations = <SupplierScore>[];

    for (final supplier in suppliers) {
      final score = await _calculateSupplierScore(
        supplier,
        itemId,
        quantity,
        requiredDate,
        priority,
      );
      recommendations.add(score);
    }

    // Sort by total score (descending)
    recommendations.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return SupplierRecommendation(
      itemId: itemId,
      quantity: quantity,
      requiredDate: requiredDate,
      recommendations: recommendations,
      primaryRecommendation: recommendations.isNotEmpty ? recommendations.first : null,
      analysisDate: DateTime.now(),
    );
  }

  /// Auto-approve low-risk purchase orders
  Future<List<AutoApprovalResult>> processAutoApprovals() async {
    final pendingPOs = await _poRepository.getPendingApprovalPOs();
    final results = <AutoApprovalResult>[];

    for (final po in pendingPOs) {
      try {
        final riskAssessment = await _assessPORisk(po);
        
        if (riskAssessment.canAutoApprove) {
          await _autoApprovePO(po, riskAssessment);
          
          results.add(AutoApprovalResult(
            poId: po.id,
            poNumber: po.poNumber,
            approved: true,
            reason: 'Low risk - auto-approved',
            riskScore: riskAssessment.riskScore,
            criteria: riskAssessment.passedCriteria,
          ));
        } else {
          results.add(AutoApprovalResult(
            poId: po.id,
            poNumber: po.poNumber,
            approved: false,
            reason: riskAssessment.rejectionReason,
            riskScore: riskAssessment.riskScore,
            criteria: riskAssessment.failedCriteria,
          ));
        }
      } catch (error) {
        _logger.e('Error processing auto-approval for PO ${po.id}: $error');
        results.add(AutoApprovalResult(
          poId: po.id,
          poNumber: po.poNumber,
          approved: false,
          reason: 'Error during assessment: $error',
          riskScore: 1.0, // High risk due to error
          criteria: [],
        ));
      }
    }

    return results;
  }

  /// Smart contract renewal automation
  Future<List<ContractRenewalAction>> processContractRenewals() async {
    final expiringContracts = await _supplierRepository.getExpiringContracts(
      withinDays: 90,
    );
    
    final actions = <ContractRenewalAction>[];

    for (final contract in expiringContracts) {
      final performance = await _analyzeSupplierPerformance(contract.supplierId);
      final recommendation = _generateRenewalRecommendation(contract, performance);
      
      actions.add(ContractRenewalAction(
        contractId: contract.id,
        supplierId: contract.supplierId,
        supplierName: contract.supplierName,
        expiryDate: contract.expiryDate,
        recommendation: recommendation,
        performanceScore: performance.overallScore,
        autoRenewEligible: recommendation.autoRenewEligible,
        suggestedTerms: recommendation.suggestedTerms,
      ));

      // Auto-renew if eligible
      if (recommendation.autoRenewEligible) {
        await _initiateAutoRenewal(contract, recommendation);
      }
    }

    return actions;
  }

  /// Intelligent price monitoring and alerts
  Stream<List<PriceAlert>> watchPriceAlerts() {
    return Stream.periodic(Duration(hours: 6), (_) async {
      final alerts = <PriceAlert>[];
      final activeItems = await _inventoryRepository.getActiveItems();

      for (final item in activeItems) {
        final priceHistory = await _analyticsRepository.getPriceHistory(item.id);
        final currentPrice = await _getCurrentMarketPrice(item.id);
        
        if (currentPrice != null) {
          final priceChange = _analyzePriceChange(priceHistory, currentPrice);
          
          if (priceChange.isSignificant) {
            alerts.add(PriceAlert(
              itemId: item.id,
              itemName: item.name,
              currentPrice: currentPrice,
              previousPrice: priceChange.previousPrice,
              changePercentage: priceChange.changePercentage,
              trend: priceChange.trend,
              recommendation: priceChange.recommendation,
              alertLevel: priceChange.alertLevel,
              detectedAt: DateTime.now(),
            ));
          }
        }
      }

      return alerts;
    }).asyncMap((future) => future);
  }

  /// Calculate comprehensive supplier score
  Future<SupplierScore> _calculateSupplierScore(
    Supplier supplier,
    String itemId,
    double quantity,
    DateTime requiredDate,
    ProcurementPriority priority,
  ) async {
    // Get historical performance data
    final performance = await _analyticsRepository.getSupplierPerformance(
      supplier.id,
      itemId,
    );

    // Calculate individual scores (0.0 to 1.0)
    final priceScore = await _calculatePriceScore(supplier, itemId, quantity);
    final qualityScore = performance.qualityScore;
    final deliveryScore = performance.onTimeDeliveryRate;
    final reliabilityScore = performance.reliabilityScore;
    final capacityScore = await _calculateCapacityScore(supplier, quantity);
    final riskScore = 1.0 - performance.riskScore; // Invert risk (lower risk = higher score)

    // Apply weights based on priority
    final weights = _getPriorityWeights(priority);
    
    final totalScore = (priceScore * weights.priceWeight) +
                      (qualityScore * weights.qualityWeight) +
                      (deliveryScore * weights.deliveryWeight) +
                      (reliabilityScore * weights.reliabilityWeight) +
                      (capacityScore * weights.capacityWeight) +
                      (riskScore * weights.riskWeight);

    return SupplierScore(
      supplier: supplier,
      totalScore: totalScore,
      priceScore: priceScore,
      qualityScore: qualityScore,
      deliveryScore: deliveryScore,
      reliabilityScore: reliabilityScore,
      capacityScore: capacityScore,
      riskScore: riskScore,
      canMeetDeadline: await _canMeetDeadline(supplier, requiredDate),
      estimatedDeliveryDate: await _estimateDeliveryDate(supplier, requiredDate),
      confidence: _calculateConfidence(performance),
    );
  }

  /// Assess purchase order risk for auto-approval
  Future<RiskAssessment> _assessPORisk(PurchaseOrder po) async {
    final criteria = <String>[];
    final failedCriteria = <String>[];
    double riskScore = 0.0;

    // Amount-based risk
    if (po.totalAmount <= 5000) {
      criteria.add('Low amount (≤ \$5,000)');
    } else if (po.totalAmount <= 15000) {
      criteria.add('Medium amount (≤ \$15,000)');
      riskScore += 0.2;
    } else {
      failedCriteria.add('High amount (> \$15,000)');
      riskScore += 0.5;
    }

    // Supplier risk
    final supplier = await _supplierRepository.getSupplier(po.supplierId);
    if (supplier != null) {
      if (supplier.riskLevel == SupplierRiskLevel.low) {
        criteria.add('Low-risk supplier');
      } else if (supplier.riskLevel == SupplierRiskLevel.medium) {
        criteria.add('Medium-risk supplier');
        riskScore += 0.1;
      } else {
        failedCriteria.add('High-risk supplier');
        riskScore += 0.4;
      }
    }

    // Category risk
    final hasHighRiskItems = await _hasHighRiskItems(po.items);
    if (!hasHighRiskItems) {
      criteria.add('Standard risk items');
    } else {
      failedCriteria.add('High-risk items present');
      riskScore += 0.3;
    }

    // Historical performance
    final supplierPerformance = await _analyticsRepository.getSupplierPerformance(
      po.supplierId,
      null, // Overall performance
    );
    
    if (supplierPerformance.overallScore >= 0.8) {
      criteria.add('Excellent supplier performance');
    } else if (supplierPerformance.overallScore >= 0.6) {
      criteria.add('Good supplier performance');
      riskScore += 0.1;
    } else {
      failedCriteria.add('Poor supplier performance');
      riskScore += 0.3;
    }

    final canAutoApprove = riskScore <= 0.3 && failedCriteria.isEmpty;

    return RiskAssessment(
      riskScore: riskScore,
      canAutoApprove: canAutoApprove,
      passedCriteria: criteria,
      failedCriteria: failedCriteria,
      rejectionReason: canAutoApprove 
          ? null 
          : 'Risk score too high (${riskScore.toStringAsFixed(2)}) or failed criteria: ${failedCriteria.join(', ')}',
    );
  }

  Future<void> _autoApprovePO(PurchaseOrder po, RiskAssessment assessment) async {
    // Update PO status
    await _poRepository.updatePurchaseOrderStatus(
      po.id,
      PurchaseOrderStatus.approved,
    );

    // Create approval record
    final approvalAction = ApprovalAction(
      id: const Uuid().v4(),
      purchaseOrderId: po.id,
      userId: 'system_auto_approval',
      userName: 'Automated System',
      timestamp: DateTime.now(),
      decision: ApprovalStatus.approved,
      notes: 'Auto-approved: ${assessment.passedCriteria.join(', ')}',
      stage: ApprovalStage.completed,
      isBiometricallyValidated: false,
    );

    // Send notification
    await _notificationService.sendAutoApprovalNotification(
      po: po,
      approvalAction: approvalAction,
      riskAssessment: assessment,
    );

    _logger.i('Auto-approved PO ${po.poNumber} with risk score ${assessment.riskScore}');
  }
}

@freezed
class SupplierScore with _$SupplierScore {
  const factory SupplierScore({
    required Supplier supplier,
    required double totalScore,
    required double priceScore,
    required double qualityScore,
    required double deliveryScore,
    required double reliabilityScore,
    required double capacityScore,
    required double riskScore,
    required bool canMeetDeadline,
    required DateTime estimatedDeliveryDate,
    required double confidence,
  }) = _SupplierScore;
}

@freezed
class SupplierRecommendation with _$SupplierRecommendation {
  const factory SupplierRecommendation({
    required String itemId,
    required double quantity,
    required DateTime requiredDate,
    required List<SupplierScore> recommendations,
    SupplierScore? primaryRecommendation,
    required DateTime analysisDate,
  }) = _SupplierRecommendation;
}

@freezed
class AutoApprovalResult with _$AutoApprovalResult {
  const factory AutoApprovalResult({
    required String poId,
    required String poNumber,
    required bool approved,
    required String reason,
    required double riskScore,
    required List<String> criteria,
  }) = _AutoApprovalResult;
}

@freezed
class RiskAssessment with _$RiskAssessment {
  const factory RiskAssessment({
    required double riskScore,
    required bool canAutoApprove,
    required List<String> passedCriteria,
    required List<String> failedCriteria,
    String? rejectionReason,
  }) = _RiskAssessment;
}
```

---

## Week 5-6: Advanced Vendor Management

### 3.1 Comprehensive Supplier Evaluation System
**File**: `lib/features/procurement/domain/services/supplier_evaluation_service.dart`

```dart
class SupplierEvaluationService {
  final SupplierRepository _supplierRepository;
  final PurchaseOrderRepository _poRepository;
  final QualityRepository _qualityRepository;
  final AnalyticsRepository _analyticsRepository;
  final Logger _logger;

  SupplierEvaluationService({
    required SupplierRepository supplierRepository,
    required PurchaseOrderRepository poRepository,
    required QualityRepository qualityRepository,
    required AnalyticsRepository analyticsRepository,
    required Logger logger,
  }) : _supplierRepository = supplierRepository,
       _poRepository = poRepository,
       _qualityRepository = qualityRepository,
       _analyticsRepository = analyticsRepository,
       _logger = logger;

  /// Comprehensive supplier performance evaluation
  Future<SupplierEvaluation> evaluateSupplier({
    required String supplierId,
    required DateTime evaluationPeriodStart,
    required DateTime evaluationPeriodEnd,
  }) async {
    final supplier = await _supplierRepository.getSupplier(supplierId);
    if (supplier == null) {
      throw Exception('Supplier not found: $supplierId');
    }

    // Get all POs for the evaluation period
    final pos = await _poRepository.getPurchaseOrders(
      supplierId: supplierId,
      fromDate: evaluationPeriodStart,
      toDate: evaluationPeriodEnd,
    );

    if (pos.isEmpty) {
      return SupplierEvaluation.noData(
        supplier: supplier,
        evaluationPeriod: DateRange(evaluationPeriodStart, evaluationPeriodEnd),
      );
    }

    // Calculate performance metrics
    final deliveryPerformance = await _evaluateDeliveryPerformance(pos.data!);
    final qualityPerformance = await _evaluateQualityPerformance(supplierId, pos.data!);
    final costPerformance = await _evaluateCostPerformance(pos.data!);
    final servicePerformance = await _evaluateServicePerformance(supplierId);
    final compliancePerformance = await _evaluateCompliancePerformance(supplierId);

    // Calculate overall score
    final overallScore = _calculateOverallScore([
      deliveryPerformance,
      qualityPerformance,
      costPerformance,
      servicePerformance,
      compliancePerformance,
    ]);

    // Generate recommendations
    final recommendations = _generateRecommendations(
      supplier,
      deliveryPerformance,
      qualityPerformance,
      costPerformance,
      servicePerformance,
      compliancePerformance,
    );

    // Determine supplier tier
    final tier = _determineSupplierTier(overallScore);

    return SupplierEvaluation(
      supplier: supplier,
      evaluationPeriod: DateRange(evaluationPeriodStart, evaluationPeriodEnd),
      overallScore: overallScore,
      tier: tier,
      deliveryPerformance: deliveryPerformance,
      qualityPerformance: qualityPerformance,
      costPerformance: costPerformance,
      servicePerformance: servicePerformance,
      compliancePerformance: compliancePerformance,
      recommendations: recommendations,
      evaluatedAt: DateTime.now(),
      totalOrderValue: pos.data!.fold<double>(0, (sum, po) => sum + po.totalAmount),
      totalOrders: pos.data!.length,
    );
  }

  /// Batch evaluate all suppliers
  Future<List<SupplierEvaluation>> evaluateAllSuppliers({
    required DateTime evaluationPeriodStart,
    required DateTime evaluationPeriodEnd,
  }) async {
    final suppliers = await _supplierRepository.getAllActiveSuppliers();
    final evaluations = <SupplierEvaluation>[];

    // Process in batches to avoid overwhelming the system
    const batchSize = 10;
    for (int i = 0; i < suppliers.length; i += batchSize) {
      final batch = suppliers.skip(i).take(batchSize);
      final batchEvaluations = await Future.wait(
        batch.map((supplier) => evaluateSupplier(
          supplierId: supplier.id,
          evaluationPeriodStart: evaluationPeriodStart,
          evaluationPeriodEnd: evaluationPeriodEnd,
        )),
      );
      evaluations.addAll(batchEvaluations);
    }

    return evaluations;
  }

  /// Generate supplier scorecard
  Future<SupplierScorecard> generateScorecard({
    required String supplierId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final evaluation = await evaluateSupplier(
      supplierId: supplierId,
      evaluationPeriodStart: periodStart,
      evaluationPeriodEnd: periodEnd,
    );

    final historicalTrend = await _getHistoricalTrend(supplierId);
    final benchmarkData = await _getBenchmarkData(evaluation.supplier.category);
    final actionItems = _generateActionItems(evaluation);

    return SupplierScorecard(
      evaluation: evaluation,
      historicalTrend: historicalTrend,
      benchmarkData: benchmarkData,
      actionItems: actionItems,
      nextReviewDate: DateTime.now().add(Duration(days: 90)),
      generatedAt: DateTime.now(),
    );
  }

  /// Evaluate delivery performance
  Future<PerformanceMetric> _evaluateDeliveryPerformance(
    List<PurchaseOrder> orders,
  ) async {
    if (orders.isEmpty) return PerformanceMetric.empty('Delivery');

    int onTimeDeliveries = 0;
    int totalDeliveries = 0;
    double totalDelayDays = 0;

    for (final order in orders) {
      if (order.deliveryDate != null && order.completionDate != null) {
        totalDeliveries++;
        
        final deliveryDelay = order.completionDate!.difference(order.deliveryDate!).inDays;
        
        if (deliveryDelay <= 0) {
          onTimeDeliveries++;
        } else {
          totalDelayDays += deliveryDelay;
        }
      }
    }

    if (totalDeliveries == 0) return PerformanceMetric.empty('Delivery');

    final onTimeRate = onTimeDeliveries / totalDeliveries;
    final averageDelay = totalDelayDays / totalDeliveries;

    return PerformanceMetric(
      category: 'Delivery',
      score: onTimeRate,
      details: {
        'onTimeDeliveryRate': onTimeRate,
        'totalDeliveries': totalDeliveries,
        'onTimeDeliveries': onTimeDeliveries,
        'averageDelayDays': averageDelay,
      },
      grade: _scoreToGrade(onTimeRate),
      trend: await _calculateTrend('delivery', orders.first.supplierId),
    );
  }

  /// Evaluate quality performance
  Future<PerformanceMetric> _evaluateQualityPerformance(
    String supplierId,
    List<PurchaseOrder> orders,
  ) async {
    final qualityRecords = await _qualityRepository.getQualityRecords(
      supplierId: supplierId,
      orders: orders.map((o) => o.id).toList(),
    );

    if (qualityRecords.isEmpty) return PerformanceMetric.empty('Quality');

    int passedInspections = 0;
    int totalInspections = qualityRecords.length;
    double totalDefectRate = 0;

    for (final record in qualityRecords) {
      if (record.passed) {
        passedInspections++;
      }
      totalDefectRate += record.defectRate;
    }

    final passRate = passedInspections / totalInspections;
    final averageDefectRate = totalDefectRate / totalInspections;

    return PerformanceMetric(
      category: 'Quality',
      score: passRate,
      details: {
        'qualityPassRate': passRate,
        'totalInspections': totalInspections,
        'passedInspections': passedInspections,
        'averageDefectRate': averageDefectRate,
      },
      grade: _scoreToGrade(passRate),
      trend: await _calculateTrend('quality', supplierId),
    );
  }

  /// Generate improvement recommendations
  List<SupplierRecommendation> _generateRecommendations(
    Supplier supplier,
    PerformanceMetric delivery,
    PerformanceMetric quality,
    PerformanceMetric cost,
    PerformanceMetric service,
    PerformanceMetric compliance,
  ) {
    final recommendations = <SupplierRecommendation>[];

    // Delivery recommendations
    if (delivery.score < 0.8) {
      recommendations.add(SupplierRecommendation(
        category: 'Delivery',
        priority: RecommendationPriority.high,
        title: 'Improve Delivery Performance',
        description: 'On-time delivery rate is ${(delivery.score * 100).toStringAsFixed(1)}%. Target: 90%+',
        suggestedActions: [
          'Review delivery schedules with supplier',
          'Implement delivery performance tracking',
          'Consider backup suppliers for critical items',
        ],
        expectedImpact: 'Reduce stockouts and improve production planning',
        timeline: '30-60 days',
      ));
    }

    // Quality recommendations
    if (quality.score < 0.9) {
      recommendations.add(SupplierRecommendation(
        category: 'Quality',
        priority: RecommendationPriority.high,
        title: 'Enhance Quality Standards',
        description: 'Quality pass rate is ${(quality.score * 100).toStringAsFixed(1)}%. Target: 95%+',
        suggestedActions: [
          'Conduct supplier quality audit',
          'Implement quality improvement plan',
          'Provide quality training to supplier',
        ],
        expectedImpact: 'Reduce defects and rework costs',
        timeline: '60-90 days',
      ));
    }

    // Cost recommendations
    if (cost.score < 0.7) {
      recommendations.add(SupplierRecommendation(
        category: 'Cost',
        priority: RecommendationPriority.medium,
        title: 'Optimize Pricing',
        description: 'Cost performance below expectations',
        suggestedActions: [
          'Negotiate better pricing terms',
          'Explore volume discounts',
          'Consider alternative suppliers',
        ],
        expectedImpact: 'Reduce procurement costs by 5-10%',
        timeline: '90-120 days',
      ));
    }

    return recommendations;
  }

  SupplierTier _determineSupplierTier(double overallScore) {
    if (overallScore >= 0.9) return SupplierTier.strategic;
    if (overallScore >= 0.8) return SupplierTier.preferred;
    if (overallScore >= 0.7) return SupplierTier.approved;
    if (overallScore >= 0.6) return SupplierTier.conditional;
    return SupplierTier.underReview;
  }
}

@freezed
class SupplierEvaluation with _$SupplierEvaluation {
  const factory SupplierEvaluation({
    required Supplier supplier,
    required DateRange evaluationPeriod,
    required double overallScore,
    required SupplierTier tier,
    required PerformanceMetric deliveryPerformance,
    required PerformanceMetric qualityPerformance,
    required PerformanceMetric costPerformance,
    required PerformanceMetric servicePerformance,
    required PerformanceMetric compliancePerformance,
    required List<SupplierRecommendation> recommendations,
    required DateTime evaluatedAt,
    required double totalOrderValue,
    required int totalOrders,
  }) = _SupplierEvaluation;

  factory SupplierEvaluation.noData({
    required Supplier supplier,
    required DateRange evaluationPeriod,
  }) = _SupplierEvaluationNoData;
}

@freezed
class PerformanceMetric with _$PerformanceMetric {
  const factory PerformanceMetric({
    required String category,
    required double score,
    required Map<String, dynamic> details,
    required PerformanceGrade grade,
    required PerformanceTrend trend,
  }) = _PerformanceMetric;

  factory PerformanceMetric.empty(String category) = _PerformanceMetricEmpty;
}

enum SupplierTier { strategic, preferred, approved, conditional, underReview }
enum PerformanceGrade { excellent, good, satisfactory, needsImprovement, poor }
enum PerformanceTrend { improving, stable, declining }
enum RecommendationPriority { low, medium, high, critical }
```

---

## Week 7-8: Contract Management & Compliance

### 4.1 Automated Contract Management
**File**: `lib/features/procurement/domain/services/contract_management_service.dart`

```dart
class ContractManagementService {
  final ContractRepository _contractRepository;
  final SupplierRepository _supplierRepository;
  final ComplianceRepository _complianceRepository;
  final NotificationService _notificationService;
  final DocumentService _documentService;
  final Logger _logger;

  ContractManagementService({
    required ContractRepository contractRepository,
    required SupplierRepository supplierRepository,
    required ComplianceRepository complianceRepository,
    required NotificationService notificationService,
    required DocumentService documentService,
    required Logger logger,
  }) : _contractRepository = contractRepository,
       _supplierRepository = supplierRepository,
       _complianceRepository = complianceRepository,
       _notificationService = notificationService,
       _documentService = documentService,
       _logger = logger;

  /// Monitor contract lifecycle and automate renewals
  Stream<List<ContractAction>> watchContractLifecycle() {
    return Stream.periodic(Duration(hours: 24), (_) async {
      final actions = <ContractAction>[];

      // Check expiring contracts
      final expiringContracts = await _contractRepository.getExpiringContracts(
        withinDays: 90,
      );

      for (final contract in expiringContracts) {
        final action = await _processExpiringContract(contract);
        if (action != null) actions.add(action);
      }

      // Check compliance requirements
      final complianceActions = await _checkComplianceRequirements();
      actions.addAll(complianceActions);

      // Check performance milestones
      final milestoneActions = await _checkPerformanceMilestones();
      actions.addAll(milestoneActions);

      return actions;
    }).asyncMap((future) => future);
  }

  /// Automated contract renewal process
  Future<ContractRenewalResult> processContractRenewal({
    required String contractId,
    required RenewalDecision decision,
    Map<String, dynamic>? newTerms,
  }) async {
    final contract = await _contractRepository.getContract(contractId);
    if (contract == null) {
      throw Exception('Contract not found: $contractId');
    }

    switch (decision) {
      case RenewalDecision.autoRenew:
        return await _autoRenewContract(contract, newTerms);
      case RenewalDecision.renegotiate:
        return await _initiateRenegotiation(contract, newTerms);
      case RenewalDecision.terminate:
        return await _terminateContract(contract);
      case RenewalDecision.extend:
        return await _extendContract(contract, newTerms);
    }
  }

  /// Generate contract performance report
  Future<ContractPerformanceReport> generatePerformanceReport({
    required String contractId,
    required DateTime reportPeriodStart,
    required DateTime reportPeriodEnd,
  }) async {
    final contract = await _contractRepository.getContract(contractId);
    if (contract == null) {
      throw Exception('Contract not found: $contractId');
    }

    // Get performance data
    final deliveryMetrics = await _getDeliveryMetrics(contract, reportPeriodStart, reportPeriodEnd);
    final qualityMetrics = await _getQualityMetrics(contract, reportPeriodStart, reportPeriodEnd);
    final costMetrics = await _getCostMetrics(contract, reportPeriodStart, reportPeriodEnd);
    final complianceMetrics = await _getComplianceMetrics(contract, reportPeriodStart, reportPeriodEnd);

    // Calculate SLA compliance
    final slaCompliance = await _calculateSLACompliance(contract, reportPeriodStart, reportPeriodEnd);

    // Generate recommendations
    final recommendations = _generateContractRecommendations(
      contract,
      deliveryMetrics,
      qualityMetrics,
      costMetrics,
      complianceMetrics,
      slaCompliance,
    );

    return ContractPerformanceReport(
      contract: contract,
      reportPeriod: DateRange(reportPeriodStart, reportPeriodEnd),
      deliveryMetrics: deliveryMetrics,
      qualityMetrics: qualityMetrics,
      costMetrics: costMetrics,
      complianceMetrics: complianceMetrics,
      slaCompliance: slaCompliance,
      overallScore: _calculateOverallContractScore([
        deliveryMetrics.score,
        qualityMetrics.score,
        costMetrics.score,
        complianceMetrics.score,
      ]),
      recommendations: recommendations,
      generatedAt: DateTime.now(),
    );
  }

  /// Automated compliance monitoring
  Future<List<ComplianceAlert>> monitorCompliance() async {
    final alerts = <ComplianceAlert>[];
    final activeContracts = await _contractRepository.getActiveContracts();

    for (final contract in activeContracts) {
      // Check regulatory compliance
      final regulatoryAlerts = await _checkRegulatoryCompliance(contract);
      alerts.addAll(regulatoryAlerts);

      // Check contractual obligations
      final obligationAlerts = await _checkContractualObligations(contract);
      alerts.addAll(obligationAlerts);

      // Check certification requirements
      final certificationAlerts = await _checkCertificationRequirements(contract);
      alerts.addAll(certificationAlerts);

      // Check insurance requirements
      final insuranceAlerts = await _checkInsuranceRequirements(contract);
      alerts.addAll(insuranceAlerts);
    }

    return alerts;
  }

  /// Auto-renew eligible contracts
  Future<ContractRenewalResult> _autoRenewContract(
    Contract contract,
    Map<String, dynamic>? newTerms,
  ) async {
    try {
      // Create new contract version
      final renewedContract = contract.copyWith(
        version: contract.version + 1,
        startDate: contract.endDate,
        endDate: contract.endDate.add(contract.renewalPeriod ?? Duration(days: 365)),
        terms: newTerms ?? contract.terms,
        status: ContractStatus.active,
        renewedAt: DateTime.now(),
        renewalType: RenewalType.automatic,
      );

      // Save renewed contract
      final savedContract = await _contractRepository.createContract(renewedContract);

      // Update original contract status
      await _contractRepository.updateContractStatus(
        contract.id,
        ContractStatus.renewed,
      );

      // Generate renewal documents
      final documents = await _generateRenewalDocuments(savedContract);

      // Send notifications
      await _notificationService.sendContractRenewalNotification(
        contract: savedContract,
        renewalType: RenewalType.automatic,
      );

      _logger.i('Auto-renewed contract ${contract.contractNumber}');

      return ContractRenewalResult(
        success: true,
        renewedContract: savedContract,
        originalContract: contract,
        renewalType: RenewalType.automatic,
        documents: documents,
        message: 'Contract successfully auto-renewed',
      );
    } catch (error) {
      _logger.e('Failed to auto-renew contract ${contract.id}: $error');
      
      return ContractRenewalResult(
        success: false,
        originalContract: contract,
        renewalType: RenewalType.automatic,
        documents: [],
        message: 'Auto-renewal failed: $error',
      );
    }
  }

  /// Check regulatory compliance
  Future<List<ComplianceAlert>> _checkRegulatoryCompliance(Contract contract) async {
    final alerts = <ComplianceAlert>[];
    final regulations = await _complianceRepository.getApplicableRegulations(
      contract.category,
      contract.supplierLocation,
    );

    for (final regulation in regulations) {
      final compliance = await _complianceRepository.checkCompliance(
        contractId: contract.id,
        regulationId: regulation.id,
      );

      if (!compliance.isCompliant) {
        alerts.add(ComplianceAlert(
          type: ComplianceAlertType.regulatory,
          severity: compliance.severity,
          contractId: contract.id,
          title: 'Regulatory Compliance Issue',
          description: 'Contract ${contract.contractNumber} is not compliant with ${regulation.name}',
          regulation: regulation,
          dueDate: compliance.dueDate,
          requiredActions: compliance.requiredActions,
          detectedAt: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  /// Generate contract recommendations
  List<ContractRecommendation> _generateContractRecommendations(
    Contract contract,
    ContractMetric deliveryMetrics,
    ContractMetric qualityMetrics,
    ContractMetric costMetrics,
    ContractMetric complianceMetrics,
    SLACompliance slaCompliance,
  ) {
    final recommendations = <ContractRecommendation>[];

    // Performance-based recommendations
    if (deliveryMetrics.score < 0.8) {
      recommendations.add(ContractRecommendation(
        type: RecommendationType.performance,
        priority: RecommendationPriority.high,
        title: 'Improve Delivery Performance Clauses',
        description: 'Add stricter delivery performance requirements and penalties',
        suggestedActions: [
          'Include delivery performance KPIs in contract',
          'Add penalty clauses for late deliveries',
          'Implement delivery performance bonuses',
        ],
        expectedBenefit: 'Improve on-time delivery rate to 95%+',
      ));
    }

    // Cost optimization recommendations
    if (costMetrics.score < 0.7) {
      recommendations.add(ContractRecommendation(
        type: RecommendationType.cost,
        priority: RecommendationPriority.medium,
        title: 'Renegotiate Pricing Terms',
        description: 'Current pricing is above market rates',
        suggestedActions: [
          'Benchmark pricing against market rates',
          'Negotiate volume-based discounts',
          'Include price adjustment mechanisms',
        ],
        expectedBenefit: 'Reduce costs by 5-10%',
      ));
    }

    // Compliance recommendations
    if (complianceMetrics.score < 0.9) {
      recommendations.add(ContractRecommendation(
        type: RecommendationType.compliance,
        priority: RecommendationPriority.high,
        title: 'Strengthen Compliance Requirements',
        description: 'Enhance compliance monitoring and reporting',
        suggestedActions: [
          'Add regular compliance audits',
          'Include compliance reporting requirements',
          'Implement compliance penalties',
        ],
        expectedBenefit: 'Ensure 100% regulatory compliance',
      ));
    }

    return recommendations;
  }
}

@freezed
class ContractAction with _$ContractAction {
  const factory ContractAction({
    required ContractActionType type,
    required String contractId,
    required String title,
    required String description,
    required ActionPriority priority,
    required DateTime dueDate,
    required List<String> requiredActions,
    Map<String, dynamic>? metadata,
  }) = _ContractAction;
}

@freezed
class ContractRenewalResult with _$ContractRenewalResult {
  const factory ContractRenewalResult({
    required bool success,
    Contract? renewedContract,
    required Contract originalContract,
    required RenewalType renewalType,
    required List<ContractDocument> documents,
    required String message,
  }) = _ContractRenewalResult;
}

@freezed
class ComplianceAlert with _$ComplianceAlert {
  const factory ComplianceAlert({
    required ComplianceAlertType type,
    required ComplianceSeverity severity,
    required String contractId,
    required String title,
    required String description,
    Regulation? regulation,
    DateTime? dueDate,
    required List<String> requiredActions,
    required DateTime detectedAt,
  }) = _ComplianceAlert;
}

enum ContractActionType { renewal, compliance, performance, termination }
enum RenewalDecision { autoRenew, renegotiate, terminate, extend }
enum RenewalType { automatic, manual, negotiated }
enum ComplianceAlertType { regulatory, contractual, certification, insurance }
enum ComplianceSeverity { low, medium, high, critical }
enum ActionPriority { low, medium, high, urgent }
enum RecommendationType { performance, cost, compliance, risk }
```

---

## Testing & Deployment

### Integration Tests
**File**: `integration_test/phase3_integration_test.dart`

```dart
void main() {
  group('Phase 3 Integration Tests', () {
    testWidgets('should generate automatic purchase orders from inventory', (tester) async {
      // Setup low stock items
      await setupLowStockItems();
      
      await tester.pumpWidget(MyApp());
      
      // Trigger auto PO generation
      final integrationService = GetIt.instance<InventoryIntegrationService>();
      final generatedPOs = await integrationService.generateAutomaticPurchaseOrders();
      
      // Verify POs were created
      expect(generatedPOs.isNotEmpty, true);
      expect(generatedPOs.first.reasonForRequest, contains('low stock'));
    });

    testWidgets('should process goods receipt and update inventory', (tester) async {
      // Setup approved PO
      final po = await createTestPurchaseOrder(status: PurchaseOrderStatus.approved);
      
      // Process goods receipt
      final integrationService = GetIt.instance<InventoryIntegrationService>();
      await integrationService.processGoodsReceipt(
        purchaseOrderId: po.id,
        receivedItems: [
          GoodsReceiptItem(
            itemId: 'test_item_1',
            receivedQuantity: 100,
            warehouseId: 'warehouse_1',
          ),
        ],
        receivedBy: 'test_user',
        receivedAt: DateTime.now(),
      );
      
      // Verify inventory was updated
      final inventory = await getInventoryItem('test_item_1');
      expect(inventory.quantity, equals(100));
    });

    testWidgets('should auto-approve low-risk purchase orders', (tester) async {
      // Create low-risk PO
      final po = await createLowRiskPurchaseOrder();
      
      // Run auto-approval process
      final automationService = GetIt.instance<SmartProcurementAutomationService>();
      final results = await automationService.processAutoApprovals();
      
      // Verify auto-approval
      final approvedResult = results.firstWhere((r) => r.poId == po.id);
      expect(approvedResult.approved, true);
      expect(approvedResult.riskScore, lessThan(0.3));
    });

    testWidgets('should evaluate supplier performance', (tester) async {
      // Setup supplier with historical data
      await setupSupplierWithHistory();
      
      // Run evaluation
      final evaluationService = GetIt.instance<SupplierEvaluationService>();
      final evaluation = await evaluationService.evaluateSupplier(
        supplierId: 'test_supplier',
        evaluationPeriodStart: DateTime.now().subtract(Duration(days: 90)),
        evaluationPeriodEnd: DateTime.now(),
      );
      
      // Verify evaluation results
      expect(evaluation.overallScore, greaterThan(0.0));
      expect(evaluation.recommendations.isNotEmpty, true);
    });
  });
}
```

### Performance Tests
**File**: `test/performance/phase3_performance_test.dart`

```dart
void main() {
  group('Phase 3 Performance Tests', () {
    test('auto PO generation should handle 1000+ items efficiently', () async {
      final service = InventoryIntegrationService(
        inventoryRepository: MockInventoryRepository(),
        poRepository: MockPurchaseOrderRepository(),
        dataManager: MockUnifiedDataManager(),
        logger: MockLogger(),
      );

      // Setup 1000 low stock items
      final lowStockItems = List.generate(1000, (i) => createTestInventoryItem(id: 'item_$i'));
      when(service._inventoryRepository.getLowStockItems()).thenAnswer((_) async => lowStockItems);

      final stopwatch = Stopwatch()..start();
      
      final generatedPOs = await service.generateAutomaticPurchaseOrders();
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds max
      expect(generatedPOs.isNotEmpty, true);
    });

    test('supplier evaluation should complete within 5 seconds', () async {
      final service = SupplierEvaluationService(
        supplierRepository: MockSupplierRepository(),
        poRepository: MockPurchaseOrderRepository(),
        qualityRepository: MockQualityRepository(),
        analyticsRepository: MockAnalyticsRepository(),
        logger: MockLogger(),
      );

      final stopwatch = Stopwatch()..start();
      
      await service.evaluateSupplier(
        supplierId: 'test_supplier',
        evaluationPeriodStart: DateTime.now().subtract(Duration(days: 90)),
        evaluationPeriodEnd: DateTime.now(),
      );
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });
}
```

---

## Success Criteria

### Technical Metrics
- [ ] Auto PO generation processes 1000+ items in <10 seconds
- [ ] Goods receipt processing updates inventory in real-time
- [ ] Auto-approval processes 100+ POs in <30 seconds
- [ ] Supplier evaluation completes in <5 seconds per supplier
- [ ] Contract monitoring checks all contracts daily

### Business Metrics
- [ ] 80% reduction in manual PO creation for routine items
- [ ] 95% accuracy in auto-approval decisions
- [ ] 50% improvement in supplier performance tracking
- [ ] 90% compliance with contract terms and regulations
- [ ] 30% reduction in procurement cycle time

### Integration Quality
- [ ] Real-time synchronization with inventory module
- [ ] Seamless integration with production planning
- [ ] Automated supplier performance updates
- [ ] Contract lifecycle fully automated
- [ ] Compliance monitoring with zero false negatives

---

*Phase 3 transforms procurement into an intelligent, automated system that seamlessly integrates with all business operations while maintaining strict compliance and performance standards.* 