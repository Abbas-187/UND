class InventoryCategory {
  const InventoryCategory({
    required this.id,
    required this.name,
    required this.description,
    this.parentCategoryId,
    this.attributeDefinitions = const {},
    this.colorCode,
    this.imageUrl,
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final String description;
  final String? parentCategoryId;
  final Map<String, AttributeDefinition> attributeDefinitions;
  final String? colorCode;
  final String? imageUrl;
  final int itemCount;

  InventoryCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? parentCategoryId,
    Map<String, AttributeDefinition>? attributeDefinitions,
    String? colorCode,
    String? imageUrl,
    int? itemCount,
  }) {
    return InventoryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      attributeDefinitions: attributeDefinitions ?? this.attributeDefinitions,
      colorCode: colorCode ?? this.colorCode,
      imageUrl: imageUrl ?? this.imageUrl,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    final attributeDefinitionsMap = <String, AttributeDefinition>{};
    if (json['attributeDefinitions'] != null) {
      final Map<String, dynamic> attrDefs =
          Map<String, dynamic>.from(json['attributeDefinitions'] as Map);

      attrDefs.forEach((key, value) {
        attributeDefinitionsMap[key] =
            AttributeDefinition.fromJson(value as Map<String, dynamic>);
      });
    }

    return InventoryCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      parentCategoryId: json['parentCategoryId'] as String?,
      attributeDefinitions: attributeDefinitionsMap,
      colorCode: json['colorCode'] as String?,
      imageUrl: json['imageUrl'] as String?,
      itemCount: (json['itemCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final attributeDefinitionsJson = <String, dynamic>{};
    attributeDefinitions.forEach((key, value) {
      attributeDefinitionsJson[key] = value.toJson();
    });

    return {
      'id': id,
      'name': name,
      'description': description,
      'parentCategoryId': parentCategoryId,
      'attributeDefinitions': attributeDefinitionsJson,
      'colorCode': colorCode,
      'imageUrl': imageUrl,
      'itemCount': itemCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          parentCategoryId == other.parentCategoryId &&
          colorCode == other.colorCode &&
          imageUrl == other.imageUrl &&
          itemCount == other.itemCount;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      parentCategoryId.hashCode ^
      colorCode.hashCode ^
      imageUrl.hashCode ^
      itemCount.hashCode;
}

enum AttributeType {
  text,
  number,
  boolean,
  date,
  selection,
}

class AttributeDefinition {
  const AttributeDefinition({
    required this.name,
    required this.type,
    this.description = '',
    this.required = false,
    this.defaultValue,
    this.validationRule,
    this.options = const [],
  });

  final String name;
  final AttributeType type;
  final String description;
  final bool required;
  final dynamic defaultValue;
  final String? validationRule;
  final List<String> options;

  factory AttributeDefinition.fromJson(Map<String, dynamic> json) {
    return AttributeDefinition(
      name: json['name'] as String,
      type: AttributeType.values.firstWhere(
          (e) => e.toString() == 'AttributeType.${json['type']}',
          orElse: () => AttributeType.text),
      description: json['description'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      defaultValue: json['defaultValue'],
      validationRule: json['validationRule'] as String?,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'required': required,
      'defaultValue': defaultValue,
      'validationRule': validationRule,
      'options': options,
    };
  }

  AttributeDefinition copyWith({
    String? name,
    AttributeType? type,
    String? description,
    bool? required,
    dynamic defaultValue,
    String? validationRule,
    List<String>? options,
  }) {
    return AttributeDefinition(
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
      validationRule: validationRule ?? this.validationRule,
      options: options ?? this.options,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeDefinition &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          description == other.description &&
          required == other.required &&
          validationRule == other.validationRule;

  @override
  int get hashCode =>
      name.hashCode ^
      type.hashCode ^
      description.hashCode ^
      required.hashCode ^
      validationRule.hashCode;
}
