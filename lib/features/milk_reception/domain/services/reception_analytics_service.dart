import '../models/milk_reception_model.dart';
import '../repositories/milk_reception_repository.dart';

/// Service to handle analytics operations for milk reception
class ReceptionAnalyticsService {
  final MilkReceptionRepository receptionRepository;

  ReceptionAnalyticsService({
    required this.receptionRepository,
  });

  /// Calculate average quality metrics across all completed receptions within a date range
  Future<Map<String, double>> calculateAverageQualityMetrics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final receptions = await receptionRepository.getReceptionsInDateRange(
      startDate,
      endDate,
      status: 'completed',
    );

    if (receptions.isEmpty) {
      return {
        'avgFatContent': 0,
        'avgProteinContent': 0,
        'avgTemperature': 0,
      };
    }

    double totalFat = 0;
    double totalProtein = 0;
    double totalTemp = 0;

    for (final reception in receptions) {
      totalFat += reception.fatContent ?? 0;
      totalProtein += reception.proteinContent ?? 0;
      totalTemp += reception.temperature ?? 0;
    }

    final count = receptions.length;

    return {
      'avgFatContent': totalFat / count,
      'avgProteinContent': totalProtein / count,
      'avgTemperature': totalTemp / count,
    };
  }

  /// Get total milk volume received within a date range, grouped by milk type
  Future<Map<String, double>> getTotalVolumeByMilkType({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final receptions = await receptionRepository.getReceptionsInDateRange(
      startDate,
      endDate,
      status: 'completed',
    );

    final Map<String, double> volumeByType = {};

    for (final reception in receptions) {
      final milkType = reception.milkType ?? 'unknown';
      final volume = reception.quantityLiters ?? 0;

      volumeByType[milkType] = (volumeByType[milkType] ?? 0) + volume;
    }

    return volumeByType;
  }

  /// Get total milk volume received by day within a date range
  Future<Map<DateTime, double>> getDailyVolumeReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final receptions = await receptionRepository.getReceptionsInDateRange(
      startDate,
      endDate,
      status: 'completed',
    );

    final Map<DateTime, double> dailyVolume = {};

    for (final reception in receptions) {
      // Normalize date to remove time component
      final receptionDate = DateTime(
        reception.receptionDate?.year ?? 0,
        reception.receptionDate?.month ?? 0,
        reception.receptionDate?.day ?? 0,
      );

      final volume = reception.quantityLiters ?? 0;
      dailyVolume[receptionDate] = (dailyVolume[receptionDate] ?? 0) + volume;
    }

    return dailyVolume;
  }

  /// Calculate quality metrics by supplier
  Future<Map<String, Map<String, double>>> getQualityMetricsBySupplier({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final receptions = await receptionRepository.getReceptionsInDateRange(
      startDate,
      endDate,
      status: 'completed',
    );

    final Map<String, List<MilkReceptionModel>> receptionsBySupplier = {};

    // Group receptions by supplier
    for (final reception in receptions) {
      final supplierId = reception.supplierId ?? 'unknown';

      if (!receptionsBySupplier.containsKey(supplierId)) {
        receptionsBySupplier[supplierId] = [];
      }

      receptionsBySupplier[supplierId]!.add(reception);
    }

    // Calculate averages for each supplier
    final Map<String, Map<String, double>> results = {};

    receptionsBySupplier.forEach((supplierId, supplierReceptions) {
      double totalFat = 0;
      double totalProtein = 0;
      double totalTemp = 0;
      double totalVolume = 0;

      for (final reception in supplierReceptions) {
        totalFat += reception.fatContent ?? 0;
        totalProtein += reception.proteinContent ?? 0;
        totalTemp += reception.temperature ?? 0;
        totalVolume += reception.quantityLiters ?? 0;
      }

      final count = supplierReceptions.length;

      results[supplierId] = {
        'avgFatContent': totalFat / count,
        'avgProteinContent': totalProtein / count,
        'avgTemperature': totalTemp / count,
        'totalVolume': totalVolume,
        'receptionCount': count.toDouble(),
      };
    });

    return results;
  }
}
