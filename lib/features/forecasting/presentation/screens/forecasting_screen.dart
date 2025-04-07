import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../common/widgets/app_loading_indicator.dart';
import '../../../../common/widgets/error_view.dart';
import '../../../../common/widgets/detail_appbar.dart';
import '../../../inventory/data/models/inventory_item_model.dart';
import '../../../inventory/domain/providers/inventory_provider.dart';
import '../../domain/entities/time_series_point.dart';
import '../../domain/services/forecasting_service.dart';
import '../providers/forecasting_provider.dart';

/// Screen for generating and viewing sales forecasts
class ForecastingScreen extends ConsumerStatefulWidget {
  const ForecastingScreen({super.key, this.forecastId});
  final String? forecastId;

  @override
  ConsumerState<ForecastingScreen> createState() => _ForecastingScreenState();
}

class _ForecastingScreenState extends ConsumerState<ForecastingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  String _selectedMethod = 'linearRegression';
  int _forecastPeriods = 6;
  int _movingAverageWindow = 3;
  double _smoothingAlpha = 0.3;
  int _seasonLength = 4;

  @override
  void initState() {
    super.initState();

    // If a forecast ID is provided, load the saved forecast
    if (widget.forecastId != null) {
      // Use a post-frame callback to ensure the widget is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(forecastingProvider.notifier)
            .loadForecastById(widget.forecastId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    final forecastingState = ref.watch(forecastingProvider);

    return Scaffold(
      appBar: DetailAppBar(
        title: 'Sales Forecasting',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputForm(inventoryState),
            const SizedBox(height: 16),
            Expanded(
              child: _buildForecastingContent(forecastingState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(AsyncValue<List<InventoryItemModel>> inventoryState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Forecast Parameters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Product selection dropdown
              inventoryState.when(
                data: (items) => DropdownButtonFormField<String>(
                  value: _selectedProductId,
                  decoration: const InputDecoration(
                    labelText: 'Select Product',
                    border: OutlineInputBorder(),
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a product';
                    }
                    return null;
                  },
                ),
                loading: () => const AppLoadingIndicator(size: 30),
                error: (error, stack) => ErrorView(
                  message: 'Failed to load products: $error',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(height: 16),

              // Forecasting method selection
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Forecasting Method',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'linearRegression',
                    child: Text('Linear Regression'),
                  ),
                  DropdownMenuItem(
                    value: 'movingAverage',
                    child: Text('Moving Average'),
                  ),
                  DropdownMenuItem(
                    value: 'exponentialSmoothing',
                    child: Text('Exponential Smoothing'),
                  ),
                  DropdownMenuItem(
                    value: 'seasonalDecomposition',
                    child: Text('Seasonal Decomposition'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Periods input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _forecastPeriods.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Forecast Periods (months)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of periods';
                        }
                        final periods = int.tryParse(value);
                        if (periods == null || periods < 1 || periods > 24) {
                          return 'Enter value between 1-24';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final periods = int.tryParse(value);
                        if (periods != null) {
                          setState(() {
                            _forecastPeriods = periods;
                          });
                        }
                      },
                    ),
                  ),

                  // Method-specific parameters
                  if (_selectedMethod == 'movingAverage') ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _movingAverageWindow.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Window Size',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter window size';
                          }
                          final window = int.tryParse(value);
                          if (window == null || window < 2) {
                            return 'Min size is 2';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final window = int.tryParse(value);
                          if (window != null) {
                            setState(() {
                              _movingAverageWindow = window;
                            });
                          }
                        },
                      ),
                    ),
                  ] else if (_selectedMethod == 'exponentialSmoothing') ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _smoothingAlpha.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Alpha (0-1)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter alpha';
                          }
                          final alpha = double.tryParse(value);
                          if (alpha == null || alpha <= 0 || alpha >= 1) {
                            return 'Range: 0-1';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final alpha = double.tryParse(value);
                          if (alpha != null) {
                            setState(() {
                              _smoothingAlpha = alpha;
                            });
                          }
                        },
                      ),
                    ),
                  ] else if (_selectedMethod == 'seasonalDecomposition') ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _seasonLength.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Season Length',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter season length';
                          }
                          final length = int.tryParse(value);
                          if (length == null || length < 2) {
                            return 'Min length is 2';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final length = int.tryParse(value);
                          if (length != null) {
                            setState(() {
                              _seasonLength = length;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Generate forecast button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateForecast,
                  child: const Text('Generate Forecast'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastingContent(ForecastingState forecastingState) {
    if (forecastingState is ForecastingInitialState) {
      return const Center(
        child: Text('Select parameters and generate a forecast to get started'),
      );
    } else if (forecastingState is ForecastingLoadingState) {
      return const Center(
        child: AppLoadingIndicator(),
      );
    } else if (forecastingState is ForecastingErrorState) {
      return Center(
        child: ErrorView(
          message: forecastingState.message,
          icon: Icons.error_outline,
        ),
      );
    } else if (forecastingState is ForecastingLoadedState) {
      return _buildForecastResults(forecastingState);
    }

    return const SizedBox.shrink();
  }

  Widget _buildForecastResults(ForecastingLoadedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Forecast for ${state.productName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Forecast',
                  onPressed: () => _saveForecast(state),
                ),
                IconButton(
                  icon: const Icon(Icons.file_download),
                  tooltip: 'Export Data',
                  onPressed: () => _exportData(state),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SfCartesianChart(
            legend: Legend(isVisible: true),
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat.MMM(),
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.compact(),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              // Historical data
              LineSeries<TimeSeriesPoint, DateTime>(
                name: 'Historical',
                dataSource: state.historicalData,
                xValueMapper: (TimeSeriesPoint data, _) => data.timestamp,
                yValueMapper: (TimeSeriesPoint data, _) => data.value,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
              // Forecast data
              LineSeries<TimeSeriesPoint, DateTime>(
                name: 'Forecast',
                dataSource: state.forecastData,
                xValueMapper: (TimeSeriesPoint data, _) => data.timestamp,
                yValueMapper: (TimeSeriesPoint data, _) => data.value,
                dashArray: const [5, 5],
                markerSettings: const MarkerSettings(isVisible: true),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _generateForecast() {
    if (_formKey.currentState?.validate() ?? false) {
      // Extract parameters based on the selected method
      Map<String, dynamic> parameters = {};
      switch (_selectedMethod) {
        case 'movingAverage':
          parameters['windowSize'] = _movingAverageWindow;
          break;
        case 'exponentialSmoothing':
          parameters['alpha'] = _smoothingAlpha;
          break;
        case 'seasonalDecomposition':
          parameters['seasonLength'] = _seasonLength;
          break;
        default:
          break;
      }

      // Generate forecast
      ref.read(forecastingProvider.notifier).generateForecast(
            productId: _selectedProductId!,
            method: _selectedMethod,
            periods: _forecastPeriods,
            parameters: parameters,
          );
    }
  }

  void _saveForecast(ForecastingLoadedState state) {
    // Show dialog to get forecast name
    showDialog(
      context: context,
      builder: (context) {
        String forecastName =
            'Forecast ${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
        return AlertDialog(
          title: const Text('Save Forecast'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Forecast Name',
            ),
            onChanged: (value) {
              forecastName = value;
            },
            controller: TextEditingController(text: forecastName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(forecastingProvider.notifier).saveForecast(
                      name: forecastName,
                      productId: state.productId,
                      method: _selectedMethod,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forecast saved successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _exportData(ForecastingLoadedState state) {
    // In a real app, this would export the data to CSV or Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Export functionality will be implemented in a future update')),
    );
  }
}
