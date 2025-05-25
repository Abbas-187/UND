/*import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:und/features/inventory/data/models/inventory_movement_model.dart';
import 'package:und/features/inventory/domain/entities/cost_layer.dart';
import 'package:und/features/inventory/domain/entities/inventory_item.dart';
import 'package:und/features/inventory/domain/usecases/calculate_outbound_movement_cost_usecase.dart';
import 'package:und/features/inventory/domain/usecases/calculate_weighted_average_cost_usecase.dart';
import 'package:und/features/inventory/domain/usecases/generate_inventory_valuation_report_usecase.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Inventory Costing E2E Tests', () {
    late MockInventoryRepository mockRepository;
    late CalculateWeightedAverageCostUseCase wacUseCase;
    late CalculateOutboundMovementCostUseCase outboundCostUseCase;
    late GenerateInventoryValuationReportUseCase valuationReportUseCase;

    final testDate = DateTime(2025, 5, 1);

    setUp(() {
      mockRepository = MockInventoryRepository();
      wacUseCase = CalculateWeightedAverageCostUseCase(mockRepository);
      outboundCostUseCase =
          CalculateOutboundMovementCostUseCase(mockRepository);
      valuationReportUseCase =
          GenerateInventoryValuationReportUseCase(mockRepository);
    });

    test('E2E: Complete inventory flow with multiple costing methods',
        () async {
      // Setup initial inventory
      final item = InventoryItem(
        id: 'item1',
        appItemId: 'APP001',
        sapCode: 'PROD001',
        name: 'Test Product',
        category: 'Test Category',
        unit: 'PCS',
        quantity: 0,
        minimumQuantity: 10,
        reorderPoint: 50,
        location: 'MAIN',
        lastUpdated: testDate,
        cost: null, // Start with no cost
      );

      when(mockRepository.getItems()).thenAnswer((_) async => [item]);
      when(mockRepository.getItemCurrentQuantity('item1', 'MAIN'))
          .thenAnswer((_) async => 0.0);

      // 1. First Receipt: 100 units @ $10
      final receipt1 = InventoryMovementModel(
        id: 'receipt1',
        movementType: InventoryMovementType.receipt,
        warehouseId: 'MAIN',
        sourceDocumentId: 'PO001',
        sourceDocumentType: 'PURCHASE_ORDER',
        status: InventoryMovementStatus.completed,
        createdAt: testDate.subtract(const Duration(days: 30)),
        completedAt: testDate.subtract(const Duration(days: 30)),
        items: [
          InventoryMovementItemModel(
            id: 'receipt1-item1',
            itemId: 'item1',
            quantity: 100,
            costAtTransaction: 10.0,
            batchLotNumber: 'BATCH001',
          ),
        ],
        notes: 'Initial receipt',
      );

      // Setup WAC calculation for first receipt
      when(mockRepository.getItemWeightedAverageCost('item1', 'MAIN'))
          .thenAnswer((_) async => null); // No previous cost

      // Calculate first WAC
      final wacResult1 = await wacUseCase.execute(
        movement: receipt1,
        itemId: 'item1',
        warehouseId: 'MAIN',
      );

      // First cost layer after receipt1
      final costLayer1 = CostLayer(
        id: 'layer1',
        itemId: 'item1',
        warehouseId: 'MAIN',
        batchLotNumber: 'BATCH001',
        initialQuantity: 100,
        remainingQuantity: 100,
        costAtTransaction: 10.0,
        movementId: 'receipt1',
        movementDate: testDate.subtract(const Duration(days: 30)),
        createdAt: testDate.subtract(const Duration(days: 30)),
      );

      // Update item with new WAC
      final updatedItem1 = item.copyWith(
        quantity: 100,
        cost: wacResult1.newWeightedAverageCost,
      );

      // 2. Second Receipt: 50 units @ $12
      final receipt2 = InventoryMovementModel(
        id: 'receipt2',
        movementType: InventoryMovementType.receipt,
        warehouseId: 'MAIN',
        sourceDocumentId: 'PO002',
        sourceDocumentType: 'PURCHASE_ORDER',
        status: InventoryMovementStatus.completed,
        createdAt: testDate.subtract(const Duration(days: 15)),
        completedAt: testDate.subtract(const Duration(days: 15)),
        items: [
          InventoryMovementItemModel(
            id: 'receipt2-item1',
            itemId: 'item1',
            quantity: 50,
            costAtTransaction: 12.0,
            batchLotNumber: 'BATCH002',
          ),
        ],
        notes: 'Second receipt',
      );

      // Setup WAC calculation for second receipt
      when(mockRepository.getItemWeightedAverageCost('item1', 'MAIN'))
          .thenAnswer((_) async => 10.0);
      when(mockRepository.getItemCurrentQuantity('item1', 'MAIN'))
          .thenAnswer((_) async => 100.0);

      // Calculate second WAC
      final wacResult2 = await wacUseCase.execute(
        movement: receipt2,
        itemId: 'item1',
        warehouseId: 'MAIN',
      );

      // Second cost layer after receipt2
      final costLayer2 = CostLayer(
        id: 'layer2',
        itemId: 'item1',
        warehouseId: 'MAIN',
        batchLotNumber: 'BATCH002',
        initialQuantity: 50,
        remainingQuantity: 50,
        costAtTransaction: 12.0,
        movementId: 'receipt2',
        movementDate: testDate.subtract(const Duration(days: 15)),
        createdAt: testDate.subtract(const Duration(days: 15)),
      );

      // Update item with new WAC
      final updatedItem2 = updatedItem1.copyWith(
        quantity: 150,
        cost: wacResult2.newWeightedAverageCost,
      );

      // 3. Issue: 120 units
      final issue = InventoryMovementModel(
        id: 'issue1',
        movementType: InventoryMovementType.issue,
        warehouseId: 'MAIN',
        sourceDocumentId: 'SO001',
        sourceDocumentType: 'SALES_ORDER',
        status: InventoryMovementStatus.completed,
        createdAt: testDate,
        completedAt: testDate,
        items: [
          InventoryMovementItemModel(
            id: 'issue1-item1',
            itemId: 'item1',
            quantity: -120, // Negative for outbound
          ),
        ],
        notes: 'Issue to sales order',
      );

      // Setup FIFO cost calculation for issue
      when(mockRepository.getAvailableCostLayers(
        'item1',
        'MAIN',
        CostingMethod.fifo,
      )).thenAnswer((_) async => [costLayer1, costLayer2]);

      // Setup LIFO cost calculation for issue
      when(mockRepository.getAvailableCostLayers(
        'item1',
        'MAIN',
        CostingMethod.lifo,
      )).thenAnswer((_) async => [costLayer2, costLayer1]);

      // Calculate issue cost using FIFO
      final fifoCostResult = await outboundCostUseCase.execute(
        movement: issue,
        costingMethod: CostingMethod.fifo,
      );

      // Calculate issue cost using LIFO
      final lifoCostResult = await outboundCostUseCase.execute(
        movement: issue,
        costingMethod: CostingMethod.lifo,
      );

      // Final inventory state after issue
      final updatedItem3 = updatedItem2.copyWith(
        quantity: 30,
      );

      // Setup remaining cost layers after issue
      final remainingFifoLayer = costLayer2.copyWith(
        remainingQuantity:
            30, // 50 - 20 = 30 (consumed 100 from first layer, 20 from second)
      );

      final remainingLifoLayer = costLayer1.copyWith(
        remainingQuantity:
            30, // 100 - 70 = 30 (consumed 50 from second layer, 70 from first)
      );

      // Setup valuation report after issue - FIFO
      when(mockRepository.getItems()).thenAnswer((_) async => [updatedItem3]);
      when(mockRepository.getAvailableCostLayers(
        'item1',
        '',
        CostingMethod.fifo,
      )).thenAnswer((_) async => [remainingFifoLayer]);

      // Setup valuation report after issue - LIFO
      when(mockRepository.getAvailableCostLayers(
        'item1',
        '',
        CostingMethod.lifo,
      )).thenAnswer((_) async => [remainingLifoLayer]);

      // Generate valuation reports
      final fifoValuationReport = await valuationReportUseCase.execute(
        costingMethod: CostingMethod.fifo,
        asOfDate: testDate,
      );

      final lifoValuationReport = await valuationReportUseCase.execute(
        costingMethod: CostingMethod.lifo,
        asOfDate: testDate,
      );

      // Setup for comparative report
      when(mockRepository.getAvailableCostLayers(
        'item1',
        '',
        CostingMethod.wac,
      )).thenAnswer((_) async => []);

      // Generate comparative report
      final comparativeReport =
          await valuationReportUseCase.generateComparativeReport(
        asOfDate: testDate,
      );

      // FIFO assertions
      expect(fifoCostResult.totalCost,
          1240.0); // (100 × $10) + (20 × $12) = $1,240
      expect(fifoCostResult.averageCostPerUnit, 10.33, closeTo(10.33, 0.01));
      expect(fifoValuationReport.totalValue, 360.0); // 30 × $12 = $360

      // LIFO assertions
      expect(
          lifoCostResult.totalCost, 1300.0); // (50 × $12) + (70 × $10) = $1,300
      expect(lifoCostResult.averageCostPerUnit, 10.83, closeTo(10.83, 0.01));
      expect(lifoValuationReport.totalValue, 300.0); // 30 × $10 = $300

      // WAC assertions
      expect(wacResult2.newWeightedAverageCost, 10.67, closeTo(10.67, 0.01));

      // Comparative report assertions
      expect(comparativeReport.fifoTotalValue, 360.0);
      expect(comparativeReport.lifoTotalValue, 300.0);
      expect(comparativeReport.entries.first.fifoLifoDifference, 60.0);
    });

    test('E2E: Edge cases for inventory costing methods', () async {
      // Setup test warehouse and item
      const warehouseId = 'warehouse001';
      const itemId = 'item001';

      // Setup initial inventory item
      final inventoryItem = InventoryItem(
        id: itemId,
        appItemId: 'APP001',
        name: 'Test Item Edge Cases',
        category: 'Test Category',
        unit: 'EA',
        quantity: 0,
        minimumQuantity: 5,
        reorderPoint: 10,
        location: 'Bin A1',
        lastUpdated: testDate,
        cost: 0.0,
      );

      // Mock the repository methods
      when(mockRepository.getItem(itemId))
          .thenAnswer((_) async => inventoryItem);
      when(mockRepository.updateItem(any)).thenAnswer((invocation) async =>
          invocation.positionalArguments[0] as InventoryItem);

      // Edge Case 1: Zero initial quantity, first receipt
      // Setup receipt movement with zero cost
      final zeroCostReceipt = InventoryMovementModel(
        id: 'mov001',
        movementType: InventoryMovementType.receipt,
        warehouseId: warehouseId,
        timestamp: testDate,
        items: [
          InventoryMovementItemModel(
            itemId: itemId,
            itemCode: 'CODE001',
            itemName: 'Test Item Edge Cases',
            uom: 'EA',
            quantity: 50,
            costAtTransaction: 0.0, // Zero cost
            batchLotNumber: 'BATCH001',
          )
        ],
        createdBy: 'user001',
        notes: 'Zero cost receipt',
      );

      // Mock cost layers for zero cost
      final zeroCostLayers = [
        CostLayer(
          id: 'layer001',
          itemId: itemId,
          warehouseId: warehouseId,
          batchLotNumber: 'BATCH001',
          initialQuantity: 50,
          remainingQuantity: 50,
          costAtTransaction: 0.0,
          movementId: 'mov001',
          movementDate: testDate,
          createdAt: testDate,
        ),
      ];

      when(mockRepository.getAvailableCostLayers(
              itemId, warehouseId, CostingMethod.fifo))
          .thenAnswer((_) async => zeroCostLayers);

      // Test WAC calculation with zero cost
      final wacZeroCost = await wacUseCase.execute(
        movement: zeroCostReceipt,
        itemId: itemId,
        warehouseId: warehouseId,
      );

      // Verify WAC with zero cost
      expect(wacZeroCost.newWeightedAverageCost, 0.0);

      // Edge Case 2: Return of goods (negative cost impact)
      // Setup return movement
      final returnMovement = InventoryMovementModel(
        id: 'mov002',
        movementType: InventoryMovementType.return_,
        warehouseId: warehouseId,
        timestamp: testDate.add(Duration(days: 1)),
        items: [
          InventoryMovementItemModel(
            itemId: itemId,
            itemCode: 'CODE001',
            itemName: 'Test Item Edge Cases',
            uom: 'EA',
            quantity: 10,
            costAtTransaction: 15.0, // Return cost
            batchLotNumber: 'BATCH002',
          )
        ],
        createdBy: 'user001',
        notes: 'Return movement',
      );

      // Mock cost layers after return
      final returnCostLayers = [
        CostLayer(
          id: 'layer001',
          itemId: itemId,
          warehouseId: warehouseId,
          batchLotNumber: 'BATCH001',
          initialQuantity: 50,
          remainingQuantity: 50,
          costAtTransaction: 0.0,
          movementId: 'mov001',
          movementDate: testDate,
          createdAt: testDate,
        ),
        CostLayer(
          id: 'layer002',
          itemId: itemId,
          warehouseId: warehouseId,
          batchLotNumber: 'BATCH002',
          initialQuantity: 10,
          remainingQuantity: 10,
          costAtTransaction: 15.0,
          movementId: 'mov002',
          movementDate: testDate.add(Duration(days: 1)),
          createdAt: testDate.add(Duration(days: 1)),
        ),
      ];

      // Mock updated item after return
      final updatedItem = inventoryItem.copyWith(
        quantity: 60,
        cost: 2.5, // (50*0 + 10*15) / 60 = 2.5
      );

      when(mockRepository.getItem(itemId)).thenAnswer((_) async => updatedItem);
      when(mockRepository.getAvailableCostLayers(
              itemId, warehouseId, CostingMethod.fifo))
          .thenAnswer((_) async => returnCostLayers);
      when(mockRepository.getAvailableCostLayers(
              itemId, warehouseId, CostingMethod.lifo))
          .thenAnswer((_) async => [...returnCostLayers].reversed.toList());

      // Edge Case 3: Partial consumption with insufficient stock
      // Setup outbound movement requesting more than available
      final largeOutboundMovement = InventoryMovementModel(
        id: 'mov003',
        movementType: InventoryMovementType.issue,
        warehouseId: warehouseId,
        timestamp: testDate.add(Duration(days: 2)),
        items: [
          InventoryMovementItemModel(
            itemId: itemId,
            itemCode: 'CODE001',
            itemName: 'Test Item Edge Cases',
            uom: 'EA',
            quantity: -100, // More than available
            batchLotNumber: 'N/A',
          )
        ],
        createdBy: 'user001',
        notes: 'Oversized issue',
      );

      // Test outbound cost calculation with insufficient stock
      final oversizedResult = await outboundCostUseCase.execute(
        movement: largeOutboundMovement,
        costingMethod: CostingMethod.fifo,
      );

      // Verify partial fulfillment behavior
      expect(oversizedResult.isPartial, true);
      expect(oversizedResult.requestedQuantity, 100);
      expect(oversizedResult.actualQuantity, 60); // Only 60 available
      expect(oversizedResult.totalCost,
          15 * 10); // 10 units @ $15 from return batch

      // Edge Case 4: Zero quantity report
      when(mockRepository.getInventoryItems(warehouseId))
          .thenAnswer((_) async => [updatedItem.copyWith(quantity: 0)]);

      final emptyReport = await valuationReportUseCase.execute(
        warehouseId: warehouseId,
        costingMethod: CostingMethod.fifo,
      );

      // Verify zero quantity report
      expect(emptyReport.entries.isEmpty, true);
      expect(emptyReport.totalValue, 0);
    });
  });
}
*/
