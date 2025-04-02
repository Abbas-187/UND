import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Model representing an optimization result for inventory levels
class OptimizationResultModel {
  /// Optimal inventory level
  final double optimalLevel;

  /// Minimum inventory level
  final double minLevel;

  /// Maximum inventory level
  final double maxLevel;

  /// Reorder point
  final double reorderPoint;

  /// Order quantity
  final double orderQuantity;

  /// Safety stock
  final double safetyStock;

  /// Expected service level
  final double serviceLevel;

  /// Expected turnover rate
  final double turnoverRate;

  /// Expected holding cost
  final double holdingCost;

  /// Expected stockout cost
  final double stockoutCost;

  /// Expected total cost
  final double totalCost;

  /// Calculation parameters used
  final Map<String, dynamic>? parameters;

  const OptimizationResultModel({
    required this.optimalLevel,
    required this.minLevel,
    required this.maxLevel,
    required this.reorderPoint,
    required this.orderQuantity,
    required this.safetyStock,
    required this.serviceLevel,
    required this.turnoverRate,
    required this.holdingCost,
    required this.stockoutCost,
    required this.totalCost,
    this.parameters,
  });

  /// Create an instance from JSON
  factory OptimizationResultModel.fromJson(Map<String, dynamic> json) {
    return OptimizationResultModel(
      optimalLevel: json['optimalLevel'] as double,
      minLevel: json['minLevel'] as double,
      maxLevel: json['maxLevel'] as double,
      reorderPoint: json['reorderPoint'] as double,
      orderQuantity: json['orderQuantity'] as double,
      safetyStock: json['safetyStock'] as double,
      serviceLevel: json['serviceLevel'] as double,
      turnoverRate: json['turnoverRate'] as double,
      holdingCost: json['holdingCost'] as double,
      stockoutCost: json['stockoutCost'] as double,
      totalCost: json['totalCost'] as double,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  /// Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'optimalLevel': optimalLevel,
      'minLevel': minLevel,
      'maxLevel': maxLevel,
      'reorderPoint': reorderPoint,
      'orderQuantity': orderQuantity,
      'safetyStock': safetyStock,
      'serviceLevel': serviceLevel,
      'turnoverRate': turnoverRate,
      'holdingCost': holdingCost,
      'stockoutCost': stockoutCost,
      'totalCost': totalCost,
      'parameters': parameters,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OptimizationResultModel &&
        other.optimalLevel == optimalLevel &&
        other.minLevel == minLevel &&
        other.maxLevel == maxLevel &&
        other.reorderPoint == reorderPoint &&
        other.orderQuantity == orderQuantity &&
        other.safetyStock == safetyStock &&
        other.serviceLevel == serviceLevel &&
        other.turnoverRate == turnoverRate &&
        other.holdingCost == holdingCost &&
        other.stockoutCost == stockoutCost &&
        other.totalCost == totalCost &&
        mapEquals(other.parameters, parameters);
  }

  @override
  int get hashCode {
    return optimalLevel.hashCode ^
        minLevel.hashCode ^
        maxLevel.hashCode ^
        reorderPoint.hashCode ^
        orderQuantity.hashCode ^
        safetyStock.hashCode ^
        serviceLevel.hashCode ^
        turnoverRate.hashCode ^
        holdingCost.hashCode ^
        stockoutCost.hashCode ^
        totalCost.hashCode ^
        parameters.hashCode;
  }

  /// Create a copy with modified values
  OptimizationResultModel copyWith({
    double? optimalLevel,
    double? minLevel,
    double? maxLevel,
    double? reorderPoint,
    double? orderQuantity,
    double? safetyStock,
    double? serviceLevel,
    double? turnoverRate,
    double? holdingCost,
    double? stockoutCost,
    double? totalCost,
    Map<String, dynamic>? parameters,
  }) {
    return OptimizationResultModel(
      optimalLevel: optimalLevel ?? this.optimalLevel,
      minLevel: minLevel ?? this.minLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      orderQuantity: orderQuantity ?? this.orderQuantity,
      safetyStock: safetyStock ?? this.safetyStock,
      serviceLevel: serviceLevel ?? this.serviceLevel,
      turnoverRate: turnoverRate ?? this.turnoverRate,
      holdingCost: holdingCost ?? this.holdingCost,
      stockoutCost: stockoutCost ?? this.stockoutCost,
      totalCost: totalCost ?? this.totalCost,
      parameters: parameters ?? this.parameters,
    );
  }
}
