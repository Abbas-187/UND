import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class for forecasts
class ForecastModel {

  const ForecastModel({
    this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.createdByUserId,
    required this.productIds,
    this.categoryId,
    this.warehouseId,
    required this.startDate,
    required this.endDate,
    required this.forecastMethod,
    required this.methodParameters,
    required this.forecastItems,
    this.accuracyMetric,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      createdDate: (json['createdDate'] as Timestamp).toDate(),
      createdByUserId: json['createdByUserId'] as String,
      productIds: (json['productIds'] as List<dynamic>).cast<String>(),
      categoryId: json['categoryId'] as String?,
      warehouseId: json['warehouseId'] as String?,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      forecastMethod: json['forecastMethod'] as String,
      methodParameters: json['methodParameters'] as Map<String, dynamic>,
      forecastItems: (json['forecastItems'] as List<dynamic>)
          .map((e) => ForecastItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      accuracyMetric: (json['accuracyMetric'] as num?)?.toDouble(),
    );
  }
  final String? id;
  final String name;
  final String description;
  final DateTime createdDate;
  final String createdByUserId;
  final List<String> productIds;
  final String? categoryId;
  final String? warehouseId;
  final DateTime startDate;
  final DateTime endDate;
  final String forecastMethod;
  final Map<String, dynamic> methodParameters;
  final List<ForecastItemModel> forecastItems;
  final double? accuracyMetric;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdDate': Timestamp.fromDate(createdDate),
      'createdByUserId': createdByUserId,
      'productIds': productIds,
      'categoryId': categoryId,
      'warehouseId': warehouseId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'forecastMethod': forecastMethod,
      'methodParameters': methodParameters,
      'forecastItems': forecastItems.map((e) => e.toJson()).toList(),
      'accuracyMetric': accuracyMetric,
    };
  }
}

/// Model class for forecast items
class ForecastItemModel {

  const ForecastItemModel({
    required this.productId,
    required this.date,
    required this.forecastedValue,
    this.actualValue,
    this.deviation,
  });

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    return ForecastItemModel(
      productId: json['productId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      forecastedValue: (json['forecastedValue'] as num).toDouble(),
      actualValue: (json['actualValue'] as num?)?.toDouble(),
      deviation: (json['deviation'] as num?)?.toDouble(),
    );
  }
  final String productId;
  final DateTime date;
  final double forecastedValue;
  final double? actualValue;
  final double? deviation;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'date': Timestamp.fromDate(date),
      'forecastedValue': forecastedValue,
      'actualValue': actualValue,
      'deviation': deviation,
    };
  }
}
