import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for storing inventory optimization results
class OptimizationResultModel {
  OptimizationResultModel({
    required this.productId,
    required this.safetyStockLevel,
    required this.reorderPoint,
    required this.economicOrderQuantity,
    required this.leadTimeAverage,
    required this.leadTimeVariance,
    required this.demandAverage,
    required this.demandVariance,
    required this.serviceLevel,
    required this.stockoutProbability,
    required this.holdingCost,
    required this.orderingCost,
  });

  factory OptimizationResultModel.fromJson(Map<String, dynamic> json) {
    return OptimizationResultModel(
      productId: json['productId'],
      safetyStockLevel: json['safetyStockLevel'].toDouble(),
      reorderPoint: json['reorderPoint'].toDouble(),
      economicOrderQuantity: json['economicOrderQuantity'].toDouble(),
      leadTimeAverage: json['leadTimeAverage'].toDouble(),
      leadTimeVariance: json['leadTimeVariance'].toDouble(),
      demandAverage: json['demandAverage'].toDouble(),
      demandVariance: json['demandVariance'].toDouble(),
      serviceLevel: json['serviceLevel'].toDouble(),
      stockoutProbability: json['stockoutProbability'].toDouble(),
      holdingCost: json['holdingCost'].toDouble(),
      orderingCost: json['orderingCost'].toDouble(),
    );
  }

  final String productId;
  final double safetyStockLevel;
  final double reorderPoint;
  final double economicOrderQuantity;
  final double leadTimeAverage;
  final double leadTimeVariance;
  final double demandAverage;
  final double demandVariance;
  final double serviceLevel;
  final double stockoutProbability;
  final double holdingCost;
  final double orderingCost;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'safetyStockLevel': safetyStockLevel,
      'reorderPoint': reorderPoint,
      'economicOrderQuantity': economicOrderQuantity,
      'leadTimeAverage': leadTimeAverage,
      'leadTimeVariance': leadTimeVariance,
      'demandAverage': demandAverage,
      'demandVariance': demandVariance,
      'serviceLevel': serviceLevel,
      'stockoutProbability': stockoutProbability,
      'holdingCost': holdingCost,
      'orderingCost': orderingCost,
    };
  }
}

/// Model for inventory optimization records stored in Firestore
class InventoryOptimizationModel {
  InventoryOptimizationModel({
    this.id,
    required this.name,
    this.description,
    required this.createdDate,
    required this.createdByUserId,
    required this.productIds,
    required this.warehouseId,
    required this.parameters,
    required this.results,
  });

  factory InventoryOptimizationModel.fromJson(Map<String, dynamic> json) {
    // Parse the results map
    final Map<String, OptimizationResultModel> resultMap = {};

    if (json['results'] != null) {
      (json['results'] as Map<String, dynamic>).forEach((key, value) {
        resultMap[key] = OptimizationResultModel.fromJson(value);
      });
    }

    return InventoryOptimizationModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdDate: (json['createdDate'] is Timestamp)
          ? (json['createdDate'] as Timestamp).toDate()
          : DateTime.parse(json['createdDate'].toString()),
      createdByUserId: json['createdByUserId'],
      productIds: List<String>.from(json['productIds']),
      warehouseId: json['warehouseId'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      results: resultMap,
    );
  }

  final String? id;
  final String name;
  final String? description;
  final DateTime createdDate;
  final String createdByUserId;
  final List<String> productIds;
  final String warehouseId;
  final Map<String, dynamic> parameters;
  final Map<String, OptimizationResultModel> results;

  Map<String, dynamic> toJson() {
    // Convert the results map to JSON
    final Map<String, dynamic> resultsJson = {};
    results.forEach((key, value) {
      resultsJson[key] = value.toJson();
    });

    return {
      'id': id,
      'name': name,
      'description': description,
      'createdDate': Timestamp.fromDate(createdDate),
      'createdByUserId': createdByUserId,
      'productIds': productIds,
      'warehouseId': warehouseId,
      'parameters': parameters,
      'results': resultsJson,
    };
  }

  /// Creates a copy of this model with the given fields replaced with new values
  InventoryOptimizationModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdDate,
    String? createdByUserId,
    List<String>? productIds,
    String? warehouseId,
    Map<String, dynamic>? parameters,
    Map<String, OptimizationResultModel>? results,
  }) {
    return InventoryOptimizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      productIds: productIds ?? this.productIds,
      warehouseId: warehouseId ?? this.warehouseId,
      parameters: parameters ?? this.parameters,
      results: results ?? this.results,
    );
  }
}
