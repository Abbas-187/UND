enum AttributeType {
  text,
  number,
  selection,
  boolean,
}

class AttributeDefinition {
  final String name;
  final AttributeType type;
  final String? description;
  final bool required;
  final List<String>? options;
  final dynamic defaultValue;

  const AttributeDefinition({
    required this.name,
    required this.type,
    this.description,
    this.required = false,
    this.options,
    this.defaultValue,
  });

  AttributeDefinition copyWith({
    String? name,
    AttributeType? type,
    String? description,
    bool? required,
    List<String>? options,
    dynamic defaultValue,
  }) {
    return AttributeDefinition(
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      required: required ?? this.required,
      options: options ?? this.options,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }
}

class InventoryCategory {
  final String id;
  final String name;
  final String description;
  final String? parentCategoryId;
  final String colorCode;
  final int itemCount;
  final Map<String, AttributeDefinition> attributeDefinitions;

  const InventoryCategory({
    required this.id,
    required this.name,
    required this.description,
    this.parentCategoryId,
    required this.colorCode,
    required this.itemCount,
    required this.attributeDefinitions,
  });

  InventoryCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? parentCategoryId,
    String? colorCode,
    int? itemCount,
    Map<String, AttributeDefinition>? attributeDefinitions,
  }) {
    return InventoryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      colorCode: colorCode ?? this.colorCode,
      itemCount: itemCount ?? this.itemCount,
      attributeDefinitions: attributeDefinitions ?? this.attributeDefinitions,
    );
  }
}
