import 'dart:async';
import '../../../crm/repositories/crm_repository.dart';
import '../entities/demand_signal_model.dart';

/// Use case to extract and transform CRM data into demand signals for forecasting
class GetCrmDemandSignalsUseCase {
  GetCrmDemandSignalsUseCase({
    required this.crmRepository,
    this.refreshInterval = const Duration(hours: 1),
  });
  final CrmRepository crmRepository;
  final Duration refreshInterval;
  Timer? _timer;
  void Function(List<DemandSignalModel>)? onSignalsUpdated;

  /// Start periodic extraction and transformation of CRM demand signals
  void startAutoExtraction({
    required DateTime startDate,
    required DateTime endDate,
    required void Function(List<DemandSignalModel>) onUpdate,
  }) {
    onSignalsUpdated = onUpdate;
    _timer?.cancel();
    _timer = Timer.periodic(refreshInterval, (_) async {
      final signals = await execute(startDate: startDate, endDate: endDate);
      onSignalsUpdated?.call(signals);
    });
  }

  /// Stop the periodic extraction
  void stopAutoExtraction() {
    _timer?.cancel();
    _timer = null;
  }

  /// Returns a list of demand signals for the given date range
  Future<List<DemandSignalModel>> execute({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final List<DemandSignalModel> signals = [];

    // Example: Use orders as a fallback if no CRM-specific endpoints exist
    final customers = await crmRepository.searchCustomers('');
    for (final customer in customers) {
      // Advanced weighting: newer customers and those with more tags are weighted higher
      final recencyWeight = 1.0 -
          (DateTime.now().difference(customer.createdAt).inDays / 365.0)
              .clamp(0, 1);
      final tagWeight = (customer.tags.length / 10.0).clamp(0.1, 1.0);
      final confidence =
          (0.5 * recencyWeight + 0.5 * tagWeight).clamp(0.1, 1.0);
      signals.add(DemandSignalModel(
        productId: 'unknown',
        signalDate: customer.createdAt,
        signalQuantity: 1 * confidence,
        signalType: 'CUSTOMER',
        confidenceScore: confidence,
        sourceId: customer.id,
      ));
    }

    // TODO: Replace with real CRM opportunity/campaign/segment/lead extraction and advanced weighting logic
    return signals;
  }
}
