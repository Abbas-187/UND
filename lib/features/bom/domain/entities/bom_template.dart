import 'package:equatable/equatable.dart';

enum TemplateCategory {
  dairy,
  packaging,
  processing,
  quality,
  maintenance,
  custom
}

enum TemplateComplexity { simple, intermediate, advanced, expert }

class BomTemplateItem extends Equatable {
  final String id;
  final String itemCode;
  final String itemName;
  final String itemType;
  final double quantity;
  final String unit;
  final bool isOptional;
  final bool isVariable;
  final double minQuantity;
  final double maxQuantity;
  final String? description;
  final Map<String, dynamic> properties;

  const BomTemplateItem({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.itemType,
    required this.quantity,
    required this.unit,
    this.isOptional = false,
    this.isVariable = false,
    this.minQuantity = 0.0,
    this.maxQuantity = double.infinity,
    this.description,
    this.properties = const {},
  });

  @override
  List<Object?> get props => [
        id,
        itemCode,
        itemName,
        itemType,
        quantity,
        unit,
        isOptional,
        isVariable,
        minQuantity,
        maxQuantity,
        description,
        properties,
      ];

  BomTemplateItem copyWith({
    String? id,
    String? itemCode,
    String? itemName,
    String? itemType,
    double? quantity,
    String? unit,
    bool? isOptional,
    bool? isVariable,
    double? minQuantity,
    double? maxQuantity,
    String? description,
    Map<String, dynamic>? properties,
  }) {
    return BomTemplateItem(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isOptional: isOptional ?? this.isOptional,
      isVariable: isVariable ?? this.isVariable,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      description: description ?? this.description,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemCode': itemCode,
      'itemName': itemName,
      'itemType': itemType,
      'quantity': quantity,
      'unit': unit,
      'isOptional': isOptional,
      'isVariable': isVariable,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
      'description': description,
      'properties': properties,
    };
  }

  factory BomTemplateItem.fromJson(Map<String, dynamic> json) {
    return BomTemplateItem(
      id: json['id'] as String,
      itemCode: json['itemCode'] as String,
      itemName: json['itemName'] as String,
      itemType: json['itemType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      isOptional: json['isOptional'] as bool? ?? false,
      isVariable: json['isVariable'] as bool? ?? false,
      minQuantity: (json['minQuantity'] as num?)?.toDouble() ?? 0.0,
      maxQuantity: (json['maxQuantity'] as num?)?.toDouble() ?? double.infinity,
      description: json['description'] as String?,
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
    );
  }
}

class BomTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final TemplateCategory category;
  final TemplateComplexity complexity;
  final String version;
  final bool isActive;
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BomTemplateItem> items;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String? thumbnailUrl;
  final int usageCount;
  final double rating;
  final List<String> validationRules;

  const BomTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.complexity,
    required this.version,
    required this.isActive,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.metadata = const {},
    this.tags = const [],
    this.thumbnailUrl,
    this.usageCount = 0,
    this.rating = 0.0,
    this.validationRules = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        complexity,
        version,
        isActive,
        isPublic,
        createdBy,
        createdAt,
        updatedAt,
        items,
        metadata,
        tags,
        thumbnailUrl,
        usageCount,
        rating,
        validationRules,
      ];

  BomTemplate copyWith({
    String? id,
    String? name,
    String? description,
    TemplateCategory? category,
    TemplateComplexity? complexity,
    String? version,
    bool? isActive,
    bool? isPublic,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BomTemplateItem>? items,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? thumbnailUrl,
    int? usageCount,
    double? rating,
    List<String>? validationRules,
  }) {
    return BomTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      complexity: complexity ?? this.complexity,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      validationRules: validationRules ?? this.validationRules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'complexity': complexity.name,
      'version': version,
      'isActive': isActive,
      'isPublic': isPublic,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'metadata': metadata,
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
      'usageCount': usageCount,
      'rating': rating,
      'validationRules': validationRules,
    };
  }

  factory BomTemplate.fromJson(Map<String, dynamic> json) {
    return BomTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: TemplateCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TemplateCategory.custom,
      ),
      complexity: TemplateComplexity.values.firstWhere(
        (e) => e.name == json['complexity'],
        orElse: () => TemplateComplexity.simple,
      ),
      version: json['version'] as String,
      isActive: json['isActive'] as bool,
      isPublic: json['isPublic'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List)
          .map((item) => BomTemplateItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      tags: List<String>.from(json['tags'] as List? ?? []),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      validationRules:
          List<String>.from(json['validationRules'] as List? ?? []),
    );
  }
}
