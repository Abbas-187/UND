import 'package:flutter/foundation.dart';

import '../models/interaction_log.dart';

class InteractionLogProvider with ChangeNotifier {
  final List<InteractionLog> _logs = [];

  List<InteractionLog> get logs => List.unmodifiable(_logs);

  void addLog(InteractionLog log) {
    _logs.add(log);
    notifyListeners();
  }

  List<InteractionLog> logsForCustomer(String customerId) {
    return _logs.where((log) => log.customerId == customerId).toList();
  }
}
