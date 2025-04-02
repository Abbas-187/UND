import 'package:cloud_firestore/cloud_firestore.dart';

// Material types enum
enum MaterialType {
  raw_material, // You can fix the lowerCamelCase naming if desired
  packaging_material,
  finished_good,
  semi_finished_good,
  other
}

class MaterialModel {
  MaterialModel({
    this.id,
    required this.materialCode,
    required this.materialName,
    required this.materialType,
    this.description,
    this.category,
    this.subCategory,
    required this.defaultUom,
    this.uomConversions,
    this.defaultWarehouseId,
    this.defaultLocationId,
    this.reorderPoint,
    this.minimumOrderQuantity,
    this.standardCost,
    this.costCurrency,
    this.weight,
    this.weightUom,
    this.volume,
    this.volumeUom,
    this.dimensions,
    this.dimensionUom,
    this.barcode,
    this.alternativeBarcodes,
    this.requiresBatchManagement = false,
    this.requiresExpiryDate = false,
    this.requiresSerialNumbers = false,
    this.isHazardous = false,
    this.isActive = true,
    this.imageUrl,
    this.safetyDataSheetUrl,
    this.specifications,
    this.tags,
    this.additionalAttributes,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      materialCode: json['materialCode'],
      materialName: json['materialName'],
      materialType: MaterialType.values.firstWhere(
        (e) => e.toString() == 'MaterialType.${json['materialType']}',
        orElse: () => MaterialType.other,
      ),
      description: json['description'],
      category: json['category'],
      subCategory: json['subCategory'],
      defaultUom: json['defaultUom'],
      uomConversions: json['uomConversions'] != null
          ? Map<String, double>.from(json['uomConversions'])
          : null,
      defaultWarehouseId: json['defaultWarehouseId'],
      defaultLocationId: json['defaultLocationId'],
      reorderPoint: json['reorderPoint']?.toDouble(),
      minimumOrderQuantity: json['minimumOrderQuantity']?.toDouble(),
      standardCost: json['standardCost']?.toDouble(),
      costCurrency: json['costCurrency'],
      weight: json['weight']?.toDouble(),
      weightUom: json['weightUom'],
      volume: json['volume']?.toDouble(),
      volumeUom: json['volumeUom'],
      dimensions: json['dimensions'] != null
          ? Map<String, double>.from(json['dimensions'])
          : null,
      dimensionUom: json['dimensionUom'],
      barcode: json['barcode'],
      alternativeBarcodes: json['alternativeBarcodes'] != null
          ? List<String>.from(json['alternativeBarcodes'])
          : null,
      requiresBatchManagement: json['requiresBatchManagement'] ?? false,
      requiresExpiryDate: json['requiresExpiryDate'] ?? false,
      requiresSerialNumbers: json['requiresSerialNumbers'] ?? false,
      isHazardous: json['isHazardous'] ?? false,
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'],
      safetyDataSheetUrl: json['safetyDataSheetUrl'],
      specifications: json['specifications'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      additionalAttributes: json['additionalAttributes'],
      createdBy: json['createdBy'],
      createdAt: (json['createdAt'] != null)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedBy: json['updatedBy'],
      updatedAt: (json['updatedAt'] != null)
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
  final String? id;
  final String materialCode;
  final String materialName;
  final MaterialType materialType;
  final String? description;
  final String? category;
  final String? subCategory;
  final String defaultUom;
  final Map<String, double>? uomConversions;
  final String? defaultWarehouseId;
  final String? defaultLocationId;
  final double? reorderPoint;
  final double? minimumOrderQuantity;
  final double? standardCost;
  final String? costCurrency;
  final double? weight;
  final String? weightUom;
  final double? volume;
  final String? volumeUom;
  final Map<String, double>? dimensions;
  final String? dimensionUom;
  final String? barcode;
  final List<String>? alternativeBarcodes;
  final bool requiresBatchManagement;
  final bool requiresExpiryDate;
  final bool requiresSerialNumbers;
  final bool isHazardous;
  final bool isActive;
  final String? imageUrl;
  final String? safetyDataSheetUrl;
  final Map<String, dynamic>? specifications;
  final List<String>? tags;
  final Map<String, dynamic>? additionalAttributes;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    final materialTypeString = materialType.toString().split('.').last;

    return {
      'id': id,
      'materialCode': materialCode,
      'materialName': materialName,
      'materialType': materialTypeString,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'defaultUom': defaultUom,
      'uomConversions': uomConversions,
      'defaultWarehouseId': defaultWarehouseId,
      'defaultLocationId': defaultLocationId,
      'reorderPoint': reorderPoint,
      'minimumOrderQuantity': minimumOrderQuantity,
      'standardCost': standardCost,
      'costCurrency': costCurrency,
      'weight': weight,
      'weightUom': weightUom,
      'volume': volume,
      'volumeUom': volumeUom,
      'dimensions': dimensions,
      'dimensionUom': dimensionUom,
      'barcode': barcode,
      'alternativeBarcodes': alternativeBarcodes,
      'requiresBatchManagement': requiresBatchManagement,
      'requiresExpiryDate': requiresExpiryDate,
      'requiresSerialNumbers': requiresSerialNumbers,
      'isHazardous': isHazardous,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'safetyDataSheetUrl': safetyDataSheetUrl,
      'specifications': specifications,
      'tags': tags,
      'additionalAttributes': additionalAttributes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Add copyWith method for immutability
  MaterialModel copyWith({
    String? id,
    String? materialCode,
    String? materialName,
    MaterialType? materialType,
    String? description,
    String? category,
    String? subCategory,
    String? defaultUom,
    Map<String, double>? uomConversions,
    String? defaultWarehouseId,
    String? defaultLocationId,
    double? reorderPoint,
    double? minimumOrderQuantity,
    double? standardCost,
    String? costCurrency,
    double? weight,
    String? weightUom,
    double? volume,
    String? volumeUom,
    Map<String, double>? dimensions,
    String? dimensionUom,
    String? barcode,
    List<String>? alternativeBarcodes,
    bool? requiresBatchManagement,
    bool? requiresExpiryDate,
    bool? requiresSerialNumbers,
    bool? isHazardous,
    bool? isActive,
    String? imageUrl,
    String? safetyDataSheetUrl,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    Map<String, dynamic>? additionalAttributes,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      materialCode: materialCode ?? this.materialCode,
      materialName: materialName ?? this.materialName,
      materialType: materialType ?? this.materialType,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      defaultUom: defaultUom ?? this.defaultUom,
      uomConversions: uomConversions ?? this.uomConversions,
      defaultWarehouseId: defaultWarehouseId ?? this.defaultWarehouseId,
      defaultLocationId: defaultLocationId ?? this.defaultLocationId,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      standardCost: standardCost ?? this.standardCost,
      costCurrency: costCurrency ?? this.costCurrency,
      weight: weight ?? this.weight,
      weightUom: weightUom ?? this.weightUom,
      volume: volume ?? this.volume,
      volumeUom: volumeUom ?? this.volumeUom,
      dimensions: dimensions ?? this.dimensions,
      dimensionUom: dimensionUom ?? this.dimensionUom,
      barcode: barcode ?? this.barcode,
      alternativeBarcodes: alternativeBarcodes ?? this.alternativeBarcodes,
      requiresBatchManagement:
          requiresBatchManagement ?? this.requiresBatchManagement,
      requiresExpiryDate: requiresExpiryDate ?? this.requiresExpiryDate,
      requiresSerialNumbers:
          requiresSerialNumbers ?? this.requiresSerialNumbers,
      isHazardous: isHazardous ?? this.isHazardous,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      safetyDataSheetUrl: safetyDataSheetUrl ?? this.safetyDataSheetUrl,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      additionalAttributes: additionalAttributes ?? this.additionalAttributes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialModel &&
          id == other.id &&
          materialCode == other.materialCode;

  @override
  int get hashCode => id.hashCode ^ materialCode.hashCode;
}
