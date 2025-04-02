// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_aging_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryAgingHash() => r'9b86a8f8b86797d8fbfee5b84029bd19ede5da07';

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

abstract class _$InventoryAging extends BuildlessAutoDisposeAsyncNotifier<
    Map<AgeBracket, List<InventoryItemModel>>> {
  late final String warehouseId;

  FutureOr<Map<AgeBracket, List<InventoryItemModel>>> build(
    String warehouseId,
  );
}

/// See also [InventoryAging].
@ProviderFor(InventoryAging)
const inventoryAgingProvider = InventoryAgingFamily();

/// See also [InventoryAging].
class InventoryAgingFamily
    extends Family<AsyncValue<Map<AgeBracket, List<InventoryItemModel>>>> {
  /// See also [InventoryAging].
  const InventoryAgingFamily();

  /// See also [InventoryAging].
  InventoryAgingProvider call(
    String warehouseId,
  ) {
    return InventoryAgingProvider(
      warehouseId,
    );
  }

  @override
  InventoryAgingProvider getProviderOverride(
    covariant InventoryAgingProvider provider,
  ) {
    return call(
      provider.warehouseId,
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
  String? get name => r'inventoryAgingProvider';
}

/// See also [InventoryAging].
class InventoryAgingProvider extends AutoDisposeAsyncNotifierProviderImpl<
    InventoryAging, Map<AgeBracket, List<InventoryItemModel>>> {
  /// See also [InventoryAging].
  InventoryAgingProvider(
    String warehouseId,
  ) : this._internal(
          () => InventoryAging()..warehouseId = warehouseId,
          from: inventoryAgingProvider,
          name: r'inventoryAgingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inventoryAgingHash,
          dependencies: InventoryAgingFamily._dependencies,
          allTransitiveDependencies:
              InventoryAgingFamily._allTransitiveDependencies,
          warehouseId: warehouseId,
        );

  InventoryAgingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.warehouseId,
  }) : super.internal();

  final String warehouseId;

  @override
  FutureOr<Map<AgeBracket, List<InventoryItemModel>>> runNotifierBuild(
    covariant InventoryAging notifier,
  ) {
    return notifier.build(
      warehouseId,
    );
  }

  @override
  Override overrideWith(InventoryAging Function() create) {
    return ProviderOverride(
      origin: this,
      override: InventoryAgingProvider._internal(
        () => create()..warehouseId = warehouseId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        warehouseId: warehouseId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<InventoryAging,
      Map<AgeBracket, List<InventoryItemModel>>> createElement() {
    return _InventoryAgingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryAgingProvider && other.warehouseId == warehouseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, warehouseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InventoryAgingRef on AutoDisposeAsyncNotifierProviderRef<
    Map<AgeBracket, List<InventoryItemModel>>> {
  /// The parameter `warehouseId` of this provider.
  String get warehouseId;
}

class _InventoryAgingProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<InventoryAging,
        Map<AgeBracket, List<InventoryItemModel>>> with InventoryAgingRef {
  _InventoryAgingProviderElement(super.provider);

  @override
  String get warehouseId => (origin as InventoryAgingProvider).warehouseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
