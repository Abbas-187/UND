class InventoryItem {

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
    );
  }
}
