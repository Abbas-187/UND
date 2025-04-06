// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$temperatureLogsHash() => r'69ecd86ead6ffc92859dbee12d931364656cb29b';

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

abstract class _$TemperatureLogs
    extends BuildlessAutoDisposeStreamNotifier<List<TemperatureLogModel>> {
  late final String locationId;

  Stream<List<TemperatureLogModel>> build(
    String locationId,
  );
}

/// See also [TemperatureLogs].
@ProviderFor(TemperatureLogs)
const temperatureLogsProvider = TemperatureLogsFamily();

/// See also [TemperatureLogs].
class TemperatureLogsFamily
    extends Family<AsyncValue<List<TemperatureLogModel>>> {
  /// See also [TemperatureLogs].
  const TemperatureLogsFamily();

  /// See also [TemperatureLogs].
  TemperatureLogsProvider call(
    String locationId,
  ) {
    return TemperatureLogsProvider(
      locationId,
    );
  }

  @override
  TemperatureLogsProvider getProviderOverride(
    covariant TemperatureLogsProvider provider,
  ) {
    return call(
      provider.locationId,
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
  String? get name => r'temperatureLogsProvider';
}

/// See also [TemperatureLogs].
class TemperatureLogsProvider extends AutoDisposeStreamNotifierProviderImpl<
    TemperatureLogs, List<TemperatureLogModel>> {
  /// See also [TemperatureLogs].
  TemperatureLogsProvider(
    String locationId,
  ) : this._internal(
          () => TemperatureLogs()..locationId = locationId,
          from: temperatureLogsProvider,
          name: r'temperatureLogsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$temperatureLogsHash,
          dependencies: TemperatureLogsFamily._dependencies,
          allTransitiveDependencies:
              TemperatureLogsFamily._allTransitiveDependencies,
          locationId: locationId,
        );

  TemperatureLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.locationId,
  }) : super.internal();

  final String locationId;

  @override
  Stream<List<TemperatureLogModel>> runNotifierBuild(
    covariant TemperatureLogs notifier,
  ) {
    return notifier.build(
      locationId,
    );
  }

  @override
  Override overrideWith(TemperatureLogs Function() create) {
    return ProviderOverride(
      origin: this,
      override: TemperatureLogsProvider._internal(
        () => create()..locationId = locationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        locationId: locationId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<TemperatureLogs,
      List<TemperatureLogModel>> createElement() {
    return _TemperatureLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemperatureLogsProvider && other.locationId == locationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, locationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TemperatureLogsRef
    on AutoDisposeStreamNotifierProviderRef<List<TemperatureLogModel>> {
  /// The parameter `locationId` of this provider.
  String get locationId;
}

class _TemperatureLogsProviderElement
    extends AutoDisposeStreamNotifierProviderElement<TemperatureLogs,
        List<TemperatureLogModel>> with TemperatureLogsRef {
  _TemperatureLogsProviderElement(super.provider);

  @override
  String get locationId => (origin as TemperatureLogsProvider).locationId;
}

String _$temperatureSettingsHash() =>
    r'3e881abe9dc5042b3aefbd7cee948f295d6d09f2';

abstract class _$TemperatureSettings
    extends BuildlessAutoDisposeAsyncNotifier<TemperatureSettingsModel> {
  late final String locationId;

  FutureOr<TemperatureSettingsModel> build(
    String locationId,
  );
}

/// See also [TemperatureSettings].
@ProviderFor(TemperatureSettings)
const temperatureSettingsProvider = TemperatureSettingsFamily();

/// See also [TemperatureSettings].
class TemperatureSettingsFamily
    extends Family<AsyncValue<TemperatureSettingsModel>> {
  /// See also [TemperatureSettings].
  const TemperatureSettingsFamily();

  /// See also [TemperatureSettings].
  TemperatureSettingsProvider call(
    String locationId,
  ) {
    return TemperatureSettingsProvider(
      locationId,
    );
  }

  @override
  TemperatureSettingsProvider getProviderOverride(
    covariant TemperatureSettingsProvider provider,
  ) {
    return call(
      provider.locationId,
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
  String? get name => r'temperatureSettingsProvider';
}

/// See also [TemperatureSettings].
class TemperatureSettingsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TemperatureSettings, TemperatureSettingsModel> {
  /// See also [TemperatureSettings].
  TemperatureSettingsProvider(
    String locationId,
  ) : this._internal(
          () => TemperatureSettings()..locationId = locationId,
          from: temperatureSettingsProvider,
          name: r'temperatureSettingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$temperatureSettingsHash,
          dependencies: TemperatureSettingsFamily._dependencies,
          allTransitiveDependencies:
              TemperatureSettingsFamily._allTransitiveDependencies,
          locationId: locationId,
        );

  TemperatureSettingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.locationId,
  }) : super.internal();

  final String locationId;

  @override
  FutureOr<TemperatureSettingsModel> runNotifierBuild(
    covariant TemperatureSettings notifier,
  ) {
    return notifier.build(
      locationId,
    );
  }

  @override
  Override overrideWith(TemperatureSettings Function() create) {
    return ProviderOverride(
      origin: this,
      override: TemperatureSettingsProvider._internal(
        () => create()..locationId = locationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        locationId: locationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TemperatureSettings,
      TemperatureSettingsModel> createElement() {
    return _TemperatureSettingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemperatureSettingsProvider &&
        other.locationId == locationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, locationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TemperatureSettingsRef
    on AutoDisposeAsyncNotifierProviderRef<TemperatureSettingsModel> {
  /// The parameter `locationId` of this provider.
  String get locationId;
}

class _TemperatureSettingsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TemperatureSettings,
        TemperatureSettingsModel> with TemperatureSettingsRef {
  _TemperatureSettingsProviderElement(super.provider);

  @override
  String get locationId => (origin as TemperatureSettingsProvider).locationId;
}

String _$temperatureAlertsHash() => r'76d3b4e2cead5e37a175ba0cdcbb64f3714f91fa';

abstract class _$TemperatureAlerts
    extends BuildlessAutoDisposeStreamNotifier<List<Map<String, dynamic>>> {
  late final bool onlyUnresolved;

  Stream<List<Map<String, dynamic>>> build({
    bool onlyUnresolved = true,
  });
}

/// See also [TemperatureAlerts].
@ProviderFor(TemperatureAlerts)
const temperatureAlertsProvider = TemperatureAlertsFamily();

/// See also [TemperatureAlerts].
class TemperatureAlertsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [TemperatureAlerts].
  const TemperatureAlertsFamily();

  /// See also [TemperatureAlerts].
  TemperatureAlertsProvider call({
    bool onlyUnresolved = true,
  }) {
    return TemperatureAlertsProvider(
      onlyUnresolved: onlyUnresolved,
    );
  }

  @override
  TemperatureAlertsProvider getProviderOverride(
    covariant TemperatureAlertsProvider provider,
  ) {
    return call(
      onlyUnresolved: provider.onlyUnresolved,
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
  String? get name => r'temperatureAlertsProvider';
}

/// See also [TemperatureAlerts].
class TemperatureAlertsProvider extends AutoDisposeStreamNotifierProviderImpl<
    TemperatureAlerts, List<Map<String, dynamic>>> {
  /// See also [TemperatureAlerts].
  TemperatureAlertsProvider({
    bool onlyUnresolved = true,
  }) : this._internal(
          () => TemperatureAlerts()..onlyUnresolved = onlyUnresolved,
          from: temperatureAlertsProvider,
          name: r'temperatureAlertsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$temperatureAlertsHash,
          dependencies: TemperatureAlertsFamily._dependencies,
          allTransitiveDependencies:
              TemperatureAlertsFamily._allTransitiveDependencies,
          onlyUnresolved: onlyUnresolved,
        );

  TemperatureAlertsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.onlyUnresolved,
  }) : super.internal();

  final bool onlyUnresolved;

  @override
  Stream<List<Map<String, dynamic>>> runNotifierBuild(
    covariant TemperatureAlerts notifier,
  ) {
    return notifier.build(
      onlyUnresolved: onlyUnresolved,
    );
  }

  @override
  Override overrideWith(TemperatureAlerts Function() create) {
    return ProviderOverride(
      origin: this,
      override: TemperatureAlertsProvider._internal(
        () => create()..onlyUnresolved = onlyUnresolved,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        onlyUnresolved: onlyUnresolved,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<TemperatureAlerts,
      List<Map<String, dynamic>>> createElement() {
    return _TemperatureAlertsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemperatureAlertsProvider &&
        other.onlyUnresolved == onlyUnresolved;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, onlyUnresolved.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TemperatureAlertsRef
    on AutoDisposeStreamNotifierProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `onlyUnresolved` of this provider.
  bool get onlyUnresolved;
}

class _TemperatureAlertsProviderElement
    extends AutoDisposeStreamNotifierProviderElement<TemperatureAlerts,
        List<Map<String, dynamic>>> with TemperatureAlertsRef {
  _TemperatureAlertsProviderElement(super.provider);

  @override
  bool get onlyUnresolved =>
      (origin as TemperatureAlertsProvider).onlyUnresolved;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
