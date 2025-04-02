import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:und_app/common/widgets/app_loading_indicator.dart';
import 'package:und_app/common/widgets/error_view.dart';
import 'package:und_app/features/forecasting/domain/entities/time_series_point.dart';
import 'package:und_app/features/forecasting/domain/services/forecasting_service.dart';
import 'package:und_app/features/forecasting/presentation/providers/forecasting_provider.dart';
import 'package:und_app/features/inventory/data/models/inventory_item_model.dart';
import 'package:und_app/features/inventory/domain/providers/inventory_provider.dart';
import 'package:und_app/features/sales/data/models/sales_order_model.dart';

/// Screen for generating and viewing sales forecasts
class ForecastingScreen extends ConsumerStatefulWidget {
  final String? forecastId;

  const ForecastingScreen({Key? key, this.forecastId}) : super(key: key);

  @override
  ConsumerState<ForecastingScreen> createState() => _ForecastingScreenState();
}

class _ForecastingScreenState extends ConsumerState<ForecastingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  ForecastingMethod _selectedMethod = ForecastingMethod.linearRegression;
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
      appBar: AppBar(
        title: const Text('Sales Forecasting'),
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
              DropdownButtonFormField<ForecastingMethod>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Forecasting Method',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: ForecastingMethod.linearRegression,
                    child: const Text('Linear Regression'),
                  ),
                  DropdownMenuItem(
                    value: ForecastingMethod.movingAverage,
                    child: const Text('Moving Average'),
                  ),
                  DropdownMenuItem(
                    value: ForecastingMethod.exponentialSmoothing,
                    child: const Text('Exponential Smoothing'),
                  ),
                  DropdownMenuItem(
                    value: ForecastingMethod.seasonalDecomposition,
                    child: const Text('Seasonal Decomposition'),
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
                  if (_selectedMethod == ForecastingMethod.movingAverage) ...[
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
                  ] else if (_selectedMethod ==
                      ForecastingMethod.exponentialSmoothing) ...[
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
                  ] else if (_selectedMethod ==
                      ForecastingMethod.seasonalDecomposition) ...[
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

  Widget _buildForecastingContent(ForecastingState state) {
    if (state is ForecastingInitialState) {
      return const Center(
        child: Text('Select parameters and generate a forecast'),
      );
    } else if (state is ForecastingLoadingState) {
      return const Center(
        child: AppLoadingIndicator(
          message: 'Generating forecast...',
        ),
      );
    } else if (state is ForecastingErrorState) {
      return Center(
        child: ErrorView(
          message: state.message,
          icon: Icons.error_outline,
          onRetry: _generateForecast,
        ),
      );
    } else if (state is ForecastingLoadedState) {
      return _buildForecastChart(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildForecastChart(ForecastingLoadedState state) {
    final allData = [...state.historicalData, ...state.forecastData];
    final dateFormat = DateFormat('MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forecast for ${state.productName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: dateFormat,
              intervalType: DateTimeIntervalType.months,
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Quantity'),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            legend: Legend(isVisible: true),
            series: <CartesianSeries<TimeSeriesPoint, DateTime>>[
              // Historical data
              LineSeries<TimeSeriesPoint, DateTime>(
                name: 'Historical',
                dataSource: state.historicalData,
                xValueMapper: (point, _) => point.timestamp,
                yValueMapper: (point, _) => point.value,
                color: Colors.blue,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
              // Forecast data
              LineSeries<TimeSeriesPoint, DateTime>(
                name: 'Forecast',
                dataSource: state.forecastData,
                xValueMapper: (point, _) => point.timestamp,
                yValueMapper: (point, _) => point.value,
                color: Colors.red,
                markerSettings: const MarkerSettings(isVisible: true),
                dashArray: const [5, 5],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => _saveForecast(state),
              icon: const Icon(Icons.save),
              label: const Text('Save Forecast'),
            ),
            OutlinedButton.icon(
              onPressed: () => _exportData(state),
              icon: const Icon(Icons.download),
              label: const Text('Export Data'),
            ),
          ],
        ),
      ],
    );
  }

  void _generateForecast() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product')),
        );
        return;
      }

      // Prepare parameters based on selected method
      Map<String, dynamic> parameters = {};
      switch (_selectedMethod) {
        case ForecastingMethod.movingAverage:
          parameters['windowSize'] = _movingAverageWindow;
          break;
        case ForecastingMethod.exponentialSmoothing:
          parameters['alpha'] = _smoothingAlpha;
          break;
        case ForecastingMethod.seasonalDecomposition:
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
