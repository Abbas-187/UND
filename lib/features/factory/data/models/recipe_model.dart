import 'recipe_step_model.dart';

class RecipeHistoryEntry {
  final DateTime timestamp;
  final String user;
  final String action;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? note;

  RecipeHistoryEntry({
    required this.timestamp,
    required this.user,
    required this.action,
    this.before,
    this.after,
    this.note,
  });

  factory RecipeHistoryEntry.fromJson(Map<String, dynamic> json) {
    return RecipeHistoryEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      user: json['user'] as String,
      action: json['action'] as String,
      before: json['before'] as Map<String, dynamic>?,
      after: json['after'] as Map<String, dynamic>?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'user': user,
      'action': action,
      'before': before,
      'after': after,
      'note': note,
    };
  }
}

class RecipeModel {
  RecipeModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.ingredients,
    this.approvedByUserId,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.steps = const [],
    this.history = const [],
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
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      history: (json['history'] as List<dynamic>?)
              ?.map(
                  (e) => RecipeHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  final String id;
  final String name;
  final String productId;
  final Map<String, double> ingredients;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RecipeStepModel> steps;
  final List<RecipeHistoryEntry> history;

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
      'steps': steps.map((e) => e.toJson()).toList(),
      'history': history.map((e) => e.toJson()).toList(),
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
    List<RecipeStepModel>? steps,
    List<RecipeHistoryEntry>? history,
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
      steps: steps ?? this.steps,
      history: history ?? this.history,
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
