import 'production_line_allocation_model.dart';
import 'production_slot_model.dart';

class ProductionScheduleModel {
  const ProductionScheduleModel({
    required this.id,
    required this.name,
    required this.scheduleDate,
    required this.createdDate,
    required this.createdBy,
    required this.lineAllocations,
    required this.slots,
    this.notes,
    required this.isActive,
    this.lastModifiedBy,
    this.lastModifiedDate,
    required this.status,
    required this.metadata,
  });

  factory ProductionScheduleModel.fromJson(Map<String, dynamic> json) {
    return ProductionScheduleModel(
      id: json['id'],
      name: json['name'],
      scheduleDate: DateTime.parse(json['scheduleDate']),
      createdDate: DateTime.parse(json['createdDate']),
      createdBy: json['createdBy'],
      lineAllocations: (json['lineAllocations'] as List)
          .map((e) => ProductionLineAllocationModel.fromJson(e))
          .toList(),
      slots: (json['slots'] as List)
          .map((e) => ProductionSlotModel.fromJson(e))
          .toList(),
      notes: json['notes'],
      isActive: json['isActive'],
      lastModifiedBy: json['lastModifiedBy'],
      lastModifiedDate: json['lastModifiedDate'] != null
          ? DateTime.parse(json['lastModifiedDate'])
          : null,
      status: ScheduleStatus.values.firstWhere(
          (e) => e.toString() == 'ScheduleStatus.${json['status']}'),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  factory ProductionScheduleModel.empty() => ProductionScheduleModel(
        id: '',
        name: '',
        scheduleDate: DateTime.now(),
        createdDate: DateTime.now(),
        createdBy: '',
        lineAllocations: [],
        slots: [],
        isActive: true,
        status: ScheduleStatus.draft,
        metadata: {},
      );
  final String id;
  final String name;
  final DateTime scheduleDate;
  final DateTime createdDate;
  final String createdBy;
  final List<ProductionLineAllocationModel> lineAllocations;
  final List<ProductionSlotModel> slots;
  final String? notes;
  final bool isActive;
  final String? lastModifiedBy;
  final DateTime? lastModifiedDate;
  final ScheduleStatus status;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scheduleDate': scheduleDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'createdBy': createdBy,
      'lineAllocations': lineAllocations.map((e) => e.toJson()).toList(),
      'slots': slots.map((e) => e.toJson()).toList(),
      'notes': notes,
      'isActive': isActive,
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedDate': lastModifiedDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'metadata': metadata,
    };
  }

  ProductionScheduleModel copyWith({
    String? id,
    String? name,
    DateTime? scheduleDate,
    DateTime? createdDate,
    String? createdBy,
    List<ProductionLineAllocationModel>? lineAllocations,
    List<ProductionSlotModel>? slots,
    String? notes,
    bool? isActive,
    String? lastModifiedBy,
    DateTime? lastModifiedDate,
    ScheduleStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return ProductionScheduleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      createdDate: createdDate ?? this.createdDate,
      createdBy: createdBy ?? this.createdBy,
      lineAllocations: lineAllocations ?? this.lineAllocations,
      slots: slots ?? this.slots,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum ScheduleStatus { draft, published, inProgress, completed, cancelled }
