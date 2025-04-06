import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:und_app/core/exceptions/failure.dart';
import 'package:und_app/core/exceptions/result.dart';
import 'package:und_app/features/factory/production/domain/models/production_batch_model.dart';
import 'package:und_app/features/factory/production/domain/repositories/production_batch_repository.dart';
import 'package:und_app/features/factory/production/domain/usecases/track_batch_process_usecase.dart';
import 'track_batch_process_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([ProductionBatchRepository])
void main() {
  late MockProductionBatchRepository mockRepository;
  late TrackBatchProcessUseCase useCase;

  // Test batch
  final testBatch = ProductionBatchModel(
    id: 'batch-123',
    batchNumber: 'B001',
    executionId: 'execution-123',
    productId: 'product-123',
    productName: 'Test Product',
    status: BatchStatus.inProgress,
    startTime: DateTime.now(),
    endTime: null,
    targetQuantity: 1000.0,
    actualQuantity: null,
    unitOfMeasure: 'kg',
    temperature: 25.0,
    pH: 6.5,
    processParameters: {},
    notes: null,
    createdAt: DateTime.now(),
    createdBy: 'user-123',
    updatedAt: DateTime.now(),
    updatedBy: 'user-123',
  );

  setUp(() {
    mockRepository = MockProductionBatchRepository();
    useCase = TrackBatchProcessUseCase(mockRepository);
  });

  group('updateProcessParameters', () {
    test('should return updated batch when repository succeeds', () async {
      // Arrange
      final batchId = 'batch-123';
      final parameters = {'temperature': 26.5, 'pH': 6.8};

      final updatedBatch = testBatch.copyWith(
        processParameters: parameters,
      );

      when(mockRepository.updateBatchParameters(batchId, parameters))
          .thenAnswer((_) async => Result.success(updatedBatch));

      // Act
      final result = await useCase.updateProcessParameters(batchId, parameters);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, equals(updatedBatch));
      verify(mockRepository.updateBatchParameters(batchId, parameters))
          .called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final batchId = 'batch-123';
      final parameters = {'temperature': 26.5, 'pH': 6.8};

      when(mockRepository.updateBatchParameters(batchId, parameters))
          .thenAnswer((_) async =>
              Result.failure(ServerFailure('Failed to update parameters')));

      // Act
      final result = await useCase.updateProcessParameters(batchId, parameters);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, equals('Failed to update parameters'));
    });

    test('should return validation failure when batch ID is empty', () async {
      // Arrange
      final batchId = '';
      final parameters = {'temperature': 26.5, 'pH': 6.8};

      // Act
      final result = await useCase.updateProcessParameters(batchId, parameters);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, equals('Batch ID cannot be empty'));
      verifyNever(mockRepository.updateBatchParameters(any, any));
    });

    test('should return validation failure when parameters are empty',
        () async {
      // Arrange
      final batchId = 'batch-123';
      final parameters = <String, dynamic>{};

      // Act
      final result = await useCase.updateProcessParameters(batchId, parameters);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message,
          equals('Process parameters cannot be empty'));
      verifyNever(mockRepository.updateBatchParameters(any, any));
    });
  });

  group('startBatchProcess', () {
    test('should return updated batch when repository succeeds', () async {
      // Arrange
      final batchId = 'batch-123';
      final startedBatch = testBatch.copyWith(
        status: BatchStatus.inProgress,
        startTime: DateTime.now(),
      );

      when(mockRepository.startBatch(batchId))
          .thenAnswer((_) async => Result.success(startedBatch));

      // Act
      final result = await useCase.startBatchProcess(batchId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, equals(startedBatch));
      verify(mockRepository.startBatch(batchId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final batchId = 'batch-123';

      when(mockRepository.startBatch(batchId)).thenAnswer(
          (_) async => Result.failure(ServerFailure('Failed to start batch')));

      // Act
      final result = await useCase.startBatchProcess(batchId);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, equals('Failed to start batch'));
    });

    test('should return validation failure when batch ID is empty', () async {
      // Arrange
      final batchId = '';

      // Act
      final result = await useCase.startBatchProcess(batchId);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, equals('Batch ID cannot be empty'));
      verifyNever(mockRepository.startBatch(any));
    });
  });

  group('completeBatchProcess', () {
    test('should return updated batch when repository succeeds', () async {
      // Arrange
      final batchId = 'batch-123';
      final actualQuantity = 950.0;

      final completedBatch = testBatch.copyWith(
        status: BatchStatus.completed,
        endTime: DateTime.now(),
        actualQuantity: actualQuantity,
      );

      when(mockRepository.completeBatch(batchId, actualQuantity))
          .thenAnswer((_) async => Result.success(completedBatch));

      // Act
      final result =
          await useCase.completeBatchProcess(batchId, actualQuantity);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, equals(completedBatch));
      verify(mockRepository.completeBatch(batchId, actualQuantity)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final batchId = 'batch-123';
      final actualQuantity = 950.0;

      when(mockRepository.completeBatch(batchId, actualQuantity)).thenAnswer(
          (_) async =>
              Result.failure(ServerFailure('Failed to complete batch')));

      // Act
      final result =
          await useCase.completeBatchProcess(batchId, actualQuantity);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, equals('Failed to complete batch'));
    });

    test('should return validation failure when actual quantity is negative',
        () async {
      // Arrange
      final batchId = 'batch-123';
      final actualQuantity = -10.0;

      // Act
      final result =
          await useCase.completeBatchProcess(batchId, actualQuantity);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message,
          equals('Actual quantity cannot be negative'));
      verifyNever(mockRepository.completeBatch(any, any));
    });
  });

  group('failBatchProcess', () {
    test('should return updated batch when repository succeeds', () async {
      // Arrange
      final batchId = 'batch-123';
      final reason = 'Equipment failure';

      final failedBatch = testBatch.copyWith(
        status: BatchStatus.failed,
        endTime: DateTime.now(),
        notes: reason,
      );

      when(mockRepository.failBatch(batchId, reason))
          .thenAnswer((_) async => Result.success(failedBatch));

      // Act
      final result = await useCase.failBatchProcess(batchId, reason);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, equals(failedBatch));
      verify(mockRepository.failBatch(batchId, reason)).called(1);
    });

    test('should return validation failure when reason is empty', () async {
      // Arrange
      final batchId = 'batch-123';
      final reason = '';

      // Act
      final result = await useCase.failBatchProcess(batchId, reason);

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, equals('Failure reason cannot be empty'));
      verifyNever(mockRepository.failBatch(any, any));
    });
  });

  group('watchBatchProcess', () {
    test('should return stream from repository', () {
      // Arrange
      final batchId = 'batch-123';
      final stream = Stream.value(testBatch);

      when(mockRepository.watchBatch(batchId)).thenAnswer((_) => stream);

      // Act
      final result = useCase.watchBatchProcess(batchId);

      // Assert
      expect(result, equals(stream));
      verify(mockRepository.watchBatch(batchId)).called(1);
    });

    test('should throw ValidationFailure when batch ID is empty', () {
      // Arrange
      final batchId = '';

      // Act & Assert
      expect(() => useCase.watchBatchProcess(batchId),
          throwsA(isA<ValidationFailure>()));
      verifyNever(mockRepository.watchBatch(any));
    });
  });
}
