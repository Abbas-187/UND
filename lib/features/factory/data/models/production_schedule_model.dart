class ProductionScheduleModel {
  final String id;
  final DateTime date;
  final String productionOrderId;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;

  ProductionScheduleModel({
    required this.id,
    required this.date,
    required this.productionOrderId,
    required this.status,
    this.startTime,
    this.endTime,
  });

  factory ProductionScheduleModel.fromJson(Map<String, dynamic> json) {
    return ProductionScheduleModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      productionOrderId: json['productionOrderId'] as String,
      status: json['status'] as String,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'productionOrderId': productionOrderId,
      'status': status,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  ProductionScheduleModel copyWith({
    String? id,
    DateTime? date,
    String? productionOrderId,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ProductionScheduleModel(
      id: id ?? this.id,
      date: date ?? this.date,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
