import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';

/// Comprehensive and robust data model for BOM that handles Firebase serialization
/// with enterprise-grade validation, business logic, and error handling
class BomModel {

  factory BomModel.fromJson(Map<String, dynamic> json) {
    return BomModel(
      id: json['id'] ?? '',
      bomCode: json['bomCode'] ?? '',
      bomName: json['bomName'] ?? '',
      productId: json['productId'] ?? '',
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      bomType: json['bomType'] ?? '',
      version: json['version'] ?? '',
      baseQuantity: (json['baseQuantity'] ?? 0.0).toDouble(),
      baseUnit: json['baseUnit'] ?? '',
      status: json['status'] ?? 'draft',
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      laborCost: (json['laborCost'] ?? 0.0).toDouble(),
      overheadCost: (json['overheadCost'] ?? 0.0).toDouble(),
      setupCost: (json['setupCost'] ?? 0.0).toDouble(),
      yieldPercentage: (json['yieldPercentage'] ?? 0.0).toDouble(),
      description: json['description'],
      notes: json['notes'],
      approvedBy: json['approvedBy'],
      approvedAt: _parseDateTime(json['approvedAt']),
      effectiveFrom: _parseDateTime(json['effectiveFrom']),
      effectiveTo: _parseDateTime(json['effectiveTo']),
      productionInstructions: json['productionInstructions'],
      qualityRequirements: json['qualityRequirements'],
      packagingInstructions: json['packagingInstructions'],
      alternativeBomIds: json['alternativeBomIds'] != null
          ? List<String>.from(json['alternativeBomIds'])
          : null,
      parentBomId: json['parentBomId'],
      childBomIds: List<String>.from(json['childBomIds'] ?? []),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      // Enhanced fields
      revision: json['revision'] ?? 1,
      isTemplate: json['isTemplate'] ?? false,
      templateCategory: json['templateCategory'],
      businessUnit: json['businessUnit'],
      costCenter: json['costCenter'],
      currency: json['currency'] ?? 'USD',
      exchangeRate: (json['exchangeRate'] ?? 1.0).toDouble(),
      lastCostUpdate: _parseDateTime(json['lastCostUpdate']),
      nextReviewDate: _parseDateTime(json['nextReviewDate']),
      complianceFlags: List<String>.from(json['complianceFlags'] ?? []),
      environmentalImpact: json['environmentalImpact'],
      sustainabilityScore: json['sustainabilityScore']?.toDouble(),
      riskAssessment: json['riskAssessment'],
      changeHistory:
          List<Map<String, dynamic>>.from(json['changeHistory'] ?? []),
      attachments: List<Map<String, dynamic>>.from(json['attachments'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      integrationStatus:
          Map<String, dynamic>.from(json['integrationStatus'] ?? {}),
      validationErrors: List<String>.from(json['validationErrors'] ?? []),
      auditTrail: Map<String, dynamic>.from(json['auditTrail'] ?? {}),
    );
  }

  /// Create from Firestore document with error handling
  factory BomModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Document data is null');
      }
      return BomModel.fromJson({
        ...data,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to parse BOM from Firestore: $e');
    }
  }

  /// Create from domain entity with comprehensive mapping
  factory BomModel.fromDomain(BillOfMaterials entity) {
    return BomModel(
      id: entity.id,
      bomCode: entity.bomCode,
      bomName: entity.bomName,
      productId: entity.productId,
      productCode: entity.productCode,
      productName: entity.productName,
      bomType: entity.bomType.name,
      version: entity.version,
      baseQuantity: entity.baseQuantity,
      baseUnit: entity.baseUnit,
      status: entity.status.name,
      items: entity.items.map((item) => _bomItemToMap(item)).toList(),
      totalCost: entity.totalCost,
      laborCost: entity.laborCost,
      overheadCost: entity.overheadCost,
      setupCost: entity.setupCost,
      yieldPercentage: entity.yieldPercentage,
      description: entity.description,
      notes: entity.notes,
      approvedBy: entity.approvedBy,
      approvedAt: entity.approvedAt,
      effectiveFrom: entity.effectiveFrom,
      effectiveTo: entity.effectiveTo,
      productionInstructions: entity.productionInstructions,
      qualityRequirements: entity.qualityRequirements,
      packagingInstructions: entity.packagingInstructions,
      alternativeBomIds: entity.alternativeBomIds,
      parentBomId: entity.parentBomId,
      childBomIds: entity.childBomIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }
  const BomModel({
    required this.id,
    required this.bomCode,
    required this.bomName,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.bomType,
    required this.version,
    required this.baseQuantity,
    required this.baseUnit,
    this.status = 'draft',
    this.items = const [],
    this.totalCost = 0.0,
    this.laborCost = 0.0,
    this.overheadCost = 0.0,
    this.setupCost = 0.0,
    this.yieldPercentage = 0.0,
    this.description,
    this.notes,
    this.approvedBy,
    this.approvedAt,
    this.effectiveFrom,
    this.effectiveTo,
    this.productionInstructions,
    this.qualityRequirements,
    this.packagingInstructions,
    this.alternativeBomIds,
    this.parentBomId,
    this.childBomIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    // Enhanced fields for robustness
    this.revision = 1,
    this.isTemplate = false,
    this.templateCategory,
    this.businessUnit,
    this.costCenter,
    this.currency = 'USD',
    this.exchangeRate = 1.0,
    this.lastCostUpdate,
    this.nextReviewDate,
    this.complianceFlags = const [],
    this.environmentalImpact,
    this.sustainabilityScore,
    this.riskAssessment,
    this.changeHistory = const [],
    this.attachments = const [],
    this.tags = const [],
    this.customFields = const {},
    this.integrationStatus = const {},
    this.validationErrors = const [],
    this.auditTrail = const {},
  });

  // Core BOM fields
  final String id;
  final String bomCode;
  final String bomName;
  final String productId;
  final String productCode;
  final String productName;
  final String bomType;
  final String version;
  final double baseQuantity;
  final String baseUnit;
  final String status;
  final List<Map<String, dynamic>> items;
  final double totalCost;
  final double laborCost;
  final double overheadCost;
  final double setupCost;
  final double yieldPercentage;
  final String? description;
  final String? notes;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final Map<String, dynamic>? productionInstructions;
  final Map<String, dynamic>? qualityRequirements;
  final Map<String, dynamic>? packagingInstructions;
  final List<String>? alternativeBomIds;
  final String? parentBomId;
  final List<String> childBomIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  // Enhanced fields for enterprise robustness
  final int revision;
  final bool isTemplate;
  final String? templateCategory;
  final String? businessUnit;
  final String? costCenter;
  final String currency;
  final double exchangeRate;
  final DateTime? lastCostUpdate;
  final DateTime? nextReviewDate;
  final List<String> complianceFlags;
  final Map<String, dynamic>? environmentalImpact;
  final double? sustainabilityScore;
  final Map<String, dynamic>? riskAssessment;
  final List<Map<String, dynamic>> changeHistory;
  final List<Map<String, dynamic>> attachments;
  final List<String> tags;
  final Map<String, dynamic> customFields;
  final Map<String, dynamic> integrationStatus;
  final List<String> validationErrors;
  final Map<String, dynamic> auditTrail;

  /// Comprehensive validation of BOM data
  List<String> validate() {
    final errors = <String>[];

    // Basic field validation
    if (bomCode.isEmpty) errors.add('BOM code is required');
    if (bomName.isEmpty) errors.add('BOM name is required');
    if (productId.isEmpty) errors.add('Product ID is required');
    if (productCode.isEmpty) errors.add('Product code is required');
    if (baseQuantity <= 0) errors.add('Base quantity must be positive');
    if (baseUnit.isEmpty) errors.add('Base unit is required');

    // Business logic validation
    if (totalCost < 0) errors.add('Total cost cannot be negative');
    if (laborCost < 0) errors.add('Labor cost cannot be negative');
    if (overheadCost < 0) errors.add('Overhead cost cannot be negative');
    if (setupCost < 0) errors.add('Setup cost cannot be negative');
    if (yieldPercentage < 0 || yieldPercentage > 100) {
      errors.add('Yield percentage must be between 0 and 100');
    }

    // Version validation
    if (version.isEmpty) errors.add('Version is required');
    if (!_isValidVersion(version)) {
      errors.add('Version format is invalid (expected: X.Y.Z)');
    }

    // Date validation
    if (effectiveFrom != null && effectiveTo != null) {
      if (effectiveFrom!.isAfter(effectiveTo!)) {
        errors.add('Effective from date must be before effective to date');
      }
    }

    // Status validation
    if (!_isValidStatus(status)) {
      errors.add('Invalid BOM status: $status');
    }

    // Currency validation
    if (!_isValidCurrency(currency)) {
      errors.add('Invalid currency code: $currency');
    }

    // Exchange rate validation
    if (exchangeRate <= 0) {
      errors.add('Exchange rate must be positive');
    }

    return errors;
  }

  /// Check if BOM is in a valid state for production
  bool get isValidForProduction {
    return status == 'active' &&
        items.isNotEmpty &&
        validate().isEmpty &&
        (effectiveFrom == null || effectiveFrom!.isBefore(DateTime.now())) &&
        (effectiveTo == null || effectiveTo!.isAfter(DateTime.now()));
  }

  /// Calculate BOM complexity score
  double get complexityScore {
    double score = 0.0;
    score += items.length * 0.1; // Item count factor
    score += childBomIds.length * 0.2; // Sub-assembly factor
    score += (alternativeBomIds?.length ?? 0) * 0.05; // Alternative factor

    // Production instruction complexity
    if (productionInstructions != null) {
      score += productionInstructions!.length * 0.02;
    }

    return score;
  }

  /// Get BOM risk level based on various factors
  String get riskLevel {
    final score = complexityScore;
    final hasRiskAssessment = riskAssessment != null;
    final isExpiringSoon = nextReviewDate != null &&
        nextReviewDate!.difference(DateTime.now()).inDays < 30;

    if (score > 5.0 || !hasRiskAssessment || isExpiringSoon) return 'High';
    if (score > 2.0) return 'Medium';
    return 'Low';
  }

  /// Check if BOM needs cost update
  bool get needsCostUpdate {
    if (lastCostUpdate == null) return true;
    final daysSinceUpdate = DateTime.now().difference(lastCostUpdate!).inDays;
    return daysSinceUpdate > 30; // Update if older than 30 days
  }

  /// Get compliance status
  Map<String, bool> get complianceStatus {
    return {
      'environmental': complianceFlags.contains('environmental'),
      'safety': complianceFlags.contains('safety'),
      'quality': complianceFlags.contains('quality'),
      'regulatory': complianceFlags.contains('regulatory'),
    };
  }

  /// Calculate environmental impact score
  double get environmentalImpactScore {
    if (environmentalImpact == null) return 0.0;

    double score = 0.0;
    score += (environmentalImpact!['carbonFootprint'] as double? ?? 0.0) * 0.4;
    score += (environmentalImpact!['waterUsage'] as double? ?? 0.0) * 0.3;
    score += (environmentalImpact!['wasteGeneration'] as double? ?? 0.0) * 0.3;

    return score;
  }

  /// Create a copy with updated fields
  BomModel copyWith({
    String? id,
    String? bomCode,
    String? bomName,
    String? productId,
    String? productCode,
    String? productName,
    String? bomType,
    String? version,
    double? baseQuantity,
    String? baseUnit,
    String? status,
    List<Map<String, dynamic>>? items,
    double? totalCost,
    double? laborCost,
    double? overheadCost,
    double? setupCost,
    double? yieldPercentage,
    String? description,
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    Map<String, dynamic>? productionInstructions,
    Map<String, dynamic>? qualityRequirements,
    Map<String, dynamic>? packagingInstructions,
    List<String>? alternativeBomIds,
    String? parentBomId,
    List<String>? childBomIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    int? revision,
    bool? isTemplate,
    String? templateCategory,
    String? businessUnit,
    String? costCenter,
    String? currency,
    double? exchangeRate,
    DateTime? lastCostUpdate,
    DateTime? nextReviewDate,
    List<String>? complianceFlags,
    Map<String, dynamic>? environmentalImpact,
    double? sustainabilityScore,
    Map<String, dynamic>? riskAssessment,
    List<Map<String, dynamic>>? changeHistory,
    List<Map<String, dynamic>>? attachments,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? integrationStatus,
    List<String>? validationErrors,
    Map<String, dynamic>? auditTrail,
  }) {
    return BomModel(
      id: id ?? this.id,
      bomCode: bomCode ?? this.bomCode,
      bomName: bomName ?? this.bomName,
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      bomType: bomType ?? this.bomType,
      version: version ?? this.version,
      baseQuantity: baseQuantity ?? this.baseQuantity,
      baseUnit: baseUnit ?? this.baseUnit,
      status: status ?? this.status,
      items: items ?? this.items,
      totalCost: totalCost ?? this.totalCost,
      laborCost: laborCost ?? this.laborCost,
      overheadCost: overheadCost ?? this.overheadCost,
      setupCost: setupCost ?? this.setupCost,
      yieldPercentage: yieldPercentage ?? this.yieldPercentage,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      productionInstructions:
          productionInstructions ?? this.productionInstructions,
      qualityRequirements: qualityRequirements ?? this.qualityRequirements,
      packagingInstructions:
          packagingInstructions ?? this.packagingInstructions,
      alternativeBomIds: alternativeBomIds ?? this.alternativeBomIds,
      parentBomId: parentBomId ?? this.parentBomId,
      childBomIds: childBomIds ?? this.childBomIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      isTemplate: isTemplate ?? this.isTemplate,
      templateCategory: templateCategory ?? this.templateCategory,
      businessUnit: businessUnit ?? this.businessUnit,
      costCenter: costCenter ?? this.costCenter,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      lastCostUpdate: lastCostUpdate ?? this.lastCostUpdate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      complianceFlags: complianceFlags ?? this.complianceFlags,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      changeHistory: changeHistory ?? this.changeHistory,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      integrationStatus: integrationStatus ?? this.integrationStatus,
      validationErrors: validationErrors ?? this.validationErrors,
      auditTrail: auditTrail ?? this.auditTrail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bomCode': bomCode,
      'bomName': bomName,
      'productId': productId,
      'productCode': productCode,
      'productName': productName,
      'bomType': bomType,
      'version': version,
      'baseQuantity': baseQuantity,
      'baseUnit': baseUnit,
      'status': status,
      'items': items,
      'totalCost': totalCost,
      'laborCost': laborCost,
      'overheadCost': overheadCost,
      'setupCost': setupCost,
      'yieldPercentage': yieldPercentage,
      'description': description,
      'notes': notes,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'effectiveFrom': effectiveFrom?.toIso8601String(),
      'effectiveTo': effectiveTo?.toIso8601String(),
      'productionInstructions': productionInstructions,
      'qualityRequirements': qualityRequirements,
      'packagingInstructions': packagingInstructions,
      'alternativeBomIds': alternativeBomIds,
      'parentBomId': parentBomId,
      'childBomIds': childBomIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      // Enhanced fields
      'revision': revision,
      'isTemplate': isTemplate,
      'templateCategory': templateCategory,
      'businessUnit': businessUnit,
      'costCenter': costCenter,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'lastCostUpdate': lastCostUpdate?.toIso8601String(),
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'complianceFlags': complianceFlags,
      'environmentalImpact': environmentalImpact,
      'sustainabilityScore': sustainabilityScore,
      'riskAssessment': riskAssessment,
      'changeHistory': changeHistory,
      'attachments': attachments,
      'tags': tags,
      'customFields': customFields,
      'integrationStatus': integrationStatus,
      'validationErrors': validationErrors,
      'auditTrail': auditTrail,
    };
  }

  /// Convert to domain entity with validation
  BillOfMaterials toDomain() {
    final errors = validate();
    if (errors.isNotEmpty) {
      throw Exception('Invalid BOM data: ${errors.join(', ')}');
    }

    return BillOfMaterials(
      id: id,
      bomCode: bomCode,
      bomName: bomName,
      productId: productId,
      productCode: productCode,
      productName: productName,
      bomType: BomType.values.firstWhere((e) => e.name == bomType),
      version: version,
      baseQuantity: baseQuantity,
      baseUnit: baseUnit,
      status: BomStatus.values.firstWhere((e) => e.name == status),
      items: items.map((item) => _bomItemFromMap(item)).toList(),
      totalCost: totalCost,
      laborCost: laborCost,
      overheadCost: overheadCost,
      setupCost: setupCost,
      yieldPercentage: yieldPercentage,
      description: description,
      notes: notes,
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      productionInstructions: productionInstructions,
      qualityRequirements: qualityRequirements,
      packagingInstructions: packagingInstructions,
      alternativeBomIds: alternativeBomIds,
      parentBomId: parentBomId,
      childBomIds: childBomIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Convert to Firestore data with sanitization
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove ID as it's handled by Firestore

    // Sanitize null values for Firestore
    json.removeWhere((key, value) => value == null);

    return json;
  }

  // Private validation methods
  bool _isValidVersion(String version) {
    final versionRegex = RegExp(r'^\d+\.\d+(\.\d+)?$');
    return versionRegex.hasMatch(version);
  }

  bool _isValidStatus(String status) {
    const validStatuses = [
      'draft',
      'active',
      'inactive',
      'obsolete',
      'underReview',
      'approved',
      'rejected'
    ];
    return validStatuses.contains(status);
  }

  bool _isValidCurrency(String currency) {
    const validCurrencies = [
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'CAD',
      'AUD',
      'CHF',
      'CNY',
      'INR'
    ];
    return validCurrencies.contains(currency);
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
    return 'BomModel(id: $id, bomCode: $bomCode, bomName: $bomName, status: $status, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BomModel &&
        other.id == id &&
        other.bomCode == bomCode &&
        other.version == version;
  }

  @override
  int get hashCode {
    return id.hashCode ^ bomCode.hashCode ^ version.hashCode;
  }
}

/// Helper function to convert BomItem to Map with comprehensive data
Map<String, dynamic> _bomItemToMap(BomItem item) {
  return {
    'id': item.id,
    'bomId': item.bomId,
    'itemId': item.itemId,
    'itemCode': item.itemCode,
    'itemName': item.itemName,
    'itemDescription': item.itemDescription,
    'itemType': item.itemType.name,
    'quantity': item.quantity,
    'unit': item.unit,
    'consumptionType': item.consumptionType.name,
    'sequenceNumber': item.sequenceNumber,
    'wastagePercentage': item.wastagePercentage,
    'yieldPercentage': item.yieldPercentage,
    'costPerUnit': item.costPerUnit,
    'totalCost': item.totalCost,
    'alternativeItemId': item.alternativeItemId,
    'supplierCode': item.supplierCode,
    'batchNumber': item.batchNumber,
    'expiryDate': item.expiryDate?.toIso8601String(),
    'qualityGrade': item.qualityGrade,
    'storageLocation': item.storageLocation,
    'specifications': item.specifications,
    'qualityParameters': item.qualityParameters,
    'status': item.status.name,
    'notes': item.notes,
    'effectiveFrom': item.effectiveFrom?.toIso8601String(),
    'effectiveTo': item.effectiveTo?.toIso8601String(),
    'createdAt': item.createdAt.toIso8601String(),
    'updatedAt': item.updatedAt.toIso8601String(),
    'createdBy': item.createdBy,
    'updatedBy': item.updatedBy,
  };
}

/// Helper function to convert Map to BomItem with error handling
BomItem _bomItemFromMap(Map<String, dynamic> map) {
  try {
    return BomItem(
      id: map['id'] ?? '',
      bomId: map['bomId'] ?? '',
      itemId: map['itemId'] ?? '',
      itemCode: map['itemCode'] ?? '',
      itemName: map['itemName'] ?? '',
      itemDescription: map['itemDescription'] ?? '',
      itemType: BomItemType.values.firstWhere((e) => e.name == map['itemType']),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      consumptionType: ConsumptionType.values
          .firstWhere((e) => e.name == map['consumptionType']),
      sequenceNumber: map['sequenceNumber'] ?? 0,
      wastagePercentage: (map['wastagePercentage'] ?? 0.0).toDouble(),
      yieldPercentage: (map['yieldPercentage'] ?? 0.0).toDouble(),
      costPerUnit: (map['costPerUnit'] ?? 0.0).toDouble(),
      totalCost: (map['totalCost'] ?? 0.0).toDouble(),
      alternativeItemId: map['alternativeItemId'],
      supplierCode: map['supplierCode'],
      batchNumber: map['batchNumber'],
      expiryDate:
          map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      qualityGrade: map['qualityGrade'],
      storageLocation: map['storageLocation'],
      specifications: map['specifications'],
      qualityParameters: map['qualityParameters'],
      status: BomItemStatus.values.firstWhere((e) => e.name == map['status']),
      notes: map['notes'],
      effectiveFrom: map['effectiveFrom'] != null
          ? DateTime.parse(map['effectiveFrom'])
          : null,
      effectiveTo: map['effectiveTo'] != null
          ? DateTime.parse(map['effectiveTo'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
    );
  } catch (e) {
    throw Exception('Failed to parse BOM item from map: $e');
  }
}
