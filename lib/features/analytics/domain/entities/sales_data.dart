import 'package:flutter/foundation.dart';

class SalesData {
  final String id;
  final DateTime date;
  final double amount;
  final String productId;
  final String productName;
  final String category;
  final int? quantity;

  const SalesData({
    required this.id,
    required this.date,
    required this.amount,
    required this.productId,
    required this.productName,
    required this.category,
    this.quantity,
  });

  SalesData copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? productId,
    String? productName,
    String? category,
    int? quantity,
  }) {
    return SalesData(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'productId': productId,
        'productName': productName,
        'category': category,
        'quantity': quantity,
      };

  factory SalesData.fromJson(Map<String, dynamic> json) => SalesData(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: json['amount'] as double,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        category: json['category'] as String,
        quantity: json['quantity'] as int?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date.isAtSameMomentAs(other.date) &&
          amount == other.amount &&
          productId == other.productId &&
          productName == other.productName &&
          category == other.category &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      id.hashCode ^
      date.hashCode ^
      amount.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      category.hashCode ^
      quantity.hashCode;
}

class MonthlySalesData {
  final DateTime month;
  final double totalSales;
  final int orderCount;

  const MonthlySalesData({
    required this.month,
    required this.totalSales,
    required this.orderCount,
  });

  MonthlySalesData copyWith({
    DateTime? month,
    double? totalSales,
    int? orderCount,
  }) {
    return MonthlySalesData(
      month: month ?? this.month,
      totalSales: totalSales ?? this.totalSales,
      orderCount: orderCount ?? this.orderCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month.toIso8601String(),
        'totalSales': totalSales,
        'orderCount': orderCount,
      };

  factory MonthlySalesData.fromJson(Map<String, dynamic> json) =>
      MonthlySalesData(
        month: DateTime.parse(json['month'] as String),
        totalSales: json['totalSales'] as double,
        orderCount: json['orderCount'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySalesData &&
          runtimeType == other.runtimeType &&
          month.isAtSameMomentAs(other.month) &&
          totalSales == other.totalSales &&
          orderCount == other.orderCount;

  @override
  int get hashCode =>
      month.hashCode ^ totalSales.hashCode ^ orderCount.hashCode;
}

class CategorySalesData {
  final String category;
  final double totalSales;
  final double percentage;

  const CategorySalesData({
    required this.category,
    required this.totalSales,
    required this.percentage,
  });

  CategorySalesData copyWith({
    String? category,
    double? totalSales,
    double? percentage,
  }) {
    return CategorySalesData(
      category: category ?? this.category,
      totalSales: totalSales ?? this.totalSales,
      percentage: percentage ?? this.percentage,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'totalSales': totalSales,
        'percentage': percentage,
      };

  factory CategorySalesData.fromJson(Map<String, dynamic> json) =>
      CategorySalesData(
        category: json['category'] as String,
        totalSales: json['totalSales'] as double,
        percentage: json['percentage'] as double,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorySalesData &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          totalSales == other.totalSales &&
          percentage == other.percentage;

  @override
  int get hashCode =>
      category.hashCode ^ totalSales.hashCode ^ percentage.hashCode;
}

class TopProductData {
  final String productId;
  final String productName;
  final double totalSales;
  final int quantity;
  final String category;

  const TopProductData({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.quantity,
    required this.category,
  });

  TopProductData copyWith({
    String? productId,
    String? productName,
    double? totalSales,
    int? quantity,
    String? category,
  }) {
    return TopProductData(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      totalSales: totalSales ?? this.totalSales,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'totalSales': totalSales,
        'quantity': quantity,
        'category': category,
      };

  factory TopProductData.fromJson(Map<String, dynamic> json) => TopProductData(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        totalSales: json['totalSales'] as double,
        quantity: json['quantity'] as int,
        category: json['category'] as String,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopProductData &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          productName == other.productName &&
          totalSales == other.totalSales &&
          quantity == other.quantity &&
          category == other.category;

  @override
  int get hashCode =>
      productId.hashCode ^
      productName.hashCode ^
      totalSales.hashCode ^
      quantity.hashCode ^
      category.hashCode;
}
