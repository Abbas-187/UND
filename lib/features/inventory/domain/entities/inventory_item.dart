class InventoryItem {

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
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
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      minimumQuantity: (json['minimumQuantity'] as num).toDouble(),
      reorderPoint: (json['reorderPoint'] as num).toDouble(),
      location: json['location'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      additionalAttributes:
          json['additionalAttributes'] as Map<String, dynamic>?,
      cost: (json['cost'] as num?)?.toDouble(),
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
    );
  }
  final String id;
  final String name;
  final String category;
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

  bool get needsReorder => quantity <= reorderPoint;
  bool get isLowStock => quantity <= minimumQuantity;
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
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
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
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
    };
  }
}
