import 'package:flutter/material.dart';
import '../models/crm_reminder.dart';

class CrmRemindersScreen extends StatelessWidget {

  const CrmRemindersScreen(
      {super.key, required this.reminders, required this.onComplete});
  final List<CrmReminder> reminders;
  final void Function(String id) onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRM Reminders')),
      body: ListView(
        children: reminders.map((reminder) {
          return ListTile(
            title: Text(reminder.message),
            subtitle: Text('Remind at: ${reminder.remindAt}'),
            trailing: reminder.isCompleted
                ? Icon(Icons.check, color: Colors.green)
                : IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () => onComplete(reminder.id),
                  ),
          );
        }).toList(),
      ),
    );
  }
}
