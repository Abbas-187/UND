import 'package:flutter/foundation.dart';
import '../models/crm_reminder.dart';

class CrmReminderProvider with ChangeNotifier {
  final List<CrmReminder> _reminders = [];

  List<CrmReminder> get reminders => List.unmodifiable(_reminders);

  void addReminder(CrmReminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void completeReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = CrmReminder(
        id: _reminders[index].id,
        customerId: _reminders[index].customerId,
        message: _reminders[index].message,
        remindAt: _reminders[index].remindAt,
        isCompleted: true,
      );
      notifyListeners();
    }
  }
}
