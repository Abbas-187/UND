// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_contract_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allContractsHash() => r'61c8b74729478dd46955704bed40656a061dbc15';

/// See also [allContracts].
@ProviderFor(allContracts)
final allContractsProvider =
    AutoDisposeStreamProvider<List<SupplierContract>>.internal(
  allContracts,
  name: r'allContractsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allContractsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllContractsRef = AutoDisposeStreamProviderRef<List<SupplierContract>>;
String _$contractHash() => r'6c5a216884e44b78da0052356de228f8e14c5c17';

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

/// See also [contract].
@ProviderFor(contract)
const contractProvider = ContractFamily();

/// See also [contract].
class ContractFamily extends Family<AsyncValue<SupplierContract>> {
  /// See also [contract].
  const ContractFamily();

  /// See also [contract].
  ContractProvider call(
    String id,
  ) {
    return ContractProvider(
      id,
    );
  }

  @override
  ContractProvider getProviderOverride(
    covariant ContractProvider provider,
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
  String? get name => r'contractProvider';
}

/// See also [contract].
class ContractProvider extends AutoDisposeStreamProvider<SupplierContract> {
  /// See also [contract].
  ContractProvider(
    String id,
  ) : this._internal(
          (ref) => contract(
            ref as ContractRef,
            id,
          ),
          from: contractProvider,
          name: r'contractProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contractHash,
          dependencies: ContractFamily._dependencies,
          allTransitiveDependencies: ContractFamily._allTransitiveDependencies,
          id: id,
        );

  ContractProvider._internal(
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
    Stream<SupplierContract> Function(ContractRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContractProvider._internal(
        (ref) => create(ref as ContractRef),
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
  AutoDisposeStreamProviderElement<SupplierContract> createElement() {
    return _ContractProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContractProvider && other.id == id;
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
mixin ContractRef on AutoDisposeStreamProviderRef<SupplierContract> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ContractProviderElement
    extends AutoDisposeStreamProviderElement<SupplierContract>
    with ContractRef {
  _ContractProviderElement(super.provider);

  @override
  String get id => (origin as ContractProvider).id;
}

String _$supplierContractsHash() => r'c74554eb1a4bc3ef6b8a29e714651bc57f653314';

/// See also [supplierContracts].
@ProviderFor(supplierContracts)
const supplierContractsProvider = SupplierContractsFamily();

/// See also [supplierContracts].
class SupplierContractsFamily
    extends Family<AsyncValue<List<SupplierContract>>> {
  /// See also [supplierContracts].
  const SupplierContractsFamily();

  /// See also [supplierContracts].
  SupplierContractsProvider call(
    String supplierId,
  ) {
    return SupplierContractsProvider(
      supplierId,
    );
  }

  @override
  SupplierContractsProvider getProviderOverride(
    covariant SupplierContractsProvider provider,
  ) {
    return call(
      provider.supplierId,
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
  String? get name => r'supplierContractsProvider';
}

/// See also [supplierContracts].
class SupplierContractsProvider
    extends AutoDisposeFutureProvider<List<SupplierContract>> {
  /// See also [supplierContracts].
  SupplierContractsProvider(
    String supplierId,
  ) : this._internal(
          (ref) => supplierContracts(
            ref as SupplierContractsRef,
            supplierId,
          ),
          from: supplierContractsProvider,
          name: r'supplierContractsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$supplierContractsHash,
          dependencies: SupplierContractsFamily._dependencies,
          allTransitiveDependencies:
              SupplierContractsFamily._allTransitiveDependencies,
          supplierId: supplierId,
        );

  SupplierContractsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplierId,
  }) : super.internal();

  final String supplierId;

  @override
  Override overrideWith(
    FutureOr<List<SupplierContract>> Function(SupplierContractsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupplierContractsProvider._internal(
        (ref) => create(ref as SupplierContractsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplierId: supplierId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SupplierContract>> createElement() {
    return _SupplierContractsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierContractsProvider && other.supplierId == supplierId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplierId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SupplierContractsRef
    on AutoDisposeFutureProviderRef<List<SupplierContract>> {
  /// The parameter `supplierId` of this provider.
  String get supplierId;
}

class _SupplierContractsProviderElement
    extends AutoDisposeFutureProviderElement<List<SupplierContract>>
    with SupplierContractsRef {
  _SupplierContractsProviderElement(super.provider);

  @override
  String get supplierId => (origin as SupplierContractsProvider).supplierId;
}

String _$filteredContractsHash() => r'e50c3641e55149e64af36820f13c5066c1733665';

/// See also [filteredContracts].
@ProviderFor(filteredContracts)
final filteredContractsProvider =
    AutoDisposeFutureProvider<List<SupplierContract>>.internal(
  filteredContracts,
  name: r'filteredContractsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredContractsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredContractsRef
    = AutoDisposeFutureProviderRef<List<SupplierContract>>;
String _$contractNotificationsHash() =>
    r'5aa37f0ad039dd4187ec53f47bab6069d0a83ce1';

/// See also [contractNotifications].
@ProviderFor(contractNotifications)
final contractNotificationsProvider =
    AutoDisposeFutureProvider<List<SupplierContract>>.internal(
  contractNotifications,
  name: r'contractNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contractNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContractNotificationsRef
    = AutoDisposeFutureProviderRef<List<SupplierContract>>;
String _$contractFilterNotifierHash() =>
    r'3bfe98966b650dc83ff0be80c8a5987277b4868c';

/// See also [ContractFilterNotifier].
@ProviderFor(ContractFilterNotifier)
final contractFilterNotifierProvider = AutoDisposeNotifierProvider<
    ContractFilterNotifier, ContractFilter>.internal(
  ContractFilterNotifier.new,
  name: r'contractFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contractFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContractFilterNotifier = AutoDisposeNotifier<ContractFilter>;
String _$contractManagerHash() => r'3267986604c527e529460e1707f2369795fc082b';

/// See also [ContractManager].
@ProviderFor(ContractManager)
final contractManagerProvider =
    AutoDisposeAsyncNotifierProvider<ContractManager, void>.internal(
  ContractManager.new,
  name: r'contractManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contractManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContractManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
