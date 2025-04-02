/// Maintenance related enums for the equipment maintenance module

/// Type of maintenance activity
enum MaintenanceType {
  preventive,
  corrective,
  predictive,
  sanitization,
  calibration,
  inspection,
  replacement,
  overhaul,
  other,
}

/// Status of maintenance record
enum MaintenanceStatus {
  scheduled,
  inProgress,
  completed,
  deferred,
  delayed,
  cancelled,
  pending,
}

class MaintenanceCheckItem {
  const MaintenanceCheckItem({
    required this.id,
    required this.description,
    required this.isCompleted,
    this.notes,
  });

  factory MaintenanceCheckItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceCheckItem(
      id: json['id'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      notes: json['notes'] as String?,
    );
  }
  final String id;
  final String description;
  final bool isCompleted;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  MaintenanceCheckItem copyWith({
    String? id,
    String? description,
    bool? isCompleted,
    String? notes,
  }) {
    return MaintenanceCheckItem(
      id: id ?? this.id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
