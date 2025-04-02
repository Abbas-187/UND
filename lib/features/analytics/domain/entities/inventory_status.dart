import 'package:flutter/foundation.dart';

class InventoryStatus {
  final String category;
  final int totalItems;
  final int lowStockItems;
  final int outOfStockItems;
  final double inventoryValue;

  const InventoryStatus({
    required this.category,
    required this.totalItems,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.inventoryValue,
  });

  InventoryStatus copyWith({
    String? category,
    int? totalItems,
    int? lowStockItems,
    int? outOfStockItems,
    double? inventoryValue,
  }) {
    return InventoryStatus(
      category: category ?? this.category,
      totalItems: totalItems ?? this.totalItems,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      outOfStockItems: outOfStockItems ?? this.outOfStockItems,
      inventoryValue: inventoryValue ?? this.inventoryValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'totalItems': totalItems,
        'lowStockItems': lowStockItems,
        'outOfStockItems': outOfStockItems,
        'inventoryValue': inventoryValue,
      };

  factory InventoryStatus.fromJson(Map<String, dynamic> json) =>
      InventoryStatus(
        category: json['category'] as String,
        totalItems: json['totalItems'] as int,
        lowStockItems: json['lowStockItems'] as int,
        outOfStockItems: json['outOfStockItems'] as int,
        inventoryValue: json['inventoryValue'] as double,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryStatus &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          totalItems == other.totalItems &&
          lowStockItems == other.lowStockItems &&
          outOfStockItems == other.outOfStockItems &&
          inventoryValue == other.inventoryValue;

  @override
  int get hashCode =>
      category.hashCode ^
      totalItems.hashCode ^
      lowStockItems.hashCode ^
      outOfStockItems.hashCode ^
      inventoryValue.hashCode;
}

class InventoryTrend {
  final DateTime date;
  final double totalValue;
  final int totalItems;

  const InventoryTrend({
    required this.date,
    required this.totalValue,
    required this.totalItems,
  });

  InventoryTrend copyWith({
    DateTime? date,
    double? totalValue,
    int? totalItems,
  }) {
    return InventoryTrend(
      date: date ?? this.date,
      totalValue: totalValue ?? this.totalValue,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'totalValue': totalValue,
        'totalItems': totalItems,
      };

  factory InventoryTrend.fromJson(Map<String, dynamic> json) => InventoryTrend(
        date: DateTime.parse(json['date'] as String),
        totalValue: json['totalValue'] as double,
        totalItems: json['totalItems'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryTrend &&
          runtimeType == other.runtimeType &&
          date.isAtSameMomentAs(other.date) &&
          totalValue == other.totalValue &&
          totalItems == other.totalItems;

  @override
  int get hashCode => date.hashCode ^ totalValue.hashCode ^ totalItems.hashCode;
}

class CategoryDistribution {
  final String category;
  final int itemCount;
  final double percentage;

  const CategoryDistribution({
    required this.category,
    required this.itemCount,
    required this.percentage,
  });

  CategoryDistribution copyWith({
    String? category,
    int? itemCount,
    double? percentage,
  }) {
    return CategoryDistribution(
      category: category ?? this.category,
      itemCount: itemCount ?? this.itemCount,
      percentage: percentage ?? this.percentage,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'itemCount': itemCount,
        'percentage': percentage,
      };

  factory CategoryDistribution.fromJson(Map<String, dynamic> json) =>
      CategoryDistribution(
        category: json['category'] as String,
        itemCount: json['itemCount'] as int,
        percentage: json['percentage'] as double,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDistribution &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          itemCount == other.itemCount &&
          percentage == other.percentage;

  @override
  int get hashCode =>
      category.hashCode ^ itemCount.hashCode ^ percentage.hashCode;
}
