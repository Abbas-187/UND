class InventoryItem {
  // Manual serialization
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      appItemId: json['appItemId'] as String? ?? '',
      sapCode: json['sapCode'] as String? ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String? ?? '',
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      minimumQuantity: (json['minimumQuantity'] as num).toDouble(),
      reorderPoint: (json['reorderPoint'] as num).toDouble(),
      location: json['location'] as String,
      lastUpdated: json['lastUpdated'] is String
          ? DateTime.parse(json['lastUpdated'])
          : (json['lastUpdated'] ?? DateTime.now()),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? (json['expiryDate'] is String
              ? DateTime.parse(json['expiryDate'])
              : json['expiryDate'] as DateTime)
          : null,
      additionalAttributes: json['additionalAttributes'] != null
          ? Map<String, dynamic>.from(json['additionalAttributes'])
          : null,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
      supplier: json['supplier'] as String?,
      safetyStock: json['safetyStock'] != null
          ? (json['safetyStock'] as num).toDouble()
          : null,
      currentConsumption: json['currentConsumption'] != null
          ? (json['currentConsumption'] as num).toDouble()
          : null,
    );
  }
  const InventoryItem({
    required this.id,
    required this.appItemId,
    this.sapCode = '',
    required this.name,
    required this.category,
    this.subCategory = '',
    required this.unit,
    required this.quantity,
    required this.minimumQuantity,
    required this.reorderPoint,
    required this.location,
    required this.lastUpdated,
    this.batchNumber,
    this.expiryDate,
    this.additionalAttributes,
    this.cost,
    this.lowStockThreshold = 5,
    this.supplier,
    this.safetyStock,
    this.currentConsumption,
  });
  final String id;
  final String appItemId;
  final String sapCode;
  final String name;
  final String category;
  final String subCategory;
  final String unit;
  final double quantity;
  final double minimumQuantity;
  final double reorderPoint;
  final String location;
  final DateTime lastUpdated;
  final String? batchNumber;
  final DateTime? expiryDate;
  final Map<String, dynamic>? additionalAttributes;
  final double? cost;
  final int lowStockThreshold;
  final String? supplier;
  final double? safetyStock;
  final double? currentConsumption;

  // Computed properties for stock alerts
  bool get isLowStock => quantity <= minimumQuantity;
  bool get needsReorder => quantity <= reorderPoint;
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  InventoryItem copyWith({
    String? id,
    String? appItemId,
    String? sapCode,
    String? name,
    String? category,
    String? subCategory,
    String? unit,
    double? quantity,
    double? minimumQuantity,
    double? reorderPoint,
    String? location,
    DateTime? lastUpdated,
    String? batchNumber,
    DateTime? expiryDate,
    Map<String, dynamic>? additionalAttributes,
    double? cost,
    int? lowStockThreshold,
    String? supplier,
    double? safetyStock,
    double? currentConsumption,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      appItemId: appItemId ?? this.appItemId,
      sapCode: sapCode ?? this.sapCode,
      name: name ?? this.name,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      additionalAttributes: additionalAttributes ?? this.additionalAttributes,
      cost: cost ?? this.cost,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      supplier: supplier ?? this.supplier,
      safetyStock: safetyStock ?? this.safetyStock,
      currentConsumption: currentConsumption ?? this.currentConsumption,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appItemId': appItemId,
      'sapCode': sapCode,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'reorderPoint': reorderPoint,
      'location': location,
      'lastUpdated': lastUpdated.toIso8601String(),
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'additionalAttributes': additionalAttributes,
      'cost': cost,
      'lowStockThreshold': lowStockThreshold,
      'supplier': supplier,
      'safetyStock': safetyStock,
      'currentConsumption': currentConsumption,
    };
  }
}
