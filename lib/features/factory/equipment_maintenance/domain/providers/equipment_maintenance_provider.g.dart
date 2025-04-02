// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_maintenance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allEquipmentHash() => r'edf419afd7339cbd3bc80ce8cfa72e85eac842a2';

/// See also [allEquipment].
@ProviderFor(allEquipment)
final allEquipmentProvider =
    AutoDisposeFutureProvider<List<EquipmentModel>>.internal(
  allEquipment,
  name: r'allEquipmentProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allEquipmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllEquipmentRef = AutoDisposeFutureProviderRef<List<EquipmentModel>>;
String _$equipmentRequiringMaintenanceHash() =>
    r'e9ba9a728ebf6f2ccc63ce640ba9d6a13859bcaa';

/// See also [equipmentRequiringMaintenance].
@ProviderFor(equipmentRequiringMaintenance)
final equipmentRequiringMaintenanceProvider =
    AutoDisposeFutureProvider<List<EquipmentModel>>.internal(
  equipmentRequiringMaintenance,
  name: r'equipmentRequiringMaintenanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$equipmentRequiringMaintenanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EquipmentRequiringMaintenanceRef
    = AutoDisposeFutureProviderRef<List<EquipmentModel>>;
String _$equipmentRequiringSanitizationHash() =>
    r'de1a9b1bb063266847dbee33a1f96778f63af40e';

/// See also [equipmentRequiringSanitization].
@ProviderFor(equipmentRequiringSanitization)
final equipmentRequiringSanitizationProvider =
    AutoDisposeFutureProvider<List<EquipmentModel>>.internal(
  equipmentRequiringSanitization,
  name: r'equipmentRequiringSanitizationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$equipmentRequiringSanitizationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EquipmentRequiringSanitizationRef
    = AutoDisposeFutureProviderRef<List<EquipmentModel>>;
String _$equipmentHash() => r'2f8a11c09f9c72578b63a7f145f128b150c4ea3b';

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

/// See also [equipment].
@ProviderFor(equipment)
const equipmentProvider = EquipmentFamily();

/// See also [equipment].
class EquipmentFamily extends Family<AsyncValue<EquipmentModel>> {
  /// See also [equipment].
  const EquipmentFamily();

  /// See also [equipment].
  EquipmentProvider call(
    String equipmentId,
  ) {
    return EquipmentProvider(
      equipmentId,
    );
  }

  @override
  EquipmentProvider getProviderOverride(
    covariant EquipmentProvider provider,
  ) {
    return call(
      provider.equipmentId,
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
  String? get name => r'equipmentProvider';
}

/// See also [equipment].
class EquipmentProvider extends AutoDisposeFutureProvider<EquipmentModel> {
  /// See also [equipment].
  EquipmentProvider(
    String equipmentId,
  ) : this._internal(
          (ref) => equipment(
            ref as EquipmentRef,
            equipmentId,
          ),
          from: equipmentProvider,
          name: r'equipmentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$equipmentHash,
          dependencies: EquipmentFamily._dependencies,
          allTransitiveDependencies: EquipmentFamily._allTransitiveDependencies,
          equipmentId: equipmentId,
        );

  EquipmentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.equipmentId,
  }) : super.internal();

  final String equipmentId;

  @override
  Override overrideWith(
    FutureOr<EquipmentModel> Function(EquipmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EquipmentProvider._internal(
        (ref) => create(ref as EquipmentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        equipmentId: equipmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EquipmentModel> createElement() {
    return _EquipmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EquipmentProvider && other.equipmentId == equipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, equipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EquipmentRef on AutoDisposeFutureProviderRef<EquipmentModel> {
  /// The parameter `equipmentId` of this provider.
  String get equipmentId;
}

class _EquipmentProviderElement
    extends AutoDisposeFutureProviderElement<EquipmentModel> with EquipmentRef {
  _EquipmentProviderElement(super.provider);

  @override
  String get equipmentId => (origin as EquipmentProvider).equipmentId;
}

String _$equipmentMaintenanceRecordsHash() =>
    r'217612642663cc074daa010c59a003b498106379';

/// See also [equipmentMaintenanceRecords].
@ProviderFor(equipmentMaintenanceRecords)
const equipmentMaintenanceRecordsProvider = EquipmentMaintenanceRecordsFamily();

/// See also [equipmentMaintenanceRecords].
class EquipmentMaintenanceRecordsFamily
    extends Family<AsyncValue<List<MaintenanceRecordModel>>> {
  /// See also [equipmentMaintenanceRecords].
  const EquipmentMaintenanceRecordsFamily();

  /// See also [equipmentMaintenanceRecords].
  EquipmentMaintenanceRecordsProvider call(
    String equipmentId,
  ) {
    return EquipmentMaintenanceRecordsProvider(
      equipmentId,
    );
  }

  @override
  EquipmentMaintenanceRecordsProvider getProviderOverride(
    covariant EquipmentMaintenanceRecordsProvider provider,
  ) {
    return call(
      provider.equipmentId,
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
  String? get name => r'equipmentMaintenanceRecordsProvider';
}

/// See also [equipmentMaintenanceRecords].
class EquipmentMaintenanceRecordsProvider
    extends AutoDisposeFutureProvider<List<MaintenanceRecordModel>> {
  /// See also [equipmentMaintenanceRecords].
  EquipmentMaintenanceRecordsProvider(
    String equipmentId,
  ) : this._internal(
          (ref) => equipmentMaintenanceRecords(
            ref as EquipmentMaintenanceRecordsRef,
            equipmentId,
          ),
          from: equipmentMaintenanceRecordsProvider,
          name: r'equipmentMaintenanceRecordsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$equipmentMaintenanceRecordsHash,
          dependencies: EquipmentMaintenanceRecordsFamily._dependencies,
          allTransitiveDependencies:
              EquipmentMaintenanceRecordsFamily._allTransitiveDependencies,
          equipmentId: equipmentId,
        );

  EquipmentMaintenanceRecordsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.equipmentId,
  }) : super.internal();

  final String equipmentId;

  @override
  Override overrideWith(
    FutureOr<List<MaintenanceRecordModel>> Function(
            EquipmentMaintenanceRecordsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EquipmentMaintenanceRecordsProvider._internal(
        (ref) => create(ref as EquipmentMaintenanceRecordsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        equipmentId: equipmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MaintenanceRecordModel>>
      createElement() {
    return _EquipmentMaintenanceRecordsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EquipmentMaintenanceRecordsProvider &&
        other.equipmentId == equipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, equipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EquipmentMaintenanceRecordsRef
    on AutoDisposeFutureProviderRef<List<MaintenanceRecordModel>> {
  /// The parameter `equipmentId` of this provider.
  String get equipmentId;
}

class _EquipmentMaintenanceRecordsProviderElement
    extends AutoDisposeFutureProviderElement<List<MaintenanceRecordModel>>
    with EquipmentMaintenanceRecordsRef {
  _EquipmentMaintenanceRecordsProviderElement(super.provider);

  @override
  String get equipmentId =>
      (origin as EquipmentMaintenanceRecordsProvider).equipmentId;
}

String _$upcomingMaintenanceRecordsHash() =>
    r'dd685073b45c355df1093c293f405ac939ffa2bf';

/// See also [upcomingMaintenanceRecords].
@ProviderFor(upcomingMaintenanceRecords)
final upcomingMaintenanceRecordsProvider =
    AutoDisposeFutureProvider<List<MaintenanceRecordModel>>.internal(
  upcomingMaintenanceRecords,
  name: r'upcomingMaintenanceRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingMaintenanceRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingMaintenanceRecordsRef
    = AutoDisposeFutureProviderRef<List<MaintenanceRecordModel>>;
String _$equipmentStateHash() => r'd53a377ad3a56dd5c83990805d560c0ea02aebbb';

abstract class _$EquipmentState
    extends BuildlessAutoDisposeNotifier<AsyncValue<EquipmentModel?>> {
  late final String? equipmentId;

  AsyncValue<EquipmentModel?> build(
    String? equipmentId,
  );
}

/// See also [EquipmentState].
@ProviderFor(EquipmentState)
const equipmentStateProvider = EquipmentStateFamily();

/// See also [EquipmentState].
class EquipmentStateFamily extends Family<AsyncValue<EquipmentModel?>> {
  /// See also [EquipmentState].
  const EquipmentStateFamily();

  /// See also [EquipmentState].
  EquipmentStateProvider call(
    String? equipmentId,
  ) {
    return EquipmentStateProvider(
      equipmentId,
    );
  }

  @override
  EquipmentStateProvider getProviderOverride(
    covariant EquipmentStateProvider provider,
  ) {
    return call(
      provider.equipmentId,
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
  String? get name => r'equipmentStateProvider';
}

/// See also [EquipmentState].
class EquipmentStateProvider extends AutoDisposeNotifierProviderImpl<
    EquipmentState, AsyncValue<EquipmentModel?>> {
  /// See also [EquipmentState].
  EquipmentStateProvider(
    String? equipmentId,
  ) : this._internal(
          () => EquipmentState()..equipmentId = equipmentId,
          from: equipmentStateProvider,
          name: r'equipmentStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$equipmentStateHash,
          dependencies: EquipmentStateFamily._dependencies,
          allTransitiveDependencies:
              EquipmentStateFamily._allTransitiveDependencies,
          equipmentId: equipmentId,
        );

  EquipmentStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.equipmentId,
  }) : super.internal();

  final String? equipmentId;

  @override
  AsyncValue<EquipmentModel?> runNotifierBuild(
    covariant EquipmentState notifier,
  ) {
    return notifier.build(
      equipmentId,
    );
  }

  @override
  Override overrideWith(EquipmentState Function() create) {
    return ProviderOverride(
      origin: this,
      override: EquipmentStateProvider._internal(
        () => create()..equipmentId = equipmentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        equipmentId: equipmentId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<EquipmentState,
      AsyncValue<EquipmentModel?>> createElement() {
    return _EquipmentStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EquipmentStateProvider && other.equipmentId == equipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, equipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EquipmentStateRef
    on AutoDisposeNotifierProviderRef<AsyncValue<EquipmentModel?>> {
  /// The parameter `equipmentId` of this provider.
  String? get equipmentId;
}

class _EquipmentStateProviderElement extends AutoDisposeNotifierProviderElement<
    EquipmentState, AsyncValue<EquipmentModel?>> with EquipmentStateRef {
  _EquipmentStateProviderElement(super.provider);

  @override
  String? get equipmentId => (origin as EquipmentStateProvider).equipmentId;
}

String _$maintenanceRecordStateHash() =>
    r'e1886056c68617a4fcc8cb9b50caa484e307b689';

abstract class _$MaintenanceRecordState
    extends BuildlessAutoDisposeNotifier<AsyncValue<MaintenanceRecordModel?>> {
  late final String? recordId;

  AsyncValue<MaintenanceRecordModel?> build(
    String? recordId,
  );
}

/// See also [MaintenanceRecordState].
@ProviderFor(MaintenanceRecordState)
const maintenanceRecordStateProvider = MaintenanceRecordStateFamily();

/// See also [MaintenanceRecordState].
class MaintenanceRecordStateFamily
    extends Family<AsyncValue<MaintenanceRecordModel?>> {
  /// See also [MaintenanceRecordState].
  const MaintenanceRecordStateFamily();

  /// See also [MaintenanceRecordState].
  MaintenanceRecordStateProvider call(
    String? recordId,
  ) {
    return MaintenanceRecordStateProvider(
      recordId,
    );
  }

  @override
  MaintenanceRecordStateProvider getProviderOverride(
    covariant MaintenanceRecordStateProvider provider,
  ) {
    return call(
      provider.recordId,
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
  String? get name => r'maintenanceRecordStateProvider';
}

/// See also [MaintenanceRecordState].
class MaintenanceRecordStateProvider extends AutoDisposeNotifierProviderImpl<
    MaintenanceRecordState, AsyncValue<MaintenanceRecordModel?>> {
  /// See also [MaintenanceRecordState].
  MaintenanceRecordStateProvider(
    String? recordId,
  ) : this._internal(
          () => MaintenanceRecordState()..recordId = recordId,
          from: maintenanceRecordStateProvider,
          name: r'maintenanceRecordStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$maintenanceRecordStateHash,
          dependencies: MaintenanceRecordStateFamily._dependencies,
          allTransitiveDependencies:
              MaintenanceRecordStateFamily._allTransitiveDependencies,
          recordId: recordId,
        );

  MaintenanceRecordStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.recordId,
  }) : super.internal();

  final String? recordId;

  @override
  AsyncValue<MaintenanceRecordModel?> runNotifierBuild(
    covariant MaintenanceRecordState notifier,
  ) {
    return notifier.build(
      recordId,
    );
  }

  @override
  Override overrideWith(MaintenanceRecordState Function() create) {
    return ProviderOverride(
      origin: this,
      override: MaintenanceRecordStateProvider._internal(
        () => create()..recordId = recordId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        recordId: recordId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<MaintenanceRecordState,
      AsyncValue<MaintenanceRecordModel?>> createElement() {
    return _MaintenanceRecordStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MaintenanceRecordStateProvider &&
        other.recordId == recordId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, recordId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MaintenanceRecordStateRef
    on AutoDisposeNotifierProviderRef<AsyncValue<MaintenanceRecordModel?>> {
  /// The parameter `recordId` of this provider.
  String? get recordId;
}

class _MaintenanceRecordStateProviderElement
    extends AutoDisposeNotifierProviderElement<MaintenanceRecordState,
        AsyncValue<MaintenanceRecordModel?>> with MaintenanceRecordStateRef {
  _MaintenanceRecordStateProviderElement(super.provider);

  @override
  String? get recordId => (origin as MaintenanceRecordStateProvider).recordId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
