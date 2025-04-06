class ProductCatalogModel {

  ProductCatalogModel({
    this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.description,
    required this.uom,
    required this.basePrice,
    this.imageUrl,
    this.packagingType,
    this.weightPerUnit,
    this.weightUom,
    this.allergens,
    this.isActive = true,
    this.minOrderQuantity,
    this.multipleOrderQuantity,
    this.availableFrom,
    this.availableTo,
    this.priceTiers,
    this.customerSpecificPrices,
    this.shelfLifeDays,
    this.storageInstructions,
    this.tags,
    this.isSeasonal = false,
    this.reorderPoint,
    this.targetStockLevel,
    this.nutritionalInfo,
    this.ingredients,
    this.searchTerms = const [],
  });

  factory ProductCatalogModel.fromJson(Map<String, dynamic> json) {
    return ProductCatalogModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      code: json['code'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      uom: json['uom'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      packagingType: json['packagingType'] as String?,
      weightPerUnit: json['weightPerUnit'] != null
          ? (json['weightPerUnit'] as num).toDouble()
          : null,
      weightUom: json['weightUom'] as String?,
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'] as List)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      minOrderQuantity: json['minOrderQuantity'] as int?,
      multipleOrderQuantity: json['multipleOrderQuantity'] as int?,
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'] as String)
          : null,
      availableTo: json['availableTo'] != null
          ? DateTime.parse(json['availableTo'] as String)
          : null,
      priceTiers: json['priceTiers'] != null
          ? Map<String, double>.from(
              (json['priceTiers'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              ),
            )
          : null,
      customerSpecificPrices: json['customerSpecificPrices'] != null
          ? Map<String, double>.from(
              (json['customerSpecificPrices'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              ),
            )
          : null,
      shelfLifeDays: json['shelfLifeDays'] as int?,
      storageInstructions: json['storageInstructions'] as String?,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      isSeasonal: json['isSeasonal'] as bool? ?? false,
      reorderPoint: json['reorderPoint'] != null
          ? (json['reorderPoint'] as num).toDouble()
          : null,
      targetStockLevel: json['targetStockLevel'] != null
          ? (json['targetStockLevel'] as num).toDouble()
          : null,
      nutritionalInfo: json['nutritionalInfo'] as String?,
      ingredients: json['ingredients'] as String?,
      searchTerms: json['searchTerms'] != null
          ? List<String>.from(json['searchTerms'] as List)
          : const [],
    );
  }
  final String? id;
  final String name;
  final String code;
  final String category;
  final String description;
  final String uom; // Unit of Measure
  final double basePrice;
  final String? imageUrl;
  final String? packagingType;
  final double? weightPerUnit;
  final String? weightUom;
  final List<String>? allergens;
  final bool isActive;
  final int? minOrderQuantity;
  final int? multipleOrderQuantity;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final Map<String, double>? priceTiers;
  final Map<String, double>? customerSpecificPrices;
  final int? shelfLifeDays;
  final String? storageInstructions;
  final List<String>? tags;
  final bool isSeasonal;
  final double? reorderPoint;
  final double? targetStockLevel;
  final String? nutritionalInfo;
  final String? ingredients;
  final List<String> searchTerms;

  ProductCatalogModel copyWith({
    String? id,
    String? name,
    String? code,
    String? category,
    String? description,
    String? uom,
    double? basePrice,
    String? imageUrl,
    String? packagingType,
    double? weightPerUnit,
    String? weightUom,
    List<String>? allergens,
    bool? isActive,
    int? minOrderQuantity,
    int? multipleOrderQuantity,
    DateTime? availableFrom,
    DateTime? availableTo,
    Map<String, double>? priceTiers,
    Map<String, double>? customerSpecificPrices,
    int? shelfLifeDays,
    String? storageInstructions,
    List<String>? tags,
    bool? isSeasonal,
    double? reorderPoint,
    double? targetStockLevel,
    String? nutritionalInfo,
    String? ingredients,
    List<String>? searchTerms,
  }) {
    return ProductCatalogModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      description: description ?? this.description,
      uom: uom ?? this.uom,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      packagingType: packagingType ?? this.packagingType,
      weightPerUnit: weightPerUnit ?? this.weightPerUnit,
      weightUom: weightUom ?? this.weightUom,
      allergens: allergens ?? this.allergens,
      isActive: isActive ?? this.isActive,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      multipleOrderQuantity:
          multipleOrderQuantity ?? this.multipleOrderQuantity,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      priceTiers: priceTiers ?? this.priceTiers,
      customerSpecificPrices:
          customerSpecificPrices ?? this.customerSpecificPrices,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      tags: tags ?? this.tags,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      targetStockLevel: targetStockLevel ?? this.targetStockLevel,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      ingredients: ingredients ?? this.ingredients,
      searchTerms: searchTerms ?? this.searchTerms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'category': category,
      'description': description,
      'uom': uom,
      'basePrice': basePrice,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (packagingType != null) 'packagingType': packagingType,
      if (weightPerUnit != null) 'weightPerUnit': weightPerUnit,
      if (weightUom != null) 'weightUom': weightUom,
      if (allergens != null) 'allergens': allergens,
      'isActive': isActive,
      if (minOrderQuantity != null) 'minOrderQuantity': minOrderQuantity,
      if (multipleOrderQuantity != null)
        'multipleOrderQuantity': multipleOrderQuantity,
      if (availableFrom != null)
        'availableFrom': availableFrom!.toIso8601String(),
      if (availableTo != null) 'availableTo': availableTo!.toIso8601String(),
      if (priceTiers != null) 'priceTiers': priceTiers,
      if (customerSpecificPrices != null)
        'customerSpecificPrices': customerSpecificPrices,
      if (shelfLifeDays != null) 'shelfLifeDays': shelfLifeDays,
      if (storageInstructions != null)
        'storageInstructions': storageInstructions,
      if (tags != null) 'tags': tags,
      'isSeasonal': isSeasonal,
      if (reorderPoint != null) 'reorderPoint': reorderPoint,
      if (targetStockLevel != null) 'targetStockLevel': targetStockLevel,
      if (nutritionalInfo != null) 'nutritionalInfo': nutritionalInfo,
      if (ingredients != null) 'ingredients': ingredients,
      'searchTerms': searchTerms,
    };
  }
}

// Custom methods can be implemented as extension methods
extension ProductCatalogModelX on ProductCatalogModel {
  double getPriceForCustomer(String customerId, double quantity) {
    // Check if there's a customer-specific price
    if (customerSpecificPrices != null &&
        customerSpecificPrices!.containsKey(customerId)) {
      return customerSpecificPrices![customerId]!;
    }

    // Check if there's a tier price based on quantity
    if (priceTiers != null && priceTiers!.isNotEmpty) {
      final sortedTiers = priceTiers!.entries.toList()
        ..sort((a, b) => double.parse(a.key).compareTo(double.parse(b.key)));

      for (final tier in sortedTiers.reversed) {
        if (quantity >= double.parse(tier.key)) {
          return tier.value;
        }
      }
    }

    // Return base price if no specific pricing applies
    return basePrice;
  }

  bool isAvailableOnDate(DateTime date) {
    if (!isActive) return false;

    if (availableFrom != null && date.isBefore(availableFrom!)) {
      return false;
    }

    if (availableTo != null && date.isAfter(availableTo!)) {
      return false;
    }

    return true;
  }

  DateTime calculateExpiryDate(DateTime productionDate) {
    if (shelfLifeDays == null) return productionDate;
    return productionDate.add(Duration(days: shelfLifeDays!));
  }
}
