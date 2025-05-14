/*import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:und/features/inventory/data/models/inventory_movement_item_model.dart';
import 'package:und/features/inventory/data/models/inventory_movement_model.dart';
import 'package:und/features/inventory/domain/entities/cost_layer.dart';
import 'package:und/features/inventory/domain/entities/inventory_item.dart';
import 'package:und/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:und/features/inventory/domain/usecases/calculate_outbound_movement_cost_usecase.dart';

@GenerateMocks([InventoryRepository])
import 'calculate_outbound_movement_cost_usecase_test.mocks.dart';

void main() {
  late CalculateOutboundMovementCostUseCase useCase;
  late MockInventoryRepository repository;

  setUp(() {
    repository = MockInventoryRepository();
    useCase = CalculateOutboundMovementCostUseCase(repository);
  });

  group('FIFO outbound cost calculation tests', () {
    test('FIFO - Calculate cost of a simple outbound movement', () async {
      // Arrange
      final itemId = 'item1';
      final movement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'ISSUE-001',
        movementType: InventoryMovementType.issue,
        warehouseId: 'warehouse1',
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: -10.0, // Negative for outbound
            uom: 'PCS',
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Setup mock cost layers (oldest first)
      final costLayers = [
        CostLayer(
          movementItemId: 'layer1',
          originalMovementId: 'rec1',
          itemId: itemId,
          batchLotNumber: 'BATCH001',
          originalQuantity: 5.0,
          remainingQuantity: 5.0,
          costAtTransaction: 10.0, // Cost $10 per unit
          movementDate:
              DateTime(2025, 1, 1), // Older layer (FIFO will use first)
        ),
        CostLayer(
          movementItemId: 'layer2',
          originalMovementId: 'rec2',
          itemId: itemId,
          batchLotNumber: 'BATCH002',
          originalQuantity: 10.0,
          remainingQuantity: 10.0,
          costAtTransaction: 12.0, // Cost $12 per unit
          movementDate: DateTime(2025, 3, 1), // Newer layer
        ),
      ];

      // Mock the repository
      when(repository.getAvailableCostLayers(
        itemId,
        'warehouse1',
        CostingMethod.fifo,
      )).thenAnswer((_) async => costLayers);

      // Act
      final result = await useCase.execute(
        movement: movement,
        costingMethod: CostingMethod.fifo,
      );

      // Assert
      // Expected calculation:
      // - Layer 1: 5 units × $10 = $50
      // - Layer 2: 5 units × $12 = $60
      // - Total: $110 for 10 units
      expect(result.totalCost, 110.0);
      expect(result.averageCostPerUnit, 11.0);
      expect(result.costBreakdown.length, 2);
      expect(result.costBreakdown[0].quantity, 5.0);
      expect(result.costBreakdown[0].costPerUnit, 10.0);
      expect(result.costBreakdown[1].quantity, 5.0);
      expect(result.costBreakdown[1].costPerUnit, 12.0);
    });

    test('FIFO - Handles insufficient stock gracefully', () async {
      // Arrange
      final itemId = 'item1';
      final movement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'ISSUE-001',
        movementType: InventoryMovementType.issue,
        warehouseId: 'warehouse1',
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: -20.0, // Requesting more than available
            uom: 'PCS',
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Setup mock cost layers with only 15 units available
      final costLayers = [
        CostLayer(
          movementItemId: 'layer1',
          originalMovementId: 'rec1',
          itemId: itemId,
          batchLotNumber: 'BATCH001',
          originalQuantity: 5.0,
          remainingQuantity: 5.0,
          costAtTransaction: 10.0,
          movementDate: DateTime(2025, 1, 1),
        ),
        CostLayer(
          movementItemId: 'layer2',
          originalMovementId: 'rec2',
          itemId: itemId,
          batchLotNumber: 'BATCH002',
          originalQuantity: 10.0,
          remainingQuantity: 10.0,
          costAtTransaction: 12.0,
          movementDate: DateTime(2025, 3, 1),
        ),
      ];

      // Mock the repository
      when(repository.getAvailableCostLayers(
        itemId,
        'warehouse1',
        CostingMethod.fifo,
      )).thenAnswer((_) async => costLayers);

      // Act
      final result = await useCase.execute(
        movement: movement,
        costingMethod: CostingMethod.fifo,
      );

      // Assert
      // Even though we requested 20 units, we should only get costs for 15 units
      expect(result.totalCost, 170.0); // 5×10 + 10×12 = 50 + 120 = 170
      expect(result.averageCostPerUnit, 11.333333333333334); // 170 ÷ 15 ≈ 11.33
      expect(result.costBreakdown.length, 2);
      expect(result.isPartial, true);
      expect(result.requestedQuantity, 20.0);
      expect(result.actualQuantity, 15.0);
    });
  });

  group('LIFO outbound cost calculation tests', () {
    test('LIFO - Calculate cost of a simple outbound movement', () async {
      // Arrange
      final itemId = 'item1';
      final movement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'ISSUE-001',
        movementType: InventoryMovementType.issue,
        warehouseId: 'warehouse1',
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: -10.0, // Negative for outbound
            uom: 'PCS',
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Setup mock cost layers (oldest first)
      final costLayers = [
        CostLayer(
          movementItemId: 'layer1',
          originalMovementId: 'rec1',
          itemId: itemId,
          batchLotNumber: 'BATCH001',
          originalQuantity: 5.0,
          remainingQuantity: 5.0,
          costAtTransaction: 10.0, // Cost $10 per unit
          movementDate: DateTime(2025, 1, 1), // Older layer
        ),
        CostLayer(
          movementItemId: 'layer2',
          originalMovementId: 'rec2',
          itemId: itemId,
          batchLotNumber: 'BATCH002',
          originalQuantity: 10.0,
          remainingQuantity: 10.0,
          costAtTransaction: 12.0, // Cost $12 per unit
          movementDate:
              DateTime(2025, 3, 1), // Newer layer (LIFO will use first)
        ),
      ];

      // Mock the repository
      when(repository.getAvailableCostLayers(
        itemId,
        'warehouse1',
        CostingMethod.lifo,
      )).thenAnswer((_) async => costLayers);

      // Act
      final result = await useCase.execute(
        movement: movement,
        costingMethod: CostingMethod.lifo,
      );

      // Assert
      // Expected calculation:
      // - Layer 2 (newest): 10 units × $12 = $120
      expect(result.totalCost, 120.0);
      expect(result.averageCostPerUnit, 12.0);
      expect(result.costBreakdown.length, 1);
      expect(result.costBreakdown[0].quantity, 10.0);
      expect(result.costBreakdown[0].costPerUnit, 12.0);
    });

    test('LIFO - Calculate cost using multiple layers', () async {
      // Arrange
      final itemId = 'item1';
      final movement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'ISSUE-001',
        movementType: InventoryMovementType.issue,
        warehouseId: 'warehouse1',
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: -15.0, // More than newest layer
            uom: 'PCS',
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Setup mock cost layers (oldest first)
      final costLayers = [
        CostLayer(
          movementItemId: 'layer1',
          originalMovementId: 'rec1',
          itemId: itemId,
          batchLotNumber: 'BATCH001',
          originalQuantity: 10.0,
          remainingQuantity: 10.0,
          costAtTransaction: 10.0, // Cost $10 per unit
          movementDate: DateTime(2025, 1, 1), // Older layer
        ),
        CostLayer(
          movementItemId: 'layer2',
          originalMovementId: 'rec2',
          itemId: itemId,
          batchLotNumber: 'BATCH002',
          originalQuantity: 10.0,
          remainingQuantity: 10.0,
          costAtTransaction: 12.0, // Cost $12 per unit
          movementDate:
              DateTime(2025, 3, 1), // Newer layer (LIFO will use first)
        ),
      ];

      // Mock the repository
      when(repository.getAvailableCostLayers(
        itemId,
        'warehouse1',
        CostingMethod.lifo,
      )).thenAnswer((_) async => costLayers);

      // Act
      final result = await useCase.execute(
        movement: movement,
        costingMethod: CostingMethod.lifo,
      );

      // Assert
      // Expected calculation:
      // - Layer 2 (newest): 10 units × $12 = $120
      // - Layer 1 (oldest): 5 units × $10 = $50
      // - Total: $170 for 15 units
      expect(result.totalCost, 170.0);
      expect(result.averageCostPerUnit, 11.333333333333334); // 170 ÷ 15 ≈ 11.33
      expect(result.costBreakdown.length, 2);
      expect(result.costBreakdown[0].quantity, 10.0);
      expect(result.costBreakdown[0].costPerUnit, 12.0);
      expect(result.costBreakdown[1].quantity, 5.0);
      expect(result.costBreakdown[1].costPerUnit, 10.0);
    });
  });

  group('Multiple item outbound cost calculation tests', () {
    test('Calculate cost of a movement with multiple items', () async {
      // Arrange
      final itemId1 = 'item1';
      final itemId2 = 'item2';
      final movement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'ISSUE-001',
        movementType: InventoryMovementType.issue,
        warehouseId: 'warehouse1',
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'line1',
            itemId: itemId1,
            itemCode: 'I001',
            itemName: 'Test Item 1',
            quantity: -5.0,
            uom: 'PCS',
          ),
          InventoryMovementItemModel(
            id: 'line2',
            itemId: itemId2,
            itemCode: 'I002',
            itemName: 'Test Item 2',
            quantity: -3.0,
            uom: 'KG',
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Setup mock cost layers for item 1
      final costLayers1 = [
        CostLayer(
          movementItemId: 'layer1-1',
          originalMovementId: 'rec1',
          itemId: itemId1,
          batchLotNumber: 'BATCH001',
          originalQuantity: 10.0,
          remainingQuantity: 10.0,
          costAtTransaction: 10.0,
          movementDate: DateTime(2025, 1, 1),
        ),
      ];

      // Setup mock cost layers for item 2
      final costLayers2 = [
        CostLayer(
          movementItemId: 'layer2-1',
          originalMovementId: 'rec2',
          itemId: itemId2,
          batchLotNumber: 'BATCH002',
          originalQuantity: 5.0,
          remainingQuantity: 5.0,
          costAtTransaction: 20.0,
          movementDate: DateTime(2025, 2, 1),
        ),
      ];

      // Mock the repository
      when(repository.getAvailableCostLayers(
        itemId1,
        'warehouse1',
        CostingMethod.fifo,
      )).thenAnswer((_) async => costLayers1);

      when(repository.getAvailableCostLayers(
        itemId2,
        'warehouse1',
        CostingMethod.fifo,
      )).thenAnswer((_) async => costLayers2);

      // Act
      final result = await useCase.execute(
        movement: movement,
        costingMethod: CostingMethod.fifo,
      );

      // Assert
      // Expected calculation:
      // - Item 1: 5 units × $10 = $50
      // - Item 2: 3 units × $20 = $60
      // - Total: $110 for both items
      expect(result.totalCost, 110.0);
      expect(result.itemCosts.length, 2);
      expect(result.itemCosts[itemId1], 50.0);
      expect(result.itemCosts[itemId2], 60.0);
    });
  });
}
*/
