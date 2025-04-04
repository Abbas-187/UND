// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getSuppliersUseCaseHash() =>
    r'aff0c640a77a4654f346aa152998e8d580145d36';

/// Provider for the GetSuppliersUseCase
///
/// Copied from [getSuppliersUseCase].
@ProviderFor(getSuppliersUseCase)
final getSuppliersUseCaseProvider =
    AutoDisposeProvider<GetSuppliersUseCase>.internal(
  getSuppliersUseCase,
  name: r'getSuppliersUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getSuppliersUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetSuppliersUseCaseRef = AutoDisposeProviderRef<GetSuppliersUseCase>;
String _$getSupplierByIdUseCaseHash() =>
    r'03b0862641b3bac8feef27517a8abdf9dedb3b6c';

/// Provider for the GetSupplierByIdUseCase
///
/// Copied from [getSupplierByIdUseCase].
@ProviderFor(getSupplierByIdUseCase)
final getSupplierByIdUseCaseProvider =
    AutoDisposeProvider<GetSupplierByIdUseCase>.internal(
  getSupplierByIdUseCase,
  name: r'getSupplierByIdUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getSupplierByIdUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetSupplierByIdUseCaseRef
    = AutoDisposeProviderRef<GetSupplierByIdUseCase>;
String _$createSupplierUseCaseHash() =>
    r'23c7a5ba3dddc7d9e3ae96854b280ed78fc3ac38';

/// Provider for the CreateSupplierUseCase
///
/// Copied from [createSupplierUseCase].
@ProviderFor(createSupplierUseCase)
final createSupplierUseCaseProvider =
    AutoDisposeProvider<CreateSupplierUseCase>.internal(
  createSupplierUseCase,
  name: r'createSupplierUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createSupplierUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateSupplierUseCaseRef
    = AutoDisposeProviderRef<CreateSupplierUseCase>;
String _$updateSupplierUseCaseHash() =>
    r'06ffff5413e71c0573f82696f09120ca49c224a2';

/// Provider for the UpdateSupplierUseCase
///
/// Copied from [updateSupplierUseCase].
@ProviderFor(updateSupplierUseCase)
final updateSupplierUseCaseProvider =
    AutoDisposeProvider<UpdateSupplierUseCase>.internal(
  updateSupplierUseCase,
  name: r'updateSupplierUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateSupplierUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateSupplierUseCaseRef
    = AutoDisposeProviderRef<UpdateSupplierUseCase>;
String _$deleteSupplierUseCaseHash() =>
    r'80818e5ddc4f4c72e9ad3dbd3d9c2abaf0026de9';

/// Provider for the DeleteSupplierUseCase
///
/// Copied from [deleteSupplierUseCase].
@ProviderFor(deleteSupplierUseCase)
final deleteSupplierUseCaseProvider =
    AutoDisposeProvider<DeleteSupplierUseCase>.internal(
  deleteSupplierUseCase,
  name: r'deleteSupplierUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteSupplierUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteSupplierUseCaseRef
    = AutoDisposeProviderRef<DeleteSupplierUseCase>;
String _$supplierRepositoryHash() =>
    r'b44c5c09760641af5f8fccc3e9257e9e6da311f3';

/// Provider for supplier repository (to be implemented in the data layer)
///
/// Copied from [supplierRepository].
@ProviderFor(supplierRepository)
final supplierRepositoryProvider =
    AutoDisposeProvider<SupplierRepository>.internal(
  supplierRepository,
  name: r'supplierRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supplierRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupplierRepositoryRef = AutoDisposeProviderRef<SupplierRepository>;
String _$suppliersNotifierHash() => r'96149affc02cd225e67c2ba43176edb1a6eb4780';

/// Notifier for suppliers list
///
/// Copied from [SuppliersNotifier].
@ProviderFor(SuppliersNotifier)
final suppliersNotifierProvider =
    AutoDisposeNotifierProvider<SuppliersNotifier, SuppliersState>.internal(
  SuppliersNotifier.new,
  name: r'suppliersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$suppliersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SuppliersNotifier = AutoDisposeNotifier<SuppliersState>;
String _$supplierDetailNotifierHash() =>
    r'a09ce498b78a2c6cc8f28b7405c97e8aa0de9680';

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

abstract class _$SupplierDetailNotifier
    extends BuildlessAutoDisposeNotifier<SupplierDetailState> {
  late final String supplierId;

  SupplierDetailState build(
    String supplierId,
  );
}

/// Notifier for supplier details
///
/// Copied from [SupplierDetailNotifier].
@ProviderFor(SupplierDetailNotifier)
const supplierDetailNotifierProvider = SupplierDetailNotifierFamily();

/// Notifier for supplier details
///
/// Copied from [SupplierDetailNotifier].
class SupplierDetailNotifierFamily extends Family<SupplierDetailState> {
  /// Notifier for supplier details
  ///
  /// Copied from [SupplierDetailNotifier].
  const SupplierDetailNotifierFamily();

  /// Notifier for supplier details
  ///
  /// Copied from [SupplierDetailNotifier].
  SupplierDetailNotifierProvider call(
    String supplierId,
  ) {
    return SupplierDetailNotifierProvider(
      supplierId,
    );
  }

  @override
  SupplierDetailNotifierProvider getProviderOverride(
    covariant SupplierDetailNotifierProvider provider,
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
  String? get name => r'supplierDetailNotifierProvider';
}

/// Notifier for supplier details
///
/// Copied from [SupplierDetailNotifier].
class SupplierDetailNotifierProvider extends AutoDisposeNotifierProviderImpl<
    SupplierDetailNotifier, SupplierDetailState> {
  /// Notifier for supplier details
  ///
  /// Copied from [SupplierDetailNotifier].
  SupplierDetailNotifierProvider(
    String supplierId,
  ) : this._internal(
          () => SupplierDetailNotifier()..supplierId = supplierId,
          from: supplierDetailNotifierProvider,
          name: r'supplierDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$supplierDetailNotifierHash,
          dependencies: SupplierDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              SupplierDetailNotifierFamily._allTransitiveDependencies,
          supplierId: supplierId,
        );

  SupplierDetailNotifierProvider._internal(
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
  SupplierDetailState runNotifierBuild(
    covariant SupplierDetailNotifier notifier,
  ) {
    return notifier.build(
      supplierId,
    );
  }

  @override
  Override overrideWith(SupplierDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SupplierDetailNotifierProvider._internal(
        () => create()..supplierId = supplierId,
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
  AutoDisposeNotifierProviderElement<SupplierDetailNotifier,
      SupplierDetailState> createElement() {
    return _SupplierDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierDetailNotifierProvider &&
        other.supplierId == supplierId;
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
mixin SupplierDetailNotifierRef
    on AutoDisposeNotifierProviderRef<SupplierDetailState> {
  /// The parameter `supplierId` of this provider.
  String get supplierId;
}

class _SupplierDetailNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<SupplierDetailNotifier,
        SupplierDetailState> with SupplierDetailNotifierRef {
  _SupplierDetailNotifierProviderElement(super.provider);

  @override
  String get supplierId =>
      (origin as SupplierDetailNotifierProvider).supplierId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
