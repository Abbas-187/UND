/* import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:und/features/inventory/data/models/inventory_movement_item_model.dart';
import 'package:und/features/inventory/data/models/inventory_movement_model.dart';
import 'package:und/features/inventory/domain/entities/cost_layer.dart';
import 'package:und/features/inventory/domain/entities/inventory_item.dart';
import 'package:und/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:und/features/inventory/domain/usecases/calculate_weighted_average_cost_usecase.dart';

@GenerateMocks([InventoryRepository])
import 'calculate_weighted_average_cost_usecase_test.mocks.dart';

void main() {
  late CalculateWeightedAverageCostUseCase useCase;
  late MockInventoryRepository repository;

  setUp(() {
    repository = MockInventoryRepository();
    useCase = CalculateWeightedAverageCostUseCase(repository);
  });

  group('Weighted Average Cost calculation tests', () {
    test('Calculate WAC with no previous inventory', () async {
      // Arrange
      final itemId = 'item1';
      final warehouseId = 'warehouse1';
      final inboundMovement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'RECEIPT-001',
        movementType: InventoryMovementType.receipt,
        warehouseId: warehouseId,
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: 10.0,
            uom: 'PCS',
            costAtTransaction: 15.0, // $15 per unit for this receipt
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Mock repository - no previous inventory
      when(repository.getItemWeightedAverageCost(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => null);

      when(repository.getItemCurrentQuantity(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 0);

      // Act
      final result = await useCase.execute(
        movement: inboundMovement,
        itemId: itemId,
        warehouseId: warehouseId,
      );

      // Assert
      // For a first receipt with no previous inventory, the WAC should be exactly the cost of the incoming items
      expect(result.newWeightedAverageCost, 15.0);
      expect(result.previousWeightedAverageCost, null);
      expect(result.previousQuantity, 0);
      expect(result.movementQuantity, 10.0);
      expect(result.newTotalQuantity, 10.0);
    });

    test('Calculate WAC with existing inventory', () async {
      // Arrange
      final itemId = 'item1';
      final warehouseId = 'warehouse1';
      final inboundMovement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'RECEIPT-001',
        movementType: InventoryMovementType.receipt,
        warehouseId: warehouseId,
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: 20.0,
            uom: 'PCS',
            costAtTransaction: 25.0, // $25 per unit for this receipt
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Mock repository - existing inventory with WAC of $15 and quantity of 10
      when(repository.getItemWeightedAverageCost(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 15.0);

      when(repository.getItemCurrentQuantity(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 10.0);

      // Act
      final result = await useCase.execute(
        movement: inboundMovement,
        itemId: itemId,
        warehouseId: warehouseId,
      );

      // Assert
      // WAC calculation:
      // (Existing Value + New Value) / Total Quantity
      // ((10 × $15) + (20 × $25)) ÷ (10 + 20) = ($150 + $500) ÷ 30 = $650 ÷ 30 = $21.67
      expect(result.newWeightedAverageCost, closeTo(21.67, 0.01));
      expect(result.previousWeightedAverageCost, 15.0);
      expect(result.previousQuantity, 10.0);
      expect(result.movementQuantity, 20.0);
      expect(result.newTotalQuantity, 30.0);
    });

    test('Calculate WAC with negative inventory adjustment', () async {
      // Arrange
      final itemId = 'item1';
      final warehouseId = 'warehouse1';
      final adjustmentMovement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'ADJ-001',
        movementType: InventoryMovementType.adjustment,
        warehouseId: warehouseId,
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: -5.0, // Negative adjustment
            uom: 'PCS',
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Mock repository - existing inventory with WAC of $15 and quantity of 20
      when(repository.getItemWeightedAverageCost(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 15.0);

      when(repository.getItemCurrentQuantity(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 20.0);

      // Act
      final result = await useCase.execute(
        movement: adjustmentMovement,
        itemId: itemId,
        warehouseId: warehouseId,
      );

      // Assert
      // For a negative adjustment, the WAC remains the same, only the quantity changes
      expect(result.newWeightedAverageCost, 15.0);
      expect(result.previousWeightedAverageCost, 15.0);
      expect(result.previousQuantity, 20.0);
      expect(result.movementQuantity, -5.0);
      expect(result.newTotalQuantity, 15.0);
    });

    test('Calculate WAC with zero quantity result', () async {
      // Arrange
      final itemId = 'item1';
      final warehouseId = 'warehouse1';
      final issueMovement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'ISSUE-001',
        movementType: InventoryMovementType.issue,
        warehouseId: warehouseId,
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: -10.0, // Issue all inventory
            uom: 'PCS',
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Mock repository - existing inventory with WAC of $15 and quantity of 10 (all will be issued)
      when(repository.getItemWeightedAverageCost(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 15.0);

      when(repository.getItemCurrentQuantity(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 10.0);

      // Act
      final result = await useCase.execute(
        movement: issueMovement,
        itemId: itemId,
        warehouseId: warehouseId,
      );

      // Assert
      // When all inventory is issued, the WAC becomes null (or remains the same in some systems)
      expect(result.newWeightedAverageCost, 15.0); // We keep the last known WAC
      expect(result.previousWeightedAverageCost, 15.0);
      expect(result.previousQuantity, 10.0);
      expect(result.movementQuantity, -10.0);
      expect(result.newTotalQuantity, 0.0);
    });

    test('Calculate WAC with different costs in same receipt', () async {
      // Arrange
      final itemId = 'item1';
      final warehouseId = 'warehouse1';
      final inboundMovement = InventoryMovementModel(
        id: 'mov1',
        documentNumber: 'RECEIPT-001',
        movementType: InventoryMovementType.receipt,
        warehouseId: warehouseId,
        movementDate: DateTime(2025, 5, 1),
        items: [
          InventoryMovementItemModel(
            id: 'item1-1',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: 5.0,
            uom: 'PCS',
            costAtTransaction: 10.0, // $10 per unit
          ),
          InventoryMovementItemModel(
            id: 'item1-2',
            itemId: itemId,
            itemCode: 'I001',
            itemName: 'Test Item',
            quantity: 5.0,
            uom: 'PCS',
            costAtTransaction: 20.0, // $20 per unit
          ),
        ],
        createdAt: DateTime(2025, 5, 1),
      );

      // Mock repository - no previous inventory
      when(repository.getItemWeightedAverageCost(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => null);

      when(repository.getItemCurrentQuantity(
        itemId,
        warehouseId,
      )).thenAnswer((_) async => 0);

      // Act
      final result = await useCase.execute(
        movement: inboundMovement,
        itemId: itemId,
        warehouseId: warehouseId,
      );

      // Assert
      // WAC calculation for multiple items with different costs:
      // ((5 × $10) + (5 × $20)) ÷ 10 = ($50 + $100) ÷ 10 = $150 ÷ 10 = $15
      expect(result.newWeightedAverageCost, 15.0);
      expect(result.previousWeightedAverageCost, null);
      expect(result.previousQuantity, 0);
      expect(result.movementQuantity, 10.0);
      expect(result.newTotalQuantity, 10.0);
    });
  });
}
*/
