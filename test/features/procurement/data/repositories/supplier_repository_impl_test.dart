import 'package:flutter_test/flutter_test.dart';
import 'package:und_app/core/exceptions/failure.dart';
import 'package:und_app/core/exceptions/result.dart';
import 'package:und_app/features/procurement/data/repositories/supplier_repository_impl.dart';
import 'package:und_app/features/procurement/domain/entities/supplier.dart';

// Define the interface similar to the real implementation
class SupplierRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSuppliers({
    String? type,
    String? status,
    String? searchQuery,
  }) async =>
      throw UnimplementedError();

  Future<Map<String, dynamic>> getSupplierById(String id) async =>
      throw UnimplementedError();

  Future<Map<String, dynamic>> createSupplier(
          Map<String, dynamic> data) async =>
      throw UnimplementedError();

  Future<Map<String, dynamic>> updateSupplier(
          String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();

  Future<void> deleteSupplier(String id) async => throw UnimplementedError();
}

// Custom mock implementation
class MockSupplierDataSource implements SupplierRemoteDataSource {
  // getSuppliers mock data and tracking
  List<Map<String, dynamic>>? _suppliersResult;
  Exception? _suppliersError;

  String? getSuppliersTypeArg;
  String? getSuppliersStatusArg;
  String? getSuppliersSearchArg;
  int getSuppliersCallCount = 0;

  void stubGetSuppliers(List<Map<String, dynamic>> result) {
    _suppliersResult = result;
    _suppliersError = null;
  }

  void stubGetSuppliersError(Exception error) {
    _suppliersError = error;
    _suppliersResult = null;
  }

  @override
  Future<List<Map<String, dynamic>>> getSuppliers({
    String? type,
    String? status,
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

  // getSupplierById mock data and tracking
  Map<String, dynamic>? _supplierByIdResult;
  Exception? _supplierByIdError;
  String? getSupplierByIdArg;
  int getSupplierByIdCallCount = 0;

  void stubGetSupplierById(Map<String, dynamic> result) {
    _supplierByIdResult = result;
    _supplierByIdError = null;
  }

  void stubGetSupplierByIdError(Exception error) {
    _supplierByIdError = error;
    _supplierByIdResult = null;
  }

  @override
  Future<Map<String, dynamic>> getSupplierById(String id) async {
    getSupplierByIdCallCount++;
    getSupplierByIdArg = id;

    if (_supplierByIdError != null) {
      throw _supplierByIdError!;
    }
    return _supplierByIdResult ?? {};
  }

  // Implement other methods as needed
  @override
  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateSupplier(
      String id, Map<String, dynamic> data) async {
    return {};
  }

  @override
  Future<void> deleteSupplier(String id) async {}
}

// Define exceptions for testing
class SupplierDataSourceException implements Exception {
  final String message;
  final String code;

  SupplierDataSourceException(this.message, {this.code = 'unknown'});

  @override
  String toString() => message;
}

void main() {
  late SupplierRepositoryImpl repository;
  late MockSupplierDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSupplierDataSource();
    repository = SupplierRepositoryImpl(mockDataSource);
  });

  group('getSuppliers', () {
    final testData = {
      'id': '1',
      'name': 'Test Supplier',
      'code': 'SUP001',
      'supplier_type': 'manufacturer',
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
      'is_active': true,
    };

    test('should return supplier entities when data source call succeeds',
        () async {
      // Arrange
      mockDataSource.stubGetSuppliers([testData]);

      // Act
      final result = await repository.getSuppliers();

      // Assert
      expect(result.isSuccess, true);

      final suppliers = result.data;
      expect(suppliers?.length, 1);
      expect(suppliers?.first.id, '1');
      expect(suppliers?.first.name, 'Test Supplier');

      expect(mockDataSource.getSuppliersCallCount, 1);
    });

    test('should map repository parameters to data source parameters',
        () async {
      // Arrange
      mockDataSource.stubGetSuppliers([testData]);

      // Act
      await repository.getSuppliers(
        type: SupplierType.manufacturer,
        status: SupplierStatus.active,
        searchQuery: 'test',
      );

      // Assert
      expect(mockDataSource.getSuppliersTypeArg, 'manufacturer');
      expect(mockDataSource.getSuppliersStatusArg, 'active');
      expect(mockDataSource.getSuppliersSearchArg, 'test');
    });

    test('should return failure when data source throws exception', () async {
      // Arrange
      mockDataSource
          .stubGetSuppliersError(SupplierDataSourceException('Server error'));

      // Act
      final result = await repository.getSuppliers();

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<ServerFailure>());
    });
  });

  group('getSupplierById', () {
    final testData = {
      'id': '1',
      'name': 'Test Supplier',
      'code': 'SUP001',
      'supplier_type': 'manufacturer',
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
      'is_active': true,
    };

    test('should return supplier entity when data source call succeeds',
        () async {
      // Arrange
      mockDataSource.stubGetSupplierById(testData);

      // Act
      final result = await repository.getSupplierById('1');

      // Assert
      expect(result.isSuccess, true);
      final supplier = result.data;
      expect(supplier?.id, '1');
      expect(supplier?.name, 'Test Supplier');

      expect(mockDataSource.getSupplierByIdCallCount, 1);
      expect(mockDataSource.getSupplierByIdArg, '1');
    });

    test(
        'should return NotFoundFailure when data source throws not-found exception',
        () async {
      // Arrange
      mockDataSource.stubGetSupplierByIdError(
          SupplierDataSourceException('Not found', code: 'not-found'));

      // Act
      final result = await repository.getSupplierById('999');

      // Assert
      expect(result.isFailure, true);
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
