import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/bom_item.dart';

/// Comprehensive and robust data model for BOM Item that handles Firebase serialization
/// with enterprise-grade validation, business logic, and error handling
class BomItemModel {

  factory BomItemModel.fromJson(Map<String, dynamic> json) {
    return BomItemModel(
      id: json['id'] ?? '',
      bomId: json['bomId'] ?? '',
      itemId: json['itemId'] ?? '',
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      itemDescription: json['itemDescription'] ?? '',
      itemType: json['itemType'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      consumptionType: json['consumptionType'] ?? '',
      sequenceNumber: json['sequenceNumber'] ?? 0,
      wastagePercentage: (json['wastagePercentage'] ?? 0.0).toDouble(),
      yieldPercentage: (json['yieldPercentage'] ?? 0.0).toDouble(),
      costPerUnit: (json['costPerUnit'] ?? 0.0).toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      alternativeItemId: json['alternativeItemId'],
      supplierCode: json['supplierCode'],
      batchNumber: json['batchNumber'],
      expiryDate: _parseDateTime(json['expiryDate']),
      qualityGrade: json['qualityGrade'],
      storageLocation: json['storageLocation'],
      specifications: json['specifications'],
      qualityParameters: json['qualityParameters'],
      status: json['status'] ?? 'active',
      notes: json['notes'],
      effectiveFrom: _parseDateTime(json['effectiveFrom']),
      effectiveTo: _parseDateTime(json['effectiveTo']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      // Enhanced fields
      leadTime: json['leadTime'] ?? 0,
      minimumOrderQuantity: (json['minimumOrderQuantity'] ?? 0.0).toDouble(),
      maximumOrderQuantity: json['maximumOrderQuantity']?.toDouble(),
      reorderPoint: (json['reorderPoint'] ?? 0.0).toDouble(),
      safetyStock: (json['safetyStock'] ?? 0.0).toDouble(),
      standardCost: (json['standardCost'] ?? 0.0).toDouble(),
      lastCostUpdate: _parseDateTime(json['lastCostUpdate']),
      priceVariance: (json['priceVariance'] ?? 0.0).toDouble(),
      supplierPartNumber: json['supplierPartNumber'],
      manufacturerPartNumber: json['manufacturerPartNumber'],
      hazardousClassification: json['hazardousClassification'],
      shelfLife: json['shelfLife'],
      storageConditions: json['storageConditions'],
      handlingInstructions: json['handlingInstructions'],
      qualityControlRequired: json['qualityControlRequired'] ?? false,
      inspectionCriteria: json['inspectionCriteria'],
      certificationRequired: json['certificationRequired'] ?? false,
      certificationDetails: json['certificationDetails'],
      environmentalImpact: json['environmentalImpact'],
      carbonFootprint: (json['carbonFootprint'] ?? 0.0).toDouble(),
      recyclable: json['recyclable'] ?? false,
      substitutes: List<String>.from(json['substitutes'] ?? []),
      crossReferences: List<String>.from(json['crossReferences'] ?? []),
      usageHistory: List<Map<String, dynamic>>.from(json['usageHistory'] ?? []),
      costHistory: List<Map<String, dynamic>>.from(json['costHistory'] ?? []),
      supplierRating: (json['supplierRating'] ?? 0.0).toDouble(),
      qualityRating: (json['qualityRating'] ?? 0.0).toDouble(),
      deliveryRating: (json['deliveryRating'] ?? 0.0).toDouble(),
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
      complianceFlags: List<String>.from(json['complianceFlags'] ?? []),
      customAttributes:
          Map<String, dynamic>.from(json['customAttributes'] ?? {}),
      integrationData: Map<String, dynamic>.from(json['integrationData'] ?? {}),
      validationErrors: List<String>.from(json['validationErrors'] ?? []),
      auditTrail: Map<String, dynamic>.from(json['auditTrail'] ?? {}),
    );
  }

  /// Create from domain entity with comprehensive mapping
  factory BomItemModel.fromDomain(BomItem entity) {
    return BomItemModel(
      id: entity.id,
      bomId: entity.bomId,
      itemId: entity.itemId,
      itemCode: entity.itemCode,
      itemName: entity.itemName,
      itemDescription: entity.itemDescription,
      itemType: entity.itemType.name,
      quantity: entity.quantity,
      unit: entity.unit,
      consumptionType: entity.consumptionType.name,
      sequenceNumber: entity.sequenceNumber,
      wastagePercentage: entity.wastagePercentage,
      yieldPercentage: entity.yieldPercentage,
      costPerUnit: entity.costPerUnit,
      totalCost: entity.totalCost,
      alternativeItemId: entity.alternativeItemId,
      supplierCode: entity.supplierCode,
      batchNumber: entity.batchNumber,
      expiryDate: entity.expiryDate,
      qualityGrade: entity.qualityGrade,
      storageLocation: entity.storageLocation,
      specifications: entity.specifications,
      qualityParameters: entity.qualityParameters,
      status: entity.status.name,
      notes: entity.notes,
      effectiveFrom: entity.effectiveFrom,
      effectiveTo: entity.effectiveTo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }
  const BomItemModel({
    required this.id,
    required this.bomId,
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.itemDescription,
    required this.itemType,
    required this.quantity,
    required this.unit,
    required this.consumptionType,
    required this.sequenceNumber,
    this.wastagePercentage = 0.0,
    this.yieldPercentage = 0.0,
    this.costPerUnit = 0.0,
    this.totalCost = 0.0,
    this.alternativeItemId,
    this.supplierCode,
    this.batchNumber,
    this.expiryDate,
    this.qualityGrade,
    this.storageLocation,
    this.specifications,
    this.qualityParameters,
    this.status = 'active',
    this.notes,
    this.effectiveFrom,
    this.effectiveTo,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    // Enhanced fields for robustness
    this.leadTime = 0,
    this.minimumOrderQuantity = 0.0,
    this.maximumOrderQuantity,
    this.reorderPoint = 0.0,
    this.safetyStock = 0.0,
    this.standardCost = 0.0,
    this.lastCostUpdate,
    this.priceVariance = 0.0,
    this.supplierPartNumber,
    this.manufacturerPartNumber,
    this.hazardousClassification,
    this.shelfLife,
    this.storageConditions,
    this.handlingInstructions,
    this.qualityControlRequired = false,
    this.inspectionCriteria,
    this.certificationRequired = false,
    this.certificationDetails,
    this.environmentalImpact,
    this.carbonFootprint = 0.0,
    this.recyclable = false,
    this.substitutes = const [],
    this.crossReferences = const [],
    this.usageHistory = const [],
    this.costHistory = const [],
    this.supplierRating = 0.0,
    this.qualityRating = 0.0,
    this.deliveryRating = 0.0,
    this.riskFactors = const [],
    this.complianceFlags = const [],
    this.customAttributes = const {},
    this.integrationData = const {},
    this.validationErrors = const [],
    this.auditTrail = const {},
  });

  // Core BOM Item fields
  final String id;
  final String bomId;
  final String itemId;
  final String itemCode;
  final String itemName;
  final String itemDescription;
  final String itemType;
  final double quantity;
  final String unit;
  final String consumptionType;
  final int sequenceNumber;
  final double wastagePercentage;
  final double yieldPercentage;
  final double costPerUnit;
  final double totalCost;
  final String? alternativeItemId;
  final String? supplierCode;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? qualityGrade;
  final String? storageLocation;
  final Map<String, dynamic>? specifications;
  final Map<String, dynamic>? qualityParameters;
  final String status;
  final String? notes;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  // Enhanced fields for enterprise robustness
  final int leadTime; // in days
  final double minimumOrderQuantity;
  final double? maximumOrderQuantity;
  final double reorderPoint;
  final double safetyStock;
  final double standardCost;
  final DateTime? lastCostUpdate;
  final double priceVariance;
  final String? supplierPartNumber;
  final String? manufacturerPartNumber;
  final String? hazardousClassification;
  final int? shelfLife; // in days
  final Map<String, dynamic>? storageConditions;
  final Map<String, dynamic>? handlingInstructions;
  final bool qualityControlRequired;
  final Map<String, dynamic>? inspectionCriteria;
  final bool certificationRequired;
  final Map<String, dynamic>? certificationDetails;
  final Map<String, dynamic>? environmentalImpact;
  final double carbonFootprint;
  final bool recyclable;
  final List<String> substitutes;
  final List<String> crossReferences;
  final List<Map<String, dynamic>> usageHistory;
  final List<Map<String, dynamic>> costHistory;
  final double supplierRating; // 0-5 scale
  final double qualityRating; // 0-5 scale
  final double deliveryRating; // 0-5 scale
  final List<String> riskFactors;
  final List<String> complianceFlags;
  final Map<String, dynamic> customAttributes;
  final Map<String, dynamic> integrationData;
  final List<String> validationErrors;
  final Map<String, dynamic> auditTrail;

  /// Comprehensive validation of BOM Item data
  List<String> validate() {
    final errors = <String>[];

    // Basic field validation
    if (bomId.isEmpty) errors.add('BOM ID is required');
    if (itemId.isEmpty) errors.add('Item ID is required');
    if (itemCode.isEmpty) errors.add('Item code is required');
    if (itemName.isEmpty) errors.add('Item name is required');
    if (unit.isEmpty) errors.add('Unit is required');

    // Quantity validation
    if (quantity <= 0) errors.add('Quantity must be positive');
    if (minimumOrderQuantity < 0) {
      errors.add('Minimum order quantity cannot be negative');
    }
    if (maximumOrderQuantity != null &&
        maximumOrderQuantity! < minimumOrderQuantity) {
      errors.add('Maximum order quantity must be greater than minimum');
    }
    if (reorderPoint < 0) errors.add('Reorder point cannot be negative');
    if (safetyStock < 0) errors.add('Safety stock cannot be negative');

    // Cost validation
    if (costPerUnit < 0) errors.add('Cost per unit cannot be negative');
    if (standardCost < 0) errors.add('Standard cost cannot be negative');
    if (totalCost < 0) errors.add('Total cost cannot be negative');

    // Percentage validation
    if (wastagePercentage < 0 || wastagePercentage > 100) {
      errors.add('Wastage percentage must be between 0 and 100');
    }
    if (yieldPercentage < 0 || yieldPercentage > 100) {
      errors.add('Yield percentage must be between 0 and 100');
    }

    // Rating validation
    if (supplierRating < 0 || supplierRating > 5) {
      errors.add('Supplier rating must be between 0 and 5');
    }
    if (qualityRating < 0 || qualityRating > 5) {
      errors.add('Quality rating must be between 0 and 5');
    }
    if (deliveryRating < 0 || deliveryRating > 5) {
      errors.add('Delivery rating must be between 0 and 5');
    }

    // Date validation
    if (effectiveFrom != null && effectiveTo != null) {
      if (effectiveFrom!.isAfter(effectiveTo!)) {
        errors.add('Effective from date must be before effective to date');
      }
    }
    if (expiryDate != null && expiryDate!.isBefore(DateTime.now())) {
      errors.add('Item has expired');
    }

    // Status validation
    if (!_isValidStatus(status)) {
      errors.add('Invalid item status: $status');
    }

    // Type validation
    if (!_isValidItemType(itemType)) {
      errors.add('Invalid item type: $itemType');
    }

    // Consumption type validation
    if (!_isValidConsumptionType(consumptionType)) {
      errors.add('Invalid consumption type: $consumptionType');
    }

    // Lead time validation
    if (leadTime < 0) errors.add('Lead time cannot be negative');

    // Shelf life validation
    if (shelfLife != null && shelfLife! <= 0) {
      errors.add('Shelf life must be positive');
    }

    return errors;
  }

  /// Check if item is currently active and valid
  bool get isActive {
    return status == 'active' &&
        validate().isEmpty &&
        (effectiveFrom == null || effectiveFrom!.isBefore(DateTime.now())) &&
        (effectiveTo == null || effectiveTo!.isAfter(DateTime.now())) &&
        (expiryDate == null || expiryDate!.isAfter(DateTime.now()));
  }

  /// Check if item requires quality inspection
  bool get requiresQualityInspection {
    return qualityControlRequired ||
        certificationRequired ||
        hazardousClassification != null ||
        qualityParameters != null;
  }

  /// Calculate actual quantity needed considering wastage
  double calculateActualQuantity(double batchSize) {
    final baseQuantity = quantity * batchSize;
    final wastageAmount = baseQuantity * (wastagePercentage / 100);
    return baseQuantity + wastageAmount;
  }

  /// Calculate total cost for given batch size
  double calculateTotalCost(double batchSize) {
    final actualQuantity = calculateActualQuantity(batchSize);
    return actualQuantity * costPerUnit;
  }

  /// Get item criticality level
  String get criticalityLevel {
    int criticalityScore = 0;

    // High cost items are more critical
    if (costPerUnit > 100) {
      criticalityScore += 2;
    } else if (costPerUnit > 50) criticalityScore += 1;

    // Long lead time items are more critical
    if (leadTime > 30) {
      criticalityScore += 2;
    } else if (leadTime > 14) criticalityScore += 1;

    // Items with quality requirements are more critical
    if (requiresQualityInspection) criticalityScore += 1;

    // Hazardous items are more critical
    if (hazardousClassification != null) criticalityScore += 1;

    // Items with risk factors are more critical
    criticalityScore += riskFactors.length;

    if (criticalityScore >= 5) return 'Critical';
    if (criticalityScore >= 3) return 'High';
    if (criticalityScore >= 1) return 'Medium';
    return 'Low';
  }

  /// Check if item needs reordering
  bool get needsReordering {
    // This would typically check current inventory levels
    // For now, return based on reorder point logic
    return reorderPoint > 0; // Simplified logic
  }

  /// Get environmental impact score
  double get environmentalImpactScore {
    double score = carbonFootprint * 0.4;

    if (environmentalImpact != null) {
      score += (environmentalImpact!['waterUsage'] as double? ?? 0.0) * 0.3;
      score +=
          (environmentalImpact!['wasteGeneration'] as double? ?? 0.0) * 0.3;
    }

    // Bonus for recyclable items
    if (recyclable) score *= 0.8;

    return score;
  }

  /// Get overall supplier performance score
  double get supplierPerformanceScore {
    return (supplierRating + qualityRating + deliveryRating) / 3;
  }

  /// Check if item is approaching expiry
  bool get isApproachingExpiry {
    if (expiryDate == null) return false;
    final daysToExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysToExpiry <= 30 && daysToExpiry > 0;
  }

  /// Get compliance status
  Map<String, bool> get complianceStatus {
    return {
      'environmental': complianceFlags.contains('environmental'),
      'safety': complianceFlags.contains('safety'),
      'quality': complianceFlags.contains('quality'),
      'regulatory': complianceFlags.contains('regulatory'),
      'hazmat': hazardousClassification != null,
    };
  }

  /// Create a copy with updated fields
  BomItemModel copyWith({
    String? id,
    String? bomId,
    String? itemId,
    String? itemCode,
    String? itemName,
    String? itemDescription,
    String? itemType,
    double? quantity,
    String? unit,
    String? consumptionType,
    int? sequenceNumber,
    double? wastagePercentage,
    double? yieldPercentage,
    double? costPerUnit,
    double? totalCost,
    String? alternativeItemId,
    String? supplierCode,
    String? batchNumber,
    DateTime? expiryDate,
    String? qualityGrade,
    String? storageLocation,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? qualityParameters,
    String? status,
    String? notes,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    int? leadTime,
    double? minimumOrderQuantity,
    double? maximumOrderQuantity,
    double? reorderPoint,
    double? safetyStock,
    double? standardCost,
    DateTime? lastCostUpdate,
    double? priceVariance,
    String? supplierPartNumber,
    String? manufacturerPartNumber,
    String? hazardousClassification,
    int? shelfLife,
    Map<String, dynamic>? storageConditions,
    Map<String, dynamic>? handlingInstructions,
    bool? qualityControlRequired,
    Map<String, dynamic>? inspectionCriteria,
    bool? certificationRequired,
    Map<String, dynamic>? certificationDetails,
    Map<String, dynamic>? environmentalImpact,
    double? carbonFootprint,
    bool? recyclable,
    List<String>? substitutes,
    List<String>? crossReferences,
    List<Map<String, dynamic>>? usageHistory,
    List<Map<String, dynamic>>? costHistory,
    double? supplierRating,
    double? qualityRating,
    double? deliveryRating,
    List<String>? riskFactors,
    List<String>? complianceFlags,
    Map<String, dynamic>? customAttributes,
    Map<String, dynamic>? integrationData,
    List<String>? validationErrors,
    Map<String, dynamic>? auditTrail,
  }) {
    return BomItemModel(
      id: id ?? this.id,
      bomId: bomId ?? this.bomId,
      itemId: itemId ?? this.itemId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      consumptionType: consumptionType ?? this.consumptionType,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      wastagePercentage: wastagePercentage ?? this.wastagePercentage,
      yieldPercentage: yieldPercentage ?? this.yieldPercentage,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      totalCost: totalCost ?? this.totalCost,
      alternativeItemId: alternativeItemId ?? this.alternativeItemId,
      supplierCode: supplierCode ?? this.supplierCode,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      storageLocation: storageLocation ?? this.storageLocation,
      specifications: specifications ?? this.specifications,
      qualityParameters: qualityParameters ?? this.qualityParameters,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      leadTime: leadTime ?? this.leadTime,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      maximumOrderQuantity: maximumOrderQuantity ?? this.maximumOrderQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      safetyStock: safetyStock ?? this.safetyStock,
      standardCost: standardCost ?? this.standardCost,
      lastCostUpdate: lastCostUpdate ?? this.lastCostUpdate,
      priceVariance: priceVariance ?? this.priceVariance,
      supplierPartNumber: supplierPartNumber ?? this.supplierPartNumber,
      manufacturerPartNumber:
          manufacturerPartNumber ?? this.manufacturerPartNumber,
      hazardousClassification:
          hazardousClassification ?? this.hazardousClassification,
      shelfLife: shelfLife ?? this.shelfLife,
      storageConditions: storageConditions ?? this.storageConditions,
      handlingInstructions: handlingInstructions ?? this.handlingInstructions,
      qualityControlRequired:
          qualityControlRequired ?? this.qualityControlRequired,
      inspectionCriteria: inspectionCriteria ?? this.inspectionCriteria,
      certificationRequired:
          certificationRequired ?? this.certificationRequired,
      certificationDetails: certificationDetails ?? this.certificationDetails,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      recyclable: recyclable ?? this.recyclable,
      substitutes: substitutes ?? this.substitutes,
      crossReferences: crossReferences ?? this.crossReferences,
      usageHistory: usageHistory ?? this.usageHistory,
      costHistory: costHistory ?? this.costHistory,
      supplierRating: supplierRating ?? this.supplierRating,
      qualityRating: qualityRating ?? this.qualityRating,
      deliveryRating: deliveryRating ?? this.deliveryRating,
      riskFactors: riskFactors ?? this.riskFactors,
      complianceFlags: complianceFlags ?? this.complianceFlags,
      customAttributes: customAttributes ?? this.customAttributes,
      integrationData: integrationData ?? this.integrationData,
      validationErrors: validationErrors ?? this.validationErrors,
      auditTrail: auditTrail ?? this.auditTrail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bomId': bomId,
      'itemId': itemId,
      'itemCode': itemCode,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemType': itemType,
      'quantity': quantity,
      'unit': unit,
      'consumptionType': consumptionType,
      'sequenceNumber': sequenceNumber,
      'wastagePercentage': wastagePercentage,
      'yieldPercentage': yieldPercentage,
      'costPerUnit': costPerUnit,
      'totalCost': totalCost,
      'alternativeItemId': alternativeItemId,
      'supplierCode': supplierCode,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'qualityGrade': qualityGrade,
      'storageLocation': storageLocation,
      'specifications': specifications,
      'qualityParameters': qualityParameters,
      'status': status,
      'notes': notes,
      'effectiveFrom': effectiveFrom?.toIso8601String(),
      'effectiveTo': effectiveTo?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      // Enhanced fields
      'leadTime': leadTime,
      'minimumOrderQuantity': minimumOrderQuantity,
      'maximumOrderQuantity': maximumOrderQuantity,
      'reorderPoint': reorderPoint,
      'safetyStock': safetyStock,
      'standardCost': standardCost,
      'lastCostUpdate': lastCostUpdate?.toIso8601String(),
      'priceVariance': priceVariance,
      'supplierPartNumber': supplierPartNumber,
      'manufacturerPartNumber': manufacturerPartNumber,
      'hazardousClassification': hazardousClassification,
      'shelfLife': shelfLife,
      'storageConditions': storageConditions,
      'handlingInstructions': handlingInstructions,
      'qualityControlRequired': qualityControlRequired,
      'inspectionCriteria': inspectionCriteria,
      'certificationRequired': certificationRequired,
      'certificationDetails': certificationDetails,
      'environmentalImpact': environmentalImpact,
      'carbonFootprint': carbonFootprint,
      'recyclable': recyclable,
      'substitutes': substitutes,
      'crossReferences': crossReferences,
      'usageHistory': usageHistory,
      'costHistory': costHistory,
      'supplierRating': supplierRating,
      'qualityRating': qualityRating,
      'deliveryRating': deliveryRating,
      'riskFactors': riskFactors,
      'complianceFlags': complianceFlags,
      'customAttributes': customAttributes,
      'integrationData': integrationData,
      'validationErrors': validationErrors,
      'auditTrail': auditTrail,
    };
  }

  /// Convert to domain entity with validation
  BomItem toDomain() {
    final errors = validate();
    if (errors.isNotEmpty) {
      throw Exception('Invalid BOM Item data: ${errors.join(', ')}');
    }

    return BomItem(
      id: id,
      bomId: bomId,
      itemId: itemId,
      itemCode: itemCode,
      itemName: itemName,
      itemDescription: itemDescription,
      itemType: BomItemType.values.firstWhere((e) => e.name == itemType),
      quantity: quantity,
      unit: unit,
      consumptionType:
          ConsumptionType.values.firstWhere((e) => e.name == consumptionType),
      sequenceNumber: sequenceNumber,
      wastagePercentage: wastagePercentage,
      yieldPercentage: yieldPercentage,
      costPerUnit: costPerUnit,
      totalCost: totalCost,
      alternativeItemId: alternativeItemId,
      supplierCode: supplierCode,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      qualityGrade: qualityGrade,
      storageLocation: storageLocation,
      specifications: specifications,
      qualityParameters: qualityParameters,
      status: BomItemStatus.values.firstWhere((e) => e.name == status),
      notes: notes,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  // Private validation methods
  bool _isValidStatus(String status) {
    const validStatuses = [
      'active',
      'inactive',
      'obsolete',
      'pending',
      'approved',
      'rejected'
    ];
    return validStatuses.contains(status);
  }

  bool _isValidItemType(String itemType) {
    const validTypes = [
      'rawMaterial',
      'semiFinished',
      'finishedGood',
      'packaging',
      'consumable',
      'tool',
      'service'
    ];
    return validTypes.contains(itemType);
  }

  bool _isValidConsumptionType(String consumptionType) {
    const validTypes = ['fixed', 'variable', 'batch', 'continuous'];
    return validTypes.contains(consumptionType);
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  String toString() {
    return 'BomItemModel(id: $id, itemCode: $itemCode, itemName: $itemName, quantity: $quantity, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BomItemModel &&
        other.id == id &&
        other.bomId == bomId &&
        other.itemId == itemId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ bomId.hashCode ^ itemId.hashCode;
  }
}
