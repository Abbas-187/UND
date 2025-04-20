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
  ];

  // Sample forecasting data for inventory items
  final Map<String, List<Map<String, dynamic>>> inventoryForecasts = {
    'inv-001': [
      // Camel Milk
      {
        'date': DateTime.now().add(const Duration(days: 1)),
        'forecastedValue': 120.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 2)),
        'forecastedValue': 135.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 3)),
        'forecastedValue': 110.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 4)),
        'forecastedValue': 125.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 5)),
        'forecastedValue': 150.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 6)),
        'forecastedValue': 140.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 7)),
        'forecastedValue': 105.0
      },
    ],
    'inv-002': [
      // Laban
      {
        'date': DateTime.now().add(const Duration(days: 1)),
        'forecastedValue': 45.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 2)),
        'forecastedValue': 50.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 3)),
        'forecastedValue': 48.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 4)),
        'forecastedValue': 52.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 5)),
        'forecastedValue': 55.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 6)),
        'forecastedValue': 49.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 7)),
        'forecastedValue': 47.0
      },
    ],
    'inv-003': [
      // Jibnah
      {
        'date': DateTime.now().add(const Duration(days: 1)),
        'forecastedValue': 18.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 2)),
        'forecastedValue': 20.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 3)),
        'forecastedValue': 22.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 4)),
        'forecastedValue': 19.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 5)),
        'forecastedValue': 21.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 6)),
        'forecastedValue': 23.0
      },
      {
        'date': DateTime.now().add(const Duration(days: 7)),
        'forecastedValue': 20.0
      },
    ],
  };

  // Recipe ingredients mapping to inventory items
  final Map<String, List<Map<String, dynamic>>> recipeIngredients = {
    'recipe-001': [
      // Laban Production
      {
        'ingredientId': 'inv-001',
        'name': 'Camel Milk (حليب الإبل)',
        'quantity': 1.0,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-006',
        'name': 'Saffron (زعفران)',
        'quantity': 0.1,
        'unit': 'g'
      },
      {
        'ingredientId': 'inv-010',
        'name': 'Halal-Certified Containers 500ml',
        'quantity': 2,
        'unit': 'Units'
      },
    ],
    'recipe-002': [
      // Date Flavored Laban
      {
        'ingredientId': 'inv-001',
        'name': 'Camel Milk (حليب الإبل)',
        'quantity': 1.0,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-005',
        'name': 'Date Syrup (دبس التمر)',
        'quantity': 0.08,
        'unit': 'Kg'
      },
      {
        'ingredientId': 'inv-008',
        'name': 'Dates (تمر)',
        'quantity': 0.1,
        'unit': 'Kg'
      },
      {
        'ingredientId': 'inv-010',
        'name': 'Halal-Certified Containers 500ml',
        'quantity': 2,
        'unit': 'Units'
      },
    ],
    'recipe-003': [
      // Traditional Jibnah
      {
        'ingredientId': 'inv-001',
        'name': 'Camel Milk (حليب الإبل)',
        'quantity': 10.0,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-006',
        'name': 'Saffron (زعفران)',
        'quantity': 0.2,
        'unit': 'g'
      },
    ],
    'recipe-004': [
      // Plain Cow Milk
      {
        'ingredientId': 'inv-014',
        'name': 'Cow Milk',
        'quantity': 1.0,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-011',
        'name': 'Traditional Glass Bottles 1L',
        'quantity': 1,
        'unit': 'Units'
      },
    ],
    'recipe-005': [
      // Strawberry Milk
      {
        'ingredientId': 'inv-014',
        'name': 'Cow Milk',
        'quantity': 0.95,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-015',
        'name': 'Strawberry Syrup',
        'quantity': 0.05,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-011',
        'name': 'Traditional Glass Bottles 1L',
        'quantity': 1,
        'unit': 'Units'
      },
    ],
    'recipe-006': [
      // Chocolate Milk
      {
        'ingredientId': 'inv-014',
        'name': 'Cow Milk',
        'quantity': 0.98,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-016',
        'name': 'Chocolate Powder',
        'quantity': 0.02,
        'unit': 'Kg'
      },
      {
        'ingredientId': 'inv-011',
        'name': 'Traditional Glass Bottles 1L',
        'quantity': 1,
        'unit': 'Units'
      },
    ],
    'recipe-007': [
      // Banana Milk
      {
        'ingredientId': 'inv-014',
        'name': 'Cow Milk',
        'quantity': 0.97,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-017',
        'name': 'Banana Extract',
        'quantity': 0.03,
        'unit': 'Liters'
      },
      {
        'ingredientId': 'inv-011',
        'name': 'Traditional Glass Bottles 1L',
        'quantity': 1,
        'unit': 'Units'
      },
    ],
  };

  // Procurement needs based on inventory
  final List<Map<String, dynamic>> procurementNeeds = [
    {
      'itemId': 'inv-014',
      'name': 'Cow Milk',
      'currentStock': 250.0,
      'reorderPoint': 350.0,
      'recommendedOrder': 300.0,
      'unit': 'Liters',
      'suggestedSupplier': 'Al-Marai Dairy Supplies',
      'estimatedCost': 1350.0,
      'priority': 'High',
      'supplierLocation': 'Riyadh',
      'halal': true,
      'organicCertified': true,
    },
    {
      'itemId': 'inv-002',
      'name': 'Laban (لبن)',
      'currentStock': 110.0,
      'reorderPoint': 150.0,
      'recommendedOrder': 100.0,
      'unit': 'Liters',
      'suggestedSupplier': 'Al-Marai Dairy Supplies',
      'estimatedCost': 420.0,
      'priority': 'Medium',
      'supplierLocation': 'Riyadh',
      'halal': true,
    },
    {
      'itemId': 'inv-015',
      'name': 'Strawberry Syrup',
      'currentStock': 8.0,
      'reorderPoint': 15.0,
      'recommendedOrder': 20.0,
      'unit': 'Liters',
      'suggestedSupplier': 'Gulf Ingredients Trading',
      'estimatedCost': 240.0,
      'priority': 'Medium',
      'supplierLocation': 'Dammam',
      'halal': true,
    },
  ];

  // Shared analytics data using the existing MockAnalyticsData class
  final MockAnalyticsData analyticsData = MockAnalyticsData();

  // Methods to sync inventory with milk reception
  void syncMilkReceptionWithInventory(dynamic reception) {
    // Find matching inventory item for raw milk
    int milkItemIndex = inventoryItems.indexWhere(
      (item) => item.name.contains('Milk') && item.name.contains('Fresh'),
    );

    if (milkItemIndex >= 0) {
      // Update inventory quantity based on milk reception
      var currentItem = inventoryItems[milkItemIndex];
      inventoryItems[milkItemIndex] = InventoryItemModel(
        id: currentItem.id,
        name: currentItem.name,
        category: currentItem.category,
        unit: currentItem.unit,
        quantity: currentItem.quantity + (reception.quantityLiters ?? 0),
        minimumQuantity: currentItem.minimumQuantity,
        reorderPoint: currentItem.reorderPoint,
        location: currentItem.location,
        lastUpdated: DateTime.now(),
        batchNumber: currentItem.batchNumber,
        expiryDate: currentItem.expiryDate,
        cost: currentItem.cost,
        currentTemperature: currentItem.currentTemperature,
        storageCondition: currentItem.storageCondition,
        overallQualityStatus: currentItem.overallQualityStatus,
      );
    }
  }

  // Update inventory item and propagate changes
  void updateInventoryItem(InventoryItemModel updatedItem) {
    int itemIndex =
        inventoryItems.indexWhere((item) => item.id == updatedItem.id);
    if (itemIndex >= 0) {
      inventoryItems[itemIndex] = updatedItem;
      // Here we would update any related data in other modules
    }
  }

  // Adjust inventory item quantity
  void adjustQuantity(String itemId, double adjustment, String reason) {
    final itemIndex = inventoryItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final item = inventoryItems[itemIndex];
      inventoryItems[itemIndex] = InventoryItemModel(
        id: item.id,
        name: item.name,
        category: item.category,
        unit: item.unit,
        quantity: item.quantity + adjustment,
        minimumQuantity: item.minimumQuantity,
        reorderPoint: item.reorderPoint,
        location: item.location,
        lastUpdated: DateTime.now(),
        batchNumber: item.batchNumber,
        expiryDate: item.expiryDate,
        cost: item.cost,
        currentTemperature: item.currentTemperature,
        storageCondition: item.storageCondition,
        overallQualityStatus: item.overallQualityStatus,
      );
    }
  }

  // Get recipe ingredients from inventory
  List<Map<String, dynamic>> getRecipeIngredients(String recipeId) {
    return recipeIngredients[recipeId] ?? [];
  }

  // Get forecast for an inventory item
  List<Map<String, dynamic>> getInventoryForecast(String itemId) {
    return inventoryForecasts[itemId] ?? [];
  }

  // Get procurement needs
  List<Map<String, dynamic>> getDetailedProcurementNeeds() {
    return [
      {
        'itemId': 'inv-014',
        'name': 'Cow Milk',
        'category': 'Dairy',
        'currentQuantity': 250.0,
        'reorderPoint': 350.0,
        'minimumQuantity': 300.0,
        'unit': 'Liters',
        'supplier': 'Al-Marai Dairy Supplies',
        'supplierId': 'supplier-001',
        'recommendedOrderQuantity': 300.0,
        'estimatedCost': 1350.0,
        'priority': 'high',
      },
      {
        'itemId': 'inv-002',
        'name': 'Laban (لبن)',
        'category': 'Dairy',
        'currentQuantity': 110.0,
        'reorderPoint': 150.0,
        'minimumQuantity': 100.0,
        'unit': 'Liters',
        'supplier': 'Al-Marai Dairy Supplies',
        'supplierId': 'supplier-001',
        'recommendedOrderQuantity': 100.0,
        'estimatedCost': 420.0,
        'priority': 'medium',
      },
      {
        'itemId': 'inv-015',
        'name': 'Strawberry Syrup',
        'category': 'Ingredients',
        'currentQuantity': 8.0,
        'reorderPoint': 15.0,
        'minimumQuantity': 10.0,
        'unit': 'Liters',
        'supplier': 'Gulf Ingredients Trading',
        'supplierId': 'supplier-003',
        'recommendedOrderQuantity': 20.0,
        'estimatedCost': 240.0,
        'priority': 'medium',
      }
    ];
  }

  // Calculate available inventory for recipe
  bool checkInventoryForRecipe(String recipeId, double batchSize) {
    final ingredients = recipeIngredients[recipeId] ?? [];
    for (final ingredient in ingredients) {
      final itemId = ingredient['ingredientId'] as String;
      final requiredQuantity = (ingredient['quantity'] as double) * batchSize;

      // Find item in inventory
      final inventoryItem = inventoryItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => InventoryItemModel(
            id: 'not-found',
            name: 'Not Found',
            category: 'Unknown',
            unit: 'N/A',
            quantity: 0,
            minimumQuantity: 0,
            reorderPoint: 0,
            location: 'Unknown',
            lastUpdated: DateTime.now()),
      );

      // Check if we have enough
      if (inventoryItem.quantity < requiredQuantity) {
        return false;
      }
    }
    return true;
  }

  /// Get mock suppliers data
  List<Map<String, dynamic>> getMockSuppliers() {
    return [
      {
        'id': 'supplier-001',
        'name': 'Al-Marai Dairy Supplies',
        'contactName': 'Mohammed Al-Otaibi',
        'email': 'contact@almarai-supply.com',
        'phone': '+966 11 123 4567',
        'address': 'Riyadh Industrial Area, Building 45',
        'city': 'Riyadh',
        'country': 'Saudi Arabia',
        'category': 'Dairy Supplies',
        'rating': 4.8,
        'status': 'active',
        'isVerified': true,
        'paymentTerms': 'Net 30',
        'notes': 'Reliable supplier for all dairy needs.'
      },
      {
        'id': 'supplier-002',
        'name': 'Najd Packaging Solutions',
        'contactName': 'Sara Al-Fahad',
        'email': 'info@najd-packaging.com',
        'phone': '+966 11 987 6543',
        'address': 'Jeddah Commercial District, Street 12',
        'city': 'Jeddah',
        'country': 'Saudi Arabia',
        'category': 'Packaging',
        'rating': 4.5,
        'status': 'active',
        'isVerified': true,
        'paymentTerms': 'Net 45',
        'notes': 'Specializes in food-grade packaging materials.'
      },
      {
        'id': 'supplier-003',
        'name': 'Gulf Ingredients Trading',
        'contactName': 'Abdullah Al-Qahtani',
        'email': 'sales@gulf-ingredients.com',
        'phone': '+966 13 456 7890',
        'address': 'Dammam Port Area, Warehouse 23',
        'city': 'Dammam',
        'country': 'Saudi Arabia',
        'category': 'Food Ingredients',
        'rating': 4.2,
        'status': 'active',
        'isVerified': true,
        'paymentTerms': 'Net 30',
        'notes': 'Wide range of imported and local ingredients.'
      },
      {
        'id': 'supplier-004',
        'name': 'Saudi Spice Merchants',
        'contactName': 'Fatima Al-Harbi',
        'email': 'orders@saudispice.com',
        'phone': '+966 12 345 6789',
        'address': 'Mecca Road, Building 78',
        'city': 'Mecca',
        'country': 'Saudi Arabia',
        'category': 'Spices & Flavorings',
        'rating': 4.7,
        'status': 'active',
        'isVerified': true,
        'paymentTerms': 'Net 15',
        'notes': 'Premium quality traditional spices and flavorings.'
      },
      {
        'id': 'supplier-005',
        'name': 'Desert Fruit Farms',
        'contactName': 'Khalid Al-Mutairi',
        'email': 'info@desertfruit.com',
        'phone': '+966 14 789 0123',
        'address': 'Al-Qassim Agricultural Zone, Farm 123',
        'city': 'Buraidah',
        'country': 'Saudi Arabia',
        'category': 'Fruits & Dates',
        'rating': 4.6,
        'status': 'active',
        'isVerified': true,
        'paymentTerms': 'Net 14',
        'notes': 'Local grower of dates and fruits.'
      }
    ];
  }

  /// Get mock purchase orders
  List<Map<String, dynamic>> getMockPurchaseOrders() {
    final now = DateTime.now();

    return [
      {
        'id': 'po-001',
        'poNumber': 'PO-2023-001',
        'procurementPlanId': 'plan-2023-Q1',
        'requestDate': now.subtract(const Duration(days: 15)),
        'requestedBy': 'Ahmed Al-Saud',
        'supplierId': 'supplier-001',
        'supplierName': 'Al-Marai Dairy Supplies',
        'status': 'completed',
        'items': [
          {
            'id': 'poi-001',
            'itemId': 'inv-001',
            'itemName': 'Camel Milk (حليب الإبل)',
            'quantity': 500.0,
            'unit': 'Liters',
            'unitPrice': 6.5,
            'totalPrice': 3250.0,
            'requiredByDate': now.subtract(const Duration(days: 10)),
            'notes': 'Premium quality camel milk'
          },
          {
            'id': 'poi-002',
            'itemId': 'inv-002',
            'itemName': 'Laban (لبن)',
            'quantity': 300.0,
            'unit': 'Liters',
            'unitPrice': 4.2,
            'totalPrice': 1260.0,
            'requiredByDate': now.subtract(const Duration(days: 10)),
            'notes': 'Fresh laban from trusted sources'
          }
        ],
        'totalAmount': 4510.0,
        'reasonForRequest': 'Regular stock replenishment',
        'intendedUse': 'Production of dairy products',
        'quantityJustification':
            'Based on production forecast for upcoming month',
        'supportingDocuments': [],
        'expectedDeliveryDate': now.subtract(const Duration(days: 8)),
      },
      {
        'id': 'po-002',
        'poNumber': 'PO-2023-002',
        'procurementPlanId': 'plan-2023-Q1',
        'requestDate': now.subtract(const Duration(days: 10)),
        'requestedBy': 'Fatima Al-Zahrani',
        'supplierId': 'supplier-002',
        'supplierName': 'Najd Packaging Solutions',
        'status': 'delivered',
        'items': [
          {
            'id': 'poi-003',
            'itemId': 'inv-010',
            'itemName': 'Halal-Certified Containers 500ml',
            'quantity': 1000.0,
            'unit': 'Units',
            'unitPrice': 0.25,
            'totalPrice': 250.0,
            'requiredByDate': now.subtract(const Duration(days: 5)),
            'notes': 'Standard packaging containers'
          },
          {
            'id': 'poi-004',
            'itemId': 'inv-011',
            'itemName': 'Traditional Glass Bottles 1L',
            'quantity': 800.0,
            'unit': 'Units',
            'unitPrice': 0.45,
            'totalPrice': 360.0,
            'requiredByDate': now.subtract(const Duration(days: 5)),
            'notes': 'For premium product line'
          }
        ],
        'totalAmount': 610.0,
        'reasonForRequest': 'Low packaging inventory',
        'intendedUse': 'Product packaging',
        'quantityJustification': 'Based on sales forecast for coming quarter',
        'supportingDocuments': [],
        'expectedDeliveryDate': now.subtract(const Duration(days: 3)),
      },
      {
        'id': 'po-003',
        'poNumber': 'PO-2023-003',
        'procurementPlanId': 'plan-2023-Q1',
        'requestDate': now.subtract(const Duration(days: 5)),
        'requestedBy': 'Khalid Al-Ghamdi',
        'supplierId': 'supplier-003',
        'supplierName': 'Gulf Ingredients Trading',
        'status': 'pending',
        'items': [
          {
            'id': 'poi-005',
            'itemId': 'inv-005',
            'itemName': 'Date Syrup (دبس التمر)',
            'quantity': 200.0,
            'unit': 'Kg',
            'unitPrice': 3.5,
            'totalPrice': 700.0,
            'requiredByDate': now.add(const Duration(days: 5)),
            'notes': 'For flavoring and sweetening'
          },
          {
            'id': 'poi-006',
            'itemId': 'inv-007',
            'itemName': 'Pure Water',
            'quantity': 15.0,
            'unit': 'Liters',
            'unitPrice': 9.5,
            'totalPrice': 142.5,
            'requiredByDate': now.add(const Duration(days: 5)),
            'notes': 'For premium dessert production'
          }
        ],
        'totalAmount': 842.5,
        'reasonForRequest': 'Specialty ingredients for new product line',
        'intendedUse': 'New dessert production',
        'quantityJustification': 'Initial production run plus safety stock',
        'supportingDocuments': [],
        'expectedDeliveryDate': now.add(const Duration(days: 7)),
      },
      {
        'id': 'po-004',
        'poNumber': 'PO-2023-004',
        'procurementPlanId': 'plan-2023-Q1',
        'requestDate': now.subtract(const Duration(days: 2)),
        'requestedBy': 'Nora Al-Dosari',
        'supplierId': 'supplier-004',
        'supplierName': 'Saudi Spice Merchants',
        'status': 'draft',
        'items': [
          {
            'id': 'poi-007',
            'itemId': 'inv-006',
            'itemName': 'Saffron (زعفران)',
            'quantity': 100.0,
            'unit': 'g',
            'unitPrice': 12.8,
            'totalPrice': 1280.0,
            'requiredByDate': now.add(const Duration(days: 10)),
            'notes': 'Premium quality saffron'
          },
          {
            'id': 'poi-008',
            'itemId': 'inv-012',
            'itemName': 'Cardamom (هيل)',
            'quantity': 20.0,
            'unit': 'Kg',
            'unitPrice': 18.5,
            'totalPrice': 370.0,
            'requiredByDate': now.add(const Duration(days: 10)),
            'notes': 'For flavor enhancement in dairy products'
          }
        ],
        'totalAmount': 1650.0,
        'reasonForRequest': 'Spice inventory running low',
        'intendedUse': 'Flavoring for various products',
        'quantityJustification': 'Based on production forecast',
        'supportingDocuments': [],
        'expectedDeliveryDate': now.add(const Duration(days: 12)),
      }
    ];
  }

  /// Get mock procurement plans
  List<Map<String, dynamic>> getMockProcurementPlans() {
    final now = DateTime.now();
    final quarter1Start = DateTime(now.year, 1, 1);
    final quarter1End = DateTime(now.year, 3, 31);
    final quarter2Start = DateTime(now.year, 4, 1);
    final quarter2End = DateTime(now.year, 6, 30);

    return [
      {
        'id': 'plan-2023-Q1',
        'title': 'Q1 Procurement Plan',
        'description':
            'Procurement plan for first quarter covering dairy and packaging supplies',
        'status': 'completed',
        'startDate': quarter1Start,
        'endDate': quarter1End,
        'budget': 25000.0,
        'actualSpent': 23450.0,
        'createdBy': 'Ahmed Al-Saud',
        'approvedBy': 'Mohammed Al-Rashid',
        'categories': ['Dairy', 'Packaging', 'Ingredients'],
        'notes': 'Plan completed successfully with 94% budget utilization',
      },
      {
        'id': 'plan-2023-Q2',
        'title': 'Q2 Procurement Plan',
        'description':
            'Procurement plan for second quarter with focus on specialty ingredients',
        'status': 'active',
        'startDate': quarter2Start,
        'endDate': quarter2End,
        'budget': 30000.0,
        'actualSpent': 12500.0,
        'createdBy': 'Fatima Al-Zahrani',
        'approvedBy': 'Mohammed Al-Rashid',
        'categories': ['Dairy', 'Packaging', 'Ingredients', 'Specialty Items'],
        'notes': 'Increased budget to accommodate new product line ingredients',
      }
    ];
  }

  /// Get mock supplier contracts
  List<Map<String, dynamic>> getMockSupplierContracts() {
    final now = DateTime.now();

    return [
      {
        'id': 'contract-001',
        'supplierId': 'supplier-001',
        'supplierName': 'Al-Marai Dairy Supplies',
        'title': 'Annual Dairy Supply Agreement',
        'contractNumber': 'CNT-2023-001',
        'status': 'active',
        'startDate': DateTime(now.year, 1, 1),
        'endDate': DateTime(now.year, 12, 31),
        'value': 75000.0,
        'paymentTerms': 'Net 30',
        'deliveryTerms': 'Weekly deliveries at buyer location',
        'categories': ['Dairy'],
        'contractType': 'Annual',
        'createdBy': 'Ahmed Al-Saud',
        'approvedBy': 'Mohammed Al-Rashid',
        'notes': 'Premium rates for high volume purchases',
      },
      {
        'id': 'contract-002',
        'supplierId': 'supplier-002',
        'supplierName': 'Najd Packaging Solutions',
        'title': 'Packaging Materials Supply Contract',
        'contractNumber': 'CNT-2023-002',
        'status': 'active',
        'startDate': DateTime(now.year, 2, 15),
        'endDate': DateTime(now.year + 1, 2, 14),
        'value': 35000.0,
        'paymentTerms': 'Net 45',
        'deliveryTerms': 'Monthly deliveries at buyer location',
        'categories': ['Packaging'],
        'contractType': 'Annual',
        'createdBy': 'Fatima Al-Zahrani',
        'approvedBy': 'Mohammed Al-Rashid',
        'notes': 'Exclusive supplier for custom packaging',
      }
    ];
  }

  /// Get mock quality logs
  List<Map<String, dynamic>> getMockQualityLogs() {
    final now = DateTime.now();

    return [
      {
        'id': 'qualitylog-001',
        'supplierId': 'supplier-001',
        'supplierName': 'Al-Marai Dairy Supplies',
        'purchaseOrderId': 'po-001',
        'inspectionDate': now.subtract(const Duration(days: 14)),
        'inspectedBy': 'Saleh Al-Otaibi',
        'qualityScore': 92,
        'status': 'passed',
        'notes': 'All items passed quality inspection',
        'issues': [],
        'correctiveActions': [],
      },
      {
        'id': 'qualitylog-002',
        'supplierId': 'supplier-002',
        'supplierName': 'Najd Packaging Solutions',
        'purchaseOrderId': 'po-002',
        'inspectionDate': now.subtract(const Duration(days: 7)),
        'inspectedBy': 'Saleh Al-Otaibi',
        'qualityScore': 85,
        'status': 'conditional-pass',
        'notes': 'Minor issues with packaging seal integrity',
        'issues': ['5% of containers had seal defects'],
        'correctiveActions': [
          'Supplier to replace defective units within 7 days'
        ],
      }
    ];
  }

  /// Get mock performance metrics
  List<Map<String, dynamic>> getMockPerformanceMetrics() {
    final now = DateTime.now();

    return [
      {
        'id': 'metrics-001',
        'supplierId': 'supplier-001',
        'supplierName': 'Al-Marai Dairy Supplies',
        'period': 'Q1',
        'year': now.year,
        'deliveryOnTimeRate': 95.0,
        'qualityConformanceRate': 98.0,
        'priceCompetitivenessScore': 85.0,
        'communicationResponseScore': 90.0,
        'overallPerformanceScore': 92.0,
        'evaluationDate': DateTime(now.year, 3, 31),
        'evaluatedBy': 'Ahmed Al-Saud',
        'notes':
            'Excellent supplier performance, recommended for continued partnership',
      },
      {
        'id': 'metrics-002',
        'supplierId': 'supplier-002',
        'supplierName': 'Najd Packaging Solutions',
        'period': 'Q1',
        'year': now.year,
        'deliveryOnTimeRate': 90.0,
        'qualityConformanceRate': 92.0,
        'priceCompetitivenessScore': 88.0,
        'communicationResponseScore': 94.0,
        'overallPerformanceScore': 91.0,
        'evaluationDate': DateTime(now.year, 3, 31),
        'evaluatedBy': 'Fatima Al-Zahrani',
        'notes': 'Good overall performance with minor delivery delays',
      }
    ];
  }

  // Sample mock procurement needs
  List<Map<String, dynamic>> getProcurementNeeds() {
    // Return mock procurement needs data
    return [
      {
        'itemId': 'inv-014',
        'name': 'Cow Milk',
        'category': 'Dairy',
        'currentQuantity': 250.0,
        'requiredQuantity': 300.0,
        'urgency': 'High',
        'estimatedCost': 1350.0,
        'notes': 'Required for milk production and flavored milk products'
      },
      {
        'itemId': 'inv-002',
        'name': 'Laban (لبن)',
        'category': 'Dairy',
        'currentQuantity': 110.0,
        'requiredQuantity': 100.0,
        'urgency': 'Medium',
        'estimatedCost': 420.0,
        'notes': 'Stock approaching reorder point, needed for daily production'
      },
      {
        'itemId': 'inv-015',
        'name': 'Strawberry Syrup',
        'category': 'Ingredients',
        'currentQuantity': 8.0,
        'requiredQuantity': 20.0,
        'urgency': 'Medium',
        'estimatedCost': 240.0,
        'notes': 'Required for strawberry milk production'
      }
    ];
  }
}

/// Provider for the mock data service
final mockDataServiceProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});
