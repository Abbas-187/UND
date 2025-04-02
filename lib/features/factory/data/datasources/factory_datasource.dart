import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/equipment_model.dart';
import '../models/material_requisition_model.dart';
import '../models/production_order_model.dart';
import '../models/recipe_model.dart';

class FactoryDatasource {
  FactoryDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collection references
  CollectionReference get _productionOrdersCollection =>
      _firestore.collection('production_orders');
  CollectionReference get _recipesCollection =>
      _firestore.collection('recipes');
  CollectionReference get _materialRequisitionsCollection =>
      _firestore.collection('material_requisitions');
  CollectionReference get _equipmentCollection =>
      _firestore.collection('equipment');

  // Production Orders
  Future<List<ProductionOrderModel>> getProductionOrders() async {
    final snapshot = await _productionOrdersCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ProductionOrderModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<ProductionOrderModel> getProductionOrderById(String id) async {
    final doc = await _productionOrdersCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Production order not found');
    }
    final data = doc.data() as Map<String, dynamic>;
    return ProductionOrderModel.fromJson({...data, 'id': doc.id});
  }

  Future<String> createProductionOrder(ProductionOrderModel order) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    final orderData = order.toJson();
    orderData['createdByUserId'] = currentUser.uid;
    orderData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _productionOrdersCollection.add(orderData);
    return docRef.id;
  }

  Future<void> updateProductionOrder(ProductionOrderModel order) async {
    if (order.id == null || order.id!.isEmpty) {
      throw Exception('Order ID cannot be empty');
    }
    final orderData = order.toJson();
    orderData['updatedAt'] = FieldValue.serverTimestamp();

    await _productionOrdersCollection.doc(order.id).update(orderData);
  }

  Future<void> deleteProductionOrder(String id) async {
    await _productionOrdersCollection.doc(id).delete();
  }

  Future<void> updateProductionOrderStatus(String id, String status) async {
    await _productionOrdersCollection
        .doc(id)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // Recipes
  Future<List<RecipeModel>> getRecipes() async {
    final snapshot = await _recipesCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return RecipeModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<RecipeModel> getRecipeById(String id) async {
    final doc = await _recipesCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Recipe not found');
    }
    final data = doc.data() as Map<String, dynamic>;
    return RecipeModel.fromJson({...data, 'id': doc.id});
  }

  Future<List<RecipeModel>> getRecipesByProductId(String productId) async {
    final snapshot = await _recipesCollection
        .where('productId', isEqualTo: productId)
        .where('isActive', isEqualTo: true)
        .orderBy('version', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return RecipeModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<String> createRecipe(RecipeModel recipe) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    final recipeData = recipe.toJson();
    recipeData['createdByUserId'] = currentUser.uid;
    recipeData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _recipesCollection.add(recipeData);
    return docRef.id;
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    if (recipe.id == null || recipe.id!.isEmpty) {
      throw Exception('Recipe ID cannot be empty');
    }
    final recipeData = recipe.toJson();
    recipeData['updatedAt'] = FieldValue.serverTimestamp();

    await _recipesCollection.doc(recipe.id).update(recipeData);
  }

  Future<void> deleteRecipe(String id) async {
    await _recipesCollection.doc(id).delete();
  }

  Future<void> approveRecipe(String id, String approvedByUserId) async {
    await _recipesCollection.doc(id).update({
      'approvedByUserId': approvedByUserId,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  // Material Requisitions
  Future<List<MaterialRequisitionModel>> getMaterialRequisitions() async {
    final snapshot = await _materialRequisitionsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MaterialRequisitionModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<MaterialRequisitionModel> getMaterialRequisitionById(String id) async {
    final doc = await _materialRequisitionsCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Material requisition not found');
    }
    final data = doc.data() as Map<String, dynamic>;
    return MaterialRequisitionModel.fromJson({...data, 'id': doc.id});
  }

  Future<List<MaterialRequisitionModel>>
      getMaterialRequisitionsByProductionOrderId(
          String productionOrderId) async {
    final snapshot = await _materialRequisitionsCollection
        .where('productionOrderId', isEqualTo: productionOrderId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MaterialRequisitionModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<String> createMaterialRequisition(
      MaterialRequisitionModel requisition) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    final requisitionData = requisition.toJson();
    requisitionData['createdByUserId'] = currentUser.uid;
    requisitionData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _materialRequisitionsCollection.add(requisitionData);
    return docRef.id;
  }

  Future<void> updateMaterialRequisition(
      MaterialRequisitionModel requisition) async {
    if (requisition.id.isEmpty) {
      throw Exception('Requisition ID cannot be empty');
    }
    final requisitionData = requisition.toJson();
    requisitionData['updatedAt'] = FieldValue.serverTimestamp();

    await _materialRequisitionsCollection
        .doc(requisition.id)
        .update(requisitionData);
  }

  Future<void> deleteMaterialRequisition(String id) async {
    await _materialRequisitionsCollection.doc(id).delete();
  }

  Future<void> approveMaterialRequisition(
      String id, String approvedByUserId) async {
    await _materialRequisitionsCollection.doc(id).update({
      'status': 'approved',
      'approvedByUserId': approvedByUserId,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  // Equipment
  Future<List<EquipmentModel>> getEquipment() async {
    final snapshot = await _equipmentCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EquipmentModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<EquipmentModel> getEquipmentById(String id) async {
    final doc = await _equipmentCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Equipment not found');
    }
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentModel.fromJson({...data, 'id': doc.id});
  }

  Future<String> createEquipment(EquipmentModel equipment) async {
    final equipmentData = equipment.toJson();
    equipmentData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _equipmentCollection.add(equipmentData);
    return docRef.id;
  }

  Future<void> updateEquipment(EquipmentModel equipment) async {
    if (equipment.id.isEmpty) {
      throw Exception('Equipment ID cannot be empty');
    }
    final equipmentData = equipment.toJson();
    equipmentData['updatedAt'] = FieldValue.serverTimestamp();

    await _equipmentCollection.doc(equipment.id).update(equipmentData);
  }

  Future<void> deleteEquipment(String id) async {
    await _equipmentCollection.doc(id).delete();
  }

  Future<void> updateEquipmentStatus(String id, bool isOperational) async {
    await _equipmentCollection.doc(id).update({
      'isOperational': isOperational,
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> recordMaintenance(
      String id, DateTime maintenanceDate, DateTime nextMaintenanceDate) async {
    await _equipmentCollection.doc(id).update({
      'lastMaintenanceDate': Timestamp.fromDate(maintenanceDate),
      'nextMaintenanceDate': Timestamp.fromDate(nextMaintenanceDate),
      'updatedAt': FieldValue.serverTimestamp()
    });
  }
}
