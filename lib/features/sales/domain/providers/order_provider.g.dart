// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredOrdersHash() => r'0ea4fa80eede4bdcda259d97095e77442eca84ec';

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

/// See also [filteredOrders].
@ProviderFor(filteredOrders)
const filteredOrdersProvider = FilteredOrdersFamily();

/// See also [filteredOrders].
class FilteredOrdersFamily extends Family<AsyncValue<List<OrderModel>>> {
  /// See also [filteredOrders].
  const FilteredOrdersFamily();

  /// See also [filteredOrders].
  FilteredOrdersProvider call({
    String? customerId,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FilteredOrdersProvider(
      customerId: customerId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  FilteredOrdersProvider getProviderOverride(
    covariant FilteredOrdersProvider provider,
  ) {
    return call(
      customerId: provider.customerId,
      status: provider.status,
      startDate: provider.startDate,
      endDate: provider.endDate,
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
  String? get name => r'filteredOrdersProvider';
}

/// See also [filteredOrders].
class FilteredOrdersProvider
    extends AutoDisposeFutureProvider<List<OrderModel>> {
  /// See also [filteredOrders].
  FilteredOrdersProvider({
    String? customerId,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
          (ref) => filteredOrders(
            ref as FilteredOrdersRef,
            customerId: customerId,
            status: status,
            startDate: startDate,
            endDate: endDate,
          ),
          from: filteredOrdersProvider,
          name: r'filteredOrdersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredOrdersHash,
          dependencies: FilteredOrdersFamily._dependencies,
          allTransitiveDependencies:
              FilteredOrdersFamily._allTransitiveDependencies,
          customerId: customerId,
          status: status,
          startDate: startDate,
          endDate: endDate,
        );

  FilteredOrdersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
    required this.status,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String? customerId;
  final OrderStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<OrderModel>> Function(FilteredOrdersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredOrdersProvider._internal(
        (ref) => create(ref as FilteredOrdersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<OrderModel>> createElement() {
    return _FilteredOrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredOrdersProvider &&
        other.customerId == customerId &&
        other.status == status &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredOrdersRef on AutoDisposeFutureProviderRef<List<OrderModel>> {
  /// The parameter `customerId` of this provider.
  String? get customerId;

  /// The parameter `status` of this provider.
  OrderStatus? get status;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _FilteredOrdersProviderElement
    extends AutoDisposeFutureProviderElement<List<OrderModel>>
    with FilteredOrdersRef {
  _FilteredOrdersProviderElement(super.provider);

  @override
  String? get customerId => (origin as FilteredOrdersProvider).customerId;
  @override
  OrderStatus? get status => (origin as FilteredOrdersProvider).status;
  @override
  DateTime? get startDate => (origin as FilteredOrdersProvider).startDate;
  @override
  DateTime? get endDate => (origin as FilteredOrdersProvider).endDate;
}

String _$orderDetailsHash() => r'9e3cd506691a6f5d059f5059747fdfa256e9a91b';

/// See also [orderDetails].
@ProviderFor(orderDetails)
const orderDetailsProvider = OrderDetailsFamily();

/// See also [orderDetails].
class OrderDetailsFamily extends Family<AsyncValue<OrderModel>> {
  /// See also [orderDetails].
  const OrderDetailsFamily();

  /// See also [orderDetails].
  OrderDetailsProvider call(
    String orderId,
  ) {
    return OrderDetailsProvider(
      orderId,
    );
  }

  @override
  OrderDetailsProvider getProviderOverride(
    covariant OrderDetailsProvider provider,
  ) {
    return call(
      provider.orderId,
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
  String? get name => r'orderDetailsProvider';
}

/// See also [orderDetails].
class OrderDetailsProvider extends AutoDisposeFutureProvider<OrderModel> {
  /// See also [orderDetails].
  OrderDetailsProvider(
    String orderId,
  ) : this._internal(
          (ref) => orderDetails(
            ref as OrderDetailsRef,
            orderId,
          ),
          from: orderDetailsProvider,
          name: r'orderDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$orderDetailsHash,
          dependencies: OrderDetailsFamily._dependencies,
          allTransitiveDependencies:
              OrderDetailsFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  OrderDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    FutureOr<OrderModel> Function(OrderDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailsProvider._internal(
        (ref) => create(ref as OrderDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<OrderModel> createElement() {
    return _OrderDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailsProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderDetailsRef on AutoDisposeFutureProviderRef<OrderModel> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailsProviderElement
    extends AutoDisposeFutureProviderElement<OrderModel> with OrderDetailsRef {
  _OrderDetailsProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailsProvider).orderId;
}

String _$orderActionsHash() => r'05da377c7117a8c1b763ca33646fb87b649a8b88';

/// See also [OrderActions].
@ProviderFor(OrderActions)
final orderActionsProvider =
    AutoDisposeNotifierProvider<OrderActions, AsyncValue<void>>.internal(
  OrderActions.new,
  name: r'orderActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$orderActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrderActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
