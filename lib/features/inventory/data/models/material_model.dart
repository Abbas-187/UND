import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// Material types enum for dairy industry products
enum MaterialType {
  rawMilk,
  cultures,
  additives,
  packagingMaterial,
  finishedGood,
  semiFinishedGood,
  other
}

/// Regulatory classification enum for dairy products
enum RegulatoryClassification {
  organic,
  hormoneFree,
  antibioticFree,
  gmoFree,
  kosher,
  halal,
  standard,
  other
}

/// Storage requirements for dairy materials
@immutable
class StorageRequirements {
  // e.g., refrigerated, frozen, ambient

  const StorageRequirements({
    required this.minTemperature,
    required this.maxTemperature,
    this.minHumidity,
    this.maxHumidity,
    this.specialInstructions,
    required this.storageZone,
  });

  factory StorageRequirements.fromJson(Map<String, dynamic> json) {
    return StorageRequirements(
      minTemperature: (json['minTemperature'] as num).toDouble(),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      minHumidity: (json['minHumidity'] as num?)?.toDouble(),
      maxHumidity: (json['maxHumidity'] as num?)?.toDouble(),
      specialInstructions: json['specialInstructions'] as String?,
      storageZone: json['storageZone'] as String,
    );
  }
  final double minTemperature;
  final double maxTemperature;
  final double? minHumidity;
  final double? maxHumidity;
  final String? specialInstructions;
  final String storageZone;

  Map<String, dynamic> toJson() {
    return {
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'specialInstructions': specialInstructions,
      'storageZone': storageZone,
    };
  }

  StorageRequirements copyWith({
    double? minTemperature,
    double? maxTemperature,
    double? minHumidity,
    double? maxHumidity,
    String? specialInstructions,
    String? storageZone,
  }) {
    return StorageRequirements(
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      storageZone: storageZone ?? this.storageZone,
    );
  }
}

/// Nutritional parameters for dairy materials
@immutable
class NutritionalParameters {
  const NutritionalParameters({
    required this.fatContent,
    required this.proteinContent,
    required this.lactoseContent,
    this.totalSolids,
    this.calcium,
    this.sodium,
    this.potassium,
    this.vitamins,
    this.minerals,
    this.calories,
  });

