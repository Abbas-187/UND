I apologize for the errors in the script. Let me provide you with a corrected version that addresses the syntax issues. The main problems in the previous script were related to PowerShell's parsing of special characters in string comparisons and variable references.

Here's a revised script that should work correctly:

```powershell
# PowerShell script to create Inventory Management Module for UND App

# Define the base directory (current directory)
$baseDir = Get-Location
$libDir = Join-Path $baseDir "lib"

Write-Host "Creating Inventory Management Module for UND App..." -ForegroundColor Cyan

# Create inventory module structure if it doesn't exist
$inventoryDirPath = Join-Path $libDir "features/inventory"
if (-not (Test-Path $inventoryDirPath)) {
    New-Item -Path $inventoryDirPath -ItemType Directory -Force | Out-Null
}

# Create subdirectories for the inventory module
$inventorySubDirs = @(
    "data",
    "data/repositories",
    "data/models", 
    "data/datasources",
    "domain",
    "domain/entities",
    "domain/usecases",
    "domain/providers",
    "presentation",
    "presentation/screens",
    "presentation/widgets"
)

foreach ($dir in $inventorySubDirs) {
    $newDir = Join-Path $inventoryDirPath $dir
    if (-not (Test-Path $newDir)) {
        New-Item -Path $newDir -ItemType Directory -Force | Out-Null
        Write-Host "Created 'features/inventory/$dir' directory" -ForegroundColor Green
    }
}

#------------------------------------------------------------------------------
# DATA LAYER
#------------------------------------------------------------------------------

# 1. Create inventory models
$inventoryItemModelPath = Join-Path $inventoryDirPath "data/models/inventory_item_model.dart"
$inventoryItemModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item_model.freezed.dart';
part 'inventory_item_model.g.dart';

@freezed
class InventoryItemModel with _$InventoryItemModel {
  const factory InventoryItemModel({
    required String id,
    required String materialId,
    required String materialName,
    required String materialCode,
    required String warehouseId,
    required String uom, // Unit of Measure
    required double currentStock,
    required double availableStock,
    double? reservedStock,
    double? allocatedStock,
    required double minStockLevel,
    required double maxStockLevel,
    required double reorderPoint,
    String? materialCategory,
    String? description,
    double? unitCost,
    String? currency,
    DateTime? lastCountDate,
    DateTime? lastReceiptDate,
    DateTime? lastIssueDate,
    DateTime? updatedAt,
    String? updatedBy,
    @Default(false) bool isActive,
    @Default([]) List<BatchModel> batches,
    @Default([]) List<StorageLocationModel> locations,
  }) = _InventoryItemModel;

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemModelFromJson(json);

  factory InventoryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert Timestamp objects to DateTime
    final lastCountDate = data['lastCountDate'] as Timestamp?;
    final lastReceiptDate = data['lastReceiptDate'] as Timestamp?;
    final lastIssueDate = data['lastIssueDate'] as Timestamp?;
    final updatedAt = data['updatedAt'] as Timestamp?;
    
    // Process batches
    final batchesList = (data['batches'] as List<dynamic>?)?.map(
      (batchData) => BatchModel.fromJson(batchData as Map<String, dynamic>),
    ).toList() ?? [];
    
    // Process locations
    final locationsList = (data['locations'] as List<dynamic>?)?.map(
      (locationData) => StorageLocationModel.fromJson(locationData as Map<String, dynamic>),
    ).toList() ?? [];
    
    return InventoryItemModel(
      id: doc.id,
      materialId: data['materialId'] ?? '',
      materialName: data['materialName'] ?? '',
      materialCode: data['materialCode'] ?? '',
      warehouseId: data['warehouseId'] ?? '',
      uom: data['uom'] ?? '',
      currentStock: (data['currentStock'] ?? 0).toDouble(),
      availableStock: (data['availableStock'] ?? 0).toDouble(),
      reservedStock: (data['reservedStock'] ?? 0).toDouble(),
      allocatedStock: (data['allocatedStock'] ?? 0).toDouble(),
      minStockLevel: (data['minStockLevel'] ?? 0).toDouble(),
      maxStockLevel: (data['maxStockLevel'] ?? 0).toDouble(),
      reorderPoint: (data['reorderPoint'] ?? 0).toDouble(),
      materialCategory: data['materialCategory'],
      description: data['description'],
      unitCost: (data['unitCost'] ?? 0).toDouble(),
      currency: data['currency'],
      lastCountDate: lastCountDate?.toDate(),
      lastReceiptDate: lastReceiptDate?.toDate(),
      lastIssueDate: lastIssueDate?.toDate(),
      updatedAt: updatedAt?.toDate(),
      updatedBy: data['updatedBy'],
      isActive: data['isActive'] ?? true,
      batches: batchesList,
      locations: locationsList,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'materialCode': materialCode,
      'warehouseId': warehouseId,
      'uom': uom,
      'currentStock': currentStock,
      'availableStock': availableStock,
      'reservedStock': reservedStock,
      'allocatedStock': allocatedStock,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'reorderPoint': reorderPoint,
      'materialCategory': materialCategory,
      'description': description,
      'unitCost': unitCost,
      'currency': currency,
      'lastCountDate': lastCountDate != null ? Timestamp.fromDate(lastCountDate!) : null,
      'lastReceiptDate': lastReceiptDate != null ? Timestamp.fromDate(lastReceiptDate!) : null,
      'lastIssueDate': lastIssueDate != null ? Timestamp.fromDate(lastIssueDate!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
      'isActive': isActive,
      'batches': batches.map((batch) => batch.toJson()).toList(),
      'locations': locations.map((location) => location.toJson()).toList(),
    };
  }
}

@freezed
class BatchModel with _$BatchModel {
  const factory BatchModel({
    required String batchNumber,
    required double quantity,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    String? supplierName,
    String? supplierBatch,
    String? notes,
    String? qualityStatus,
    @Default(false) bool isQuarantined,
  }) = _BatchModel;

  factory BatchModel.fromJson(Map<String, dynamic> json) =>
      _$BatchModelFromJson(json);
}

@freezed
class StorageLocationModel with _$StorageLocationModel {
  const factory StorageLocationModel({
    required String locationId,
    required String locationName,
    required double quantity,
    String? zone,
    String? aisle,
    String? rack,
    String? bin,
    String? notes,
  }) = _StorageLocationModel;

  factory StorageLocationModel.fromJson(Map<String, dynamic> json) =>
      _$StorageLocationModelFromJson(json);
}
'@
Set-Content -Path $inventoryItemModelPath -Value $inventoryItemModelContent
Write-Host "Created inventory_item_model.dart" -ForegroundColor Green

# Create inventory transaction model
$inventoryTransactionModelPath = Join-Path $inventoryDirPath "data/models/inventory_transaction_model.dart"
$inventoryTransactionModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_transaction_model.freezed.dart';
part 'inventory_transaction_model.g.dart';

enum TransactionType {
  receipt,
  issue,
  adjustment,
  transfer,
  return_,
  count
}

@freezed
class InventoryTransactionModel with _$InventoryTransactionModel {
  const factory InventoryTransactionModel({
    String? id,
    required String materialId,
    required String materialName,
    required String warehouseId,
    required TransactionType transactionType,
    required double quantity,
    required String uom,
    String? batchNumber,
    String? sourceLocationId,
    String? destinationLocationId,
    String? referenceNumber,
    String? referenceType,
    String? reason,
    String? notes,
    DateTime? transactionDate,
    String? performedBy,
    String? approvedBy,
    DateTime? approvedAt,
    @Default(false) bool isApproved,
    @Default(false) bool isPending,
    DateTime? createdAt,
  }) = _InventoryTransactionModel;

  factory InventoryTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryTransactionModelFromJson(json);

  factory InventoryTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert Timestamp objects to DateTime
    final transactionDate = data['transactionDate'] as Timestamp?;
    final approvedAt = data['approvedAt'] as Timestamp?;
    final createdAt = data['createdAt'] as Timestamp?;

    // Convert string to enum
    final transactionTypeStr = data['transactionType'] as String;
    final transactionType = TransactionType.values.firstWhere(
      (type) => type.name == transactionTypeStr.toLowerCase(),
      orElse: () => TransactionType.adjustment,
    );
    
    return InventoryTransactionModel(
      id: doc.id,
      materialId: data['materialId'] ?? '',
      materialName: data['materialName'] ?? '',
      warehouseId: data['warehouseId'] ?? '',
      transactionType: transactionType,
      quantity: (data['quantity'] ?? 0).toDouble(),
      uom: data['uom'] ?? '',
      batchNumber: data['batchNumber'],
      sourceLocationId: data['sourceLocationId'],
      destinationLocationId: data['destinationLocationId'],
      referenceNumber: data['referenceNumber'],
      referenceType: data['referenceType'],
      reason: data['reason'],
      notes: data['notes'],
      transactionDate: transactionDate?.toDate(),
      performedBy: data['performedBy'],
      approvedBy: data['approvedBy'],
      approvedAt: approvedAt?.toDate(),
      isApproved: data['isApproved'] ?? false,
      isPending: data['isPending'] ?? false,
      createdAt: createdAt?.toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'warehouseId': warehouseId,
      'transactionType': transactionType.name,
      'quantity': quantity,
      'uom': uom,
      'batchNumber': batchNumber,
      'sourceLocationId': sourceLocationId,
      'destinationLocationId': destinationLocationId,
      'referenceNumber': referenceNumber,
      'referenceType': referenceType,
      'reason': reason,
      'notes': notes,
      'transactionDate': transactionDate != null ? Timestamp.fromDate(transactionDate!) : Timestamp.now(),
      'performedBy': performedBy,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'isApproved': isApproved,
      'isPending': isPending,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
    };
  }
}
'@
Set-Content -Path $inventoryTransactionModelPath -Value $inventoryTransactionModelContent
Write-Host "Created inventory_transaction_model.dart" -ForegroundColor Green

# Create warehouse location model
$warehouseLocationModelPath = Join-Path $inventoryDirPath "data/models/warehouse_location_model.dart"
$warehouseLocationModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'warehouse_location_model.freezed.dart';
part 'warehouse_location_model.g.dart';

@freezed
class WarehouseLocationModel with _$WarehouseLocationModel {
  const factory WarehouseLocationModel({
    required String id,
    required String warehouseId,
    required String locationCode,
    required String locationName,
    required String locationType, // Zone, Aisle, Rack, Bin, etc.
    String? zone,
    String? aisle,
    String? rack,
    String? level,
    String? bin,
    String? parentLocationId,
    double? maxWeight,
    double? maxVolume,
    double? currentWeight,
    double? currentVolume,
    int? currentItemCount,
    @Default([]) List<String> specialHandling,
    @Default([]) List<String> restrictedMaterials,
    String? temperatureZone,
    double? minTemperature,
    double? maxTemperature,
    bool? requiresHumidityControl,
    double? minHumidity,
    double? maxHumidity,
    @Default(true) bool isActive,
    @Default(false) bool isQuarantine,
    @Default(false) bool isStaging,
    @Default(false) bool isReceiving,
    @Default(false) bool isShipping,
    String? notes,
    String? barcode,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) = _WarehouseLocationModel;

  factory WarehouseLocationModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseLocationModelFromJson(json);

  factory WarehouseLocationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert Timestamp objects to DateTime
    final createdAt = data['createdAt'] as Timestamp?;
    final updatedAt = data['updatedAt'] as Timestamp?;
    
    // Convert special handling and restricted materials
    final specialHandlingList = (data['specialHandling'] as List<dynamic>?)?.cast<String>() ?? [];
    final restrictedMaterialsList = (data['restrictedMaterials'] as List<dynamic>?)?.cast<String>() ?? [];
    
    return WarehouseLocationModel(
      id: doc.id,
      warehouseId: data['warehouseId'] ?? '',
      locationCode: data['locationCode'] ?? '',
      locationName: data['locationName'] ?? '',
      locationType: data['locationType'] ?? '',
      zone: data['zone'],
      aisle: data['aisle'],
      rack: data['rack'],
      level: data['level'],
      bin: data['bin'],
      parentLocationId: data['parentLocationId'],
      maxWeight: (data['maxWeight'] ?? 0).toDouble(),
      maxVolume: (data['maxVolume'] ?? 0).toDouble(),
      currentWeight: (data['currentWeight'] ?? 0).toDouble(),
      currentVolume: (data['currentVolume'] ?? 0).toDouble(),
      currentItemCount: data['currentItemCount'] as int?,
      specialHandling: specialHandlingList,
      restrictedMaterials: restrictedMaterialsList,
      temperatureZone: data['temperatureZone'],
      minTemperature: (data['minTemperature'] ?? 0).toDouble(),
      maxTemperature: (data['maxTemperature'] ?? 0).toDouble(),
      requiresHumidityControl: data['requiresHumidityControl'] as bool?,
      minHumidity: (data['minHumidity'] ?? 0).toDouble(),
      maxHumidity: (data['maxHumidity'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      isQuarantine: data['isQuarantine'] ?? false,
      isStaging: data['isStaging'] ?? false,
      isReceiving: data['isReceiving'] ?? false,
      isShipping: data['isShipping'] ?? false,
      notes: data['notes'],
      barcode: data['barcode'],
      createdBy: data['createdBy'],
      createdAt: createdAt?.toDate(),
      updatedBy: data['updatedBy'],
      updatedAt: updatedAt?.toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'warehouseId': warehouseId,
      'locationCode': locationCode,
      'locationName': locationName,
      'locationType': locationType,
      'zone': zone,
      'aisle': aisle,
      'rack': rack,
      'level': level,
      'bin': bin,
      'parentLocationId': parentLocationId,
      'maxWeight': maxWeight,
      'maxVolume': maxVolume,
      'currentWeight': currentWeight,
      'currentVolume': currentVolume,
      'currentItemCount': currentItemCount,
      'specialHandling': specialHandling,
      'restrictedMaterials': restrictedMaterials,
      'temperatureZone': temperatureZone,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'requiresHumidityControl': requiresHumidityControl,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'isActive': isActive,
      'isQuarantine': isQuarantine,
      'isStaging': isStaging,
      'isReceiving': isReceiving,
      'isShipping': isShipping,
      'notes': notes,
      'barcode': barcode,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }
}
'@
Set-Content -Path $warehouseLocationModelPath -Value $warehouseLocationModelContent
Write-Host "Created warehouse_location_model.dart" -ForegroundColor Green

# Create material model
$materialModelPath = Join-Path $inventoryDirPath "data/models/material_model.dart"
$materialModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_model.freezed.dart';
part 'material_model.g.dart';

enum MaterialType {
  raw_material,
  packaging_material,
  finished_good,
  semi_finished_good,
  consumable
}

@freezed
class MaterialModel with _$MaterialModel {
  const factory MaterialModel({
    required String id,
    required String materialCode,
    required String materialName,
    required MaterialType materialType,
    String? description,
    String? category,
    String? subCategory,
    required String defaultUom,
    Map<String, double>? uomConversions,
    String? defaultWarehouseId,
    String? defaultLocationId,
    double? reorderPoint,
    double? minimumOrderQuantity,
    double? standardCost,
    String? costCurrency,
    double? weight,
    String? weightUom,
    double? volume,
    String? volumeUom,
    List<String>? dimensions,
    String? dimensionUom,
    String? barcode,
    @Default([]) List<String> alternativeBarcodes,
    @Default(false) bool requiresBatchManagement,
    @Default(false) bool requiresExpiryDate,
    @Default(false) bool requiresSerialNumbers,
    @Default(false) bool isHazardous,
    @Default(false) bool isActive,
    String? imageUrl,
    String? safetyDataSheetUrl,
    String? specifications,
    List<String>? tags,
    Map<String, dynamic>? additionalAttributes,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) = _MaterialModel;

  factory MaterialModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialModelFromJson(json);
      
  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert Timestamp objects to DateTime
    final createdAt = data['createdAt'] as Timestamp?;
    final updatedAt = data['updatedAt'] as Timestamp?;
    
    // Convert string to enum
    final materialTypeStr = data['materialType'] as String;
    final materialType = MaterialType.values.firstWhere(
      (type) => type.name == materialTypeStr,
      orElse: () => MaterialType.raw_material,
    );
    
    // Convert UOM conversions map
    final uomConversionsData = data['uomConversions'] as Map<String, dynamic>?;
    final Map<String, double>? uomConversions = uomConversionsData?.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    
    // Convert lists
    final dimensionsList = (data['dimensions'] as List<dynamic>?)?.cast<String>();
    final alternativeBarCodesList = (data['alternativeBarcodes'] as List<dynamic>?)?.cast<String>() ?? [];
    final tagsList = (data['tags'] as List<dynamic>?)?.cast<String>();
    
    return MaterialModel(
      id: doc.id,
      materialCode: data['materialCode'] ?? '',
      materialName: data['materialName'] ?? '',
      materialType: materialType,
      description: data['description'],
      category: data['category'],
      subCategory: data['subCategory'],
      defaultUom: data['defaultUom'] ?? '',
      uomConversions: uomConversions,
      defaultWarehouseId: data['defaultWarehouseId'],
      defaultLocationId: data['defaultLocationId'],
      reorderPoint: (data['reorderPoint'] ?? 0).toDouble(),
      minimumOrderQuantity: (data['minimumOrderQuantity'] ?? 0).toDouble(),
      standardCost: (data['standardCost'] ?? 0).toDouble(),
      costCurrency: data['costCurrency'],
      weight: (data['weight'] ?? 0).toDouble(),
      weightUom: data['weightUom'],
      volume: (data['volume'] ?? 0).toDouble(),
      volumeUom: data['volumeUom'],
      dimensions: dimensionsList,
      dimensionUom: data['dimensionUom'],
      barcode: data['barcode'],
      alternativeBarcodes: alternativeBarCodesList,
      requiresBatchManagement: data['requiresBatchManagement'] ?? false,
      requiresExpiryDate: data['requiresExpiryDate'] ?? false,
      requiresSerialNumbers: data['requiresSerialNumbers'] ?? false,
      isHazardous: data['isHazardous'] ?? false,
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'],
      safetyDataSheetUrl: data['safetyDataSheetUrl'],
      specifications: data['specifications'],
      tags: tagsList,
      additionalAttributes: data['additionalAttributes'] as Map<String, dynamic>?,
      createdBy: data['createdBy'],
      createdAt: createdAt?.toDate(),
      updatedBy: data['updatedBy'],
      updatedAt: updatedAt?.toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'materialCode': materialCode,
      'materialName': materialName,
      'materialType': materialType.name,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'defaultUom': defaultUom,
      'uomConversions': uomConversions,
      'defaultWarehouseId': defaultWarehouseId,
      'defaultLocationId': defaultLocationId,
      'reorderPoint': reorderPoint,
      'minimumOrderQuantity': minimumOrderQuantity,
      'standardCost': standardCost,
      'costCurrency': costCurrency,
      'weight': weight,
      'weightUom': weightUom,
      'volume': volume,
      'volumeUom': volumeUom,
      'dimensions': dimensions,
      'dimensionUom': dimensionUom,
      'barcode': barcode,
      'alternativeBarcodes': alternativeBarcodes,
      'requiresBatchManagement': requiresBatchManagement,
      'requiresExpiryDate': requiresExpiryDate,
      'requiresSerialNumbers': requiresSerialNumbers,
      'isHazardous': isHazardous,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'safetyDataSheetUrl': safetyDataSheetUrl,
      'specifications': specifications,
      'tags': tags,
      'additionalAttributes': additionalAttributes,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }
}
'@
Set-Content -Path $materialModelPath -Value $materialModelContent
Write-Host "Created material_model.dart" -ForegroundColor Green

# Create repositories
$inventoryRepositoryPath = Join-Path $inventoryDirPath "data/repositories/inventory_repository.dart"
$inventoryRepositoryContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_transaction_model.dart';
import '../models/warehouse_location_model.dart';
import '../models/material_model.dart';

part 'inventory_repository.g.dart';

class InventoryException implements Exception {
  final String message;
  
  InventoryException(this.message);
  
  @override
  String toString() => message;
}

@riverpod
class InventoryRepository extends _$InventoryRepository {
  late FirebaseFirestore _firestore;
  
  @override
  FutureOr<void> build() {
    _firestore = ref.read(firestoreProvider);
  }

  // Inventory Items
  
  Stream<List<InventoryItemModel>> getInventoryItems({String? warehouseId}) {
    Query query = _firestore.collection('inventory');
    
    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
    });
  }
  
  Future<InventoryItemModel?> getInventoryItem(String warehouseId, String materialId) async {
    final docId = '${warehouseId}_${materialId}';
    final docSnap = await _firestore.collection('inventory').doc(docId).get();
    
    if (!docSnap.exists) {
      return null;
    }
    
    return InventoryItemModel.fromFirestore(docSnap);
  }
  
  Future<void> updateInventoryItem(InventoryItemModel item) async {
    final docId = '${item.warehouseId}_${item.materialId}';
    
    try {
      await _firestore.collection('inventory').doc(docId).set(
        item.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw InventoryException('Failed to update inventory item: $e');
    }
  }
  
  // Inventory Transactions
  
  Future<String> createInventoryTransaction(InventoryTransactionModel transaction) async {
    try {
      final docRef = await _firestore.collection('inventory_transactions').add(
        transaction.toFirestore(),
      );
      
      return docRef.id;
    } catch (e) {
      throw InventoryException('Failed to create inventory transaction: $e');
    }
  }
  
  Stream<List<InventoryTransactionModel>> getInventoryTransactions({
    String? warehouseId,
    String? materialId,
    TransactionType? transactionType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    Query query = _firestore.collection('inventory_transactions')
        .orderBy('transactionDate', descending: true);
    
    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }
    
    if (materialId != null) {
      query = query.where('materialId', isEqualTo: materialId);
    }
    
    if (transactionType != null) {
      query = query.where('transactionType', isEqualTo: transactionType.name);
    }
    
    if (startDate != null) {
      query = query.where('transactionDate', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    
    if (endDate != null) {
      query = query.where('transactionDate', 
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryTransactionModel.fromFirestore(doc))
          .toList();
    });
  }
  
  // Process inventory transactions (this would typically trigger a Cloud Function)
  Future<void> processInventoryTransaction(InventoryTransactionModel transaction) async {
    try {
      // In a real implementation, you might call a Cloud Function here
      // or implement the logic to update inventory based on the transaction type
      
      // For now, we'll simulate the process by creating the transaction
      final transactionId = await createInventoryTransaction(transaction);
      
      // Get current inventory item
      final inventoryItem = await getInventoryItem(
        transaction.warehouseId, 
        transaction.materialId
      );
      
      if (inventoryItem == null && transaction.transactionType != TransactionType.receipt) {
        throw InventoryException('Cannot process transaction: Inventory item not found');
      }
      
      // Update inventory based on transaction type
      double newStock = inventoryItem?.currentStock ?? 0;
      double newAvailable = inventoryItem?.availableStock ?? 0;
      
      switch (transaction.transactionType) {
        case TransactionType.receipt:
          newStock += transaction.quantity;
          newAvailable += transaction.quantity;
          break;
        case TransactionType.issue:
          if (newAvailable < transaction.quantity) {
            throw InventoryException('Insufficient available stock');
          }
          newStock -= transaction.quantity;
          newAvailable -= transaction.quantity;
          break;
        case TransactionType.adjustment:
          newStock = transaction.quantity; // Direct adjustment
          newAvailable = transaction.quantity; // Simplification
          break;
        case TransactionType.transfer:
          // Transfers would involve two transactions - handled separately
          break;
        case TransactionType.return_:
          newStock += transaction.quantity;
          newAvailable += transaction.quantity;
          break;
        case TransactionType.count:
          // Stock count adjustments are handled like direct adjustments
          newStock = transaction.quantity;
          newAvailable = transaction.quantity; // Simplification
          break;
      }
      
      // Create or update the inventory item
      final updatedItem = inventoryItem != null
          ? inventoryItem.copyWith(
              currentStock: newStock,
              availableStock: newAvailable,
              updatedAt: DateTime.now(),
            )
          : InventoryItemModel(
              id: '${transaction.warehouseId}_${transaction.materialId}',
              materialId: transaction.materialId,
              materialName: transaction.materialName,
              materialCode: transaction.materialId, // Simplification
              warehouseId: transaction.warehouseId,
              uom: transaction.uom,
              currentStock: newStock,
              availableStock: newAvailable,
              minStockLevel: 0,
              maxStockLevel: 1000,
              reorderPoint: 100,
              updatedAt: DateTime.now(),
            );
      
      await updateInventoryItem(updatedItem);
      
    } catch (e) {
      throw InventoryException('Failed to process inventory transaction: $e');
    }
  }
  
  // Warehouse Locations
  
  Stream<List<WarehouseLocationModel>> getWarehouseLocations(String warehouseId) {
    return _firestore
        .collection('warehouse_locations')
        .where('warehouseId', isEqualTo: warehouseId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WarehouseLocationModel.fromFirestore(doc))
              .toList();
        });
  }
  
  Future<WarehouseLocationModel?> getWarehouseLocation(String locationId) async {
    final docSnap = await _firestore.collection('warehouse_locations').doc(locationId).get();
    
    if (!docSnap.exists) {
      return null;
    }
    
    return WarehouseLocationModel.fromFirestore(docSnap);
  }
  
  Future<String> createWarehouseLocation(WarehouseLocationModel location) async {
    try {
      final docRef = await _firestore.collection('warehouse_locations').add(
        location.toFirestore(),
      );
      
      return docRef.id;
    } catch (e) {
      throw InventoryException('Failed to create warehouse location: $e');
    }
  }
  
  Future<void> updateWarehouseLocation(WarehouseLocationModel location) async {
    try {
      await _firestore.collection('warehouse_locations').doc(location.id).update(
        location.toFirestore(),
      );
    } catch (e) {
      throw InventoryException('Failed to update warehouse location: $e');
    }
  }
  
  // Materials
  
  Stream<List<MaterialModel>> getMaterials({MaterialType? materialType}) {
    Query query = _firestore.collection('materials');
    
    if (materialType != null) {
      query = query.where('materialType', isEqualTo: materialType.name);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MaterialModel.fromFirestore(doc))
          .toList();
    });
  }
  
  Future<MaterialModel?> getMaterial(String materialId) async {
    final docSnap = await _firestore.collection('materials').doc(materialId).get();
    
    if (!docSnap.exists) {
      return null;
    }
    
    return MaterialModel.fromFirestore(docSnap);
  }
  
  Future<String> createMaterial(MaterialModel material) async {
    try {
      final docRef = await _firestore.collection('materials').add(
        material.toFirestore(),
      );
      
      return docRef.id;
    } catch (e) {
      throw InventoryException('Failed to create material: $e');
    }
  }
  
  Future<void> updateMaterial(MaterialModel material) async {
    try {
      await _firestore.collection('materials').doc(material.id).update(
        material.toFirestore(),
      );
    } catch (e) {
      throw InventoryException('Failed to update material: $e');
    }
  }
}
'@
Set-Content -Path $inventoryRepositoryPath -Value $inventoryRepositoryContent
Write-Host "Created inventory_repository.dart" -ForegroundColor Green

#------------------------------------------------------------------------------
# DOMAIN LAYER
#------------------------------------------------------------------------------

# Create providers for inventory
$inventoryProvidersPath = Join-Path $inventoryDirPath "domain/providers/inventory_providers.dart"
$inventoryProvidersContent = @'
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/models/inventory_item_model.dart';
import '../../data/models/inventory_transaction_model.dart';
import '../../data/models/warehouse_location_model.dart';
import '../../data/models/material_model.dart';

part 'inventory_providers.g.dart';

// Inventory Items Providers
@riverpod
Stream<List<InventoryItemModel>> inventoryItems(
  InventoryItemsRef ref, 
  {String? warehouseId}
) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getInventoryItems(warehouseId: warehouseId);
}

@riverpod
Future<InventoryItemModel?> inventoryItem(
  InventoryItemRef ref,
  String warehouseId,
  String materialId
) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getInventoryItem(warehouseId, materialId);
}

// Inventory Transactions Providers
@riverpod
Stream<List<InventoryTransactionModel>> inventoryTransactions(
  InventoryTransactionsRef ref,
  {
    String? warehouseId,
    String? materialId,
    TransactionType? transactionType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }
) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getInventoryTransactions(
    warehouseId: warehouseId,
    materialId: materialId,
    transactionType: transactionType,
    startDate: startDate,
    endDate: endDate,
    limit: limit,
  );
}

// Warehouse Locations Providers
@riverpod
Stream<List<WarehouseLocationModel>> warehouseLocations(
  WarehouseLocationsRef ref, 
  String warehouseId
) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getWarehouseLocations(warehouseId);
}

@riverpod
Future<WarehouseLocationModel?> warehouseLocation(
  WarehouseLocationRef ref,
  String locationId
) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getWarehouseLocation(locationId);
}

// Materials Providers
@riverpod
Stream<List<MaterialModel>> materials(
  MaterialsRef ref, 
  {MaterialType? materialType}
) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getMaterials(materialType: materialType);
}

@riverpod
Future<MaterialModel?> material(
  MaterialRef ref,
  String materialId
) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getMaterial(materialId);
}

// Inventory Operations Providers
@riverpod
class InventoryOperations extends _$InventoryOperations {
  @override
  FutureOr<void> build() {
    // Nothing to build initially
  }
  
  Future<void> receiveStock({
    required String materialId,
    required String materialName,
    required String warehouseId,
    required double quantity,
    required String uom,
    String? batchNumber,
    String? locationId,
    String? referenceNumber,
    String? notes,
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);
    
    final transaction = InventoryTransactionModel(
      materialId: materialId,
      materialName: materialName,
      warehouseId: warehouseId,
      transactionType: TransactionType.receipt,
      quantity: quantity,
      uom: uom,
      batchNumber: batchNumber,
      destinationLocationId: locationId,
      referenceNumber: referenceNumber,
      notes: notes,
      transactionDate: DateTime.now(),
    );
    
    await repository.processInventoryTransaction(transaction);
  }
  
  Future<void> issueStock({
    required String materialId,
    required String materialName,
    required String warehouseId,
    required double quantity,
    required String uom,
    String? batchNumber,
    String? locationId,
    String? referenceNumber,
    String? referenceType,
    String? notes,
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);
    
    final transaction = InventoryTransactionModel(
      materialId: materialId,
      materialName: materialName,
      warehouseId: warehouseId,
      transactionType: TransactionType.issue,
      quantity: quantity,
      uom: uom,
      batchNumber: batchNumber,
      sourceLocationId: locationId,
      referenceNumber: referenceNumber,
      referenceType: referenceType,
      notes: notes,
      transactionDate: DateTime.now(),
    );
    
    await repository.processInventoryTransaction(transaction);
  }
  
  Future<void> adjustStock({
    required String materialId,
    required String materialName,
    required String warehouseId,
    required double quantity,
    required String uom,
    String? reason,
    String? locationId,
    String? notes,
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);
    
    final transaction = InventoryTransactionModel(
      materialId: materialId,
      materialName: materialName,
      warehouseId: warehouseId,
      transactionType: TransactionType.adjustment,
      quantity: quantity,
      uom: uom,
      reason: reason,
      sourceLocationId: locationId,
      notes: notes,
      transactionDate: DateTime.now(),
    );
    
    await repository.processInventoryTransaction(transaction);
  }
  
  Future<void> transferStock({
    required String materialId,
    required String materialName,
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required double quantity,
    required String uom,
    String? batchNumber,
    String? sourceLocationId,
    String? destinationLocationId,
    String? notes,
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);
    
    // First create the issue transaction from source
    final issueTransaction = InventoryTransactionModel(
      materialId: materialId,
      materialName: materialName,
      warehouseId: sourceWarehouseId,
      transactionType: TransactionType.issue,
      quantity: quantity,
      uom: uom,
      batchNumber: batchNumber,
      sourceLocationId: sourceLocationId,
      referenceType: 'transfer',
      notes: notes,
      transactionDate: DateTime.now(),
    );
    
    await repository.processInventoryTransaction(issueTransaction);
    
    // Then create the receipt transaction at destination
    final receiptTransaction = InventoryTransactionModel(
      materialId: materialId,
      materialName: materialName,
      warehouseId: destinationWarehouseId,
      transactionType: TransactionType.receipt,
      quantity: quantity,
      uom: uom,
      batchNumber: batchNumber,
      destinationLocationId: destinationLocationId,
      referenceType: 'transfer',
      notes: notes,
      transactionDate: DateTime.now(),
    );
    
    await repository.processInventoryTransaction(receiptTransaction);
  }
  
  Future<void> countStock({
    required String materialId,
    required String materialName,
    required String warehouseId,
    required double quantity,
    required String uom,
    String? batchNumber,
    String? locationId,
    String? notes,
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);
    
    final transaction = InventoryTransactionModel(
      materialId: materialId,
      materialName: materialName,
      warehouseId: warehouseId,
      transactionType: TransactionType.count,
      quantity: quantity,
      uom: uom,
      batchNumber: batchNumber,
      sourceLocationId: locationId,
      notes: notes,
      transactionDate: DateTime.now(),
    );
    
    await repository.processInventoryTransaction(transaction);
  }
}
'@
Set-Content -Path $inventoryProvidersPath -Value $inventoryProvidersContent
Write-Host "Created inventory_providers.dart" -ForegroundColor Green

#------------------------------------------------------------------------------
# PRESENTATION LAYER
#------------------------------------------------------------------------------

# Create inventory dashboard screen
$inventoryDashboardPath = Join-Path $inventoryDirPath "presentation/screens/inventory_dashboard_screen.dart"
$inventoryDashboardContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../domain/providers/inventory_providers.dart';
import '../widgets/inventory_status_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/low_stock_alert_card.dart';

class InventoryDashboardScreen extends ConsumerWidget {
  const InventoryDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
      ),
      body: userAsync.when(
        data: (user) {
          final warehouseId = user?.warehouseId ?? 'WH001'; // Default warehouse if not assigned
          
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh providers
              ref.invalidate(inventoryItemsProvider(warehouseId: warehouseId));
              ref.invalidate(inventoryTransactionsProvider());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventory Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Stat Cards
                  _buildQuickStats(context, ref, warehouseId),
                  
                  const SizedBox(height: 24),
                  
                  // Low Stock Alerts
                  Text(
                    'Low Stock Alerts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  LowStockAlertCard(warehouseId: warehouseId),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: RecentTransactionsList(warehouseId: warehouseId),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildQuickActions(context),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user information: $error'),
        ),
      ),
    );
  }
  
  Widget _buildQuickStats(BuildContext context, WidgetRef ref, String warehouseId) {
    return Consumer(
      builder: (context, ref, child) {
        final inventoryItemsAsync = ref.watch(inventoryItemsProvider(warehouseId: warehouseId));
        
        return inventoryItemsAsync.when(
          data: (items) {
            // Calculate some statistics
            final totalItems = items.length;
            final totalStock = items.fold<double>(
              0, 
              (sum, item) => sum + item.currentStock
            );
            final lowStockItems = items.where(
              (item) => item.currentStock <= item.reorderPoint
            ).length;
            
            return Row(
              children: [
                Expanded(
                  child: InventoryStatusCard(
                    title: 'Total Items',
                    value: totalItems.toString(),
                    icon: Icons.category,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InventoryStatusCard(
                    title: 'Total Stock',
                    value: totalStock.toStringAsFixed(2),
                    icon: Icons.inventory_2,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InventoryStatusCard(
                    title: 'Low Stock',
                    value: lowStockItems.toString(),
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
          loading: () => SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text('Error loading inventory: $error'),
        );
      },
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ActionButton(
          label: 'Receive Stock',
          icon: Icons.add_circle,
          color: Colors.green,
          onTap: () {
            Navigator.of(context).pushNamed('/inventory/receive');
          },
        ),
        ActionButton(
          label: 'Issue Stock',
          icon: Icons.remove_circle,
          color: Colors.red,
          onTap: () {
            Navigator.of(context).pushNamed('/inventory/issue');
          },
        ),
        ActionButton(
          label: 'Stock Count',
          icon: Icons.checklist,
          color: Colors.purple,
          onTap: () {
            Navigator.of(context).pushNamed('/inventory/count');
          },
        ),
        ActionButton(
          label: 'View Items',
          icon: Icons.search,
          color: Colors.blue,
          onTap: () {
            Navigator.of(context).pushNamed('/inventory/items');
          },
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'@
Set-Content -Path $inventoryDashboardPath -Value $inventoryDashboardContent
Write-Host "Created inventory_dashboard_screen.dart" -ForegroundColor Green

# Create inventory widgets
$inventoryStatusCardPath = Join-Path $inventoryDirPath "presentation/widgets/inventory_status_card.dart"
$inventoryStatusCardContent = @'
import 'package:flutter/material.dart';

class InventoryStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InventoryStatusCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'@
Set-Content -Path $inventoryStatusCardPath -Value $inventoryStatusCardContent
Write-Host "Created inventory_status_card.dart" -ForegroundColor Green

$recentTransactionsListPath = Join-Path $inventoryDirPath "presentation/widgets/recent_transactions_list.dart"
$recentTransactionsListContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/providers/inventory_providers.dart';
import '../../data/models/inventory_transaction_model.dart';

class RecentTransactionsList extends ConsumerWidget {
  final String? warehouseId;
  final int limit;

  const RecentTransactionsList({
    Key? key,
    this.warehouseId,
    this.limit = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(
      inventoryTransactionsProvider(
        warehouseId: warehouseId,
        limit: limit,
      ),
    );

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Text('No recent transactions'),
          );
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return TransactionListItem(transaction: transaction);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading transactions: $error'),
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final InventoryTransactionModel transaction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    final formattedDate = transaction.transactionDate != null
        ? dateFormat.format(transaction.transactionDate!)
        : 'Unknown date';

    // Determine colors and icons based on transaction type
    IconData typeIcon;
    Color typeColor;

    switch (transaction.transactionType) {
      case TransactionType.receipt:
        typeIcon = Icons.add_circle;
        typeColor = Colors.green;
        break;
      case TransactionType.issue:
        typeIcon = Icons.remove_circle;
        typeColor = Colors.red;
        break;
      case TransactionType.adjustment:
        typeIcon = Icons.tune;
        typeColor = Colors.orange;
        break;
      case TransactionType.transfer:
        typeIcon = Icons.swap_horiz;
        typeColor = Colors.blue;
        break;
      case TransactionType.return_:
        typeIcon = Icons.assignment_return;
        typeColor = Colors.purple;
        break;
      case TransactionType.count:
        typeIcon = Icons.list_alt;
        typeColor = Colors.teal;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.2),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          '${transaction.materialName} (${transaction.quantity} ${transaction.uom})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(
                'Note: ${transaction.notes}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.transactionType.name.toUpperCase(),
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              transaction.warehouseId,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to transaction details
        },
      ),
    );
  }
}
'@
Set-Content -Path $recentTransactionsListPath -Value $recentTransactionsListContent
Write-Host "Created recent_transactions_list.dart" -ForegroundColor Green

$lowStockAlertCardPath = Join-Path $inventoryDirPath "presentation/widgets/low_stock_alert_card.dart"
$lowStockAlertCardContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/inventory_providers.dart';

class LowStockAlertCard extends ConsumerWidget {
  final String warehouseId;

  const LowStockAlertCard({
    Key? key,
    required this.warehouseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryItemsAsync = ref.watch(inventoryItemsProvider(warehouseId: warehouseId));

    return inventoryItemsAsync.when(
      data: (items) {
        // Filter items with stock at or below reorder point
        final lowStockItems = items
            .where((item) => item.currentStock <= item.reorderPoint)
            .toList();

        if (lowStockItems.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'All items are above reorder levels',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: lowStockItems.map((item) {
            final stockLevel = item.currentStock / item.reorderPoint;
            final double percentage = stockLevel > 1 ? 1.0 : stockLevel;
            
            // Determine the alert level color
            Color alertColor;
            if (item.currentStock <= item.minStockLevel) {
              alertColor = Colors.red;
            } else if (item.currentStock <= item.reorderPoint * 0.5) {
              alertColor = Colors.orange;
            } else {
              alertColor = Colors.amber;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.materialName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: alertColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: alertColor),
                          ),
                          child: Text(
                            'Low Stock',
                            style: TextStyle(
                              color: alertColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${item.currentStock} ${item.uom}'),
                        Text(' / '),
                        Text('${item.reorderPoint} ${item.uom}'),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Reorder'),
                          onPressed: () {
                            // Implement reorder functionality
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(alertColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading inventory: $error'),
      ),
    );
  }
}
'@
Set-Content -Path $lowStockAlertCardPath -Value $lowStockAlertCardContent
Write-Host "Created low_stock_alert_card.dart" -ForegroundColor Green

# Create the stock receive screen
$receiveStockScreenPath = Join-Path $inventoryDirPath "presentation/screens/receive_stock_screen.dart"
$receiveStockScreenContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../domain/providers/inventory_providers.dart';
import '../../data/models/material_model.dart';
import '../../data/models/warehouse_location_model.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  const ReceiveStockScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends ConsumerState<ReceiveStockScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMaterialId;
  String? _selectedMaterialName;
  String? _selectedLocationId;
  final _quantityController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime? _expiryDate;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(String warehouseId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMaterialId == null) {
      setState(() {
        _errorMessage = 'Please select a material';
      });
      return;
    }

    if (_selectedLocationId == null) {
      setState(() {
        _errorMessage = 'Please select a location';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await ref.read(inventoryOperationsProvider.notifier).receiveStock(
            materialId: _selectedMaterialId!,
            materialName: _selectedMaterialName!,
            warehouseId: warehouseId,
            quantity: double.parse(_quantityController.text),
            uom: 'units', // This should be dynamically set based on material
            batchNumber: _batchNumberController.text,
            locationId: _selectedLocationId,
            referenceNumber: _referenceController.text,
            notes: _notesController.text,
          );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock received successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _selectedMaterialId = null;
          _selectedMaterialName = null;
          _selectedLocationId = null;
          _quantityController.clear();
          _batchNumberController.clear();
          _notesController.clear();
          _referenceController.clear();
          _expiryDate = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Stock'),
      ),
      body: userAsync.when(
        data: (user) {
          final warehouseId = user?.warehouseId ?? 'WH001'; // Default warehouse if not assigned

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),

                  // Material selection
                  Text(
                    'Material',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildMaterialDropdown(warehouseId),
                  const SizedBox(height: 16),

                  // Quantity
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Quantity must be greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Batch Number
                  Text(
                    'Batch Number',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _batchNumberController,
                    decoration: const InputDecoration(
                      hintText: 'Enter batch number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a batch number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expiry Date
                  Text(
                    'Expiry Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setState(() {
                          _expiryDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        hintText: 'Select expiry date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _expiryDate == null
                                ? 'Select expiry date'
                                : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location selection
                  Text(
                    'Storage Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildLocationDropdown(warehouseId),
                  const SizedBox(height: 16),

                  // Reference Number
                  Text(
                    'Reference Number',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      hintText: 'Enter PO or reference number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Add notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _submitForm(warehouseId),
                      child: _isProcessing
                          ? const CircularProgressIndicator()
                          : const Text('Submit Receipt'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user information: $error'),
        ),
      ),
    );
  }

  Widget _buildMaterialDropdown(String warehouseId) {
    return Consumer(
      builder: (context, ref, child) {
        final materialsAsync = ref.watch(materialsProvider());

        return materialsAsync.when(
          data: (materials) {
            if (materials.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('No materials found'),
              );
            }

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Select material',
                border: OutlineInputBorder(),
              ),
              value: _selectedMaterialId,
              items: materials.map((material) {
                return DropdownMenuItem<String>(
                  value: material.id,
                  child: Text('${material.materialCode} - ${material.materialName}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final selectedMaterial = materials.firstWhere((m) => m.id == value);
                  setState(() {
                    _selectedMaterialId = value;
                    _selectedMaterialName = selectedMaterial.materialName;
                  });
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading materials: $error'),
        );
      },
    );
  }

  Widget _buildLocationDropdown(String warehouseId) {
    return Consumer(
      builder: (context, ref, child) {
        final locationsAsync = ref.watch(warehouseLocationsProvider(warehouseId));

        return locationsAsync.when(
          data: (locations) {
            if (locations.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('No locations found'),
              );
            }

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Select location',
                border: OutlineInputBorder(),
              ),
              value: _selectedLocationId,
              items: locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location.id,
                  child: Text(location.locationName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocationId = value;
                });
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading locations: $error'),
        );
      },
    );
  }
}
'@
Set-Content -Path $receiveStockScreenPath -Value $receiveStockScreenContent
Write-Host "Created receive_stock_screen.dart" -ForegroundColor Green

# Create issue stock screen
$issueStockScreenPath = Join-Path $inventoryDirPath "presentation/screens/issue_stock_screen.dart"
$issueStockScreenContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../domain/providers/inventory_providers.dart';
import '../../data/models/inventory_item_model.dart';

class IssueStockScreen extends ConsumerStatefulWidget {
  const IssueStockScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IssueStockScreen> createState() => _IssueStockScreenState();
}

class _IssueStockScreenState extends ConsumerState<IssueStockScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedInventoryItemId;
  InventoryItemModel? _selectedInventoryItem;
  String? _selectedLocationId;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  final _referenceTypeController = TextEditingController();
  String? _batchNumber;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _referenceController.dispose();
    _referenceTypeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(String warehouseId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedInventoryItem == null) {
      setState(() {
        _errorMessage = 'Please select an inventory item';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await ref.read(inventoryOperationsProvider.notifier).issueStock(
            materialId: _selectedInventoryItem!.materialId,
            materialName: _selectedInventoryItem!.materialName,
            warehouseId: warehouseId,
            quantity: double.parse(_quantityController.text),
            uom: _selectedInventoryItem!.uom,
            batchNumber: _batchNumber,
            locationId: _selectedLocationId,
            referenceNumber: _referenceController.text,
            referenceType: _referenceTypeController.text,
            notes: _notesController.text,
          );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock issued successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _selectedInventoryItemId = null;
          _selectedInventoryItem = null;
          _selectedLocationId = null;
          _batchNumber = null;
          _quantityController.clear();
          _notesController.clear();
          _referenceController.clear();
          _referenceTypeController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Stock'),
      ),
      body: userAsync.when(
        data: (user) {
          final warehouseId = user?.warehouseId ?? 'WH001'; // Default warehouse if not assigned

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),

                  // Inventory Item selection
                  Text(
                    'Inventory Item',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildInventoryItemDropdown(warehouseId),
                  const SizedBox(height: 16),

                  // Show current stock of selected item
                  if (_selectedInventoryItem != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Stock: ${_selectedInventoryItem!.currentStock} ${_selectedInventoryItem!.uom}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Available: ${_selectedInventoryItem!.availableStock} ${_selectedInventoryItem!.uom}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Batch selection (if item has batches)
                  if (_selectedInventoryItem != null &&
                      _selectedInventoryItem!.batches.isNotEmpty) ...[
                    Text(
                      'Batch Number',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildBatchDropdown(),
                    const SizedBox(height: 16),
                  ],

                  // Location selection (if item has locations)
                  if (_selectedInventoryItem != null &&
                      _selectedInventoryItem!.locations.isNotEmpty) ...[
                    Text(
                      'Storage Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationDropdown(),
                    const SizedBox(height: 16),
                  ],

                  // Quantity
                  Text(
                    'Quantity to Issue',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Quantity must be greater than zero';
                      }
                      if (_selectedInventoryItem != null &&
                          double.parse(value) > _selectedInventoryItem!.availableStock) {
                        return 'Quantity exceeds available stock';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Reference Number
                  Text(
                    'Reference Number',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      hintText: 'Enter order or reference number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reference Type
                  Text(
                    'Reference Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _referenceTypeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Production Order, Sales Order',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Add notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _submitForm(warehouseId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Issue Stock'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user information: $error'),
        ),
      ),
    );
  }

  Widget _buildInventoryItemDropdown(String warehouseId) {
    return Consumer(
      builder: (context, ref, child) {
        final inventoryItemsAsync = ref.watch(inventoryItemsProvider(warehouseId: warehouseId));

        return inventoryItemsAsync.when(
          data: (items) {
            // Filter out items with zero stock
            final availableItems = items.where((item) => item.availableStock > 0).toList();

            if (availableItems.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('No inventory items with stock available'),
              );
            }

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Select inventory item',
                border: OutlineInputBorder(),
              ),
              value: _selectedInventoryItemId,
              items: availableItems.map((item) {
                return DropdownMenuItem<String>(
                  value: item.id,
                  child: Text('${item.materialCode} - ${item.materialName}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final selectedItem = availableItems.firstWhere((item) => item.id == value);
                  setState(() {
                    _selectedInventoryItemId = value;
                    _selectedInventoryItem = selectedItem;
                    _batchNumber = null;
                    _selectedLocationId = null;
                  });
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading inventory items: $error'),
        );
      },
    );
  }

  Widget _buildBatchDropdown() {
    if (_selectedInventoryItem == null || _selectedInventoryItem!.batches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('No batches available'),
      );
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        hintText: 'Select batch',
        border: OutlineInputBorder(),
      ),
      value: _batchNumber,
      items: _selectedInventoryItem!.batches.map((batch) {
        final expiryInfo = batch.expiryDate != null
            ? ' (Expires: ${batch.expiryDate!.day}/${batch.expiryDate!.month}/${batch.expiryDate!.year})'
            : '';
        return DropdownMenuItem<String>(
          value: batch.batchNumber,
          child: Text('${batch.batchNumber} - ${batch.quantity} ${_selectedInventoryItem!.uom}$expiryInfo'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _batchNumber = value;
        });
      },
    );
  }

  Widget _buildLocationDropdown() {
    if (_selectedInventoryItem == null || _selectedInventoryItem!.locations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('No locations available'),
      );
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        hintText: 'Select location',
        border: OutlineInputBorder(),
      ),
      value: _selectedLocationId,
      items: _selectedInventoryItem!.locations.map((location) {
        return DropdownMenuItem<String>(
          value: location.locationId,
          child: Text('${location.locationName} - ${location.quantity} ${_selectedInventoryItem!.uom}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLocationId = value;
        });
      },
    );
  }
}
'@
Set-Content -Path $issueStockScreenPath -Value $issueStockScreenContent
Write-Host "Created issue_stock_screen.dart" -ForegroundColor Green

# Update the app's router to include inventory routes
$routerPath = Join-Path $libDir "core/utils/router.dart"
if (Test-Path $routerPath) {
    $routerContent = Get-Content $routerPath -Raw
    if (-not ($routerContent -match "inventory/dashboard")) {
        $updatedRouterContent = $routerContent -replace "GoRoute\(\s+path: '/warehouse/dashboard',", @"
GoRoute(
        path: '/inventory/dashboard',
        builder: (context, state) => const InventoryDashboardScreen(),
      ),
      GoRoute(
        path: '/inventory/receive',
        builder: (context, state) => const ReceiveStockScreen(),
      ),
      GoRoute(
        path: '/inventory/issue',
        builder: (context, state) => const IssueStockScreen(),
      ),
      GoRoute(
        path: '/warehouse/dashboard',
"@
        Set-Content -Path $routerPath -Value $updatedRouterContent
        Write-Host "Updated router.dart with inventory routes" -ForegroundColor Green
    }
}

# Update the imports in the router file
$routerImportsToAdd = @(
    "import '../../../features/inventory/presentation/screens/inventory_dashboard_screen.dart';",
    "import '../../../features/inventory/presentation/screens/receive_stock_screen.dart';",
    "import '../../../features/inventory/presentation/screens/issue_stock_screen.dart';"
)

if (Test-Path $routerPath) {
    $routerContent = Get-Content $routerPath -Raw
    $importSection = $routerContent -match "import.*?;"
    
    foreach ($import in $routerImportsToAdd) {
        if (-not ($routerContent -match [regex]::Escape($import))) {
            # Find position after last import statement
            $lastImportPosition = $routerContent.LastIndexOf(';', $routerContent.IndexOf('part '))
            $updatedRouterContent = $routerContent.Insert($lastImportPosition + 1, "`n$import")
            Set-Content -Path $routerPath -Value $updatedRouterContent
            $routerContent = $updatedRouterContent  # Update for next iteration
            Write-Host "Added import for $import" -ForegroundColor Green
        }
    }
}

