import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/constants/api_endpoints.dart';
import '../../data/datasources/remote/order_remote_datasource.dart';
import '../../data/integrations/crm_integration.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl(
    client: http.Client(),
    baseUrl: ApiEndpoints.orders,
  );
});

class OrderFormState {
  OrderFormState({
    this.selectedCustomer,
    this.customerBranches = const [],
    this.selectedBranch,
    this.productQuantityItems = const [],
    this.dueDate,
    this.notes,
  });
  final CustomerModel? selectedCustomer;
  final List<CustomerBranch> customerBranches;
  final CustomerBranch? selectedBranch;
  final List<OrderItemModel> productQuantityItems;
  final DateTime? dueDate;
  final String? notes;

  OrderFormState copyWith({
    CustomerModel? selectedCustomer,
    List<CustomerBranch>? customerBranches,
    CustomerBranch? selectedBranch,
    List<OrderItemModel>? productQuantityItems,
    DateTime? dueDate,
    String? notes,
  }) {
    return OrderFormState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      customerBranches: customerBranches ?? this.customerBranches,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      productQuantityItems: productQuantityItems ?? this.productQuantityItems,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }
}

class ProductList {
  final String name;
  final List<OrderItemModel> items;
  ProductList({required this.name, required this.items});

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
        name: json['name'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  Map<String, dynamic> toJson() => {
        'name': name,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderFormNotifier extends StateNotifier<OrderFormState> {
  OrderFormNotifier(this._orderRemoteDataSource) : super(OrderFormState());
  final OrderRemoteDataSource _orderRemoteDataSource;
  static const _productListsKey = 'saved_product_lists';

  void setCustomer(CustomerModel customer) {
    state = state.copyWith(
      selectedCustomer: customer,
      customerBranches: customer.branches,
      selectedBranch: null,
    );
  }

  void setBranch(CustomerBranch branch) {
    state = state.copyWith(selectedBranch: branch);
  }

  void addProduct(OrderItemModel product) {
    final updatedList = List<OrderItemModel>.from(state.productQuantityItems)
      ..add(product);
    state = state.copyWith(productQuantityItems: updatedList);
  }

  void removeProduct(String productId) {
    final updatedList = state.productQuantityItems
        .where((item) => item.productId != productId)
        .toList();
    state = state.copyWith(productQuantityItems: updatedList);
  }

  void setDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<void> saveProductList(String listName) async {
    final prefs = await SharedPreferences.getInstance();
    final listsJson = prefs.getStringList(_productListsKey) ?? [];
    final lists =
        listsJson.map((str) => ProductList.fromJson(json.decode(str))).toList();
    // Remove any existing list with the same name
    final filtered = lists.where((l) => l.name != listName).toList();
    filtered
        .add(ProductList(name: listName, items: state.productQuantityItems));
    final updatedJson = filtered.map((l) => json.encode(l.toJson())).toList();
    await prefs.setStringList(_productListsKey, updatedJson);
  }

  Future<void> setSavedList(ProductList savedList) async {
    state = state.copyWith(productQuantityItems: savedList.items);
  }

  static Future<List<ProductList>> getSavedProductLists() async {
    final prefs = await SharedPreferences.getInstance();
    final listsJson = prefs.getStringList(_productListsKey) ?? [];
    return listsJson
        .map((str) => ProductList.fromJson(json.decode(str)))
        .toList();
  }

  Future<void> submitOrder() async {
    if (state.selectedCustomer?.id == null) {
      throw Exception('Customer ID is required');
    }
    if (state.productQuantityItems.isEmpty || state.dueDate == null) {
      throw Exception('Invalid order data');
    }
    final order = OrderModel(
      id: '',
      orderNumber: '',
      orderDate: DateTime.now(),
      customerId: state.selectedCustomer!.id!,
      customerName: state.selectedCustomer!.name,
      billingAddress: null, // Not available in CustomerModel
      shippingAddress: null, // Not available in CustomerModel
      status: OrderStatus.submitted,
      items: state.productQuantityItems
          .map((item) => OrderItemModel(
                productId: item.productId,
                productName: item.productName,
                productCode: item.productCode,
                quantity: item.quantity,
                uom: item.uom,
                unitPrice: item.unitPrice,
                taxAmount: item.taxAmount,
              ))
          .toList(),
      subtotal: state.productQuantityItems
          .fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice)),
      taxAmount: 0.0,
      shippingCost: 0.0,
      totalAmount: state.productQuantityItems
          .fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice)),
      notes: state.notes,
      createdByUserId: '',
      requiredDeliveryDate: state.dueDate,
    );
    await _orderRemoteDataSource.createOrder(order.toEntity());
  }
}

final orderFormProvider =
    StateNotifierProvider<OrderFormNotifier, OrderFormState>((ref) {
  final orderRemoteDataSource = ref.read(orderRemoteDataSourceProvider);
  return OrderFormNotifier(orderRemoteDataSource);
});

final customerProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final crm = ref.read(crmIntegrationServiceProvider);
  final uri = Uri.parse(ApiEndpoints.customers);
  final response = await crm.client.get(uri);
  if (response.statusCode == 200) {
    final list = (json.decode(response.body) as List<dynamic>);
    return list
        .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception('Failed to fetch customers: \\${response.statusCode}');
});

final savedProductListsProvider =
    FutureProvider<List<ProductList>>((ref) async {
  return await OrderFormNotifier.getSavedProductLists();
});

final branchProvider = FutureProvider.family<List<CustomerBranch>, String>(
    (ref, customerId) async {
  final crm = ref.read(crmIntegrationServiceProvider);
  final uri = Uri.parse('${ApiEndpoints.customers}/$customerId/branches');
  final response = await crm.client.get(uri);
  if (response.statusCode == 200) {
    final list = (json.decode(response.body) as List<dynamic>);
    return list
        .map((e) => CustomerBranch.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception('Failed to fetch branches: \\${response.statusCode}');
});
