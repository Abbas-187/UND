class SalesAnalyticsModel {

  SalesAnalyticsModel({
    required this.periodStart,
    required this.periodEnd,
    required this.totalSales,
    required this.orderCount,
    required this.salesByCategory,
    required this.salesByProduct,
    required this.salesByCustomer,
    required this.dailySales,
    this.averageOrderValue,
    this.previousPeriodSales,
    this.salesGrowth,
    this.categoryGrowth,
    this.productUnitsSold,
    this.customerGrowth,
    this.newCustomerCount,
    this.newCustomerSales,
  });

  factory SalesAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SalesAnalyticsModel(
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      orderCount: json['orderCount'] as int,
      salesByCategory:
          _parseDoubleMap(json['salesByCategory'] as Map<String, dynamic>),
      salesByProduct:
          _parseDoubleMap(json['salesByProduct'] as Map<String, dynamic>),
      salesByCustomer:
          _parseDoubleMap(json['salesByCustomer'] as Map<String, dynamic>),
      dailySales: (json['dailySales'] as List<dynamic>)
          .map((e) => DailySalesData.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageOrderValue: json['averageOrderValue'] != null
          ? (json['averageOrderValue'] as num).toDouble()
          : null,
      previousPeriodSales: json['previousPeriodSales'] != null
          ? (json['previousPeriodSales'] as num).toDouble()
          : null,
      salesGrowth: json['salesGrowth'] != null
          ? (json['salesGrowth'] as num).toDouble()
          : null,
      categoryGrowth: json['categoryGrowth'] != null
          ? _parseDoubleMap(json['categoryGrowth'] as Map<String, dynamic>)
          : null,
      productUnitsSold: json['productUnitsSold'] != null
          ? _parseIntMap(json['productUnitsSold'] as Map<String, dynamic>)
          : null,
      customerGrowth: json['customerGrowth'] != null
          ? _parseDoubleMap(json['customerGrowth'] as Map<String, dynamic>)
          : null,
      newCustomerCount: json['newCustomerCount'] as int?,
      newCustomerSales: json['newCustomerSales'] != null
          ? (json['newCustomerSales'] as num).toDouble()
          : null,
    );
  }
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalSales;
  final int orderCount;
  final Map<String, double> salesByCategory;
  final Map<String, double> salesByProduct;
  final Map<String, double> salesByCustomer;
  final List<DailySalesData> dailySales;
  final double? averageOrderValue;
  final double? previousPeriodSales;
  final double? salesGrowth;
  final Map<String, double>? categoryGrowth;
  final Map<String, int>? productUnitsSold;
  final Map<String, double>? customerGrowth;
  final int? newCustomerCount;
  final double? newCustomerSales;

  static Map<String, double> _parseDoubleMap(Map<String, dynamic> json) {
    return json.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  static Map<String, int> _parseIntMap(Map<String, dynamic> json) {
    return json.map((key, value) => MapEntry(key, value as int));
  }

  Map<String, dynamic> toJson() {
    return {
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'totalSales': totalSales,
      'orderCount': orderCount,
      'salesByCategory': salesByCategory,
      'salesByProduct': salesByProduct,
      'salesByCustomer': salesByCustomer,
      'dailySales': dailySales.map((e) => e.toJson()).toList(),
      if (averageOrderValue != null) 'averageOrderValue': averageOrderValue,
      if (previousPeriodSales != null)
        'previousPeriodSales': previousPeriodSales,
      if (salesGrowth != null) 'salesGrowth': salesGrowth,
      if (categoryGrowth != null) 'categoryGrowth': categoryGrowth,
      if (productUnitsSold != null) 'productUnitsSold': productUnitsSold,
      if (customerGrowth != null) 'customerGrowth': customerGrowth,
      if (newCustomerCount != null) 'newCustomerCount': newCustomerCount,
      if (newCustomerSales != null) 'newCustomerSales': newCustomerSales,
    };
  }
}

class DailySalesData {

  DailySalesData({
    required this.date,
    required this.sales,
    required this.orderCount,
    this.averageOrderValue,
  });

  factory DailySalesData.fromJson(Map<String, dynamic> json) {
    return DailySalesData(
      date: DateTime.parse(json['date'] as String),
      sales: (json['sales'] as num).toDouble(),
      orderCount: json['orderCount'] as int,
      averageOrderValue: json['averageOrderValue'] != null
          ? (json['averageOrderValue'] as num).toDouble()
          : null,
    );
  }
  final DateTime date;
  final double sales;
  final int orderCount;
  final double? averageOrderValue;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sales': sales,
      'orderCount': orderCount,
      if (averageOrderValue != null) 'averageOrderValue': averageOrderValue,
    };
  }
}

// Extension methods for additional functionality
extension SalesAnalyticsModelX on SalesAnalyticsModel {
  List<MapEntry<String, double>> getTopSellingProducts(int limit) {
    final sorted = salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  List<MapEntry<String, double>> getTopCustomers(int limit) {
    final sorted = salesByCustomer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  double calculateGrowthPercent() {
    if (previousPeriodSales == null || previousPeriodSales == 0) return 0;
    return ((totalSales - previousPeriodSales!) / previousPeriodSales!) * 100;
  }

  String? getBestPerformingCategory() {
    if (salesByCategory.isEmpty) return null;
    return salesByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String? getFastestGrowingCategory() {
    if (categoryGrowth == null || categoryGrowth!.isEmpty) return null;
    return categoryGrowth!.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
