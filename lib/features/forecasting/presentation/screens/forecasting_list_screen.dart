import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/app_loading_indicator.dart';
import '../../../../common/widgets/error_view.dart';
import '../../../../core/routes/app_router.dart';
import '../../data/models/sales_forecast_model.dart';
import '../../domain/services/forecasting_service.dart';

/// Provider for fetching all saved forecasts
final savedForecastsProvider =
    FutureProvider<List<SalesForecastModel>>((ref) async {
  final forecastingService = ForecastingService();
  // In a real app, we would fetch all forecasts or filter by product
  // For now, we'll assume we're getting all forecasts for a demo product
  try {
    return forecastingService.getForecastsForProduct('demo-product-id');
  } catch (e) {
    // Return empty list in case of errors for now
    return [];
  }
});

class ForecastingListScreen extends ConsumerWidget {
  const ForecastingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedForecasts = ref.watch(savedForecastsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Forecasting'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Forecasting',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use data-driven forecasting to predict future sales and optimize inventory levels.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.forecastingCreate);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Forecast'),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const Text(
              'Saved Forecasts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: savedForecasts.when(
              data: (forecasts) {
                if (forecasts.isEmpty) {
                  return const Center(
                    child: Text('No saved forecasts yet'),
                  );
                }
                return ListView.builder(
                  itemCount: forecasts.length,
                  itemBuilder: (context, index) {
                    final forecast = forecasts[index];
                    return ForecastListItem(
                      forecast: forecast,
                      onTap: () {
                        _openSavedForecast(context, forecast.id);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: AppLoadingIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: ErrorView(
                  message: 'Error loading forecasts: $error',
                  icon: Icons.error_outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSavedForecast(BuildContext context, String? forecastId) {
    if (forecastId == null) return;

    Navigator.of(context).pushNamed(
      AppRoutes.forecastingDetail,
      arguments: ForecastingDetailArgs(forecastId: forecastId),
    );
  }
}

class ForecastListItem extends StatelessWidget {

  const ForecastListItem({
    super.key,
    required this.forecast,
    required this.onTap,
  });
  final SalesForecastModel forecast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Calculate simple forecast metrics
    final lastValue =
        forecast.forecastData.isNotEmpty ? forecast.forecastData.last.value : 0;
    final firstValue = forecast.forecastData.isNotEmpty
        ? forecast.forecastData.first.value
        : 0;
    final change = lastValue - firstValue;
    final isPositive = change >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      forecast.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildMethodBadge(forecast.methodName),
                ],
              ),
              const SizedBox(height: 8),
              Text('Created: ${dateFormat.format(forecast.createdDate)}'),
              const SizedBox(height: 4),
              Text('Product ID: ${forecast.productId}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Periods: ${forecast.forecastData.length}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodBadge(String methodName) {
    Color color;
    String label;

    switch (methodName) {
      case 'linearRegression':
        color = Colors.blue;
        label = 'Linear';
        break;
      case 'movingAverage':
        color = Colors.green;
        label = 'Moving Avg';
        break;
      case 'exponentialSmoothing':
        color = Colors.orange;
        label = 'Exp Smooth';
        break;
      case 'seasonalDecomposition':
        color = Colors.purple;
        label = 'Seasonal';
        break;
      default:
        color = Colors.grey;
        label = 'Other';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
