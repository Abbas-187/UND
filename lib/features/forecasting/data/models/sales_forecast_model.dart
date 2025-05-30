import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../forecasting/domain/entities/time_series_point.dart';

/// Model for sales forecasts stored in Firestore
class SalesForecastModel {
  SalesForecastModel({
    this.id,
    required this.name,
    this.description,
    required this.productId,
    required this.createdDate,
    required this.methodName,
    required this.historicalData,
    required this.forecastData,
    required this.parameters,
    required this.accuracy,
  });

  factory SalesForecastModel.fromJson(Map<String, dynamic> json) {
    // Parse historical data
    final List<TimeSeriesPoint> historicalData = [];
    if (json['historicalData'] != null) {
      for (final item in json['historicalData']) {
        historicalData.add(TimeSeriesPoint.fromJson(item));
      }
    }

    // Parse forecast data
    final List<TimeSeriesPoint> forecastData = [];
    if (json['forecastData'] != null) {
      for (final item in json['forecastData']) {
        forecastData.add(TimeSeriesPoint.fromJson(item));
      }
    }

    return SalesForecastModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      productId: json['productId'],
      createdDate: (json['createdDate'] is Timestamp)
          ? (json['createdDate'] as Timestamp).toDate()
          : DateTime.parse(json['createdDate'].toString()),
      methodName: json['methodName'],
      historicalData: historicalData,
      forecastData: forecastData,
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      accuracy: Map<String, double>.from(json['accuracy'] ?? {}),
    );
  }

  final String? id;
  final String name;
  final String? description;
  final String productId;
  final DateTime createdDate;
  final String methodName;
  final List<TimeSeriesPoint> historicalData;
  final List<TimeSeriesPoint> forecastData;
  final Map<String, dynamic> parameters;
  final Map<String, double> accuracy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'productId': productId,
      'createdDate': Timestamp.fromDate(createdDate),
      'methodName': methodName,
      'historicalData': historicalData.map((point) => point.toJson()).toList(),
      'forecastData': forecastData.map((point) => point.toJson()).toList(),
      'parameters': parameters,
      'accuracy': accuracy,
    };
  }

  /// Creates a copy of this model with the given fields replaced with new values
  SalesForecastModel copyWith({
    String? id,
    String? name,
    String? description,
    String? productId,
    DateTime? createdDate,
    String? methodName,
    List<TimeSeriesPoint>? historicalData,
    List<TimeSeriesPoint>? forecastData,
    Map<String, dynamic>? parameters,
    Map<String, double>? accuracy,
  }) {
    return SalesForecastModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productId: productId ?? this.productId,
      createdDate: createdDate ?? this.createdDate,
      methodName: methodName ?? this.methodName,
      historicalData: historicalData ?? this.historicalData,
      forecastData: forecastData ?? this.forecastData,
      parameters: parameters ?? this.parameters,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}
