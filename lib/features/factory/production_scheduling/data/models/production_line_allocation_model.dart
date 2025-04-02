class ProductionLineAllocationModel {
  const ProductionLineAllocationModel({
    required this.id,
    required this.lineId,
    required this.lineName,
    required this.capacity,
    required this.availableTimeBlocks,
    required this.isAvailable,
    this.unavailabilityReason,
    required this.metadata,
  });

  factory ProductionLineAllocationModel.fromJson(Map<String, dynamic> json) {
    return ProductionLineAllocationModel(
      id: json['id'],
      lineId: json['lineId'],
      lineName: json['lineName'],
      capacity: (json['capacity'] as num).toDouble(),
      availableTimeBlocks: (json['availableTimeBlocks'] as List)
          .map((e) => TimeBlock.fromJson(e))
          .toList(),
      isAvailable: json['isAvailable'],
      unavailabilityReason: json['unavailabilityReason'],
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
  final String id;
  final String lineId;
  final String lineName;
  final double capacity; // Liters per hour
  final List<TimeBlock> availableTimeBlocks;
  final bool isAvailable;
  final String? unavailabilityReason;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lineId': lineId,
      'lineName': lineName,
      'capacity': capacity,
      'availableTimeBlocks':
          availableTimeBlocks.map((e) => e.toJson()).toList(),
      'isAvailable': isAvailable,
      'unavailabilityReason': unavailabilityReason,
      'metadata': metadata,
    };
  }
}

class TimeBlock {
  const TimeBlock({
    required this.startTime,
    required this.endTime,
    required this.isAllocated,
    this.allocationId,
    this.allocationName,
  });

  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAllocated: json['isAllocated'],
      allocationId: json['allocationId'],
      allocationName: json['allocationName'],
    );
  }
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllocated;
  final String? allocationId;
  final String? allocationName;

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllocated': isAllocated,
      'allocationId': allocationId,
      'allocationName': allocationName,
    };
  }
}
