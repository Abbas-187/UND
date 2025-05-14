import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/inventory_category.dart';
import '../../domain/repositories/inventory_category_repository.dart';

/// Firebase Firestore implementation of InventoryCategoryRepository
class InventoryCategoryRepositoryImpl implements InventoryCategoryRepository {
  InventoryCategoryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('inventory_categories');

  // Convert AttributeDefinition to Firestore-storable Map
  Map<String, dynamic> _defToMap(AttributeDefinition def) {
    return {
      'name': def.name,
      'type': def.type.toString().split('.').last,
      if (def.description != null) 'description': def.description,
      'required': def.required,
      if (def.options != null) 'options': def.options,
      if (def.defaultValue != null) 'defaultValue': def.defaultValue,
    };
  }

  // Convert Firestore map to AttributeDefinition
  AttributeDefinition _mapToDef(Map<String, dynamic> map) {
    return AttributeDefinition(
      name: map['name'] as String,
      type: AttributeType.values
          .firstWhere((e) => e.toString().split('.').last == map['type']),
      description: map['description'] as String?,
      required: map['required'] as bool? ?? false,
      options: (map['options'] as List<dynamic>?)?.cast<String>(),
      defaultValue: map['defaultValue'],
    );
  }

  // Convert Firestore document to InventoryCategory entity
  InventoryCategory _docToEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final defs = <String, AttributeDefinition>{};
    final rawDefs = data['attributeDefinitions'] as Map<String, dynamic>?;
    if (rawDefs != null) {
      rawDefs.forEach((key, value) {
        defs[key] = _mapToDef(value as Map<String, dynamic>);
      });
    }

    return InventoryCategory(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      parentCategoryId: data['parentCategoryId'] as String?,
      colorCode: data['colorCode'] as String,
      itemCount: (data['itemCount'] as num?)?.toInt() ?? 0,
      attributeDefinitions: defs,
    );
  }

  @override
  Future<List<InventoryCategory>> getCategories() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(_docToEntity).toList();
  }

  @override
  Future<InventoryCategory?> getCategory(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _docToEntity(doc);
  }

  @override
  Future<InventoryCategory> addCategory(InventoryCategory category) async {
    final docRef =
        category.id.isEmpty ? _collection.doc() : _collection.doc(category.id);
    final defsMap = category.attributeDefinitions
        .map((key, def) => MapEntry(key, _defToMap(def)));
    await docRef.set({
      'name': category.name,
      'description': category.description,
      'parentCategoryId': category.parentCategoryId,
      'colorCode': category.colorCode,
      'itemCount': category.itemCount,
      'attributeDefinitions': defsMap,
    });
    return category.id.isEmpty ? category.copyWith(id: docRef.id) : category;
  }

  @override
  Future<void> updateCategory(InventoryCategory category) async {
    final defsMap = category.attributeDefinitions
        .map((key, def) => MapEntry(key, _defToMap(def)));
    await _collection.doc(category.id).update({
      'name': category.name,
      'description': category.description,
      'parentCategoryId': category.parentCategoryId,
      'colorCode': category.colorCode,
      'itemCount': category.itemCount,
      'attributeDefinitions': defsMap,
    });
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<List<InventoryCategory>> getChildCategories(String parentId) async {
    final snapshot =
        await _collection.where('parentCategoryId', isEqualTo: parentId).get();
    return snapshot.docs.map(_docToEntity).toList();
  }

  @override
  Future<Map<String, int>> getCategoryItemCounts() async {
    final categories = await getCategories();
    return {for (var c in categories) c.id: c.itemCount};
  }

  @override
  Future<void> updateCategoryAttributes(String categoryId,
      Map<String, AttributeDefinition> attributeDefinitions) async {
    final defsMap =
        attributeDefinitions.map((key, def) => MapEntry(key, _defToMap(def)));
    await _collection.doc(categoryId).update({'attributeDefinitions': defsMap});
  }
}