  factory NutritionalParameters.fromJson(Map<String, dynamic> json) {
    return NutritionalParameters(
      fatContent: (json['fatContent'] as num).toDouble(),
      proteinContent: (json['proteinContent'] as num).toDouble(),
      lactoseContent: (json['lactoseContent'] as num).toDouble(),
      totalSolids: (json['totalSolids'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toDouble(),
      vitamins: json['vitamins'] != null
          ? Map<String, double>.from(json['vitamins'] as Map)
          : null,
      minerals: json['minerals'] != null
          ? Map<String, double>.from(json['minerals'] as Map)
          : null,
      calories: (json['calories'] as num?)?.toDouble(),
    );
  }
  final double fatContent;
  final double proteinContent;
  final double lactoseContent;
  final double? totalSolids;
  final double? calcium;
  final double? sodium;
  final double? potassium;
  final Map<String, double>? vitamins;
  final Map<String, double>? minerals;
  final double? calories;

  Map<String, dynamic> toJson() {
    return {
      'fatContent': fatContent,
      'proteinContent': proteinContent,
      'lactoseContent': lactoseContent,
      'totalSolids': totalSolids,
      'calcium': calcium,
      'sodium': sodium,
      'potassium': potassium,
      'vitamins': vitamins,
      'minerals': minerals,
      'calories': calories,
    };
  }

  NutritionalParameters copyWith({
    double? fatContent,
    double? proteinContent,
    double? lactoseContent,
    double? totalSolids,
    double? calcium,
    double? sodium,
    double? potassium,
    Map<String, double>? vitamins,
    Map<String, double>? minerals,
    double? calories,
  }) {
    return NutritionalParameters(
      fatContent: fatContent ?? this.fatContent,
      proteinContent: proteinContent ?? this.proteinContent,
      lactoseContent: lactoseContent ?? this.lactoseContent,
      totalSolids: totalSolids ?? this.totalSolids,
      calcium: calcium ?? this.calcium,
      sodium: sodium ?? this.sodium,
      potassium: potassium ?? this.potassium,
      vitamins: vitamins ?? this.vitamins,
      minerals: minerals ?? this.minerals,
      calories: calories ?? this.calories,
    );
  }
}

/// Testing requirements for dairy materials
@immutable
class TestingRequirements {
  const TestingRequirements({
    required this.requiredTests,
    required this.thresholds,
    required this.testingFrequency,
    this.testingProtocol,
    required this.microbiologicalTestingRequired,
  });

  factory TestingRequirements.fromJson(Map<String, dynamic> json) {
    // Convert nested map for thresholds
    final thresholdsMap = <String, Map<String, double>>{};
    final jsonThresholds = json['thresholds'] as Map<String, dynamic>;

    jsonThresholds.forEach((testName, values) {
      thresholdsMap[testName] = Map<String, double>.from(values as Map);
    });

    return TestingRequirements(
      requiredTests: List<String>.from(json['requiredTests'] as List),
      thresholds: thresholdsMap,
      testingFrequency: json['testingFrequency'] as int,
      testingProtocol: json['testingProtocol'] as String?,
      microbiologicalTestingRequired:
          json['microbiologicalTestingRequired'] as bool,
    );
  }
  final List<String> requiredTests;
  final Map<String, Map<String, double>> thresholds; // test name -> {min, max}
  final int testingFrequency; // in hours
  final String? testingProtocol;
  final bool microbiologicalTestingRequired;

  Map<String, dynamic> toJson() {
    return {
      'requiredTests': requiredTests,
      'thresholds': thresholds,
      'testingFrequency': testingFrequency,
      'testingProtocol': testingProtocol,
      'microbiologicalTestingRequired': microbiologicalTestingRequired,
    };
  }

  TestingRequirements copyWith({
    List<String>? requiredTests,
    Map<String, Map<String, double>>? thresholds,
    int? testingFrequency,
    String? testingProtocol,
    bool? microbiologicalTestingRequired,
  }) {
    return TestingRequirements(
      requiredTests: requiredTests ?? this.requiredTests,
      thresholds: thresholds ?? this.thresholds,
      testingFrequency: testingFrequency ?? this.testingFrequency,
      testingProtocol: testingProtocol ?? this.testingProtocol,
      microbiologicalTestingRequired:
          microbiologicalTestingRequired ?? this.microbiologicalTestingRequired,
    );
  }
}

/// Immutable Material Model with dairy industry specific fields
@immutable
class MaterialModel {
  const MaterialModel({
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

    // Dairy-specific fields
    this.nutritionalParameters,
    this.regulatoryClassifications,
    this.storageRequirements,
    this.testingRequirements,
    this.milkType,
    this.originFarm,
    this.processingFacility,
    this.milkingDate,
    this.shelfLifeDays,
    this.allergens,
    this.ingredients,
    this.certifications,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    // Handle MaterialType enum conversion
    final materialTypeString = json['materialType'] as String;
    final materialType = MaterialType.values.firstWhere(
      (e) => e.toString().split('.').last == materialTypeString,
      orElse: () => MaterialType.other,
    );

    // Handle RegulatoryClassification list conversion
    List<RegulatoryClassification>? regulatoryClassifications;
    if (json['regulatoryClassifications'] != null) {
      regulatoryClassifications = (json['regulatoryClassifications'] as List)
          .map((e) => RegulatoryClassification.values.firstWhere(
                (cl) => cl.toString().split('.').last == e,
                orElse: () => RegulatoryClassification.other,
              ))
          .toList();
    }

    // Handle complex object conversions
    NutritionalParameters? nutritionalParameters;
    if (json['nutritionalParameters'] != null) {
      nutritionalParameters = NutritionalParameters.fromJson(
          json['nutritionalParameters'] as Map<String, dynamic>);
    }

    StorageRequirements? storageRequirements;
    if (json['storageRequirements'] != null) {
      storageRequirements = StorageRequirements.fromJson(
          json['storageRequirements'] as Map<String, dynamic>);
    }

    TestingRequirements? testingRequirements;
    if (json['testingRequirements'] != null) {
      testingRequirements = TestingRequirements.fromJson(
          json['testingRequirements'] as Map<String, dynamic>);
    }

    // Handle DateTime conversions
    final createdAt = json['createdAt'] is String
        ? DateTime.parse(json['createdAt'] as String)
        : (json['createdAt'] as Timestamp).toDate();

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      updatedAt = json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updatedAt'] as Timestamp).toDate();
    }

    DateTime? milkingDate;
    if (json['milkingDate'] != null) {
      milkingDate = json['milkingDate'] is String
          ? DateTime.parse(json['milkingDate'] as String)
          : (json['milkingDate'] as Timestamp).toDate();
    }

    return MaterialModel(
      id: json['id'] as String?,
      materialCode: json['materialCode'] as String,
      materialName: json['materialName'] as String,
      materialType: materialType,
      description: json['description'] as String?,
      category: json['category'] as String?,
      subCategory: json['subCategory'] as String?,
      defaultUom: json['defaultUom'] as String,
      uomConversions: json['uomConversions'] != null
          ? Map<String, double>.from(json['uomConversions'] as Map)
          : null,
      defaultWarehouseId: json['defaultWarehouseId'] as String?,
      defaultLocationId: json['defaultLocationId'] as String?,
      reorderPoint: (json['reorderPoint'] as num?)?.toDouble(),
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toDouble(),
      standardCost: (json['standardCost'] as num?)?.toDouble(),
      costCurrency: json['costCurrency'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      weightUom: json['weightUom'] as String?,
      volume: (json['volume'] as num?)?.toDouble(),
      volumeUom: json['volumeUom'] as String?,
      dimensions: json['dimensions'] != null
          ? Map<String, double>.from(json['dimensions'] as Map)
          : null,
      dimensionUom: json['dimensionUom'] as String?,
      barcode: json['barcode'] as String?,
      alternativeBarcodes: json['alternativeBarcodes'] != null
          ? List<String>.from(json['alternativeBarcodes'] as List)
          : null,
      requiresBatchManagement:
          json['requiresBatchManagement'] as bool? ?? false,
      requiresExpiryDate: json['requiresExpiryDate'] as bool? ?? false,
      requiresSerialNumbers: json['requiresSerialNumbers'] as bool? ?? false,
      isHazardous: json['isHazardous'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      safetyDataSheetUrl: json['safetyDataSheetUrl'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      additionalAttributes:
          json['additionalAttributes'] as Map<String, dynamic>?,
      createdBy: json['createdBy'] as String?,
      createdAt: createdAt,
      updatedBy: json['updatedBy'] as String?,
      updatedAt: updatedAt,

      // Dairy-specific fields
      nutritionalParameters: nutritionalParameters,
      regulatoryClassifications: regulatoryClassifications,
      storageRequirements: storageRequirements,
      testingRequirements: testingRequirements,
      milkType: json['milkType'] as String?,
      originFarm: json['originFarm'] as String?,
      processingFacility: json['processingFacility'] as String?,
      milkingDate: milkingDate,
      shelfLifeDays: (json['shelfLifeDays'] as num?)?.toDouble(),
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'] as List)
          : null,
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'] as List)
          : null,
      certifications: json['certifications'] != null
          ? Map<String, String>.from(json['certifications'] as Map)
          : null,
    );
  }

  /// Factory method to convert from Firestore document
  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Timestamp to DateTime
    final createdAt = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    final updatedAt = data['updatedAt'] is Timestamp
        ? (data['updatedAt'] as Timestamp).toDate()
        : null;

    final milkingDate = data['milkingDate'] is Timestamp
        ? (data['milkingDate'] as Timestamp).toDate()
        : null;

    // Convert material type string to enum
    final materialTypeString = data['materialType'] as String? ?? 'other';
    final materialType = MaterialType.values.firstWhere(
      (e) => e.toString().split('.').last == materialTypeString,
      orElse: () => MaterialType.other,
    );

    // Convert regulatory classifications
    List<RegulatoryClassification>? regulatoryClassifications;
    if (data['regulatoryClassifications'] != null) {
      regulatoryClassifications = (data['regulatoryClassifications'] as List)
          .map((e) => RegulatoryClassification.values.firstWhere(
                (cl) => cl.toString().split('.').last == e,
                orElse: () => RegulatoryClassification.other,
              ))
          .toList();
    }

    // Convert complex objects
    NutritionalParameters? nutritionalParameters;
    if (data['nutritionalParameters'] != null) {
      nutritionalParameters = NutritionalParameters.fromJson(
          data['nutritionalParameters'] as Map<String, dynamic>);
    }

    StorageRequirements? storageRequirements;
    if (data['storageRequirements'] != null) {
      storageRequirements = StorageRequirements.fromJson(
          data['storageRequirements'] as Map<String, dynamic>);
    }

    TestingRequirements? testingRequirements;
    if (data['testingRequirements'] != null) {
      testingRequirements = TestingRequirements.fromJson(
          data['testingRequirements'] as Map<String, dynamic>);
    }

    return MaterialModel(
      id: doc.id,
      materialCode: data['materialCode'] as String? ?? '',
      materialName: data['materialName'] as String? ?? '',
      materialType: materialType,
      description: data['description'] as String?,
      category: data['category'] as String?,
      subCategory: data['subCategory'] as String?,
      defaultUom: data['defaultUom'] as String? ?? 'EA',
      uomConversions: data['uomConversions'] != null
          ? Map<String, double>.from(data['uomConversions'] as Map)
          : null,
      defaultWarehouseId: data['defaultWarehouseId'] as String?,
      defaultLocationId: data['defaultLocationId'] as String?,
      reorderPoint: (data['reorderPoint'] as num?)?.toDouble(),
      minimumOrderQuantity: (data['minimumOrderQuantity'] as num?)?.toDouble(),
      standardCost: (data['standardCost'] as num?)?.toDouble(),
      costCurrency: data['costCurrency'] as String?,
      weight: (data['weight'] as num?)?.toDouble(),
      weightUom: data['weightUom'] as String?,
      volume: (data['volume'] as num?)?.toDouble(),
      volumeUom: data['volumeUom'] as String?,
      dimensions: data['dimensions'] != null
          ? Map<String, double>.from(data['dimensions'] as Map)
          : null,
      dimensionUom: data['dimensionUom'] as String?,
      barcode: data['barcode'] as String?,
      alternativeBarcodes: data['alternativeBarcodes'] != null
          ? List<String>.from(data['alternativeBarcodes'] as List)
          : null,
      requiresBatchManagement:
          data['requiresBatchManagement'] as bool? ?? false,
      requiresExpiryDate: data['requiresExpiryDate'] as bool? ?? false,
      requiresSerialNumbers: data['requiresSerialNumbers'] as bool? ?? false,
      isHazardous: data['isHazardous'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      imageUrl: data['imageUrl'] as String?,
      safetyDataSheetUrl: data['safetyDataSheetUrl'] as String?,
      specifications: data['specifications'] as Map<String, dynamic>?,
      tags:
          data['tags'] != null ? List<String>.from(data['tags'] as List) : null,
      additionalAttributes:
          data['additionalAttributes'] as Map<String, dynamic>?,
      createdBy: data['createdBy'] as String?,
      createdAt: createdAt,
      updatedBy: data['updatedBy'] as String?,
      updatedAt: updatedAt,

      // Dairy-specific fields
      nutritionalParameters: nutritionalParameters,
      regulatoryClassifications: regulatoryClassifications,
      storageRequirements: storageRequirements,
      testingRequirements: testingRequirements,
      milkType: data['milkType'] as String?,
      originFarm: data['originFarm'] as String?,
      processingFacility: data['processingFacility'] as String?,
      milkingDate: milkingDate,
      shelfLifeDays: (data['shelfLifeDays'] as num?)?.toDouble(),
      allergens: data['allergens'] != null
          ? List<String>.from(data['allergens'] as List)
          : null,
      ingredients: data['ingredients'] != null
          ? List<String>.from(data['ingredients'] as List)
          : null,
      certifications: data['certifications'] != null
          ? Map<String, String>.from(data['certifications'] as Map)
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

  // Dairy-specific fields
  final NutritionalParameters? nutritionalParameters;
  final List<RegulatoryClassification>? regulatoryClassifications;
  final StorageRequirements? storageRequirements;
  final TestingRequirements? testingRequirements;
  final String? milkType; // cow, goat, sheep, etc.
  final String? originFarm;
  final String? processingFacility;
  final DateTime? milkingDate;
  final double? shelfLifeDays;
  final List<String>? allergens;
  final List<String>? ingredients;
  final Map<String, String>? certifications;

  Map<String, dynamic> toJson() {
    final materialTypeString = materialType.toString().split('.').last;

    // Convert regulatory classifications to strings
    final regulatoryClassificationsStrings = regulatoryClassifications
        ?.map((e) => e.toString().split('.').last)
        .toList();

    // Handle nested objects
    final nutritionalParamsJson = nutritionalParameters?.toJson();
    final storageRequirementsJson = storageRequirements?.toJson();
    final testingRequirementsJson = testingRequirements?.toJson();

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
      'createdAt': createdAt.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt?.toIso8601String(),

      // Dairy-specific fields
      'nutritionalParameters': nutritionalParamsJson,
      'regulatoryClassifications': regulatoryClassificationsStrings,
      'storageRequirements': storageRequirementsJson,
      'testingRequirements': testingRequirementsJson,
      'milkType': milkType,
      'originFarm': originFarm,
      'processingFacility': processingFacility,
      'milkingDate': milkingDate?.toIso8601String(),
      'shelfLifeDays': shelfLifeDays,
      'allergens': allergens,
      'ingredients': ingredients,
      'certifications': certifications,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime to Timestamp
    final createdAtTimestamp = Timestamp.fromDate(createdAt);
    final updatedAtTimestamp =
        updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;
    final milkingDateTimestamp =
        milkingDate != null ? Timestamp.fromDate(milkingDate!) : null;

    return {
      ...json,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'milkingDate': milkingDateTimestamp,
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

    // Dairy-specific fields
    NutritionalParameters? nutritionalParameters,
    List<RegulatoryClassification>? regulatoryClassifications,
    StorageRequirements? storageRequirements,
    TestingRequirements? testingRequirements,
    String? milkType,
    String? originFarm,
    String? processingFacility,
    DateTime? milkingDate,
    double? shelfLifeDays,
    List<String>? allergens,
    List<String>? ingredients,
    Map<String, String>? certifications,
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

      // Dairy-specific fields
      nutritionalParameters:
          nutritionalParameters ?? this.nutritionalParameters,
      regulatoryClassifications:
          regulatoryClassifications ?? this.regulatoryClassifications,
      storageRequirements: storageRequirements ?? this.storageRequirements,
      testingRequirements: testingRequirements ?? this.testingRequirements,
      milkType: milkType ?? this.milkType,
      originFarm: originFarm ?? this.originFarm,
      processingFacility: processingFacility ?? this.processingFacility,
      milkingDate: milkingDate ?? this.milkingDate,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      allergens: allergens ?? this.allergens,
      ingredients: ingredients ?? this.ingredients,
      certifications: certifications ?? this.certifications,
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
