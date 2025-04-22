import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/inventory/data/models/inventory_item_model.dart'
    hide QualityStatus;
import '../../features/inventory/data/models/inventory_location_model.dart';
import '../../features/inventory/data/models/inventory_movement_type.dart';
import '../../features/inventory/data/models/inventory_movement_model.dart';
import '../../features/inventory/data/models/inventory_movement_item_model.dart';
import '../../features/inventory/data/models/quality_status.dart';
import '../../features/analytics/data/mock_analytics_data.dart';
import 'dart:math' as math;
import '../../features/factory/equipment_maintenance/data/models/equipment_model.dart';
import '../../features/factory/equipment_maintenance/data/models/maintenance_record_model.dart';
import '../../features/factory/equipment_maintenance/data/models/maintenance_models.dart';

/// Global singleton service to provide centralized mock data
/// This ensures mock data is synchronized between all modules
class MockDataService {
  // Singleton pattern implementation
  static final MockDataService _instance = MockDataService._internal();

  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();

  // Mock inventory items - shared across inventory features and modules
  final List<InventoryItemModel> inventoryItems = [
    // Milk and Dairy Products
    InventoryItemModel(
      id: 'inv-001',
      name: 'Camel Milk (حليب الإبل)',
      category: 'Dairy',
      unit: 'Liters',
      quantity: 1200.0,
      minimumQuantity: 300.0,
      reorderPoint: 500.0,
      location: 'Cold Storage A',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
      batchNumber: 'BATCH001',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      cost: 6.5,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: null,
      fatContent: 3.5,
      pasteurized: true,
      searchTerms: ['milk', 'camel', 'dairy', 'حليب', 'إبل'],
      additionalAttributes: {
        'source': 'Najdi Camel Farm',
        'organicCertified': true,
        'region': 'Riyadh Province',
      },
    ),
    InventoryItemModel(
      id: 'inv-002',
      name: 'Laban (لبن)',
      category: 'Dairy',
      unit: 'Liters',
      quantity: 110.0,
      minimumQuantity: 100.0,
      reorderPoint: 150.0,
      location: 'Cold Storage B',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      batchNumber: 'BATCH002',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      cost: 4.2,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: null,
      searchTerms: ['laban', 'buttermilk', 'dairy', 'لبن'],
    ),
    InventoryItemModel(
      id: 'inv-003',
      name: 'Jibnah (جبنة)',
      category: 'Dairy',
      unit: 'Kg',
      quantity: 250.0,
      minimumQuantity: 50.0,
      reorderPoint: 75.0,
      location: 'Cold Storage B',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      batchNumber: 'BATCH003',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      cost: 12.5,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: null,
      searchTerms: ['jibnah', 'cheese', 'dairy', 'جبنة'],
    ),
    InventoryItemModel(
      id: 'inv-004',
      name: 'Qishta (قشطة)',
      category: 'Dairy',
      unit: 'Kg',
      quantity: 100.0,
      minimumQuantity: 20.0,
      reorderPoint: 30.0,
      location: 'Cold Storage A',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      batchNumber: 'BATCH004',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      cost: 8.2,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: null,
      fatContent: 45.0,
      searchTerms: ['qishta', 'cream', 'dairy', 'قشطة'],
    ),
    InventoryItemModel(
      id: 'inv-014',
      name: 'Cow Milk',
      category: 'Dairy',
      unit: 'Liters',
      quantity: 250.0,
      minimumQuantity: 300.0,
      reorderPoint: 350.0,
      location: 'Cold Storage A',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 8)),
      batchNumber: 'BATCH014',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      cost: 4.5,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: null,
      fatContent: 3.2,
      pasteurized: true,
      searchTerms: ['milk', 'cow', 'dairy'],
      additionalAttributes: {
        'source': 'Local Dairy Farm',
        'organicCertified': true,
        'region': 'Riyadh Province',
      },
    ),

    // Ingredients
    InventoryItemModel(
      id: 'inv-005',
      name: 'Date Syrup (دبس التمر)',
      category: 'Ingredients',
      unit: 'Kg',
      quantity: 500.0,
      minimumQuantity: 100.0,
      reorderPoint: 150.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      batchNumber: 'BATCH005',
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      cost: 3.5,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['date', 'syrup', 'ingredient', 'دبس', 'تمر'],
    ),
    InventoryItemModel(
      id: 'inv-006',
      name: 'Saffron (زعفران)',
      category: 'Ingredients',
      unit: 'g',
      quantity: 300.0,
      minimumQuantity: 50.0,
      reorderPoint: 80.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
      batchNumber: 'BATCH006',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      cost: 12.8,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['saffron', 'spice', 'ingredient', 'زعفران'],
    ),
    InventoryItemModel(
      id: 'inv-007',
      name: 'Pure Water',
      category: 'Ingredients',
      unit: 'Liters',
      quantity: 20.0,
      minimumQuantity: 5.0,
      reorderPoint: 8.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
      batchNumber: 'BATCH007',
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      cost: 9.5,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['pure', 'water', 'ingredient', 'flavoring'],
    ),

    // Fruits
    InventoryItemModel(
      id: 'inv-008',
      name: 'Dates (تمر)',
      category: 'Fruits',
      unit: 'Kg',
      quantity: 80.0,
      minimumQuantity: 20.0,
      reorderPoint: 30.0,
      location: 'Cold Storage A',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
      batchNumber: 'BATCH008',
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      cost: 6.0,
      currentTemperature: 18.0,
      storageCondition: 'cool dry',
      overallQualityStatus: null,
      searchTerms: ['dates', 'fruit', 'تمر'],
    ),
    InventoryItemModel(
      id: 'inv-009',
      name: 'Pomegranate (رمان)',
      category: 'Fruits',
      unit: 'Kg',
      quantity: 60.0,
      minimumQuantity: 15.0,
      reorderPoint: 25.0,
      location: 'Cold Storage A',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
      batchNumber: 'BATCH009',
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      cost: 8.0,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: null,
      searchTerms: ['pomegranate', 'fruit', 'رمان'],
    ),

    // Packaging
    InventoryItemModel(
      id: 'inv-010',
      name: 'Halal-Certified Containers 500ml',
      category: 'Packaging',
      unit: 'Units',
      quantity: 2000.0,
      minimumQuantity: 500.0,
      reorderPoint: 800.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
      batchNumber: 'BATCH010',
      cost: 0.25,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['container', 'plastic', 'packaging', '500ml', 'halal'],
    ),
    InventoryItemModel(
      id: 'inv-011',
      name: 'Traditional Glass Bottles 1L',
      category: 'Packaging',
      unit: 'Units',
      quantity: 1500.0,
      minimumQuantity: 300.0,
      reorderPoint: 500.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
      batchNumber: 'BATCH011',
      cost: 0.45,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['bottle', 'glass', 'packaging', '1L', 'traditional'],
    ),

    // Low Stock Items (for testing)
    InventoryItemModel(
      id: 'inv-015',
      name: 'Strawberry Syrup',
      category: 'Ingredients',
      unit: 'Liters',
      quantity: 8.0,
      minimumQuantity: 10.0,
      reorderPoint: 15.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      batchNumber: 'BATCH015',
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      cost: 12.0,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['strawberry', 'syrup', 'flavoring', 'ingredient'],
    ),
    InventoryItemModel(
      id: 'inv-016',
      name: 'Chocolate Powder',
      category: 'Ingredients',
      unit: 'Kg',
      quantity: 45.0,
      minimumQuantity: 10.0,
      reorderPoint: 15.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
      batchNumber: 'BATCH016',
      expiryDate: DateTime.now().add(const Duration(days: 240)),
      cost: 18.0,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['chocolate', 'powder', 'cocoa', 'flavoring', 'ingredient'],
    ),
    InventoryItemModel(
      id: 'inv-017',
      name: 'Banana Extract',
      category: 'Ingredients',
      unit: 'Liters',
      quantity: 30.0,
      minimumQuantity: 5.0,
      reorderPoint: 10.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 8)),
      batchNumber: 'BATCH017',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      cost: 15.0,
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['banana', 'extract', 'flavoring', 'ingredient'],
    ),
    // Additional mock items for Ingredients and Packaging
    InventoryItemModel(
      id: 'inv-018',
      name: 'Cardamom Pods',
      category: 'Ingredients',
      unit: 'Kg',
      quantity: 60.0,
      minimumQuantity: 10.0,
      reorderPoint: 20.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      batchNumber: 'BATCH018',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      cost: 80.0, // 80 ﷼ per Kg
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['cardamom', 'spice', 'ingredient'],
    ),
    InventoryItemModel(
      id: 'inv-019',
      name: 'Rose Water',
      category: 'Ingredients',
      unit: 'Liters',
      quantity: 25.0,
      minimumQuantity: 5.0,
      reorderPoint: 10.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      batchNumber: 'BATCH019',
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      cost: 15.0, // 15 ﷼ per Liter
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['rose', 'water', 'ingredient'],
    ),
    InventoryItemModel(
      id: 'inv-020',
      name: 'Pistachio Nuts',
      category: 'Ingredients',
      unit: 'Kg',
      quantity: 40.0,
      minimumQuantity: 8.0,
      reorderPoint: 15.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 4)),
      batchNumber: 'BATCH020',
      expiryDate: DateTime.now().add(const Duration(days: 300)),
      cost: 120.0, // 120 ﷼ per Kg
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['pistachio', 'nut', 'ingredient'],
    ),
    InventoryItemModel(
      id: 'inv-021',
      name: 'Vanilla Beans',
      category: 'Ingredients',
      unit: 'g',
      quantity: 500.0,
      minimumQuantity: 100.0,
      reorderPoint: 200.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 6)),
      batchNumber: 'BATCH021',
      expiryDate: DateTime.now().add(const Duration(days: 400)),
      cost: 200.0, // 200 ﷼ per 100g
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['vanilla', 'bean', 'ingredient'],
    ),
    InventoryItemModel(
      id: 'inv-022',
      name: 'Plastic Cups 250ml',
      category: 'Packaging',
      unit: 'Units',
      quantity: 5000.0,
      minimumQuantity: 1000.0,
      reorderPoint: 2000.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
      batchNumber: 'BATCH022',
      cost: 0.15, // 0.15 ﷼ per unit
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['cup', 'plastic', 'packaging', '250ml'],
    ),
    InventoryItemModel(
      id: 'inv-023',
      name: 'Paper Labels',
      category: 'Packaging',
      unit: 'Units',
      quantity: 10000.0,
      minimumQuantity: 2000.0,
      reorderPoint: 4000.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 12)),
      batchNumber: 'BATCH023',
      cost: 0.02, // 0.02 ﷼ per unit
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['label', 'paper', 'packaging'],
    ),
    InventoryItemModel(
      id: 'inv-024',
      name: 'Shrink Wrap Film',
      category: 'Packaging',
      unit: 'Rolls',
      quantity: 60.0,
      minimumQuantity: 10.0,
      reorderPoint: 20.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 8)),
      batchNumber: 'BATCH024',
      cost: 8.0, // 8 ﷼ per roll
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['shrink', 'wrap', 'film', 'packaging'],
    ),
    InventoryItemModel(
      id: 'inv-025',
      name: 'Aluminum Foil Lids',
      category: 'Packaging',
      unit: 'Units',
      quantity: 8000.0,
      minimumQuantity: 2000.0,
      reorderPoint: 3000.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
      batchNumber: 'BATCH025',
      cost: 0.03, // 0.03 ﷼ per unit
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['foil', 'lid', 'aluminum', 'packaging'],
    ),
    // ... (repeat similar for 30+ items, varying expiry, cost, quantity, location, etc.)
    // Example expired and expiring soon items:
    InventoryItemModel(
      id: 'inv-026',
      name: 'Expired Yeast',
      category: 'Ingredients',
      unit: 'Kg',
      quantity: 5.0,
      minimumQuantity: 2.0,
      reorderPoint: 4.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
      batchNumber: 'BATCH026',
      expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      cost: 10.0, // 10 ﷼ per Kg
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['yeast', 'ingredient', 'expired'],
    ),
    InventoryItemModel(
      id: 'inv-027',
      name: 'Salt (ملح)',
      category: 'Ingredients',
      unit: 'Kg',
      quantity: 100.0,
      minimumQuantity: 20.0,
      reorderPoint: 40.0,
      location: 'Dry Storage',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      batchNumber: 'BATCH027',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      cost: 1.0, // 1 ﷼ per Kg
      storageCondition: 'dry',
      overallQualityStatus: null,
      searchTerms: ['salt', 'ingredient'],
    ),
    // ... (add more items up to 30+ for robust demo)
  ];

  // Mock inventory locations - shared across inventory features
  final List<InventoryLocationModel> inventoryLocations = [
    InventoryLocationModel(
      locationId: 'loc-001',
      locationName: 'Cold Storage A (مخزن بارد أ)',
      locationType: LocationType.COLD_STORAGE,
      temperatureCondition: '4°C',
      storageCapacity: 2000.0,
      currentUtilization: 1200.0,
      isActive: true,
    ),
    InventoryLocationModel(
      locationId: 'loc-002',
      locationName: 'Cold Storage B (مخزن بارد ب)',
      locationType: LocationType.COLD_STORAGE,
      temperatureCondition: '4°C',
      storageCapacity: 1800.0,
      currentUtilization: 900.0,
      isActive: true,
    ),
    InventoryLocationModel(
      locationId: 'loc-003',
      locationName: 'Dry Storage (مخزن جاف)',
      locationType: LocationType.DRY_STORAGE,
      temperatureCondition: '22°C',
      storageCapacity: 3000.0,
      currentUtilization: 1500.0,
      isActive: true,
    ),
    InventoryLocationModel(
      locationId: 'loc-004',
      locationName: 'Freezer (مجمد)',
      locationType: LocationType.FREEZER,
      temperatureCondition: '-18°C',
      storageCapacity: 1500.0,
      currentUtilization: 600.0,
      isActive: true,
    ),
    InventoryLocationModel(
      locationId: 'loc-005',
      locationName: 'Production Area (منطقة الإنتاج)',
      locationType: LocationType.PRODUCTION_AREA,
      temperatureCondition: '18°C',
      storageCapacity: 800.0,
      currentUtilization: 400.0,
      isActive: true,
    ),
    InventoryLocationModel(
      locationId: 'loc-006',
      locationName: 'Quality Control (مراقبة الجودة)',
      locationType: LocationType.QUALITY_CONTROL,
      temperatureCondition: '20°C',
      storageCapacity: 300.0,
      currentUtilization: 100.0,
      isActive: true,
    ),
    InventoryLocationModel(
      locationId: 'loc-007',
      locationName: 'Dispatch Area (منطقة الشحن)',
      locationType: LocationType.DISPATCH_AREA,
      temperatureCondition: '18°C',
      storageCapacity: 500.0,
      currentUtilization: 200.0,
      isActive: true,
    ),
  ];

  // Mock inventory movements
  final List<InventoryMovementModel> inventoryMovements = [
    InventoryMovementModel(
      movementId: 'mov-001',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      movementType: InventoryMovementType.RECEIPT,
      sourceLocationId: 'external-supplier-001',
      sourceLocationName: 'Al-Marai Camel Farm (مزرعة المراعي للإبل)',
      destinationLocationId: 'loc-001',
      destinationLocationName: 'Cold Storage A (مخزن بارد أ)',
      initiatingEmployeeId: 'emp-001',
      initiatingEmployeeName: 'Mohammed Al-Harbi',
      approvalStatus: ApprovalStatus.APPROVED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Weekly camel milk delivery from Al-Marai',
      referenceDocuments: ['PO-123456', 'HALAL-CERT-789'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-001',
          productId: 'inv-001',
          productName: 'Camel Milk (حليب الإبل)',
          batchLotNumber: 'BATCH001',
          quantity: 500.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 1)),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
          qualityStatus: QualityStatus.excellent,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-002',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      movementType: InventoryMovementType.ISSUE,
      sourceLocationId: 'loc-001',
      sourceLocationName: 'Cold Storage A (مخزن بارد أ)',
      destinationLocationId: 'loc-005',
      destinationLocationName: 'Production Area (منطقة الإنتاج)',
      initiatingEmployeeId: 'emp-003',
      initiatingEmployeeName: 'Abdullah Al-Qahtani',
      approvalStatus: ApprovalStatus.APPROVED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Daily Laban production batch',
      referenceDocuments: ['PROD-789'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-002',
          productId: 'inv-001',
          productName: 'Camel Milk (حليب الإبل)',
          batchLotNumber: 'BATCH001',
          quantity: 100.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 1)),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
          qualityStatus: QualityStatus.excellent,
        ),
        InventoryMovementItemModel(
          itemId: 'mov-item-003',
          productId: 'inv-005',
          productName: 'Date Syrup (دبس التمر)',
          batchLotNumber: 'BATCH005',
          quantity: 25.0,
          unitOfMeasurement: 'Kg',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 10)),
          expirationDate: DateTime.now().add(const Duration(days: 180)),
          qualityStatus: QualityStatus.excellent,
        ),
      ],
    ),
    // Additional movements for testing
    InventoryMovementModel(
      movementId: 'mov-003',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      movementType: InventoryMovementType.TRANSFER,
      sourceLocationId: 'loc-003',
      sourceLocationName: 'Dry Storage (مخزن جاف)',
      destinationLocationId: 'loc-005',
      destinationLocationName: 'Production Area (منطقة الإنتاج)',
      initiatingEmployeeId: 'emp-004',
      initiatingEmployeeName: 'Noura Al-Saud',
      approvalStatus: ApprovalStatus.PENDING,
      approverEmployeeId: null,
      approverEmployeeName: null,
      reasonNotes: 'Transfer of ingredients for tomorrow\'s production',
      referenceDocuments: ['TRANSFER-123'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-004',
          productId: 'inv-006',
          productName: 'Saffron (زعفران)',
          batchLotNumber: 'BATCH006',
          quantity: 15.0,
          unitOfMeasurement: 'g',
          status: MovementItemStatus.IN_TRANSIT,
          productionDate: DateTime.now().subtract(const Duration(days: 10)),
          expirationDate: DateTime.now().add(const Duration(days: 365)),
          qualityStatus: QualityStatus.excellent,
        ),
        InventoryMovementItemModel(
          itemId: 'mov-item-005',
          productId: 'inv-007',
          productName: 'Pure Water',
          batchLotNumber: 'BATCH007',
          quantity: 5.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.IN_TRANSIT,
          productionDate: DateTime.now().subtract(const Duration(days: 15)),
          expirationDate: DateTime.now().add(const Duration(days: 180)),
          qualityStatus: QualityStatus.excellent,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-004',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      movementType: InventoryMovementType.ISSUE,
      sourceLocationId: 'loc-005',
      sourceLocationName: 'Production Area (منطقة الإنتاج)',
      destinationLocationId: 'loc-001',
      destinationLocationName: 'Cold Storage A (مخزن بارد أ)',
      initiatingEmployeeId: 'emp-005',
      initiatingEmployeeName: 'Hassan Al-Farsi',
      approvalStatus: ApprovalStatus.APPROVED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Finished batch of Laban production',
      referenceDocuments: ['PROD-790', 'QC-123'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-006',
          productId: 'inv-002',
          productName: 'Laban (لبن)',
          batchLotNumber: 'BATCH-LABAN-001',
          quantity: 80.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(hours: 6)),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
          qualityStatus: QualityStatus.excellent,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-005',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      movementType: InventoryMovementType.RECEIPT,
      sourceLocationId: 'external-supplier-002',
      sourceLocationName: 'Organic Fruits Co.',
      destinationLocationId: 'loc-003',
      destinationLocationName: 'Dry Storage (مخزن جاف)',
      initiatingEmployeeId: 'emp-001',
      initiatingEmployeeName: 'Mohammed Al-Harbi',
      approvalStatus: ApprovalStatus.APPROVED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Monthly fruit delivery',
      referenceDocuments: ['PO-789', 'DELIVERY-456'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-007',
          productId: 'inv-008',
          productName: 'Dates (تمر)',
          batchLotNumber: 'BATCH-DATES-001',
          quantity: 100.0,
          unitOfMeasurement: 'Kg',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 10)),
          expirationDate: DateTime.now().add(const Duration(days: 90)),
          qualityStatus: QualityStatus.excellent,
        ),
        InventoryMovementItemModel(
          itemId: 'mov-item-008',
          productId: 'inv-009',
          productName: 'Pomegranate (رمان)',
          batchLotNumber: 'BATCH-POM-001',
          quantity: 75.0,
          unitOfMeasurement: 'Kg',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 5)),
          expirationDate: DateTime.now().add(const Duration(days: 14)),
          qualityStatus: QualityStatus.good,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-006',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      movementType: InventoryMovementType.TRANSFER,
      sourceLocationId: 'loc-001',
      sourceLocationName: 'Cold Storage A (مخزن بارد أ)',
      destinationLocationId: 'loc-006',
      destinationLocationName: 'Quality Control (مراقبة الجودة)',
      initiatingEmployeeId: 'emp-006',
      initiatingEmployeeName: 'Aisha Al-Zahrani',
      approvalStatus: ApprovalStatus.APPROVED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Quality check required for temperature fluctuation',
      referenceDocuments: ['QC-HOLD-123'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-009',
          productId: 'inv-014',
          productName: 'Cow Milk',
          batchLotNumber: 'BATCH014',
          quantity: 50.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 1)),
          expirationDate: DateTime.now().add(const Duration(days: 5)),
          qualityStatus: QualityStatus.warning,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-007',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      movementType: InventoryMovementType.ADJUSTMENT,
      sourceLocationId: 'loc-003',
      sourceLocationName: 'Dry Storage (مخزن جاف)',
      destinationLocationId: 'loc-003',
      destinationLocationName: 'Dry Storage (مخزن جاف)',
      initiatingEmployeeId: 'emp-007',
      initiatingEmployeeName: 'Khaled Al-Mansour',
      approvalStatus: ApprovalStatus.PENDING,
      approverEmployeeId: null,
      approverEmployeeName: null,
      reasonNotes: 'Inventory adjustment after physical count',
      referenceDocuments: ['ADJ-001'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-010',
          productId: 'inv-015',
          productName: 'Strawberry Syrup',
          batchLotNumber: 'BATCH015',
          quantity: 2.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.IN_TRANSIT,
          productionDate: DateTime.now().subtract(const Duration(days: 5)),
          expirationDate: DateTime.now().add(const Duration(days: 180)),
          qualityStatus: QualityStatus.excellent,
        ),
      ],
    ),
    // Additional movements for demo/reporting coverage
    InventoryMovementModel(
      movementId: 'mov-008',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      movementType: InventoryMovementType.ADJUSTMENT,
      sourceLocationId: 'loc-003',
      sourceLocationName: 'Dry Storage (مخزن جاف)',
      destinationLocationId: 'loc-003',
      destinationLocationName: 'Dry Storage (مخزن جاف)',
      initiatingEmployeeId: 'emp-008',
      initiatingEmployeeName: 'Layla Al-Mutairi',
      approvalStatus: ApprovalStatus.REJECTED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Adjustment after audit, rejected due to discrepancy',
      referenceDocuments: ['ADJ-002'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-011',
          productId: 'inv-016',
          productName: 'Chocolate Powder',
          batchLotNumber: 'BATCH016',
          quantity: -5.0,
          unitOfMeasurement: 'Kg',
          status: MovementItemStatus.IN_TRANSIT,
          productionDate: DateTime.now().subtract(const Duration(days: 7)),
          expirationDate: DateTime.now().add(const Duration(days: 240)),
          qualityStatus: QualityStatus.good,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-009',
      timestamp: DateTime.now().subtract(const Duration(days: 8)),
      movementType: InventoryMovementType.RECEIPT,
      sourceLocationId: 'external-supplier-003',
      sourceLocationName: 'Desert Fruit Farms',
      destinationLocationId: 'loc-003',
      destinationLocationName: 'Dry Storage (مخزن جاف)',
      initiatingEmployeeId: 'emp-009',
      initiatingEmployeeName: 'Omar Al-Saleh',
      approvalStatus: ApprovalStatus.PENDING,
      approverEmployeeId: null,
      approverEmployeeName: null,
      reasonNotes: 'Bulk date delivery, pending inspection',
      referenceDocuments: ['PO-987654'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-012',
          productId: 'inv-008',
          productName: 'Dates (تمر)',
          batchLotNumber: 'BATCH008',
          quantity: 150.0,
          unitOfMeasurement: 'Kg',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 1)),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
          qualityStatus: QualityStatus.excellent,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-012',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      movementType: InventoryMovementType.RECEIPT,
      sourceLocationId: 'external-supplier-004',
      sourceLocationName: 'Saudi Spice Merchants',
      destinationLocationId: 'loc-003',
      destinationLocationName: 'Dry Storage (مخزن جاف)',
      initiatingEmployeeId: 'emp-012',
      initiatingEmployeeName: 'Mona Al-Fahad',
      approvalStatus: ApprovalStatus.APPROVED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Spice delivery for production',
      referenceDocuments: ['PO-2024-001'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-015',
          productId: 'inv-006',
          productName: 'Saffron (زعفران)',
          batchLotNumber: 'BATCH006',
          quantity: 50.0,
          unitOfMeasurement: 'g',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 12)),
          expirationDate: DateTime.now().add(const Duration(days: 360)),
          qualityStatus: QualityStatus.good,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-013',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      movementType: InventoryMovementType.ISSUE,
      sourceLocationId: 'loc-003',
      sourceLocationName: 'Dry Storage (مخزن جاف)',
      destinationLocationId: 'loc-005',
      destinationLocationName: 'Production Area (منطقة الإنتاج)',
      initiatingEmployeeId: 'emp-013',
      initiatingEmployeeName: 'Yousef Al-Rashid',
      approvalStatus: ApprovalStatus.REJECTED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Issue rejected due to insufficient stock',
      referenceDocuments: ['PROD-2024-002'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-016',
          productId: 'inv-019',
          productName: 'Rose Water',
          batchLotNumber: 'BATCH019',
          quantity: 10.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.IN_TRANSIT,
          productionDate: DateTime.now().subtract(const Duration(days: 3)),
          expirationDate: DateTime.now().add(const Duration(days: 170)),
          qualityStatus: QualityStatus.warning,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-014',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      movementType: InventoryMovementType.TRANSFER,
      sourceLocationId: 'loc-002',
      sourceLocationName: 'Cold Storage B (مخزن بارد ب)',
      destinationLocationId: 'loc-007',
      destinationLocationName: 'Dispatch Area (منطقة الشحن)',
      initiatingEmployeeId: 'emp-014',
      initiatingEmployeeName: 'Rania Al-Saif',
      approvalStatus: ApprovalStatus.PENDING,
      approverEmployeeId: null,
      approverEmployeeName: null,
      reasonNotes: 'Transfer for outgoing shipment',
      referenceDocuments: ['DISPATCH-2024-003'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-017',
          productId: 'inv-002',
          productName: 'Laban (لبن)',
          batchLotNumber: 'BATCH002',
          quantity: 60.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.IN_TRANSIT,
          productionDate: DateTime.now().subtract(const Duration(days: 6)),
          expirationDate: DateTime.now().add(const Duration(days: 4)),
          qualityStatus: QualityStatus.good,
        ),
      ],
    ),
    InventoryMovementModel(
      movementId: 'mov-015',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      movementType: InventoryMovementType.ADJUSTMENT,
      sourceLocationId: 'loc-001',
      sourceLocationName: 'Cold Storage A (مخزن بارد أ)',
      destinationLocationId: 'loc-001',
      destinationLocationName: 'Cold Storage A (مخزن بارد أ)',
      initiatingEmployeeId: 'emp-015',
      initiatingEmployeeName: 'Majed Al-Harbi',
      approvalStatus: ApprovalStatus.APPROVED,
      approverEmployeeId: 'emp-002',
      approverEmployeeName: 'Fatima Al-Otaibi',
      reasonNotes: 'Stock adjustment after spoilage',
      referenceDocuments: ['ADJ-2024-004'],
      items: [
        InventoryMovementItemModel(
          itemId: 'mov-item-018',
          productId: 'inv-014',
          productName: 'Cow Milk',
          batchLotNumber: 'BATCH014',
          quantity: -20.0,
          unitOfMeasurement: 'Liters',
          status: MovementItemStatus.RECEIVED,
          productionDate: DateTime.now().subtract(const Duration(days: 8)),
          expirationDate: DateTime.now().add(const Duration(days: 2)),
          qualityStatus: QualityStatus.warning,
        ),
      ],
    ),
  ];

  /// Generate inventory locations (helper for reset)
  List<InventoryLocationModel> _generateInventoryLocations() {
    return [
      InventoryLocationModel(
        locationId: 'loc-001',
        locationName: 'Cold Storage A (مخزن بارد أ)',
        locationType: LocationType.COLD_STORAGE,
        temperatureCondition: '4°C',
        storageCapacity: 2000.0,
        currentUtilization: 1200.0,
        isActive: true,
      ),
    ];
  }

  // Mock equipment for equipment maintenance module
  final List<EquipmentModel> mockEquipment = [
    EquipmentModel(
      id: 'eq-001',
      name: 'Pasteurizer 1',
      type: EquipmentType.pasteurizer,
      status: EquipmentStatus.operational,
      locationId: 'loc-001',
      locationName: 'Processing Hall A',
      manufacturer: 'DairyTech',
      model: 'DT-1000',
      serialNumber: 'PAST-1001',
      installDate: DateTime.now().subtract(const Duration(days: 900)),
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 30)),
      nextMaintenanceDate: DateTime.now().add(const Duration(days: 60)),
      maintenanceIntervalDays: 90,
      responsiblePersonId: 'emp-001',
      responsiblePersonName: 'Ahmed Al-Saud',
      lastSanitizationDate: DateTime.now().subtract(const Duration(hours: 20)),
      sanitizationIntervalHours: 24,
      requiresSanitization: true,
      runningHoursTotal: 12000,
      runningHoursSinceLastMaintenance: 400,
      specifications: {'capacity': '2000L/h', 'power': '15kW'},
      metadata: {'notes': 'Main pasteurizer for camel milk'},
    ),
    EquipmentModel(
      id: 'eq-002',
      name: 'Homogenizer 2',
      type: EquipmentType.homogenizer,
      status: EquipmentStatus.maintenance,
      locationId: 'loc-002',
      locationName: 'Processing Hall B',
      manufacturer: 'MilkPro',
      model: 'MP-500',
      serialNumber: 'HOMO-2002',
      installDate: DateTime.now().subtract(const Duration(days: 700)),
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 5)),
      nextMaintenanceDate: DateTime.now().add(const Duration(days: 85)),
      maintenanceIntervalDays: 90,
      responsiblePersonId: 'emp-002',
      responsiblePersonName: 'Fatima Al-Zahrani',
      lastSanitizationDate: DateTime.now().subtract(const Duration(hours: 30)),
      sanitizationIntervalHours: 48,
      requiresSanitization: true,
      runningHoursTotal: 8000,
      runningHoursSinceLastMaintenance: 100,
      specifications: {'capacity': '1000L/h', 'power': '10kW'},
      metadata: {'notes': 'Currently under scheduled maintenance'},
    ),
    EquipmentModel(
      id: 'eq-003',
      name: 'Separator 1',
      type: EquipmentType.separator,
      status: EquipmentStatus.repair,
      locationId: 'loc-003',
      locationName: 'Processing Hall C',
      manufacturer: 'DairyParts',
      model: 'SEP-300',
      serialNumber: 'SEP-3003',
      installDate: DateTime.now().subtract(const Duration(days: 400)),
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 120)),
      nextMaintenanceDate: DateTime.now().subtract(const Duration(days: 30)),
      maintenanceIntervalDays: 90,
      responsiblePersonId: 'emp-003',
      responsiblePersonName: 'Khalid Al-Ghamdi',
      lastSanitizationDate: DateTime.now().subtract(const Duration(hours: 60)),
      sanitizationIntervalHours: 72,
      requiresSanitization: false,
      runningHoursTotal: 5000,
      runningHoursSinceLastMaintenance: 1200,
      specifications: {'capacity': '500L/h', 'power': '5kW'},
      metadata: {'notes': 'Awaiting spare part for repair'},
    ),
    EquipmentModel(
      id: 'eq-004',
      name: 'Tank 1',
      type: EquipmentType.tank,
      status: EquipmentStatus.sanitization,
      locationId: 'loc-004',
      locationName: 'Storage Area',
      manufacturer: 'TankCo',
      model: 'TANK-1500',
      serialNumber: 'TANK-4004',
      installDate: DateTime.now().subtract(const Duration(days: 1000)),
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 60)),
      nextMaintenanceDate: DateTime.now().add(const Duration(days: 30)),
      maintenanceIntervalDays: 120,
      responsiblePersonId: 'emp-004',
      responsiblePersonName: 'Nora Al-Dosari',
      lastSanitizationDate: DateTime.now().subtract(const Duration(hours: 50)),
      sanitizationIntervalHours: 48,
      requiresSanitization: true,
      runningHoursTotal: 20000,
      runningHoursSinceLastMaintenance: 2000,
      specifications: {'capacity': '15000L', 'material': 'Stainless Steel'},
      metadata: {'notes': 'Sanitization overdue'},
    ),
    EquipmentModel(
      id: 'eq-005',
      name: 'Packaging Machine',
      type: EquipmentType.packagingMachine,
      status: EquipmentStatus.operational,
      locationId: 'loc-005',
      locationName: 'Packaging Area',
      manufacturer: 'PackIt',
      model: 'PKG-900',
      serialNumber: 'PKG-5005',
      installDate: DateTime.now().subtract(const Duration(days: 300)),
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 20)),
      nextMaintenanceDate: DateTime.now().add(const Duration(days: 70)),
      maintenanceIntervalDays: 90,
      responsiblePersonId: 'emp-005',
      responsiblePersonName: 'Sara Al-Fahad',
      lastSanitizationDate: DateTime.now().subtract(const Duration(hours: 10)),
      sanitizationIntervalHours: 24,
      requiresSanitization: true,
      runningHoursTotal: 3000,
      runningHoursSinceLastMaintenance: 300,
      specifications: {'capacity': '500 packs/h', 'power': '3kW'},
      metadata: {'notes': 'Used for all retail packaging'},
    ),
    // Add more equipment as needed for comprehensive coverage
  ];

  // Mock maintenance records for equipment maintenance module
  final List<MaintenanceRecordModel> mockMaintenanceRecords = [
    MaintenanceRecordModel(
      id: 'mr-001',
      equipmentId: 'eq-001',
      equipmentName: 'Pasteurizer 1',
      equipmentType: EquipmentType.pasteurizer,
      scheduledDate: DateTime.now().subtract(const Duration(days: 30)),
      completionDate: DateTime.now().subtract(const Duration(days: 29)),
      maintenanceType: MaintenanceType.preventive,
      description: 'Quarterly preventive maintenance',
      status: MaintenanceStatus.completed,
      performedById: 'emp-001',
      performedByName: 'Ahmed Al-Saud',
      notes: 'All checks passed. Lubricated moving parts.',
      partsReplaced: ['Filter', 'Seal'],
      downtimeHours: 2.5,
      metadata: {'report': 'PDF-001'},
    ),
    MaintenanceRecordModel(
      id: 'mr-002',
      equipmentId: 'eq-002',
      equipmentName: 'Homogenizer 2',
      equipmentType: EquipmentType.homogenizer,
      scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      completionDate: null,
      maintenanceType: MaintenanceType.corrective,
      description: 'Corrective maintenance for vibration issue',
      status: MaintenanceStatus.inProgress,
      performedById: 'emp-002',
      performedByName: 'Fatima Al-Zahrani',
      notes: 'Investigating abnormal vibration',
      partsReplaced: [],
      downtimeHours: 4.0,
      metadata: {'report': 'PDF-002'},
    ),
    MaintenanceRecordModel(
      id: 'mr-003',
      equipmentId: 'eq-003',
      equipmentName: 'Separator 1',
      equipmentType: EquipmentType.separator,
      scheduledDate: DateTime.now().subtract(const Duration(days: 10)),
      completionDate: null,
      maintenanceType: MaintenanceType.corrective,
      description: 'Repair: replace broken shaft',
      status: MaintenanceStatus.scheduled,
      performedById: 'emp-003',
      performedByName: 'Khalid Al-Ghamdi',
      notes: 'Awaiting spare part delivery',
      partsReplaced: [],
      downtimeHours: null,
      metadata: {},
    ),
    MaintenanceRecordModel(
      id: 'mr-004',
      equipmentId: 'eq-004',
      equipmentName: 'Tank 1',
      equipmentType: EquipmentType.tank,
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      completionDate: null,
      maintenanceType: MaintenanceType.sanitization,
      description: 'Sanitization overdue',
      status: MaintenanceStatus.delayed,
      performedById: 'emp-004',
      performedByName: 'Nora Al-Dosari',
      notes: 'Sanitization not performed on time',
      partsReplaced: [],
      downtimeHours: 1.0,
      metadata: {},
    ),
    MaintenanceRecordModel(
      id: 'mr-005',
      equipmentId: 'eq-005',
      equipmentName: 'Packaging Machine',
      equipmentType: EquipmentType.packagingMachine,
      scheduledDate: DateTime.now().add(const Duration(days: 10)),
      completionDate: null,
      maintenanceType: MaintenanceType.preventive,
      description: 'Scheduled preventive maintenance',
      status: MaintenanceStatus.scheduled,
      performedById: 'emp-005',
      performedByName: 'Sara Al-Fahad',
      notes: null,
      partsReplaced: [],
      downtimeHours: null,
      metadata: {},
    ),
    // Add more records as needed for comprehensive coverage
  ];

  // Helper methods for mock equipment
  List<EquipmentModel> getAllMockEquipment() =>
      List.unmodifiable(mockEquipment);
  EquipmentModel? getMockEquipmentById(String id) => mockEquipment
      .cast<EquipmentModel?>()
      .firstWhere((e) => e!.id == id, orElse: () => null);
  void addMockEquipment(EquipmentModel equipment) =>
      mockEquipment.add(equipment);
  void updateMockEquipment(EquipmentModel equipment) {
    final idx = mockEquipment.indexWhere((e) => e.id == equipment.id);
    if (idx != -1) mockEquipment[idx] = equipment;
  }

  void deleteMockEquipment(String id) =>
      mockEquipment.removeWhere((e) => e.id == id);

  // Helper methods for mock maintenance records
  List<MaintenanceRecordModel> getAllMockMaintenanceRecords() =>
      List.unmodifiable(mockMaintenanceRecords);
  List<MaintenanceRecordModel> getMockMaintenanceRecordsForEquipment(
          String equipmentId) =>
      mockMaintenanceRecords
          .where((r) => r.equipmentId == equipmentId)
          .toList();
  MaintenanceRecordModel? getMockMaintenanceRecordById(String id) =>
      mockMaintenanceRecords
          .cast<MaintenanceRecordModel?>()
          .firstWhere((r) => r!.id == id, orElse: () => null);
  void addMockMaintenanceRecord(MaintenanceRecordModel record) =>
      mockMaintenanceRecords.add(record);
  void updateMockMaintenanceRecord(MaintenanceRecordModel record) {
    final idx = mockMaintenanceRecords.indexWhere((r) => r.id == record.id);
    if (idx != -1) mockMaintenanceRecords[idx] = record;
  }

  void deleteMockMaintenanceRecord(String id) =>
      mockMaintenanceRecords.removeWhere((r) => r.id == id);

  /// Aggregation: Get current stock by item
  Map<String, double> getCurrentStockByItem() {
    final Map<String, double> stock = {};
    for (final item in inventoryItems) {
      stock[item.name] = item.quantity;
    }
    return stock;
  }

  /// Aggregation: Get current stock by category
  Map<String, double> getCurrentStockByCategory() {
    final Map<String, double> stock = {};
    for (final item in inventoryItems) {
      stock[item.category] = (stock[item.category] ?? 0) + item.quantity;
    }
    return stock;
  }

  /// Aggregation: Get expiry status for all items
  Map<String, String> getExpiryStatus({int expiringSoonDays = 7}) {
    final now = DateTime.now();
    final Map<String, String> status = {};
    for (final item in inventoryItems) {
      if (item.expiryDate == null) {
        status[item.name] = 'no_expiry';
      } else if (item.expiryDate!.isBefore(now)) {
        status[item.name] = 'expired';
      } else if (item.expiryDate!.difference(now).inDays <= expiringSoonDays) {
        status[item.name] = 'expiring_soon';
      } else {
        status[item.name] = 'safe';
      }
    }
    return status;
  }

  /// Aggregation: Get valuation by item
  Map<String, double> getValuationByItem() {
    final Map<String, double> valuation = {};
    for (final item in inventoryItems) {
      if (item.cost != null) {
        valuation[item.name] = item.quantity * item.cost!;
      }
    }
    return valuation;
  }

  /// Aggregation: Get valuation by category
  Map<String, double> getValuationByCategory() {
    final Map<String, double> valuation = {};
    for (final item in inventoryItems) {
      if (item.cost != null) {
        valuation[item.category] =
            (valuation[item.category] ?? 0) + (item.quantity * item.cost!);
      }
    }
    return valuation;
  }

  /// Aggregation: Get movement breakdown by type
  Map<String, int> getMovementCountByType() {
    final Map<String, int> counts = {};
    for (final mov in inventoryMovements) {
      final type = mov.movementType.toString().split('.').last;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  /// Aggregation: Get movement breakdown by status
  Map<String, int> getMovementCountByStatus() {
    final Map<String, int> counts = {};
    for (final mov in inventoryMovements) {
      final status = mov.approvalStatus.toString().split('.').last;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Aggregation: Get movement breakdown by date (day granularity)
  Map<String, int> getMovementCountByDate() {
    final Map<String, int> counts = {};
    for (final mov in inventoryMovements) {
      final date = mov.timestamp.toIso8601String().substring(0, 10);
      counts[date] = (counts[date] ?? 0) + 1;
    }
    return counts;
  }

  /// Update an inventory item by id
  void updateInventoryItem(InventoryItemModel updatedItem) {
    final idx = inventoryItems.indexWhere((item) => item.id == updatedItem.id);
    if (idx != -1) {
      inventoryItems[idx] = updatedItem;
    }
  }

  /// Check if inventory has enough for a recipe (mock: always true)
  bool checkInventoryForRecipe(String recipeId, double batchSize) {
    // For demo, always return true
    return true;
  }

  /// Get recipe ingredients (mock: returns a list of maps)
  List<Map<String, dynamic>> getRecipeIngredients(String recipeId) {
    // For demo, return a mock list
    return [
      {
        'ingredient': 'Camel Milk',
        'quantity': 10,
        'unit': 'Liters',
      },
      {
        'ingredient': 'Date Syrup',
        'quantity': 2,
        'unit': 'Kg',
      },
    ];
  }

  /// Get inventory forecast (mock: returns a list of maps)
  List<Map<String, dynamic>> getInventoryForecast(String itemId) {
    // For demo, return a mock forecast
    return [
      {'date': DateTime.now().add(const Duration(days: 1)), 'forecast': 100},
      {'date': DateTime.now().add(const Duration(days: 2)), 'forecast': 90},
      {'date': DateTime.now().add(const Duration(days: 3)), 'forecast': 80},
    ];
  }

  /// Get procurement needs (mock: returns a list of maps)
  List<Map<String, dynamic>> getProcurementNeeds() {
    // For demo, return a mock list
    return [
      {'item': 'Camel Milk', 'needed': 200, 'unit': 'Liters'},
      {'item': 'Date Syrup', 'needed': 50, 'unit': 'Kg'},
    ];
  }

  /// Adjust quantity of an inventory item
  void adjustQuantity(String itemId, double adjustment, String reason) {
    final idx = inventoryItems.indexWhere((item) => item.id == itemId);
    if (idx != -1) {
      final item = inventoryItems[idx];
      inventoryItems[idx] = item.copyWith(
        quantity: item.quantity + adjustment,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Mock recipe ingredients by recipe ID
  Map<String, List<Map<String, dynamic>>> get recipeIngredients => {
        'recipe-001': [
          {
            'ingredientId': 'inv-001',
            'name': 'Camel Milk',
            'quantity': 100.0,
            'unit': 'Liters',
          },
          {
            'ingredientId': 'inv-005',
            'name': 'Date Syrup',
            'quantity': 10.0,
            'unit': 'Kg',
          },
        ],
        'recipe-002': [
          {
            'ingredientId': 'inv-001',
            'name': 'Camel Milk',
            'quantity': 80.0,
            'unit': 'Liters',
          },
          {
            'ingredientId': 'inv-006',
            'name': 'Saffron',
            'quantity': 0.5,
            'unit': 'g',
          },
          {
            'ingredientId': 'inv-007',
            'name': 'Pure Water',
            'quantity': 5.0,
            'unit': 'Liters',
          },
        ],
        'recipe-003': [
          {
            'ingredientId': 'inv-014',
            'name': 'Cow Milk',
            'quantity': 120.0,
            'unit': 'Liters',
          },
          {
            'ingredientId': 'inv-016',
            'name': 'Chocolate Powder',
            'quantity': 2.0,
            'unit': 'Kg',
          },
        ],
      };

  /// Reset all mock data to initial state
  void reset() {
    // This is a simple reset for demo: clear and re-add initial items
    inventoryItems.clear();
    inventoryItems.addAll([
      InventoryItemModel(
        id: 'inv-001',
        name: 'Camel Milk (حليب الإبل)',
        category: 'Dairy',
        unit: 'Liters',
        quantity: 1200.0,
        minimumQuantity: 300.0,
        reorderPoint: 500.0,
        location: 'Cold Storage A',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        cost: 6.5,
        currentTemperature: 4.0,
        storageCondition: 'refrigerated',
        overallQualityStatus: null,
        fatContent: 3.5,
        pasteurized: true,
        searchTerms: ['milk', 'camel', 'dairy', 'حليب', 'إبل'],
        additionalAttributes: {
          'source': 'Najdi Camel Farm',
          'organicCertified': true,
          'region': 'Riyadh Province',
        },
      ),
      // ... (add more initial items as needed)
    ]);
    // Similarly reset locations and movements if needed
    // For demo, you can clear and re-add initial mock data
  }

  /// Mock: Get suppliers
  List<Map<String, dynamic>> getMockSuppliers() {
    return [
      {
        'id': 'sup-001',
        'name': 'Al-Marai Camel Farm',
        'code': 'AMC-001',
        'contact_name': 'Ahmed Al-Saud',
        'phone_number': '+966500000001',
        'email': 'contact@almarai.com',
        'address': 'Riyadh, Saudi Arabia',
        'supplier_type': 'raw_milk',
        'quality_rating': 4.8,
        'delivery_rating': 4.7,
        'performance_metrics': {
          'quality_score': 4.8,
          'delivery_score': 4.7,
          'price_score': 4.5,
          'overall_score': 4.7,
        },
        'certifications': ['ISO 22000', 'SASO'],
        'payment_terms': 'Net 30',
        'is_active': true,
        'created_at': DateTime.now()
            .subtract(const Duration(days: 100))
            .toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];
  }

  /// Mock: Get purchase orders
  List<Map<String, dynamic>> getMockPurchaseOrders() {
    return [
      // Approved PO (printable)
      {
        'id': 'po-001',
        'supplierId': 'sup-001',
        'orderNumber': 'PO-2024-001',
        'poNumber': 'PO-2024-001',
        'status': 'approved',
        'paymentStatus': 'paid',
        'orderDate':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'requestDate':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'deliveryDate':
            DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'items': [
          {
            'id': 'poi-001',
            'itemId': 'inv-001',
            'itemName': 'Camel Milk',
            'quantity': 500.0,
            'unit': 'Liters',
            'unitPrice': 6.5,
            'totalPrice': 3250.0,
            'requiredByDate':
                DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          },
        ],
        'totalAmount': 3250.0,
        'notes': 'Urgent delivery',
        'reasonForRequest': 'Stock replenishment',
        'intendedUse': 'Production',
        'quantityJustification': 'Based on forecasted demand',
        'supportingDocuments': [],
        'approvalDate':
            DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'approvedBy': 'manager-001',
      },
      // Declined PO
      {
        'id': 'po-002',
        'supplierId': 'sup-002',
        'orderNumber': 'PO-2024-002',
        'poNumber': 'PO-2024-002',
        'status': 'declined',
        'paymentStatus': 'pending',
        'orderDate':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'requestDate':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'deliveryDate':
            DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'items': [
          {
            'id': 'poi-002',
            'itemId': 'inv-002',
            'itemName': 'Laban',
            'quantity': 200.0,
            'unit': 'Liters',
            'unitPrice': 4.2,
            'totalPrice': 840.0,
            'requiredByDate':
                DateTime.now().add(const Duration(days: 10)).toIso8601String(),
          },
        ],
        'totalAmount': 840.0,
        'notes': 'Supplier could not meet requirements',
        'reasonForRequest': 'New product trial',
        'intendedUse': 'R&D',
        'quantityJustification': 'Small batch for testing',
        'supportingDocuments': [],
        'approvalDate': null,
        'approvedBy': null,
      },
      // Pending PO
      {
        'id': 'po-003',
        'supplierId': 'sup-003',
        'orderNumber': 'PO-2024-003',
        'poNumber': 'PO-2024-003',
        'status': 'pending',
        'paymentStatus': 'pending',
        'orderDate':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'requestDate':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'deliveryDate':
            DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'items': [
          {
            'id': 'poi-003',
            'itemId': 'inv-003',
            'itemName': 'Jibnah',
            'quantity': 100.0,
            'unit': 'Kg',
            'unitPrice': 12.5,
            'totalPrice': 1250.0,
            'requiredByDate':
                DateTime.now().add(const Duration(days: 14)).toIso8601String(),
          },
        ],
        'totalAmount': 1250.0,
        'notes': 'Awaiting approval from finance',
        'reasonForRequest': 'Seasonal demand',
        'intendedUse': 'Sales',
        'quantityJustification': 'Expected increase in orders',
        'supportingDocuments': [],
        'approvalDate': null,
        'approvedBy': null,
      },
    ];
  }

  /// Mock: Get procurement plans
  List<Map<String, dynamic>> getMockProcurementPlans() {
    return [
      {
        'id': 'plan-001',
        'name': 'Q2 Raw Milk Procurement',
        'creationDate':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'createdBy': 'user-001',
        'status': 'approved',
        'items': [
          {
            'id': 'ppi-001',
            'itemId': 'inv-001',
            'itemName': 'Camel Milk',
            'quantity': 1000.0,
            'unit': 'Liters',
            'preferredSupplierId': 'sup-001',
            'preferredSupplierName': 'Al-Marai Camel Farm',
            'estimatedUnitCost': 6.5,
            'estimatedTotalCost': 6500.0,
            'requiredByDate':
                DateTime.now().add(const Duration(days: 10)).toIso8601String(),
            'urgency': 'high',
          },
        ],
        'estimatedTotalCost': 6500.0,
        'notes': 'Plan for Q2 production',
        'approvalDate':
            DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'approvedBy': 'manager-001',
        'budgetLimit': 10000.0,
        'requiredByDate':
            DateTime.now().add(const Duration(days: 10)).toIso8601String(),
      },
    ];
  }

  /// Mock: Get supplier contracts
  List<Map<String, dynamic>> getMockSupplierContracts() {
    return [
      {
        'id': 'contract-001',
        'contract_number': 'C-2024-001',
        'contract_type': 'supply',
        'contract_date':
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'start_date':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'end_date':
            DateTime.now().add(const Duration(days: 335)).toIso8601String(),
        'supplier_id': 'sup-001',
        'supplier_name': 'Al-Marai Camel Farm',
        'terms_and_conditions': 'Standard supply contract terms',
        'pricing_schedules': 'Fixed price for 2024',
        'material_quality_specifications': 'ISO 22000, SASO',
        'delivery_requirements': 'Monthly delivery',
        'special_conditions': null,
        'notes': 'Renewal option included',
        'created_at':
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];
  }

  /// Mock: Get quality logs
  List<Map<String, dynamic>> getMockQualityLogs() {
    return [
      {
        'id': 'ql-001',
        'supplierId': 'sup-001',
        'date':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'qualityScore': 4.7,
        'notes': 'Batch passed all quality checks',
      },
    ];
  }

  /// Mock: Get performance metrics
  List<Map<String, dynamic>> getMockPerformanceMetrics() {
    return [
      {
        'id': 'pm-001',
        'supplierId': 'sup-001',
        'date':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'qualityScore': 4.8,
        'deliveryScore': 4.7,
        'priceScore': 4.5,
        'overallScore': 4.7,
        'notes': 'Consistent high performance',
      },
    ];
  }
}

/// Extension to add reset functionality to the MockAnalyticsData class
extension MockAnalyticsDataReset on MockAnalyticsData {
  void reset() {
    // Reset analytics data if needed
  }
}

/// Provider for the mock data service
final mockDataServiceProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});
