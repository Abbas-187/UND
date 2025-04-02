# PowerShell Script to Create Warehouse Operations Module for UND App

This script creates a comprehensive warehouse operations module for your UND app, following clean architecture principles with Riverpod for state management. The module will handle goods receipt, goods issue, inventory transfers, and stock counting operations.

```powershell
# PowerShell script to create Warehouse Operations Module for UND App

# Define the base directory (current directory)
$baseDir = Get-Location
$libDir = Join-Path $baseDir "lib"

Write-Host "Creating Warehouse Operations Module for UND App..." -ForegroundColor Cyan

# Create warehouse operations module structure
$warehouseDirPath = Join-Path $libDir "features/warehouse_operations"
if (-not (Test-Path $warehouseDirPath)) {
    New-Item -Path $warehouseDirPath -ItemType Directory -Force | Out-Null
    Write-Host "Created 'features/warehouse_operations' directory" -ForegroundColor Green
}

# Create subdirectories for the warehouse operations module
$warehouseSubDirs = @(
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
    "presentation/screens/goods_receipt",
    "presentation/screens/goods_issue",
    "presentation/screens/inventory_transfer",
    "presentation/screens/stock_count",
    "presentation/widgets"
)

foreach ($dir in $warehouseSubDirs) {
    $newDir = Join-Path $warehouseDirPath $dir
    if (-not (Test-Path $newDir)) {
        New-Item -Path $newDir -ItemType Directory -Force | Out-Null
        Write-Host "Created 'features/warehouse_operations/$dir' directory" -ForegroundColor Green
    }
}

#------------------------------------------------------------------------------
# DATA LAYER
#------------------------------------------------------------------------------

# 1. Create warehouse operation models
$goodsReceiptModelPath = Join-Path $warehouseDirPath "data/models/goods_receipt_model.dart"
$goodsReceiptModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goods_receipt_model.freezed.dart';
part 'goods_receipt_model.g.dart';

/// Represents a goods receipt transaction in the warehouse
@freezed
class GoodsReceiptModel with _$GoodsReceiptModel {
  const factory GoodsReceiptModel({
    String? id,
    required String documentNumber,
    required DateTime receiptDate,
    required String supplierName,
    String? supplierReference,
    required String warehouseId,
    required String receivedByUserId,
    String? remarks,
    required List<GoodsReceiptItemModel> items,
    @Default(false) bool isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    @Default('draft') String status,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
  }) = _GoodsReceiptModel;

  factory GoodsReceiptModel.fromJson(Map<String, dynamic> json) => 
      _$GoodsReceiptModelFromJson(json);
      
  factory GoodsReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoodsReceiptModel.fromJson({
      'id': doc.id,
      ...data,
      'receiptDate': (data['receiptDate'] as Timestamp).toDate(),
      'postedDate': data['postedDate'] != null 
          ? (data['postedDate'] as Timestamp).toDate() 
          : null,
      'createdAt': data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      'updatedAt': data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    });
  }
}

/// Represents an item in a goods receipt transaction
@freezed
class GoodsReceiptItemModel with _$GoodsReceiptItemModel {
  const factory GoodsReceiptItemModel({
    required String itemId,
    required String itemCode,
    required String itemName,
    required double quantity,
    required String unitOfMeasure,
    String? batchNumber,
    DateTime? expiryDate,
    String? locationId,
    String? remarks,
    Map<String, dynamic>? customAttributes,
  }) = _GoodsReceiptItemModel;

  factory GoodsReceiptItemModel.fromJson(Map<String, dynamic> json) => 
      _$GoodsReceiptItemModelFromJson(json);
}
'@
Set-Content -Path $goodsReceiptModelPath -Value $goodsReceiptModelContent -NoNewline
Write-Host "Created goods_receipt_model.dart" -ForegroundColor Green

$goodsIssueModelPath = Join-Path $warehouseDirPath "data/models/goods_issue_model.dart"
$goodsIssueModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goods_issue_model.freezed.dart';
part 'goods_issue_model.g.dart';

/// Represents a goods issue transaction in the warehouse
@freezed
class GoodsIssueModel with _$GoodsIssueModel {
  const factory GoodsIssueModel({
    String? id,
    required String documentNumber,
    required DateTime issueDate,
    required String requestedByDepartment,
    String? requestReference,
    required String warehouseId,
    required String issuedByUserId,
    String? remarks,
    required List<GoodsIssueItemModel> items,
    @Default(false) bool isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    @Default('draft') String status,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
  }) = _GoodsIssueModel;

  factory GoodsIssueModel.fromJson(Map<String, dynamic> json) => 
      _$GoodsIssueModelFromJson(json);
      
  factory GoodsIssueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoodsIssueModel.fromJson({
      'id': doc.id,
      ...data,
      'issueDate': (data['issueDate'] as Timestamp).toDate(),
      'postedDate': data['postedDate'] != null 
          ? (data['postedDate'] as Timestamp).toDate() 
          : null,
      'createdAt': data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      'updatedAt': data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    });
  }
}

/// Represents an item in a goods issue transaction
@freezed
class GoodsIssueItemModel with _$GoodsIssueItemModel {
  const factory GoodsIssueItemModel({
    required String itemId,
    required String itemCode,
    required String itemName,
    required double quantity,
    required String unitOfMeasure,
    String? batchNumber,
    String? locationId,
    String? remarks,
    Map<String, dynamic>? customAttributes,
  }) = _GoodsIssueItemModel;

  factory GoodsIssueItemModel.fromJson(Map<String, dynamic> json) => 
      _$GoodsIssueItemModelFromJson(json);
}
'@
Set-Content -Path $goodsIssueModelPath -Value $goodsIssueModelContent -NoNewline
Write-Host "Created goods_issue_model.dart" -ForegroundColor Green

$inventoryTransferModelPath = Join-Path $warehouseDirPath "data/models/inventory_transfer_model.dart"
$inventoryTransferModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_transfer_model.freezed.dart';
part 'inventory_transfer_model.g.dart';

/// Represents an inventory transfer transaction between locations
@freezed
class InventoryTransferModel with _$InventoryTransferModel {
  const factory InventoryTransferModel({
    String? id,
    required String documentNumber,
    required DateTime transferDate,
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required String transferredByUserId,
    String? remarks,
    required List<InventoryTransferItemModel> items,
    @Default(false) bool isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    @Default('draft') String status,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
  }) = _InventoryTransferModel;

  factory InventoryTransferModel.fromJson(Map<String, dynamic> json) => 
      _$InventoryTransferModelFromJson(json);
      
  factory InventoryTransferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryTransferModel.fromJson({
      'id': doc.id,
      ...data,
      'transferDate': (data['transferDate'] as Timestamp).toDate(),
      'postedDate': data['postedDate'] != null 
          ? (data['postedDate'] as Timestamp).toDate() 
          : null,
      'createdAt': data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      'updatedAt': data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    });
  }
}

/// Represents an item in an inventory transfer transaction
@freezed
class InventoryTransferItemModel with _$InventoryTransferItemModel {
  const factory InventoryTransferItemModel({
    required String itemId,
    required String itemCode,
    required String itemName,
    required double quantity,
    required String unitOfMeasure,
    String? batchNumber,
    required String sourceLocationId,
    required String destinationLocationId,
    String? remarks,
    Map<String, dynamic>? customAttributes,
  }) = _InventoryTransferItemModel;

  factory InventoryTransferItemModel.fromJson(Map<String, dynamic> json) => 
      _$InventoryTransferItemModelFromJson(json);
}
'@
Set-Content -Path $inventoryTransferModelPath -Value $inventoryTransferModelContent -NoNewline
Write-Host "Created inventory_transfer_model.dart" -ForegroundColor Green

$stockCountModelPath = Join-Path $warehouseDirPath "data/models/stock_count_model.dart"
$stockCountModelContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_count_model.freezed.dart';
part 'stock_count_model.g.dart';

/// Represents a stock counting operation in the warehouse
@freezed
class StockCountModel with _$StockCountModel {
  const factory StockCountModel({
    String? id,
    required String documentNumber,
    required DateTime countDate,
    required String warehouseId,
    String? locationId,
    required String countedByUserId,
    String? remarks,
    required List<StockCountItemModel> items,
    @Default(false) bool isPosted,
    DateTime? postedDate,
    String? postedByUserId,
    required String countType, // 'cycle', 'full', 'spot'
    @Default('draft') String status,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
  }) = _StockCountModel;

  factory StockCountModel.fromJson(Map<String, dynamic> json) => 
      _$StockCountModelFromJson(json);
      
  factory StockCountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockCountModel.fromJson({
      'id': doc.id,
      ...data,
      'countDate': (data['countDate'] as Timestamp).toDate(),
      'postedDate': data['postedDate'] != null 
          ? (data['postedDate'] as Timestamp).toDate() 
          : null,
      'createdAt': data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      'updatedAt': data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    });
  }
}

/// Represents an item in a stock counting operation
@freezed
class StockCountItemModel with _$StockCountItemModel {
  const factory StockCountItemModel({
    required String itemId,
    required String itemCode,
    required String itemName,
    required double systemQuantity,
    required double countedQuantity,
    required double variance,
    required String unitOfMeasure,
    String? batchNumber,
    String? locationId,
    String? remarks,
    String? adjustmentReason,
    Map<String, dynamic>? customAttributes,
  }) = _StockCountItemModel;

  factory StockCountItemModel.fromJson(Map<String, dynamic> json) => 
      _$StockCountItemModelFromJson(json);
}
'@
Set-Content -Path $stockCountModelPath -Value $stockCountModelContent -NoNewline
Write-Host "Created stock_count_model.dart" -ForegroundColor Green

# 2. Create warehouse operations repository
$warehouseRepoPath = Join-Path $warehouseDirPath "data/repositories/warehouse_operations_repository_impl.dart"
$warehouseRepoContent = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/warehouse_operations_exception.dart';
import '../models/goods_receipt_model.dart';
import '../models/goods_issue_model.dart';
import '../models/inventory_transfer_model.dart';
import '../models/stock_count_model.dart';
import '../../domain/repositories/warehouse_operations_repository.dart';

part 'warehouse_operations_repository_impl.g.dart';

class WarehouseOperationsRepositoryImpl implements WarehouseOperationsRepository {
  final FirebaseFirestore _firestore;

  WarehouseOperationsRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collections
  CollectionReference<Map<String, dynamic>> get _goodsReceiptCollection => 
      _firestore.collection('goods_receipts');
  
  CollectionReference<Map<String, dynamic>> get _goodsIssueCollection => 
      _firestore.collection('goods_issues');
  
  CollectionReference<Map<String, dynamic>> get _inventoryTransferCollection => 
      _firestore.collection('inventory_transfers');
  
  CollectionReference<Map<String, dynamic>> get _stockCountCollection => 
      _firestore.collection('stock_counts');

  // Goods Receipt Operations
  @override
  Future<List<GoodsReceiptModel>> getAllGoodsReceipts() async {
    try {
      final snapshot = await _goodsReceiptCollection
          .orderBy('receiptDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => GoodsReceiptModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to fetch goods receipts: ${e.toString()}',
      );
    }
  }

  @override
  Future<GoodsReceiptModel> getGoodsReceiptById(String id) async {
    try {
      final docSnapshot = await _goodsReceiptCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        throw WarehouseOperationsException('Goods receipt not found');
      }
      
      return GoodsReceiptModel.fromFirestore(docSnapshot);
    } catch (e) {
      if (e is WarehouseOperationsException) {
        rethrow;
      }
      throw WarehouseOperationsException(
        'Failed to fetch goods receipt: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> createGoodsReceipt(GoodsReceiptModel goodsReceipt) async {
    try {
      final now = DateTime.now();
      final data = goodsReceipt.toJson();
      
      // Add created timestamp
      data['createdAt'] = now;
      data['updatedAt'] = now;
      
      // Generate document number if not provided
      if (data['documentNumber'] == null || data['documentNumber'].isEmpty) {
        final timestamp = now.millisecondsSinceEpoch.toString();
        data['documentNumber'] = 'GR-${timestamp.substring(timestamp.length - 8)}';
      }
      
      final docRef = await _goodsReceiptCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to create goods receipt: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateGoodsReceipt(GoodsReceiptModel goodsReceipt) async {
    try {
      if (goodsReceipt.id == null) {
        throw WarehouseOperationsException('Goods receipt ID cannot be null');
      }
      
      final data = goodsReceipt.toJson();
      data['updatedAt'] = DateTime.now();
      
      await _goodsReceiptCollection.doc(goodsReceipt.id).update(data);
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to update goods receipt: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> postGoodsReceipt(String id, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _goodsReceiptCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);
        
        if (!docSnapshot.exists) {
          throw WarehouseOperationsException('Goods receipt not found');
        }
        
        final data = docSnapshot.data()!;
        if (data['isPosted'] == true) {
          throw WarehouseOperationsException('Goods receipt is already posted');
        }
        
        transaction.update(docRef, {
          'isPosted': true,
          'postedDate': DateTime.now(),
          'postedByUserId': userId,
          'status': 'posted',
          'updatedAt': DateTime.now(),
        });
        
        // TODO: Update inventory levels (implement in inventory service)
      });
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to post goods receipt: ${e.toString()}',
      );
    }
  }

  // Goods Issue Operations
  @override
  Future<List<GoodsIssueModel>> getAllGoodsIssues() async {
    try {
      final snapshot = await _goodsIssueCollection
          .orderBy('issueDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => GoodsIssueModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to fetch goods issues: ${e.toString()}',
      );
    }
  }

  @override
  Future<GoodsIssueModel> getGoodsIssueById(String id) async {
    try {
      final docSnapshot = await _goodsIssueCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        throw WarehouseOperationsException('Goods issue not found');
      }
      
      return GoodsIssueModel.fromFirestore(docSnapshot);
    } catch (e) {
      if (e is WarehouseOperationsException) {
        rethrow;
      }
      throw WarehouseOperationsException(
        'Failed to fetch goods issue: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> createGoodsIssue(GoodsIssueModel goodsIssue) async {
    try {
      final now = DateTime.now();
      final data = goodsIssue.toJson();
      
      // Add created timestamp
      data['createdAt'] = now;
      data['updatedAt'] = now;
      
      // Generate document number if not provided
      if (data['documentNumber'] == null || data['documentNumber'].isEmpty) {
        final timestamp = now.millisecondsSinceEpoch.toString();
        data['documentNumber'] = 'GI-${timestamp.substring(timestamp.length - 8)}';
      }
      
      final docRef = await _goodsIssueCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to create goods issue: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateGoodsIssue(GoodsIssueModel goodsIssue) async {
    try {
      if (goodsIssue.id == null) {
        throw WarehouseOperationsException('Goods issue ID cannot be null');
      }
      
      final data = goodsIssue.toJson();
      data['updatedAt'] = DateTime.now();
      
      await _goodsIssueCollection.doc(goodsIssue.id).update(data);
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to update goods issue: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> postGoodsIssue(String id, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _goodsIssueCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);
        
        if (!docSnapshot.exists) {
          throw WarehouseOperationsException('Goods issue not found');
        }
        
        final data = docSnapshot.data()!;
        if (data['isPosted'] == true) {
          throw WarehouseOperationsException('Goods issue is already posted');
        }
        
        transaction.update(docRef, {
          'isPosted': true,
          'postedDate': DateTime.now(),
          'postedByUserId': userId,
          'status': 'posted',
          'updatedAt': DateTime.now(),
        });
        
        // TODO: Update inventory levels (implement in inventory service)
      });
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to post goods issue: ${e.toString()}',
      );
    }
  }

  // Inventory Transfer Operations
  @override
  Future<List<InventoryTransferModel>> getAllInventoryTransfers() async {
    try {
      final snapshot = await _inventoryTransferCollection
          .orderBy('transferDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => InventoryTransferModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to fetch inventory transfers: ${e.toString()}',
      );
    }
  }

  @override
  Future<InventoryTransferModel> getInventoryTransferById(String id) async {
    try {
      final docSnapshot = await _inventoryTransferCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        throw WarehouseOperationsException('Inventory transfer not found');
      }
      
      return InventoryTransferModel.fromFirestore(docSnapshot);
    } catch (e) {
      if (e is WarehouseOperationsException) {
        rethrow;
      }
      throw WarehouseOperationsException(
        'Failed to fetch inventory transfer: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> createInventoryTransfer(InventoryTransferModel inventoryTransfer) async {
    try {
      final now = DateTime.now();
      final data = inventoryTransfer.toJson();
      
      // Add created timestamp
      data['createdAt'] = now;
      data['updatedAt'] = now;
      
      // Generate document number if not provided
      if (data['documentNumber'] == null || data['documentNumber'].isEmpty) {
        final timestamp = now.millisecondsSinceEpoch.toString();
        data['documentNumber'] = 'IT-${timestamp.substring(timestamp.length - 8)}';
      }
      
      final docRef = await _inventoryTransferCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to create inventory transfer: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateInventoryTransfer(InventoryTransferModel inventoryTransfer) async {
    try {
      if (inventoryTransfer.id == null) {
        throw WarehouseOperationsException('Inventory transfer ID cannot be null');
      }
      
      final data = inventoryTransfer.toJson();
      data['updatedAt'] = DateTime.now();
      
      await _inventoryTransferCollection.doc(inventoryTransfer.id).update(data);
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to update inventory transfer: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> postInventoryTransfer(String id, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _inventoryTransferCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);
        
        if (!docSnapshot.exists) {
          throw WarehouseOperationsException('Inventory transfer not found');
        }
        
        final data = docSnapshot.data()!;
        if (data['isPosted'] == true) {
          throw WarehouseOperationsException('Inventory transfer is already posted');
        }
        
        transaction.update(docRef, {
          'isPosted': true,
          'postedDate': DateTime.now(),
          'postedByUserId': userId,
          'status': 'posted',
          'updatedAt': DateTime.now(),
        });
        
        // TODO: Update inventory levels (implement in inventory service)
      });
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to post inventory transfer: ${e.toString()}',
      );
    }
  }

  // Stock Count Operations
  @override
  Future<List<StockCountModel>> getAllStockCounts() async {
    try {
      final snapshot = await _stockCountCollection
          .orderBy('countDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => StockCountModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to fetch stock counts: ${e.toString()}',
      );
    }
  }

  @override
  Future<StockCountModel> getStockCountById(String id) async {
    try {
      final docSnapshot = await _stockCountCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        throw WarehouseOperationsException('Stock count not found');
      }
      
      return StockCountModel.fromFirestore(docSnapshot);
    } catch (e) {
      if (e is WarehouseOperationsException) {
        rethrow;
      }
      throw WarehouseOperationsException(
        'Failed to fetch stock count: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> createStockCount(StockCountModel stockCount) async {
    try {
      final now = DateTime.now();
      final data = stockCount.toJson();
      
      // Add created timestamp
      data['createdAt'] = now;
      data['updatedAt'] = now;
      
      // Generate document number if not provided
      if (data['documentNumber'] == null || data['documentNumber'].isEmpty) {
        final timestamp = now.millisecondsSinceEpoch.toString();
        data['documentNumber'] = 'SC-${timestamp.substring(timestamp.length - 8)}';
      }
      
      final docRef = await _stockCountCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to create stock count: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateStockCount(StockCountModel stockCount) async {
    try {
      if (stockCount.id == null) {
        throw WarehouseOperationsException('Stock count ID cannot be null');
      }
      
      final data = stockCount.toJson();
      data['updatedAt'] = DateTime.now();
      
      await _stockCountCollection.doc(stockCount.id).update(data);
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to update stock count: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> postStockCount(String id, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _stockCountCollection.doc(id);
        final docSnapshot = await transaction.get(docRef);
        
        if (!docSnapshot.exists) {
          throw WarehouseOperationsException('Stock count not found');
        }
        
        final data = docSnapshot.data()!;
        if (data['isPosted'] == true) {
          throw WarehouseOperationsException('Stock count is already posted');
        }
        
        transaction.update(docRef, {
          'isPosted': true,
          'postedDate': DateTime.now(),
          'postedByUserId': userId,
          'status': 'posted',
          'updatedAt': DateTime.now(),
        });
        
        // TODO: Update inventory levels (implement in inventory service)
      });
    } catch (e) {
      throw WarehouseOperationsException(
        'Failed to post stock count: ${e.toString()}',
      );
    }
  }
}

@riverpod
WarehouseOperationsRepository warehouseOperationsRepository(
    WarehouseOperationsRepositoryRef ref) {
  return WarehouseOperationsRepositoryImpl();
}
'@
Set-Content -Path $warehouseRepoPath -Value $warehouseRepoContent -NoNewline
Write-Host "Created warehouse_operations_repository_impl.dart" -ForegroundColor Green

#------------------------------------------------------------------------------
# DOMAIN LAYER
#------------------------------------------------------------------------------

# 1. Create the repository interface
$warehouseRepoInterfacePath = Join-Path $warehouseDirPath "domain/repositories/warehouse_operations_repository.dart"
$warehouseRepoInterfaceContent = @'
import '../../data/models/goods_receipt_model.dart';
import '../../data/models/goods_issue_model.dart';
import '../../data/models/inventory_transfer_model.dart';
import '../../data/models/stock_count_model.dart';

abstract class WarehouseOperationsRepository {
  // Goods Receipt Operations
  Future<List<GoodsReceiptModel>> getAllGoodsReceipts();
  Future<GoodsReceiptModel> getGoodsReceiptById(String id);
  Future<String> createGoodsReceipt(GoodsReceiptModel goodsReceipt);
  Future<void> updateGoodsReceipt(GoodsReceiptModel goodsReceipt);
  Future<void> postGoodsReceipt(String id, String userId);

  // Goods Issue Operations
  Future<List<GoodsIssueModel>> getAllGoodsIssues();
  Future<GoodsIssueModel> getGoodsIssueById(String id);
  Future<String> createGoodsIssue(GoodsIssueModel goodsIssue);
  Future<void> updateGoodsIssue(GoodsIssueModel goodsIssue);
  Future<void> postGoodsIssue(String id, String userId);

  // Inventory Transfer Operations
  Future<List<InventoryTransferModel>> getAllInventoryTransfers();
  Future<InventoryTransferModel> getInventoryTransferById(String id);
  Future<String> createInventoryTransfer(InventoryTransferModel inventoryTransfer);
  Future<void> updateInventoryTransfer(InventoryTransferModel inventoryTransfer);
  Future<void> postInventoryTransfer(String id, String userId);

  // Stock Count Operations
  Future<List<StockCountModel>> getAllStockCounts();
  Future<StockCountModel> getStockCountById(String id);
  Future<String> createStockCount(StockCountModel stockCount);
  Future<void> updateStockCount(StockCountModel stockCount);
  Future<void> postStockCount(String id, String userId);
}
'@
$warehouseRepoInterfaceDir = Join-Path $warehouseDirPath "domain/repositories"
if (-not (Test-Path $warehouseRepoInterfaceDir)) {
    New-Item -Path $warehouseRepoInterfaceDir -ItemType Directory -Force | Out-Null
}
Set-Content -Path $warehouseRepoInterfacePath -Value $warehouseRepoInterfaceContent -NoNewline
Write-Host "Created warehouse_operations_repository.dart" -ForegroundColor Green

# 2. Create exception class
$exceptionPath = Join-Path $warehouseDirPath "domain/entities/warehouse_operations_exception.dart" 
$exceptionContent = @'
/// Exception thrown when warehouse operations fail
class WarehouseOperationsException implements Exception {
  final String message;
  final dynamic originalError;

  WarehouseOperationsException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'WarehouseOperationsException: $message (Original error: $originalError)';
    }
    return 'WarehouseOperationsException: $message';
  }
}
'@
$exceptionDir = Join-Path $warehouseDirPath "domain/entities"
if (-not (Test-Path $exceptionDir)) {
    New-Item -Path $exceptionDir -ItemType Directory -Force | Out-Null
}
Set-Content -Path $exceptionPath -Value $exceptionContent -NoNewline
Write-Host "Created warehouse_operations_exception.dart" -ForegroundColor Green

# 3. Create the providers
$providersPath = Join-Path $warehouseDirPath "domain/providers/warehouse_operations_providers.dart"
$providersContent = @'
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/goods_receipt_model.dart';
import '../../data/models/goods_issue_model.dart';
import '../../data/models/inventory_transfer_model.dart';
import '../../data/models/stock_count_model.dart';
import '../repositories/warehouse_operations_repository.dart';
import '../../data/repositories/warehouse_operations_repository_impl.dart';

part 'warehouse_operations_providers.g.dart';

// Goods Receipt Providers
@riverpod
Future<List<GoodsReceiptModel>> goodsReceipts(GoodsReceiptsRef ref) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getAllGoodsReceipts();
}

@riverpod
Future<GoodsReceiptModel> goodsReceiptDetails(
  GoodsReceiptDetailsRef ref, 
  String id,
) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getGoodsReceiptById(id);
}

// Goods Issue Providers
@riverpod
Future<List<GoodsIssueModel>> goodsIssues(GoodsIssuesRef ref) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getAllGoodsIssues();
}

@riverpod
Future<GoodsIssueModel> goodsIssueDetails(
  GoodsIssueDetailsRef ref, 
  String id,
) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getGoodsIssueById(id);
}

// Inventory Transfer Providers
@riverpod
Future<List<InventoryTransferModel>> inventoryTransfers(InventoryTransfersRef ref) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getAllInventoryTransfers();
}

@riverpod
Future<InventoryTransferModel> inventoryTransferDetails(
  InventoryTransferDetailsRef ref, 
  String id,
) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getInventoryTransferById(id);
}

// Stock Count Providers
@riverpod
Future<List<StockCountModel>> stockCounts(StockCountsRef ref) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getAllStockCounts();
}

@riverpod
Future<StockCountModel> stockCountDetails(
  StockCountDetailsRef ref, 
  String id,
) {
  final repository = ref.watch(warehouseOperationsRepositoryProvider);
  return repository.getStockCountById(id);
}
'@
$providersDir = Join-Path $warehouseDirPath "domain/providers"
if (-not (Test-Path $providersDir)) {
    New-Item -Path $providersDir -ItemType Directory -Force | Out-Null
}
Set-Content -Path $providersPath -Value $providersContent -NoNewline
Write-Host "Created warehouse_operations_providers.dart" -ForegroundColor Green

#------------------------------------------------------------------------------
# PRESENTATION LAYER
#------------------------------------------------------------------------------

# 1. Create warehouse operations dashboard screen
$dashboardScreenPath = Join-Path $warehouseDirPath "presentation/screens/warehouse_operations_dashboard.dart"
$dashboardScreenContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/warehouse_operation_card.dart';

class WarehouseOperationsDashboard extends ConsumerWidget {
  const WarehouseOperationsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Operations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Warehouse Operations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Main operations grid
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                WarehouseOperationCard(
                  title: 'Goods Receipt',
                  icon: Icons.move_to_inbox,
                  color: Colors.green.shade700,
                  onTap: () => Navigator.pushNamed(
                    context, 
                    '/warehouse-operations/goods-receipts',
                  ),
                ),
                WarehouseOperationCard(
                  title: 'Goods Issue',
                  icon: Icons.outbox,
                  color: Colors.red.shade700,
                  onTap: () => Navigator.pushNamed(
                    context, 
                    '/warehouse-operations/goods-issues',
                  ),
                ),
                WarehouseOperationCard(
                  title: 'Inventory Transfer',
                  icon: Icons.compare_arrows,
                  color: Colors.blue.shade700,
                  onTap: () => Navigator.pushNamed(
                    context, 
                    '/warehouse-operations/inventory-transfers',
                  ),
                ),
                WarehouseOperationCard(
                  title: 'Stock Count',
                  icon: Icons.inventory_2,
                  color: Colors.amber.shade700,
                  onTap: () => Navigator.pushNamed(
                    context, 
                    '/warehouse-operations/stock-counts',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Placeholder for recent activities
            // To be implemented with actual data fetching
            Card(
              elevation: 2,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Activity ${5 - index}'),
                    subtitle: Text('Details about the activity ${5 - index}'),
                    trailing: Text(
                      '${DateTime.now().subtract(Duration(hours: index * 3)).day}/${DateTime.now().subtract(Duration(hours: index * 3)).month}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.move_to_inbox),
                    title: const Text('New Goods Receipt'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context, 
                        '/warehouse-operations/goods-receipts/new',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.outbox),
                    title: const Text('New Goods Issue'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context, 
                        '/warehouse-operations/goods-issues/new',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.compare_arrows),
                    title: const Text('New Inventory Transfer'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context, 
                        '/warehouse-operations/inventory-transfers/new',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: const Text('New Stock Count'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context, 
                        '/warehouse-operations/stock-counts/new',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
'@
Set-Content -Path $dashboardScreenPath -Value $dashboardScreenContent -NoNewline
Write-Host "Created warehouse_operations_dashboard.dart" -ForegroundColor Green

# 2. Create the warehouse operation card widget
$operationCardPath = Join-Path $warehouseDirPath "presentation/widgets/warehouse_operation_card.dart"
$operationCardContent = @'
import 'package:flutter/material.dart';

class WarehouseOperationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;

  const WarehouseOperationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
'@
Set-Content -Path $operationCardPath -Value $operationCardContent -NoNewline
Write-Host "Created warehouse_operation_card.dart" -ForegroundColor Green

# 3. Create goods receipt list screen
$goodsReceiptListPath = Join-Path $warehouseDirPath "presentation/screens/goods_receipt/goods_receipt_list_screen.dart"
$goodsReceiptListContent = @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/warehouse_operations_providers.dart';

class GoodsReceiptListScreen extends ConsumerWidget {
  const GoodsReceiptListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goodsReceiptsAsync = ref.watch(goodsReceiptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goods Receipts'),
      ),
      body: goodsReceiptsAsync.when(
        data: (goodsReceipts) {
          if (goodsReceipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No goods receipts found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/warehouse-operations/goods-receipts/new',
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: goodsReceipts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final receipt = goodsReceipts[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    receipt.documentNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From: ${receipt.supplierName}'),
                      Text(
                        'Date: ${receipt.receiptDate.day}/${receipt.receiptDate.month}/${receipt.receiptDate.year}',
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      receipt.isPosted ? 'Posted' : 'Draft',
                      style: TextStyle(
                        color: receipt.isPosted ? Colors.white : Colors.black87,
                      ),
                    ),
                    backgroundColor: receipt.isPosted
                        ? Colors.green.shade700
                        : Colors.amber.shade300,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/warehouse-operations/goods-receipts/${receipt.id}',
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading goods receipts',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(goodsReceiptsProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/warehouse-operations/goods-receipts/new',
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
'@
$goodsReceiptDir = Join-Path $warehouseDirPath "presentation/screens/goods_receipt"
if (-not (Test-Path $goodsReceiptDir)) {
    New-Item -Path $goodsReceiptDir -ItemType Directory -Force | Out-Null
}
Set-Content -Path $goodsReceiptListPath -Value $goodsReceiptListContent -NoNewline
Write-Host "Created goods_receipt_list_screen.dart" -ForegroundColor Green

# Done
Write-Host ""
Write-Host "Warehouse Operations Module created successfully!" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run 'flutter pub run build_runner build --delete-conflicting-outputs' to generate the freezed and riverpod code" -ForegroundColor Yellow
Write-Host "2. Update your app's router to include the warehouse operations routes" -ForegroundColor Yellow
Write-Host "3. Complete the UI implementation of the remaining screens" -ForegroundColor Yellow
Write-Host "4. Test the module's functionality with Firebase" -ForegroundColor Yellow