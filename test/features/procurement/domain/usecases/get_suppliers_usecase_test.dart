import 'package:flutter_test/flutter_test.dart';
import 'package:und_app/core/exceptions/app_exception.dart';
import 'package:und_app/features/procurement/domain/entities/supplier.dart';
import 'package:und_app/features/procurement/domain/usecases/supplier_usecases.dart';

void main() {
  late GetSuppliersUseCase getSuppliersUseCase;
  late _MockSupplierRepository mockRepository;

  setUp(() {
    mockRepository = _MockSupplierRepository();
    getSuppliersUseCase = GetSuppliersUseCase(mockRepository);
  });

  group('GetSuppliersUseCase', () {
    test('should return suppliers from repository', () async {
      // Arrange
      final suppliers = [
        Supplier(
          id: '1',
          name: 'Test Supplier',
          code: 'SUP001',
          type: SupplierType.manufacturer,
          status: SupplierStatus.active,
          createdAt: DateTime(2023),
        )
      ];

      mockRepository.stubGetSuppliers(suppliers);

      // Act
      final result = await getSuppliersUseCase.execute();

      // Assert
      expect(result, equals(suppliers));
      expect(mockRepository.getSuppliersCallCount, 1);
      expect(mockRepository.getSuppliersTypeArg, null);
      expect(mockRepository.getSuppliersStatusArg, null);
      expect(mockRepository.getSuppliersSearchArg, null);
    });

    test('should pass filter parameters to repository', () async {
      // Arrange
      final suppliers = [
        Supplier(
          id: '1',
          name: 'Test Supplier',
          code: 'SUP001',
          type: SupplierType.manufacturer,
          status: SupplierStatus.active,
          createdAt: DateTime(2023),
        )
      ];

      mockRepository.stubGetSuppliers(suppliers);

      // Act
      final result = await getSuppliersUseCase.execute(
        type: SupplierType.manufacturer,
        status: SupplierStatus.active,
        searchQuery: 'test',
      );

      // Assert
      expect(result, equals(suppliers));
      expect(mockRepository.getSuppliersCallCount, 1);
      expect(mockRepository.getSuppliersTypeArg, SupplierType.manufacturer);
      expect(mockRepository.getSuppliersStatusArg, SupplierStatus.active);
      expect(mockRepository.getSuppliersSearchArg, 'test');
    });

    test('should throw AppException when repository throws an error', () async {
      // Arrange
      mockRepository.stubGetSuppliersError(Exception('Database error'));

      // Act & Assert
      expect(
        () => getSuppliersUseCase.execute(),
        throwsA(isA<AppException>()),
      );
      expect(mockRepository.getSuppliersCallCount, 1);
    });
  });
}

// Custom mock implementation that doesn't rely on mockito
class _MockSupplierRepository implements SupplierRepository {
  List<Supplier>? _suppliersResult;
  Exception? _suppliersError;

  int getSuppliersCallCount = 0;
  SupplierType? getSuppliersTypeArg;
  SupplierStatus? getSuppliersStatusArg;
  String? getSuppliersSearchArg;

  void stubGetSuppliers(List<Supplier> suppliers) {
    _suppliersResult = suppliers;
    _suppliersError = null;
  }

  void stubGetSuppliersError(Exception error) {
    _suppliersError = error;
    _suppliersResult = null;
  }

  @override
  Future<List<Supplier>> getSuppliers({
    SupplierType? type,
    SupplierStatus? status,
    String? searchQuery,
  }) async {
    getSuppliersCallCount++;
    getSuppliersTypeArg = type;
    getSuppliersStatusArg = status;
    getSuppliersSearchArg = searchQuery;

    if (_suppliersError != null) {
      throw _suppliersError!;
    }
    return _suppliersResult ?? [];
  }

  @override
  Future<Supplier> getSupplierById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) {
    throw UnimplementedError();
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSupplier(String id) {
    throw UnimplementedError();
  }
}