# Run build_runner to generate Riverpod code
Write-Host "Running build_runner to generate code for the inventory module..." -ForegroundColor Yellow
Start-Process -FilePath "flutter" -ArgumentList "pub run build_runner build --delete-conflicting-outputs" -NoNewWindow -Wait

# Success message
Write-Host "`nInventory Management Module has been successfully created for your UND app!" -ForegroundColor Cyan
Write-Host "The module includes:" -ForegroundColor Cyan
Write-Host "1. Data models for inventory items, transactions, warehouse locations, and materials" -ForegroundColor White
Write-Host "2. Repository for database operations" -ForegroundColor White
Write-Host "3. Riverpod providers for state management" -ForegroundColor White
Write-Host "4. UI screens for inventory dashboard, receiving stock, and issuing stock" -ForegroundColor White
Write-Host "5. Reusable widgets for inventory management" -ForegroundColor White
Write-Host "6. Integration with the app's routing system" -ForegroundColor White

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Review and customize the UI components to match your design requirements" -ForegroundColor White
Write-Host "2. Implement additional inventory features like stock counts, transfers, and adjustments" -ForegroundColor White
Write-Host "3. Connect to your actual Firebase backend by updating the firebase_options.dart file" -ForegroundColor White
Write-Host "4. Test the inventory workflow with real data" -ForegroundColor White