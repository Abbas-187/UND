// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allCustomersHash() => r'fd1c288f91555d75a4753a0c39ccee2d4c9212f8';

/// See also [allCustomers].
@ProviderFor(allCustomers)
final allCustomersProvider =
    AutoDisposeFutureProvider<List<CustomerModel>>.internal(
  allCustomers,
  name: r'allCustomersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allCustomersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCustomersRef = AutoDisposeFutureProviderRef<List<CustomerModel>>;
String _$filteredCustomersHash() => r'77c800eb5994e8d6688b96ff0636f19d9f080d6b';

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

/// See also [filteredCustomers].
@ProviderFor(filteredCustomers)
const filteredCustomersProvider = FilteredCustomersFamily();

/// See also [filteredCustomers].
class FilteredCustomersFamily extends Family<AsyncValue<List<CustomerModel>>> {
  /// See also [filteredCustomers].
  const FilteredCustomersFamily();

  /// See also [filteredCustomers].
  FilteredCustomersProvider call({
    String? status,
    String? customerType,
  }) {
    return FilteredCustomersProvider(
      status: status,
      customerType: customerType,
    );
  }

  @override
  FilteredCustomersProvider getProviderOverride(
    covariant FilteredCustomersProvider provider,
  ) {
    return call(
      status: provider.status,
      customerType: provider.customerType,
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
  String? get name => r'filteredCustomersProvider';
}

/// See also [filteredCustomers].
class FilteredCustomersProvider
    extends AutoDisposeFutureProvider<List<CustomerModel>> {
  /// See also [filteredCustomers].
  FilteredCustomersProvider({
    String? status,
    String? customerType,
  }) : this._internal(
          (ref) => filteredCustomers(
            ref as FilteredCustomersRef,
            status: status,
            customerType: customerType,
          ),
          from: filteredCustomersProvider,
          name: r'filteredCustomersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredCustomersHash,
          dependencies: FilteredCustomersFamily._dependencies,
          allTransitiveDependencies:
              FilteredCustomersFamily._allTransitiveDependencies,
          status: status,
          customerType: customerType,
        );

  FilteredCustomersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
    required this.customerType,
  }) : super.internal();

  final String? status;
  final String? customerType;

  @override
  Override overrideWith(
    FutureOr<List<CustomerModel>> Function(FilteredCustomersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredCustomersProvider._internal(
        (ref) => create(ref as FilteredCustomersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
        customerType: customerType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CustomerModel>> createElement() {
    return _FilteredCustomersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredCustomersProvider &&
        other.status == status &&
        other.customerType == customerType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, customerType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredCustomersRef
    on AutoDisposeFutureProviderRef<List<CustomerModel>> {
  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `customerType` of this provider.
  String? get customerType;
}

class _FilteredCustomersProviderElement
    extends AutoDisposeFutureProviderElement<List<CustomerModel>>
    with FilteredCustomersRef {
  _FilteredCustomersProviderElement(super.provider);

  @override
  String? get status => (origin as FilteredCustomersProvider).status;
  @override
  String? get customerType =>
      (origin as FilteredCustomersProvider).customerType;
}

String _$customerDetailsHash() => r'd68605232a21987887dafb368b803fbd05545b64';

/// See also [customerDetails].
@ProviderFor(customerDetails)
const customerDetailsProvider = CustomerDetailsFamily();

/// See also [customerDetails].
class CustomerDetailsFamily extends Family<AsyncValue<CustomerModel>> {
  /// See also [customerDetails].
  const CustomerDetailsFamily();

  /// See also [customerDetails].
  CustomerDetailsProvider call(
    String customerId,
  ) {
    return CustomerDetailsProvider(
      customerId,
    );
  }

  @override
  CustomerDetailsProvider getProviderOverride(
    covariant CustomerDetailsProvider provider,
  ) {
    return call(
      provider.customerId,
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
  String? get name => r'customerDetailsProvider';
}

/// See also [customerDetails].
class CustomerDetailsProvider extends AutoDisposeFutureProvider<CustomerModel> {
  /// See also [customerDetails].
  CustomerDetailsProvider(
    String customerId,
  ) : this._internal(
          (ref) => customerDetails(
            ref as CustomerDetailsRef,
            customerId,
          ),
          from: customerDetailsProvider,
          name: r'customerDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$customerDetailsHash,
          dependencies: CustomerDetailsFamily._dependencies,
          allTransitiveDependencies:
              CustomerDetailsFamily._allTransitiveDependencies,
          customerId: customerId,
        );

  CustomerDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
  }) : super.internal();

  final String customerId;

  @override
  Override overrideWith(
    FutureOr<CustomerModel> Function(CustomerDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerDetailsProvider._internal(
        (ref) => create(ref as CustomerDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CustomerModel> createElement() {
    return _CustomerDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerDetailsProvider && other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomerDetailsRef on AutoDisposeFutureProviderRef<CustomerModel> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _CustomerDetailsProviderElement
    extends AutoDisposeFutureProviderElement<CustomerModel>
    with CustomerDetailsRef {
  _CustomerDetailsProviderElement(super.provider);

  @override
  String get customerId => (origin as CustomerDetailsProvider).customerId;
}

String _$customerActionsHash() => r'3fe46dc354214314fcaab33bcbf244d88ea44eec';

/// See also [CustomerActions].
@ProviderFor(CustomerActions)
final customerActionsProvider =
    AutoDisposeNotifierProvider<CustomerActions, AsyncValue<void>>.internal(
  CustomerActions.new,
  name: r'customerActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomerActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
