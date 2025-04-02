import 'package:cloud_firestore/cloud_firestore.dart';

class ForecastItemModel {
  const ForecastItemModel({
    required this.date,
    required this.forecastedQuantity,
    this.lowerBound,
    this.upperBound,
    this.actualQuantity,
    this.errorPercentage,
  });

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    return ForecastItemModel(
      date: (json['date'] as Timestamp).toDate(),
      forecastedQuantity: json['forecastedQuantity'],
      lowerBound: json['lowerBound'],
      upperBound: json['upperBound'],
      actualQuantity: json['actualQuantity'],
      errorPercentage: json['errorPercentage'],
    );
  }
  final DateTime date;
  final double forecastedQuantity;
  final double? lowerBound; // Lower confidence interval
  final double? upperBound; // Upper confidence interval
  final double? actualQuantity;
  final double? errorPercentage;

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'forecastedQuantity': forecastedQuantity,
      'lowerBound': lowerBound,
      'upperBound': upperBound,
      'actualQuantity': actualQuantity,
      'errorPercentage': errorPercentage,
    };
  }
}
