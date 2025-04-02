class RecipeStepModel {
  const RecipeStepModel({
    this.id,
    required this.instruction,
    required this.order,
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      id: json['id'] as String?,
      instruction: json['instruction'] as String,
      order: json['order'] as int,
    );
  }

  final String? id;
  final String instruction;
  final int order;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instruction': instruction,
      'order': order,
    };
  }

  RecipeStepModel copyWith({
    String? id,
    String? instruction,
    int? order,
  }) {
    return RecipeStepModel(
      id: id ?? this.id,
      instruction: instruction ?? this.instruction,
      order: order ?? this.order,
    );
  }

  @override
  String toString() =>
      'RecipeStepModel(id: $id, instruction: $instruction, order: $order)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecipeStepModel &&
        other.id == id &&
        other.instruction == instruction &&
        other.order == order;
  }

  @override
  int get hashCode => id.hashCode ^ instruction.hashCode ^ order.hashCode;
}
