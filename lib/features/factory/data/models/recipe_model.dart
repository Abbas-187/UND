import 'recipe_ingredient_model.dart';

class RecipeModel {
  final String id;
  final String name;
  final String productId;
  final Map<String, double> ingredients;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.ingredients,
    this.approvedByUserId,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      productId: json['productId'] as String,
      ingredients: Map<String, double>.from(json['ingredients'] as Map),
      approvedByUserId: json['approvedByUserId'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'productId': productId,
      'ingredients': ingredients,
      'approvedByUserId': approvedByUserId,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RecipeModel copyWith({
    String? id,
    String? name,
    String? productId,
    Map<String, double>? ingredients,
    String? approvedByUserId,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      productId: productId ?? this.productId,
      ingredients: ingredients ?? this.ingredients,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RecipeModel(id: $id, name: $name, productId: $productId, ingredients: $ingredients, approvedByUserId: $approvedByUserId, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecipeModel &&
        other.id == id &&
        other.name == name &&
        other.productId == productId &&
        other.ingredients == ingredients &&
        other.approvedByUserId == approvedByUserId &&
        other.approvedAt == approvedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        productId.hashCode ^
        ingredients.hashCode ^
        approvedByUserId.hashCode ^
        approvedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
