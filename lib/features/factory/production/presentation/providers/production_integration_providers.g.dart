// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_integration_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$convertPlanToExecutionUseCaseHash() =>
    r'a15c3fa9c48a652690b461190c078e3493d3ac5a';

/// Provider for the ConvertPlanToExecutionUseCase
///
/// Copied from [convertPlanToExecutionUseCase].
@ProviderFor(convertPlanToExecutionUseCase)
final convertPlanToExecutionUseCaseProvider =
    AutoDisposeProvider<ConvertPlanToExecutionUseCase>.internal(
  convertPlanToExecutionUseCase,
  name: r'convertPlanToExecutionUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$convertPlanToExecutionUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConvertPlanToExecutionUseCaseRef
    = AutoDisposeProviderRef<ConvertPlanToExecutionUseCase>;
String _$canConvertPlanToExecutionHash() =>
    r'784010a00a8417b4223ca4cc38609b8c45a04808';

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

/// Provider to check if a production plan can be converted to execution
///
/// Copied from [canConvertPlanToExecution].
@ProviderFor(canConvertPlanToExecution)
const canConvertPlanToExecutionProvider = CanConvertPlanToExecutionFamily();

/// Provider to check if a production plan can be converted to execution
///
/// Copied from [canConvertPlanToExecution].
class CanConvertPlanToExecutionFamily extends Family<AsyncValue<bool>> {
  /// Provider to check if a production plan can be converted to execution
  ///
  /// Copied from [canConvertPlanToExecution].
  const CanConvertPlanToExecutionFamily();

  /// Provider to check if a production plan can be converted to execution
  ///
  /// Copied from [canConvertPlanToExecution].
  CanConvertPlanToExecutionProvider call(
    String planId,
  ) {
    return CanConvertPlanToExecutionProvider(
      planId,
    );
  }

  @override
  CanConvertPlanToExecutionProvider getProviderOverride(
    covariant CanConvertPlanToExecutionProvider provider,
  ) {
    return call(
      provider.planId,
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
  String? get name => r'canConvertPlanToExecutionProvider';
}

/// Provider to check if a production plan can be converted to execution
///
/// Copied from [canConvertPlanToExecution].
class CanConvertPlanToExecutionProvider
    extends AutoDisposeFutureProvider<bool> {
  /// Provider to check if a production plan can be converted to execution
  ///
  /// Copied from [canConvertPlanToExecution].
  CanConvertPlanToExecutionProvider(
    String planId,
  ) : this._internal(
          (ref) => canConvertPlanToExecution(
            ref as CanConvertPlanToExecutionRef,
            planId,
          ),
          from: canConvertPlanToExecutionProvider,
          name: r'canConvertPlanToExecutionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$canConvertPlanToExecutionHash,
          dependencies: CanConvertPlanToExecutionFamily._dependencies,
          allTransitiveDependencies:
              CanConvertPlanToExecutionFamily._allTransitiveDependencies,
          planId: planId,
        );

  CanConvertPlanToExecutionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planId,
  }) : super.internal();

  final String planId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanConvertPlanToExecutionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanConvertPlanToExecutionProvider._internal(
        (ref) => create(ref as CanConvertPlanToExecutionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planId: planId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanConvertPlanToExecutionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanConvertPlanToExecutionProvider && other.planId == planId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanConvertPlanToExecutionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `planId` of this provider.
  String get planId;
}

class _CanConvertPlanToExecutionProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CanConvertPlanToExecutionRef {
  _CanConvertPlanToExecutionProviderElement(super.provider);

  @override
  String get planId => (origin as CanConvertPlanToExecutionProvider).planId;
}

String _$productionIntegrationControllerHash() =>
    r'19bf02ece7c8cbc7ab6d69eab0825d8cc1fac2c9';

/// State controller for integration between production planning and execution
///
/// Copied from [ProductionIntegrationController].
@ProviderFor(ProductionIntegrationController)
final productionIntegrationControllerProvider = AutoDisposeNotifierProvider<
    ProductionIntegrationController, AsyncValue<void>>.internal(
  ProductionIntegrationController.new,
  name: r'productionIntegrationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productionIntegrationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductionIntegrationController
    = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
