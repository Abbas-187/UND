// Data model for cycle count schedule
class CycleCountSchedule {
  CycleCountSchedule({
    required this.scheduleId,
    required this.scheduleName,
    required this.creationDate,
    required this.frequency,
    required this.nextDueDate,
    required this.itemSelectionCriteria,
    required this.status,
    this.lastGeneratedSheetId,
  });
  final String scheduleId;
  final String scheduleName;
  final DateTime creationDate;
  final String frequency; // e.g., daily, weekly, monthly
  final DateTime nextDueDate;
  final Map<String, dynamic> itemSelectionCriteria; // ABC, location, etc.
  final String status; // Active, Inactive, Archived
  final String? lastGeneratedSheetId;
}
