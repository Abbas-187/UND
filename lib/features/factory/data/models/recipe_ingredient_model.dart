class RecipeIngredientModel {
  const RecipeIngredientModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  final String id;
  final String name;
  final double quantity;
  final String unit;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  RecipeIngredientModel copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
  }) {
    return RecipeIngredientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() {
    return 'RecipeIngredientModel(id: $id, name: $name, quantity: $quantity, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecipeIngredientModel &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ quantity.hashCode ^ unit.hashCode;
  }
}
