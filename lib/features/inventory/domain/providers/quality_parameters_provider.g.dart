// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_parameters_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemQualityParametersHash() =>
    r'a2d2368b732a7a00c0042cbd37dec7cd77ff7900';

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

abstract class _$ItemQualityParameters
    extends BuildlessAutoDisposeStreamNotifier<
        List<DairyQualityParametersModel>> {
  late final String inventoryItemId;

  Stream<List<DairyQualityParametersModel>> build(
    String inventoryItemId,
  );
}

/// See also [ItemQualityParameters].
@ProviderFor(ItemQualityParameters)
const itemQualityParametersProvider = ItemQualityParametersFamily();

/// See also [ItemQualityParameters].
class ItemQualityParametersFamily
    extends Family<AsyncValue<List<DairyQualityParametersModel>>> {
  /// See also [ItemQualityParameters].
  const ItemQualityParametersFamily();

  /// See also [ItemQualityParameters].
  ItemQualityParametersProvider call(
    String inventoryItemId,
  ) {
    return ItemQualityParametersProvider(
      inventoryItemId,
    );
  }

  @override
  ItemQualityParametersProvider getProviderOverride(
    covariant ItemQualityParametersProvider provider,
  ) {
    return call(
      provider.inventoryItemId,
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
  String? get name => r'itemQualityParametersProvider';
}

/// See also [ItemQualityParameters].
class ItemQualityParametersProvider
    extends AutoDisposeStreamNotifierProviderImpl<ItemQualityParameters,
        List<DairyQualityParametersModel>> {
  /// See also [ItemQualityParameters].
  ItemQualityParametersProvider(
    String inventoryItemId,
  ) : this._internal(
          () => ItemQualityParameters()..inventoryItemId = inventoryItemId,
          from: itemQualityParametersProvider,
          name: r'itemQualityParametersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemQualityParametersHash,
          dependencies: ItemQualityParametersFamily._dependencies,
          allTransitiveDependencies:
              ItemQualityParametersFamily._allTransitiveDependencies,
          inventoryItemId: inventoryItemId,
        );

  ItemQualityParametersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inventoryItemId,
  }) : super.internal();

  final String inventoryItemId;

  @override
  Stream<List<DairyQualityParametersModel>> runNotifierBuild(
    covariant ItemQualityParameters notifier,
  ) {
    return notifier.build(
      inventoryItemId,
    );
  }

  @override
  Override overrideWith(ItemQualityParameters Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemQualityParametersProvider._internal(
        () => create()..inventoryItemId = inventoryItemId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inventoryItemId: inventoryItemId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<ItemQualityParameters,
      List<DairyQualityParametersModel>> createElement() {
    return _ItemQualityParametersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemQualityParametersProvider &&
        other.inventoryItemId == inventoryItemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inventoryItemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemQualityParametersRef
    on AutoDisposeStreamNotifierProviderRef<List<DairyQualityParametersModel>> {
  /// The parameter `inventoryItemId` of this provider.
  String get inventoryItemId;
}

class _ItemQualityParametersProviderElement
    extends AutoDisposeStreamNotifierProviderElement<ItemQualityParameters,
        List<DairyQualityParametersModel>> with ItemQualityParametersRef {
  _ItemQualityParametersProviderElement(super.provider);

  @override
  String get inventoryItemId =>
      (origin as ItemQualityParametersProvider).inventoryItemId;
}

String _$batchQualityParametersHash() =>
    r'2380ce68887f2e9be3482772786f0724ddeaaa8f';

abstract class _$BatchQualityParameters
    extends BuildlessAutoDisposeStreamNotifier<
        List<DairyQualityParametersModel>> {
  late final String batchNumber;

  Stream<List<DairyQualityParametersModel>> build(
    String batchNumber,
  );
}

/// See also [BatchQualityParameters].
@ProviderFor(BatchQualityParameters)
const batchQualityParametersProvider = BatchQualityParametersFamily();

/// See also [BatchQualityParameters].
class BatchQualityParametersFamily
    extends Family<AsyncValue<List<DairyQualityParametersModel>>> {
  /// See also [BatchQualityParameters].
  const BatchQualityParametersFamily();

  /// See also [BatchQualityParameters].
  BatchQualityParametersProvider call(
    String batchNumber,
  ) {
    return BatchQualityParametersProvider(
      batchNumber,
    );
  }

  @override
  BatchQualityParametersProvider getProviderOverride(
    covariant BatchQualityParametersProvider provider,
  ) {
    return call(
      provider.batchNumber,
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
  String? get name => r'batchQualityParametersProvider';
}

/// See also [BatchQualityParameters].
class BatchQualityParametersProvider
    extends AutoDisposeStreamNotifierProviderImpl<BatchQualityParameters,
        List<DairyQualityParametersModel>> {
  /// See also [BatchQualityParameters].
  BatchQualityParametersProvider(
    String batchNumber,
  ) : this._internal(
          () => BatchQualityParameters()..batchNumber = batchNumber,
          from: batchQualityParametersProvider,
          name: r'batchQualityParametersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$batchQualityParametersHash,
          dependencies: BatchQualityParametersFamily._dependencies,
          allTransitiveDependencies:
              BatchQualityParametersFamily._allTransitiveDependencies,
          batchNumber: batchNumber,
        );

  BatchQualityParametersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.batchNumber,
  }) : super.internal();

  final String batchNumber;

  @override
  Stream<List<DairyQualityParametersModel>> runNotifierBuild(
    covariant BatchQualityParameters notifier,
  ) {
    return notifier.build(
      batchNumber,
    );
  }

  @override
  Override overrideWith(BatchQualityParameters Function() create) {
    return ProviderOverride(
      origin: this,
      override: BatchQualityParametersProvider._internal(
        () => create()..batchNumber = batchNumber,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        batchNumber: batchNumber,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<BatchQualityParameters,
      List<DairyQualityParametersModel>> createElement() {
    return _BatchQualityParametersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BatchQualityParametersProvider &&
        other.batchNumber == batchNumber;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, batchNumber.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BatchQualityParametersRef
    on AutoDisposeStreamNotifierProviderRef<List<DairyQualityParametersModel>> {
  /// The parameter `batchNumber` of this provider.
  String get batchNumber;
}

class _BatchQualityParametersProviderElement
    extends AutoDisposeStreamNotifierProviderElement<BatchQualityParameters,
        List<DairyQualityParametersModel>> with BatchQualityParametersRef {
  _BatchQualityParametersProviderElement(super.provider);

  @override
  String get batchNumber =>
      (origin as BatchQualityParametersProvider).batchNumber;
}

String _$pendingQualityTestsHash() =>
    r'a31d6e3f20ad8c4b67e0980d56f1466c16de987f';

/// See also [PendingQualityTests].
@ProviderFor(PendingQualityTests)
final pendingQualityTestsProvider = AutoDisposeStreamNotifierProvider<
    PendingQualityTests, List<DairyQualityParametersModel>>.internal(
  PendingQualityTests.new,
  name: r'pendingQualityTestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingQualityTestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PendingQualityTests
    = AutoDisposeStreamNotifier<List<DairyQualityParametersModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
