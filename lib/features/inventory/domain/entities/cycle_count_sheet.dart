// Data model for cycle count sheet
class CycleCountSheet {
  CycleCountSheet({
    required this.sheetId,
    this.scheduleId,
    required this.creationDate,
    required this.assignedUserId,
    required this.dueDate,
    required this.status,
    required this.warehouseId,
    this.notes,
  });
  final String sheetId;
  final String? scheduleId;
  final DateTime creationDate;
  final String assignedUserId;
  final DateTime dueDate;
  final String status; // Pending, In Progress, Completed, Adjusted, Cancelled
  final String warehouseId;
  final String? notes;

  CycleCountSheet copyWith({
    String? sheetId,
    String? scheduleId,
    DateTime? creationDate,
    String? assignedUserId,
    DateTime? dueDate,
    String? status,
    String? warehouseId,
    String? notes,
  }) {
    return CycleCountSheet(
      sheetId: sheetId ?? this.sheetId,
      scheduleId: scheduleId ?? this.scheduleId,
      creationDate: creationDate ?? this.creationDate,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      warehouseId: warehouseId ?? this.warehouseId,
      notes: notes ?? this.notes,
    );
  }
}
