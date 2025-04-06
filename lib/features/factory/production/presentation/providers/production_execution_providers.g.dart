// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_execution_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productionExecutionRepositoryHash() =>
    r'b98242f519caa5d3b9305bfc883e661721a58cb7';

/// Provider for the production execution repository interface
/// This needs to be overridden in the data layer with the actual implementation
///
/// Copied from [productionExecutionRepository].
@ProviderFor(productionExecutionRepository)
final productionExecutionRepositoryProvider =
    AutoDisposeProvider<ProductionExecutionRepository>.internal(
  productionExecutionRepository,
  name: r'productionExecutionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productionExecutionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductionExecutionRepositoryRef
    = AutoDisposeProviderRef<ProductionExecutionRepository>;
String _$getProductionExecutionsUseCaseHash() =>
    r'0869eae01550466876da0569b63db56d3a549256';

/// Provider for the GetProductionExecutionsUseCase
///
/// Copied from [getProductionExecutionsUseCase].
@ProviderFor(getProductionExecutionsUseCase)
final getProductionExecutionsUseCaseProvider =
    AutoDisposeProvider<GetProductionExecutionsUseCase>.internal(
  getProductionExecutionsUseCase,
  name: r'getProductionExecutionsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getProductionExecutionsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetProductionExecutionsUseCaseRef
    = AutoDisposeProviderRef<GetProductionExecutionsUseCase>;
String _$getProductionExecutionUseCaseHash() =>
    r'1922412aace682d3ad2305b78b3dd8d68a90c226';

/// Provider for the GetProductionExecutionUseCase
///
/// Copied from [getProductionExecutionUseCase].
@ProviderFor(getProductionExecutionUseCase)
final getProductionExecutionUseCaseProvider =
    AutoDisposeProvider<GetProductionExecutionUseCase>.internal(
  getProductionExecutionUseCase,
  name: r'getProductionExecutionUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getProductionExecutionUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetProductionExecutionUseCaseRef
    = AutoDisposeProviderRef<GetProductionExecutionUseCase>;
String _$updateProductionExecutionStatusUseCaseHash() =>
    r'44254004149148ad61bb95983bee03adfdfddf00';

/// Provider for the UpdateProductionExecutionStatusUseCase
///
/// Copied from [updateProductionExecutionStatusUseCase].
@ProviderFor(updateProductionExecutionStatusUseCase)
final updateProductionExecutionStatusUseCaseProvider =
    AutoDisposeProvider<UpdateProductionExecutionStatusUseCase>.internal(
  updateProductionExecutionStatusUseCase,
  name: r'updateProductionExecutionStatusUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateProductionExecutionStatusUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateProductionExecutionStatusUseCaseRef
    = AutoDisposeProviderRef<UpdateProductionExecutionStatusUseCase>;
String _$completeProductionExecutionUseCaseHash() =>
    r'e85a976eff07e1a9c2506b5382272d425c2fb064';

/// Provider for the CompleteProductionExecutionUseCase
///
/// Copied from [completeProductionExecutionUseCase].
@ProviderFor(completeProductionExecutionUseCase)
final completeProductionExecutionUseCaseProvider =
    AutoDisposeProvider<CompleteProductionExecutionUseCase>.internal(
  completeProductionExecutionUseCase,
  name: r'completeProductionExecutionUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completeProductionExecutionUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompleteProductionExecutionUseCaseRef
    = AutoDisposeProviderRef<CompleteProductionExecutionUseCase>;
String _$createProductionExecutionUseCaseHash() =>
    r'35b04cb5ebb55a2e97737eb489e4e2de5a52b63f';

/// Provider for the CreateProductionExecutionUseCase
///
/// Copied from [createProductionExecutionUseCase].
@ProviderFor(createProductionExecutionUseCase)
final createProductionExecutionUseCaseProvider =
    AutoDisposeProvider<CreateProductionExecutionUseCase>.internal(
  createProductionExecutionUseCase,
  name: r'createProductionExecutionUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createProductionExecutionUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateProductionExecutionUseCaseRef
    = AutoDisposeProviderRef<CreateProductionExecutionUseCase>;
String _$productionExecutionsHash() =>
    r'e3b5f2208e2dd2a126274bc60973031abab7d8a7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// StreamProvider for a list of production executions with filtering
///
/// Copied from [productionExecutions].
@ProviderFor(productionExecutions)
const productionExecutionsProvider = ProductionExecutionsFamily();

/// StreamProvider for a list of production executions with filtering
///
/// Copied from [productionExecutions].
class ProductionExecutionsFamily
    extends Family<AsyncValue<List<ProductionExecutionModel>>> {
  /// StreamProvider for a list of production executions with filtering
  ///
  /// Copied from [productionExecutions].
  const ProductionExecutionsFamily();

  /// StreamProvider for a list of production executions with filtering
  ///
  /// Copied from [productionExecutions].
  ProductionExecutionsProvider call({
    DateTime? startDate,
    DateTime? endDate,
    ProductionExecutionStatus? status,
    String? productId,
    String? productionLineId,
    String? searchQuery,
  }) {
    return ProductionExecutionsProvider(
      startDate: startDate,
      endDate: endDate,
      status: status,
      productId: productId,
      productionLineId: productionLineId,
      searchQuery: searchQuery,
    );
  }

  @override
  ProductionExecutionsProvider getProviderOverride(
    covariant ProductionExecutionsProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
      status: provider.status,
      productId: provider.productId,
      productionLineId: provider.productionLineId,
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productionExecutionsProvider';
}

/// StreamProvider for a list of production executions with filtering
///
/// Copied from [productionExecutions].
class ProductionExecutionsProvider
    extends AutoDisposeStreamProvider<List<ProductionExecutionModel>> {
  /// StreamProvider for a list of production executions with filtering
  ///
  /// Copied from [productionExecutions].
  ProductionExecutionsProvider({
    DateTime? startDate,
    DateTime? endDate,
    ProductionExecutionStatus? status,
    String? productId,
    String? productionLineId,
    String? searchQuery,
  }) : this._internal(
          (ref) => productionExecutions(
            ref as ProductionExecutionsRef,
            startDate: startDate,
            endDate: endDate,
            status: status,
            productId: productId,
            productionLineId: productionLineId,
            searchQuery: searchQuery,
          ),
          from: productionExecutionsProvider,
          name: r'productionExecutionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productionExecutionsHash,
          dependencies: ProductionExecutionsFamily._dependencies,
          allTransitiveDependencies:
              ProductionExecutionsFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
          status: status,
          productId: productId,
          productionLineId: productionLineId,
          searchQuery: searchQuery,
        );

  ProductionExecutionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.productId,
    required this.productionLineId,
    required this.searchQuery,
  }) : super.internal();

  final DateTime? startDate;
  final DateTime? endDate;
  final ProductionExecutionStatus? status;
  final String? productId;
  final String? productionLineId;
  final String? searchQuery;

  @override
  Override overrideWith(
    Stream<List<ProductionExecutionModel>> Function(
            ProductionExecutionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductionExecutionsProvider._internal(
        (ref) => create(ref as ProductionExecutionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
        status: status,
        productId: productId,
        productionLineId: productionLineId,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ProductionExecutionModel>>
      createElement() {
    return _ProductionExecutionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductionExecutionsProvider &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.status == status &&
        other.productId == productId &&
        other.productionLineId == productionLineId &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);
    hash = _SystemHash.combine(hash, productionLineId.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductionExecutionsRef
    on AutoDisposeStreamProviderRef<List<ProductionExecutionModel>> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `status` of this provider.
  ProductionExecutionStatus? get status;

  /// The parameter `productId` of this provider.
  String? get productId;

  /// The parameter `productionLineId` of this provider.
  String? get productionLineId;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _ProductionExecutionsProviderElement
    extends AutoDisposeStreamProviderElement<List<ProductionExecutionModel>>
    with ProductionExecutionsRef {
  _ProductionExecutionsProviderElement(super.provider);

  @override
  DateTime? get startDate => (origin as ProductionExecutionsProvider).startDate;
  @override
  DateTime? get endDate => (origin as ProductionExecutionsProvider).endDate;
  @override
  ProductionExecutionStatus? get status =>
      (origin as ProductionExecutionsProvider).status;
  @override
  String? get productId => (origin as ProductionExecutionsProvider).productId;
  @override
  String? get productionLineId =>
      (origin as ProductionExecutionsProvider).productionLineId;
  @override
  String? get searchQuery =>
      (origin as ProductionExecutionsProvider).searchQuery;
}

String _$activeProductionExecutionsHash() =>
    r'f0e649ceb87b81fdc0ebea6a3cf7dcf444be1cfc';

/// Derived provider for only active production executions
///
/// Copied from [activeProductionExecutions].
@ProviderFor(activeProductionExecutions)
final activeProductionExecutionsProvider =
    AutoDisposeStreamProvider<List<ProductionExecutionModel>>.internal(
  activeProductionExecutions,
  name: r'activeProductionExecutionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeProductionExecutionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveProductionExecutionsRef
    = AutoDisposeStreamProviderRef<List<ProductionExecutionModel>>;
String _$productionExecutionHash() =>
    r'babe866880be378c0a683fa9aec34d445cb8c6c5';

/// Provider family for a single production execution by ID
///
/// Copied from [productionExecution].
@ProviderFor(productionExecution)
const productionExecutionProvider = ProductionExecutionFamily();

/// Provider family for a single production execution by ID
///
/// Copied from [productionExecution].
class ProductionExecutionFamily
    extends Family<AsyncValue<ProductionExecutionModel>> {
  /// Provider family for a single production execution by ID
  ///
  /// Copied from [productionExecution].
  const ProductionExecutionFamily();

  /// Provider family for a single production execution by ID
  ///
  /// Copied from [productionExecution].
  ProductionExecutionProvider call(
    String id,
  ) {
    return ProductionExecutionProvider(
      id,
    );
  }

  @override
  ProductionExecutionProvider getProviderOverride(
    covariant ProductionExecutionProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productionExecutionProvider';
}

/// Provider family for a single production execution by ID
///
/// Copied from [productionExecution].
class ProductionExecutionProvider
    extends AutoDisposeStreamProvider<ProductionExecutionModel> {
  /// Provider family for a single production execution by ID
  ///
  /// Copied from [productionExecution].
  ProductionExecutionProvider(
    String id,
  ) : this._internal(
          (ref) => productionExecution(
            ref as ProductionExecutionRef,
            id,
          ),
          from: productionExecutionProvider,
          name: r'productionExecutionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productionExecutionHash,
          dependencies: ProductionExecutionFamily._dependencies,
          allTransitiveDependencies:
              ProductionExecutionFamily._allTransitiveDependencies,
          id: id,
        );

  ProductionExecutionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<ProductionExecutionModel> Function(ProductionExecutionRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductionExecutionProvider._internal(
        (ref) => create(ref as ProductionExecutionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ProductionExecutionModel> createElement() {
    return _ProductionExecutionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductionExecutionProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductionExecutionRef
    on AutoDisposeStreamProviderRef<ProductionExecutionModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ProductionExecutionProviderElement
    extends AutoDisposeStreamProviderElement<ProductionExecutionModel>
    with ProductionExecutionRef {
  _ProductionExecutionProviderElement(super.provider);

  @override
  String get id => (origin as ProductionExecutionProvider).id;
}

String _$productionExecutionControllerHash() =>
    r'ba203e60083438d9d0808bb3002c3a9f9279e57e';

/// StateNotifier provider for managing production execution state
///
/// Copied from [ProductionExecutionController].
@ProviderFor(ProductionExecutionController)
final productionExecutionControllerProvider = AutoDisposeNotifierProvider<
    ProductionExecutionController, AsyncValue<void>>.internal(
  ProductionExecutionController.new,
  name: r'productionExecutionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productionExecutionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductionExecutionController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
