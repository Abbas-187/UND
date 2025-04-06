import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:und_app/features/factory/production/domain/models/production_batch_model.dart';
import 'package:und_app/features/factory/production/presentation/widgets/batch_detail_card.dart';

void main() {
  final testBatch = ProductionBatchModel(
    id: 'batch-123',
    batchNumber: 'B001',
    executionId: 'execution-123',
    productId: 'product-123',
    productName: 'Test Yogurt',
    status: BatchStatus.inProgress,
    startTime: DateTime(2023, 5, 15, 8, 30),
    endTime: null,
    targetQuantity: 1000.0,
    actualQuantity: null,
    unitOfMeasure: 'kg',
    temperature: 25.0,
    pH: 6.5,
    processParameters: {
      'viscosity': 120.5,
      'fatContent': 3.2,
    },
    notes: 'Test batch',
    createdAt: DateTime(2023, 5, 15, 8, 0),
    createdBy: 'user-123',
    updatedAt: DateTime(2023, 5, 15, 9, 15),
    updatedBy: 'user-123',
  );

  testWidgets('BatchDetailCard displays batch information correctly',
      (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BatchDetailCard(batch: testBatch),
        ),
      ),
    );

    // Verify that the batch number is displayed
    expect(find.text('Batch #B001'), findsOneWidget);

    // Verify that the product info is displayed
    expect(find.text('Product:'), findsOneWidget);
    expect(find.text('Test Yogurt'), findsOneWidget);

    // Verify that the batch status is displayed
    expect(find.byType(Chip), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);

    // Verify that the target quantity is displayed
    expect(find.text('Target Quantity:'), findsOneWidget);
    expect(find.text('1000.0 kg'), findsOneWidget);

    // Verify that temperature and pH are displayed
    expect(find.text('Temperature:'), findsOneWidget);
    expect(find.text('25.0°C'), findsOneWidget);
    expect(find.text('pH Level:'), findsOneWidget);
    expect(find.text('6.5'), findsOneWidget);

    // Verify that creation and update times are displayed
    expect(find.text('Created'), findsOneWidget);
    expect(find.text('Updated'), findsOneWidget);

    // Verify that process parameters are displayed
    expect(find.text('Process Parameters'), findsOneWidget);
    expect(find.text('Viscosity:'), findsOneWidget);
    expect(find.text('120.5'), findsOneWidget);
    expect(find.text('Fat Content:'), findsOneWidget);
    expect(find.text('3.2'), findsOneWidget);
  });

  testWidgets('BatchDetailCard displays different status colors correctly',
      (WidgetTester tester) async {
    // Test different batch statuses and their colors
    for (final status in BatchStatus.values) {
      final batch = testBatch.copyWith(status: status);

      // Build widget with the status and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BatchDetailCard(batch: batch),
          ),
        ),
      );

      // Find the chip
      final chipFinder = find.byType(Chip);
      expect(chipFinder, findsOneWidget);

      // Get the chip widget
      final chipWidget = tester.widget<Chip>(chipFinder);

      // Verify the color matches the status
      Color expectedColor;
      switch (status) {
        case BatchStatus.notStarted:
          expectedColor = Colors.grey;
          expect(find.text('Not Started'), findsOneWidget);
        case BatchStatus.inProgress:
          expectedColor = Colors.blue;
          expect(find.text('In Progress'), findsOneWidget);
        case BatchStatus.completed:
          expectedColor = Colors.green;
          expect(find.text('Completed'), findsOneWidget);
        case BatchStatus.failed:
          expectedColor = Colors.red;
          expect(find.text('Failed'), findsOneWidget);
        case BatchStatus.onHold:
          expectedColor = Colors.amber;
          expect(find.text('On Hold'), findsOneWidget);
      }

      expect(chipWidget.backgroundColor, expectedColor);
    }
  });

  testWidgets('BatchDetailCard handles null values gracefully',
      (WidgetTester tester) async {
    // Create a batch with minimal information
    final minimalBatch = ProductionBatchModel(
      id: 'batch-123',
      batchNumber: 'B001',
      executionId: 'execution-123',
      productId: 'product-123',
      productName: 'Test Product',
      status: BatchStatus.notStarted,
      targetQuantity: 1000.0,
      unitOfMeasure: 'kg',
      createdAt: DateTime.now(),
      createdBy: 'user-123',
      updatedAt: DateTime.now(),
      updatedBy: 'user-123',
    );

    // Build widget with minimal batch and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BatchDetailCard(batch: minimalBatch),
        ),
      ),
    );

    // Verify that the required fields are displayed
    expect(find.text('Batch #B001'), findsOneWidget);
    expect(find.text('Product:'), findsOneWidget);
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Target Quantity:'), findsOneWidget);
    expect(find.text('1000.0 kg'), findsOneWidget);

    // Verify that optional fields are not displayed
    expect(find.text('Temperature:'), findsNothing);
    expect(find.text('pH Level:'), findsNothing);
    expect(find.text('Process Parameters'), findsNothing);
  });
}
