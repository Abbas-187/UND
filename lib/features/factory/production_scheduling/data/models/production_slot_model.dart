class ProductionSlotModel {
  const ProductionSlotModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.lineId,
    required this.lineName,
    required this.startTime,
    required this.endTime,
    required this.plannedQuantity,
    this.recipeId,
    this.recipeVersion,
    required this.status,
    required this.assignedStaffId,
    this.comments,
    required this.prerequisiteSlotIds,
    required this.pasteurizationData,
    required this.metadata,
  });

  factory ProductionSlotModel.fromJson(Map<String, dynamic> json) {
    return ProductionSlotModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      lineId: json['lineId'],
      lineName: json['lineName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      plannedQuantity: (json['plannedQuantity'] as num).toDouble(),
      recipeId: json['recipeId'],
      recipeVersion: json['recipeVersion'],
      status: SlotStatus.values
          .firstWhere((e) => e.toString() == 'SlotStatus.${json['status']}'),
      assignedStaffId: json['assignedStaffId'],
      comments: json['comments'],
      prerequisiteSlotIds: List<String>.from(json['prerequisiteSlotIds']),
      pasteurizationData: json['pasteurizationData'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
  final String id;
  final String productId;
  final String productName;
  final String lineId;
  final String lineName;
  final DateTime startTime;
  final DateTime endTime;
  final double plannedQuantity;
  final String? recipeId;
  final String? recipeVersion;
  final SlotStatus status;
  final String assignedStaffId;
  final String? comments;
  final List<String> prerequisiteSlotIds;
  final Map<String, dynamic> pasteurizationData;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'lineId': lineId,
      'lineName': lineName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'plannedQuantity': plannedQuantity,
      'recipeId': recipeId,
      'recipeVersion': recipeVersion,
      'status': status.toString().split('.').last,
      'assignedStaffId': assignedStaffId,
      'comments': comments,
      'prerequisiteSlotIds': prerequisiteSlotIds,
      'pasteurizationData': pasteurizationData,
      'metadata': metadata,
    };
  }

  ProductionSlotModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? lineId,
    String? lineName,
    DateTime? startTime,
    DateTime? endTime,
    double? plannedQuantity,
    String? recipeId,
    String? recipeVersion,
    SlotStatus? status,
    String? assignedStaffId,
    String? comments,
    List<String>? prerequisiteSlotIds,
    Map<String, dynamic>? pasteurizationData,
    Map<String, dynamic>? metadata,
  }) {
    return ProductionSlotModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      lineId: lineId ?? this.lineId,
      lineName: lineName ?? this.lineName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      recipeId: recipeId ?? this.recipeId,
      recipeVersion: recipeVersion ?? this.recipeVersion,
      status: status ?? this.status,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      comments: comments ?? this.comments,
      prerequisiteSlotIds: prerequisiteSlotIds ?? this.prerequisiteSlotIds,
      pasteurizationData: pasteurizationData ?? this.pasteurizationData,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum SlotStatus {
  scheduled,
  inPreparation,
  inProgress,
  completed,
  cancelled,
  delayed
}
