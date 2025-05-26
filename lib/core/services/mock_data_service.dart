/*import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/data/mock_analytics_data.dart';
import '../../features/factory/equipment_maintenance/data/models/equipment_model.dart';
import '../../features/factory/equipment_maintenance/data/models/maintenance_models.dart';
import '../../features/factory/equipment_maintenance/data/models/maintenance_record_model.dart';
import '../../features/inventory/data/models/inventory_item_model.dart'
    hide QualityStatus;
import '../../features/inventory/data/models/inventory_location_model.dart';
import '../../features/inventory/data/models/inventory_movement_item_model.dart';
import '../../features/inventory/data/models/inventory_movement_model.dart';
import '../../features/inventory/data/models/inventory_movement_type.dart';
import '../../features/inventory/data/models/quality_status.dart';
import '../../features/inventory/data/models/location_model.dart';

/// Global singleton service to provide centralized mock data
/// This ensures mock data is synchronized between all modules
class MockDataService {
  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();
  // Singleton pattern implementation
  static final MockDataService _instance = MockDataService._internal();

  // Mock inventory items - shared across inventory features and modules
  final List<InventoryItemModel> inventoryItems = [
    // Commented out as it's no longer needed
    /*
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
    */
  ];

  // Mock inventory locations - shared across inventory features
  final List<LocationModel> inventoryLocations = [
    LocationModel.inventory(
      locationId: 'loc-001',
      locationName: 'Cold Storage A (مخزن بارد أ)',
      locationType: LocationType.coldStorage,
      temperatureCondition: '4°C',
      storageCapacity: 2000.0,
      currentUtilization: 1200.0,
      isActive: true,
    ),
    LocationModel.inventory(
      locationId: 'loc-002',
      locationName: 'Cold Storage B (مخزن بارد ب)',
      locationType: LocationType.coldStorage,
      temperatureCondition: '4°C',
      storageCapacity: 1800.0,
      currentUtilization: 900.0,
      isActive: true,
    ),
    LocationModel.inventory(
      locationId: 'loc-003',
      locationName: 'Dry Storage (مخزن جاف)',
      locationType: LocationType.dryStorage,
      temperatureCondition: '22°C',
      storageCapacity: 3000.0,
      currentUtilization: 1500.0,
      isActive: true,
    ),
    LocationModel.inventory(
      locationId: 'loc-004',
      locationName: 'Freezer (مجمد)',
      locationType: LocationType.freezer,
      temperatureCondition: '-18°C',
      storageCapacity: 1500.0,
      currentUtilization: 600.0,
      isActive: true,
    ),
    LocationModel.inventory(
      locationId: 'loc-005',
      locationName: 'Production Area (منطقة الإنتاج)',
      locationType: LocationType.productionArea,
      temperatureCondition: '18°C',
      storageCapacity: 800.0,
      currentUtilization: 400.0,
      isActive: true,
    ),
    LocationModel.inventory(
      locationId: 'loc-006',
      locationName: 'Quality Control (مراقبة الجودة)',
      locationType: LocationType.qualityControl,
      temperatureCondition: '20°C',
      storageCapacity: 300.0,
      currentUtilization: 100.0,
      isActive: true,
    ),
    LocationModel.inventory(
      locationId: 'loc-007',
      locationName: 'Dispatch Area (منطقة الشحن)',
      locationType: LocationType.dispatchArea,
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
      movementType: InventoryMovementType.PO_RECEIPT,
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
      movementType: InventoryMovementType.PRODUCTION_ISSUE,
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
      movementType: InventoryMovementType.TRANSFER_IN,
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
      movementType: InventoryMovementType.PRODUCTION_ISSUE,
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
      movementType: InventoryMovementType.PO_RECEIPT,
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
      movementType: InventoryMovementType.TRANSFER_IN,
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
      movementType: InventoryMovementType.ADJUSTMENT_OTHER,
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
      movementType: InventoryMovementType.ADJUSTMENT_OTHER,
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
      movementType: InventoryMovementType.PO_RECEIPT,
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
      movementType: InventoryMovementType.PO_RECEIPT,
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
      movementType: InventoryMovementType.PRODUCTION_ISSUE,
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
      movementType: InventoryMovementType.TRANSFER_IN,
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
      movementType: InventoryMovementType.ADJUSTMENT_OTHER,
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

  /// Check if inventory has enough for a BOM (mock: always true)
  bool checkInventoryForBom(String bomId, double batchSize) {
    // Mock implementation: always return true
    return true;
  }

  /// Get BOM ingredients (mock: returns a list of maps)
  List<Map<String, dynamic>> getBomIngredients(String bomId) {
    // Mock implementation: return sample ingredients
    return bomIngredients[bomId] ?? [];
  }

  /// Mock BOM ingredients by BOM ID
  Map<String, List<Map<String, dynamic>>> get bomIngredients => {
        'bom-001': [
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
        'bom-002': [
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
        'bom-003': [
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
*/
