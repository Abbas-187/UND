import 'dart:async';

import '../models/milk_reception_model.dart';
import '../repositories/milk_reception_repository.dart';
import '../../../../core/notifications/notification_service.dart';

/// Service to handle notifications related to milk reception
class ReceptionNotificationService {
  final MilkReceptionRepository receptionRepository;
  final NotificationService notificationService;
  StreamSubscription<List<MilkReceptionModel>>? _receptionStreamSubscription;

  ReceptionNotificationService({
    required this.receptionRepository,
    required this.notificationService,
  });

  /// Initialize the service and start listening for milk reception events
  void initialize() {
    _startListeningToReceptions();
  }

  /// Start listening to reception updates to send notifications
  void _startListeningToReceptions() {
    _receptionStreamSubscription?.cancel();
    _receptionStreamSubscription = receptionRepository
        .getRealtimeReceptions()
        .listen(_processReceptionUpdates);
  }

  /// Process reception updates and send appropriate notifications
  void _processReceptionUpdates(List<MilkReceptionModel> receptions) {
    for (final reception in receptions) {
      if (reception.needsAttention == true) {
        _sendQualityIssueNotification(reception);
      }

      if (reception.status == 'completed' &&
          reception.inventoryProcessed != true) {
        _sendInventoryPendingNotification(reception);
      }

      if (reception.quantityLiters != null &&
          reception.quantityLiters! > 1000) {
        _sendLargeVolumeNotification(reception);
      }
    }
  }

  /// Send a notification about quality issues with a milk reception
  Future<void> _sendQualityIssueNotification(
      MilkReceptionModel reception) async {
    await notificationService.sendNotification(
      title: 'Quality Issue Detected',
      body:
          'Reception #${reception.id} has quality issues that need attention.',
      data: {
        'type': 'milk_reception_quality_issue',
        'receptionId': reception.id ?? '',
      },
      importance: NotificationImportance.high,
    );
  }

  /// Send a notification about pending inventory creation
  Future<void> _sendInventoryPendingNotification(
      MilkReceptionModel reception) async {
    await notificationService.sendNotification(
      title: 'Inventory Update Required',
      body:
          'Reception #${reception.id} is completed and ready for inventory processing.',
      data: {
        'type': 'milk_reception_inventory_pending',
        'receptionId': reception.id ?? '',
      },
      importance: NotificationImportance.medium,
    );
  }

  /// Send a notification about large volume reception
  Future<void> _sendLargeVolumeNotification(
      MilkReceptionModel reception) async {
    await notificationService.sendNotification(
      title: 'Large Volume Reception',
      body:
          'A large volume reception of ${reception.quantityLiters} liters has been recorded.',
      data: {
        'type': 'milk_reception_large_volume',
        'receptionId': reception.id ?? '',
        'volume': reception.quantityLiters.toString(),
      },
      importance: NotificationImportance.low,
    );
  }

  /// Send a notification when reception quality metrics are below threshold
  Future<void> sendLowQualityMetricsNotification({
    required String receptionId,
    required Map<String, double> metrics,
    required Map<String, double> thresholds,
  }) async {
    final issues = <String>[];

    if ((metrics['fatContent'] ?? 0) < (thresholds['minFatContent'] ?? 0)) {
      issues.add('Low fat content');
    }

    if ((metrics['proteinContent'] ?? 0) <
        (thresholds['minProteinContent'] ?? 0)) {
      issues.add('Low protein content');
    }

    if ((metrics['temperature'] ?? 0) > (thresholds['maxTemperature'] ?? 0)) {
      issues.add('Temperature too high');
    }

    if (issues.isNotEmpty) {
      await notificationService.sendNotification(
        title: 'Quality Metrics Alert',
        body:
            'Reception #$receptionId has quality issues: ${issues.join(', ')}',
        data: {
          'type': 'milk_reception_quality_metrics',
          'receptionId': receptionId,
          'issues': issues.join(','),
        },
        importance: NotificationImportance.high,
      );
    }
  }

  /// Dispose of resources
  void dispose() {
    _receptionStreamSubscription?.cancel();
    _receptionStreamSubscription = null;
  }
}
