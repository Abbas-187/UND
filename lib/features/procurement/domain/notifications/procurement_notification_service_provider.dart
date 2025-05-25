import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'procurement_notification_service.dart';

final procurementNotificationServiceProvider =
    Provider<ProcurementNotificationService>((ref) {
  return ProcurementNotificationService();
});
