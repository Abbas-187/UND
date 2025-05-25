/*import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:und/features/inventory/domain/entities/cost_layer.dart';
import 'package:und/features/inventory/domain/entities/inventory_item.dart';
import 'package:und/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:und/features/inventory/domain/usecases/generate_inventory_valuation_report_usecase.dart';

@GenerateMocks([InventoryRepository])
import 'generate_inventory_valuation_report_test.mocks.dart';

void main() {
  late GenerateInventoryValuationReportUseCase useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GenerateInventoryValuationReportUseCase(mockRepository);
  });

  group('Inventory Valuation Report Tests', () {
    // Test data
    final testDate = DateTime(2025, 5, 1);

    // Mock inventory items
    final inventoryItem1 = InventoryItem(
      id: 'item1',
      appItemId: 'APP001',
      name: 'Test Item 1',
      category: 'Category A',
      unit: 'PCS',
      quantity: 100.0,
      minimumQuantity: 10.0,
      reorderPoint: 50.0,
      location: 'Warehouse1',
      lastUpdated: testDate,
      cost: 15.0, // WAC cost
    );

    final inventoryItem2 = InventoryItem(
      id: 'item2',
      appItemId: 'APP002',
      name: 'Test Item 2',
      category: 'Category B',
      unit: 'KG',
      quantity: 200.0,
      minimumQuantity: 20.0,
      reorderPoint: 80.0,
      location: 'Warehouse1',
      lastUpdated: testDate,
      cost: 25.0, // WAC cost
    );

    // Mock cost layers for FIFO/LIFO
    final costLayer1a = CostLayer(
      id: 'layer1a',
      itemId: 'item1',
      warehouseId: 'Warehouse1',
      batchLotNumber: 'BATCH001',
      initialQuantity: 50.0,
      remainingQuantity: 50.0,
      costAtTransaction: 12.0, // Earlier batch at $12
      movementDate: testDate.subtract(const Duration(days: 30)),
      createdAt: testDate.subtract(const Duration(days: 30)),
    );

    final costLayer1b = CostLayer(
      id: 'layer1b',
      itemId: 'item1',
      warehouseId: 'Warehouse1',
      batchLotNumber: 'BATCH002',
      initialQuantity: 50.0,
      remainingQuantity: 50.0,
      costAtTransaction: 18.0, // Later batch at $18
      movementDate: testDate.subtract(const Duration(days: 15)),
      createdAt: testDate.subtract(const Duration(days: 15)),
    );

    final costLayer2a = CostLayer(
      id: 'layer2a',
      itemId: 'item2',
      warehouseId: 'Warehouse1',
      batchLotNumber: 'BATCH003',
      initialQuantity: 100.0,
      remainingQuantity: 100.0,
      costAtTransaction: 20.0, // Earlier batch at $20
      movementDate: testDate.subtract(const Duration(days: 25)),
      createdAt: testDate.subtract(const Duration(days: 25)),
    );

    final costLayer2b = CostLayer(
      id: 'layer2b',
      itemId: 'item2',
      warehouseId: 'Warehouse1',
      batchLotNumber: 'BATCH004',
      initialQuantity: 100.0,
      remainingQuantity: 100.0,
      costAtTransaction: 30.0, // Later batch at $30
      movementDate: testDate.subtract(const Duration(days: 10)),
      createdAt: testDate.subtract(const Duration(days: 10)),
    );

    test('FIFO valuation is calculated correctly', () async {
      // Arrange
      when(mockRepository.getItems()).thenAnswer((_) async => [
            inventoryItem1,
            inventoryItem2,
          ]);

      when(mockRepository.getAvailableCostLayers(
        'item1',
        any,
        CostingMethod.fifo,
      )).thenAnswer((_) async => [
            costLayer1a, // Older batch first in FIFO
            costLayer1b,
          ]);

      when(mockRepository.getAvailableCostLayers(
        'item2',
        any,
        CostingMethod.fifo,
      )).thenAnswer((_) async => [
            costLayer2a, // Older batch first in FIFO
            costLayer2b,
          ]);

      // Act
      final report = await useCase.execute(
        costingMethod: CostingMethod.fifo,
        asOfDate: testDate,
      );

      // Assert
      expect(report.entries.length, 2);
      expect(report.costingMethod, CostingMethod.fifo);

      // First item valuation = (50 * $12) + (50 * $18) = $600 + $900 = $1,500
      final item1Entry = report.entries.firstWhere((e) => e.itemId == 'item1');
      expect(item1Entry.totalQuantity, 100.0);
      expect(item1Entry.totalValue, 1500.0);
      expect(item1Entry.averageCost,
          15.0); // Average of FIFO layers = (600 + 900)/100 = 15.0

      // Second item valuation = (100 * $20) + (100 * $30) = $2,000 + $3,000 = $5,000
      final item2Entry = report.entries.firstWhere((e) => e.itemId == 'item2');
      expect(item2Entry.totalQuantity, 200.0);
      expect(item2Entry.totalValue, 5000.0);
      expect(item2Entry.averageCost, 25.0); // Average of FIFO layers

      // Total report valuation = $1,500 + $5,000 = $6,500
      expect(report.totalValue, 6500.0);
    });

    test('LIFO valuation is calculated correctly', () async {
      // Arrange
      when(mockRepository.getItems()).thenAnswer((_) async => [
            inventoryItem1,
            inventoryItem2,
          ]);

      when(mockRepository.getAvailableCostLayers(
        'item1',
        any,
        CostingMethod.lifo,
      )).thenAnswer((_) async => [
            costLayer1b, // Newer batch first in LIFO
            costLayer1a,
          ]);

      when(mockRepository.getAvailableCostLayers(
        'item2',
        any,
        CostingMethod.lifo,
      )).thenAnswer((_) async => [
            costLayer2b, // Newer batch first in LIFO
            costLayer2a,
          ]);

      // Act
      final report = await useCase.execute(
        costingMethod: CostingMethod.lifo,
        asOfDate: testDate,
      );

      // Assert
      expect(report.entries.length, 2);
      expect(report.costingMethod, CostingMethod.lifo);

      // First item valuation = (50 * $18) + (50 * $12) = $900 + $600 = $1,500
      final item1Entry = report.entries.firstWhere((e) => e.itemId == 'item1');
      expect(item1Entry.totalQuantity, 100.0);
      expect(item1Entry.totalValue, 1500.0);
      expect(item1Entry.averageCost, 15.0); // Average of LIFO layers

      // Second item valuation = (100 * $30) + (100 * $20) = $3,000 + $2,000 = $5,000
      final item2Entry = report.entries.firstWhere((e) => e.itemId == 'item2');
      expect(item2Entry.totalQuantity, 200.0);
      expect(item2Entry.totalValue, 5000.0);
      expect(item2Entry.averageCost, 25.0); // Average of LIFO layers

      // Total report valuation = $1,500 + $5,000 = $6,500
      // Note: Total value is the same for FIFO and LIFO because all layers are fully present
      expect(report.totalValue, 6500.0);
    });

    test('Weighted average valuation is calculated correctly', () async {
      // Arrange
      when(mockRepository.getItems()).thenAnswer((_) async => [
            inventoryItem1,
            inventoryItem2,
          ]);

      when(mockRepository.getAvailableCostLayers(
        any,
        any,
        CostingMethod.wac,
      )).thenAnswer((_) async => []);

      // Act
      final report = await useCase.execute(
        costingMethod: CostingMethod.wac,
        asOfDate: testDate,
      );

      // Assert
      expect(report.entries.length, 2);
      expect(report.costingMethod, CostingMethod.wac);

      // First item WAC valuation = 100 * 15.0 = $1,500
      final item1Entry = report.entries.firstWhere((e) => e.itemId == 'item1');
      expect(item1Entry.totalQuantity, 100.0);
      expect(item1Entry.totalValue, 1500.0);
      expect(item1Entry.averageCost, 15.0);

      // Second item WAC valuation = 200 * 25.0 = $5,000
      final item2Entry = report.entries.firstWhere((e) => e.itemId == 'item2');
      expect(item2Entry.totalQuantity, 200.0);
      expect(item2Entry.totalValue, 5000.0);
      expect(item2Entry.averageCost, 25.0);

      // Total report valuation = $1,500 + $5,000 = $6,500
      expect(report.totalValue, 6500.0);
    });

    test('Comparative report includes all valuation methods', () async {
      // Arrange - Set up mocks for all methods
      when(mockRepository.getItems()).thenAnswer((_) async => [
            inventoryItem1,
            inventoryItem2,
          ]);

      // FIFO layers
      when(mockRepository.getAvailableCostLayers(
        'item1',
        any,
        CostingMethod.fifo,
      )).thenAnswer((_) async => [costLayer1a, costLayer1b]);

      when(mockRepository.getAvailableCostLayers(
        'item2',
        any,
        CostingMethod.fifo,
      )).thenAnswer((_) async => [costLayer2a, costLayer2b]);

      // LIFO layers
      when(mockRepository.getAvailableCostLayers(
        'item1',
        any,
        CostingMethod.lifo,
      )).thenAnswer((_) async => [costLayer1b, costLayer1a]);

      when(mockRepository.getAvailableCostLayers(
        'item2',
        any,
        CostingMethod.lifo,
      )).thenAnswer((_) async => [costLayer2b, costLayer2a]);

      // WAC valuation (empty layers since we just use item.cost)
      when(mockRepository.getAvailableCostLayers(
        any,
        any,
        CostingMethod.wac,
      )).thenAnswer((_) async => []);

      // Mock warehouse name lookup
      when(mockRepository.getWarehouse(any)).thenAnswer((_) async => null);

      // Act
      final report = await useCase.generateComparativeReport(
        asOfDate: testDate,
      );

      // Assert
      expect(report.entries.length, 2);
      expect(report.fifoTotalValue, 6500.0);
      expect(report.lifoTotalValue, 6500.0);
      expect(report.wacTotalValue, 6500.0);

      // Check comparative values for item1
      final item1Entry = report.entries.firstWhere((e) => e.itemId == 'item1');
      expect(item1Entry.fifoValue, 1500.0);
      expect(item1Entry.lifoValue, 1500.0);
      expect(item1Entry.wacValue, 1500.0);
      expect(item1Entry.fifoLifoDifference, 0.0);

      // Check comparative values for item2
      final item2Entry = report.entries.firstWhere((e) => e.itemId == 'item2');
      expect(item2Entry.fifoValue, 5000.0);
      expect(item2Entry.lifoValue, 5000.0);
      expect(item2Entry.wacValue, 5000.0);
      expect(item2Entry.fifoLifoDifference, 0.0);
    });
  });
}
*/
