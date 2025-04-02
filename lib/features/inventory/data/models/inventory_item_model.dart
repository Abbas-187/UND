import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryItemModel {
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
  final List<String> searchTerms;
  final double? cost;
  final int lowStockThreshold;

  InventoryItemModel({
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
    List<String>? searchTerms,
    this.cost,
    this.lowStockThreshold = 5,
  }) : searchTerms = searchTerms ?? _generateSearchTerms(name, category);

  // Convert from Firestore document
  factory InventoryItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return InventoryItemModel(
      id: doc.id,
      name: data['name'] as String,
      category: data['category'] as String,
      unit: data['unit'] as String,
      quantity: (data['quantity'] as num).toDouble(),
      minimumQuantity: (data['minimumQuantity'] as num).toDouble(),
      reorderPoint: (data['reorderPoint'] as num).toDouble(),
      location: data['location'] as String,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      batchNumber: data['batchNumber'] as String?,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      additionalAttributes:
          data['additionalAttributes'] as Map<String, dynamic>?,
      searchTerms: List<String>.from(data['searchTerms'] as List? ?? []),
      cost: (data['cost'] as num?)?.toDouble(),
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 5,
    );
  }

  // Convert from domain entity
  factory InventoryItemModel.fromDomain(InventoryItem item) {
    return InventoryItemModel(
      id: item.id,
      name: item.name,
      category: item.category,
      unit: item.unit,
      quantity: item.quantity,
      minimumQuantity: item.minimumQuantity,
      reorderPoint: item.reorderPoint,
      location: item.location,
      lastUpdated: item.lastUpdated,
      batchNumber: item.batchNumber,
      expiryDate: item.expiryDate,
      additionalAttributes: item.additionalAttributes,
      cost: item.cost,
      lowStockThreshold: item.lowStockThreshold,
    );
  }

  // Convert to domain entity
  InventoryItem toDomain() {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      unit: unit,
      quantity: quantity,
      minimumQuantity: minimumQuantity,
      reorderPoint: reorderPoint,
      location: location,
      lastUpdated: lastUpdated,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      additionalAttributes: additionalAttributes,
      cost: cost,
      lowStockThreshold: lowStockThreshold,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'reorderPoint': reorderPoint,
      'location': location,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'batchNumber': batchNumber,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'additionalAttributes': additionalAttributes,
      'searchTerms': searchTerms,
      'cost': cost,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  InventoryItemModel copyWith({
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
    List<String>? searchTerms,
    double? cost,
    int? lowStockThreshold,
  }) {
    return InventoryItemModel(
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
      searchTerms: searchTerms ?? this.searchTerms,
      cost: cost ?? this.cost,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  // Generate search terms for better search functionality
  static List<String> _generateSearchTerms(String name, String category) {
    final terms = <String>{};

    // Add full name and category
    terms.add(name.toLowerCase());
    terms.add(category.toLowerCase());

    // Add name parts
    terms.addAll(name.toLowerCase().split(' '));

    // Add partial matches for name (minimum 3 characters)
    final words = name.toLowerCase().split(' ');
    for (final word in words) {
      for (int i = 0; i < word.length - 2; i++) {
        for (int j = i + 3; j <= word.length; j++) {
          terms.add(word.substring(i, j));
        }
      }
    }

    return terms.toList();
  }
}
