import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../models/product_catalog_model.dart';
import '../models/sales_analytics_model.dart';

// --- Interface (Abstract Class) ---
abstract class SalesDataSource {
  Future<List<ProductCatalogModel>> getProducts({
    bool? isActive,
    String? category,
    bool? isSeasonal,
  });
  Future<ProductCatalogModel> getProductById(String id);
  Future<String> createProduct(ProductCatalogModel product);
  Future<void> updateProduct(ProductCatalogModel product);
  Future<void> updateProductActiveStatus(String productId, bool isActive);
  Future<void> deleteProduct(String productId);
  Future<List<String>> getProductCategories();
  Future<List<ProductCatalogModel>> searchProducts(String query);
  Future<List<ProductCatalogModel>> getProductsNeedingReorder();
  Future<void> updateProductPriceTiers(
    String productId,
    Map<String, double> priceTiers,
  );

  // Customer Methods
  Future<List<CustomerModel>> getCustomers({
    String? status,
    String? customerType,
  });
  Future<CustomerModel> getCustomerById(String id);
  Future<String> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);
  Future<List<CustomerModel>> searchCustomers(String query);

  // Order Methods
  Future<List<OrderModel>> getOrders({
    String? customerId,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<OrderModel> getOrderById(String id);
  Future<String> createOrder(OrderModel order);
  Future<void> updateOrder(OrderModel order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status,
      {String? userId, String? notes});
  Future<void> deleteOrder(String orderId);
  Future<List<OrderModel>> searchOrders(String query);

  // Analytics Methods
  Future<SalesAnalyticsModel> getSalesAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
    String? productId,
    String? category,
  });

  Future<List<DailySalesData>> getDailySalesData({
    required DateTime startDate,
    required DateTime endDate,
    String? productId,
    String? category,
  });

  Future<Map<String, double>> getProductSalesTrends({
    required DateTime startDate,
    required DateTime endDate,
    int? topN,
  });

  Future<Map<String, double>> getCustomerSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
    int? topN,
  });

  Future<Map<String, double>> getCategorySalesTrends({
    required DateTime startDate,
    required DateTime endDate,
  });
}

// --- Firestore Implementation ---
class FirestoreSalesDataSource implements SalesDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _productsCollection = 'products';
  final String _categoriesCollection = 'productCategories';
  final String _customersCollection = 'customers';
  final String _ordersCollection = 'orders';

  @override
  Future<List<ProductCatalogModel>> getProducts({
    bool? isActive,
    String? category,
    bool? isSeasonal,
  }) async {
    Query query = _firestore.collection(_productsCollection);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (isSeasonal != null) {
      query = query.where('isSeasonal', isEqualTo: isSeasonal);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            ProductCatalogModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductCatalogModel> getProductById(String id) async {
    final doc = await _firestore.collection(_productsCollection).doc(id).get();
    if (!doc.exists) {
      throw Exception('Product with ID $id not found');
    }
    // ID is included in the fromJson generated code if present in the snapshot
    return ProductCatalogModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<String> createProduct(ProductCatalogModel product) async {
    // Generate search terms using product fields
    final searchTerms = _generateSearchTerms(product.name, product.category);
    // Create data map using toJson and add searchTerms
    final data = product.copyWith(searchTerms: searchTerms).toJson();
    final docRef = await _firestore.collection(_productsCollection).add(data);
    return docRef.id;
  }

  @override
  Future<void> updateProduct(ProductCatalogModel product) async {
    if (product.id == null) {
      throw ArgumentError('Product ID cannot be null for update');
    }
    // Generate search terms using product fields
    final searchTerms = _generateSearchTerms(product.name, product.category);
    // Create data map using toJson and add searchTerms
    final data = product.copyWith(searchTerms: searchTerms).toJson();
    await _firestore
        .collection(_productsCollection)
        .doc(product.id)
        .update(data);
  }

  @override
  Future<void> updateProductActiveStatus(
      String productId, bool isActive) async {
    await _firestore.collection(_productsCollection).doc(productId).update({
      'isActive': isActive,
    });
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection(_productsCollection).doc(productId).delete();
  }

  @override
  Future<List<String>> getProductCategories() async {
    // Option 1: Read from a dedicated categories collection
    final snapshot = await _firestore.collection(_categoriesCollection).get();
    return snapshot.docs
        .map((doc) => doc.id)
        .toList(); // Assuming category name is doc ID

    // Option 2: Aggregate distinct categories from products (less efficient)
    // final productSnapshot = await _firestore.collection(_productsCollection).get();
    // final categories = productSnapshot.docs.map((doc) => doc.data()['category'] as String).toSet();
    // return categories.toList();
  }

  @override
  Future<List<ProductCatalogModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    final lowerCaseQuery = query.toLowerCase();
    // Firestore array-contains query for search terms
    final snapshot = await _firestore
        .collection(_productsCollection)
        .where('searchTerms', arrayContains: lowerCaseQuery)
        .limit(20) // Limit results for performance
        .get();

    return snapshot.docs
        .map((doc) =>
            ProductCatalogModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<ProductCatalogModel>> getProductsNeedingReorder() async {
    // This is tricky as it requires inventory data.
    // Placeholder: Return products where reorderPoint is defined.
    // A real implementation would need access to current stock levels.
    final snapshot = await _firestore
        .collection(_productsCollection)
        .where('reorderPoint', isGreaterThan: 0) // Basic filter
        .get();

    // Further filtering based on actual inventory levels would happen here
    // if inventory data was accessible.

    return snapshot.docs
        .map((doc) =>
            ProductCatalogModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> updateProductPriceTiers(
      String productId, Map<String, double> priceTiers) async {
    await _firestore.collection(_productsCollection).doc(productId).update({
      'priceTiers': priceTiers,
    });
  }

  // --- Customer Implementations ---
  @override
  Future<List<CustomerModel>> getCustomers({
    String? status,
    String? customerType,
  }) async {
    Query query = _firestore.collection(_customersCollection);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (customerType != null) {
      query = query.where('customerType', isEqualTo: customerType);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id)) // Add id from doc
        .toList();
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    final doc = await _firestore.collection(_customersCollection).doc(id).get();
    if (!doc.exists) {
      throw Exception('Customer with ID $id not found');
    }
    return CustomerModel.fromJson(doc.data() as Map<String, dynamic>)
        .copyWith(id: doc.id); // Add id from doc
  }

  @override
  Future<String> createCustomer(CustomerModel customer) async {
    final searchTerms =
        _generateSearchTerms(customer.name, customer.customerType);
    final data = customer.copyWith(searchTerms: searchTerms).toJson();
    final docRef = await _firestore.collection(_customersCollection).add(data);
    return docRef.id;
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    if (customer.id == null) {
      throw ArgumentError('Customer ID cannot be null for update');
    }
    final searchTerms =
        _generateSearchTerms(customer.name, customer.customerType);
    final data = customer.copyWith(searchTerms: searchTerms).toJson();
    await _firestore
        .collection(_customersCollection)
        .doc(customer.id)
        .update(data);
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection(_customersCollection).doc(customerId).delete();
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    if (query.isEmpty) return [];
    final lowerCaseQuery = query.toLowerCase();
    final snapshot = await _firestore
        .collection(_customersCollection)
        .where('searchTerms', arrayContains: lowerCaseQuery)
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data())
            .copyWith(id: doc.id))
        .toList();
  }

  // --- Order Implementations ---
  @override
  Future<List<OrderModel>> getOrders({
    String? customerId,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection(_ordersCollection)
        .orderBy('orderDate', descending: true);

    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    if (status != null) {
      // Firestore stores enums as strings, use .name
      query = query.where('status', isEqualTo: status.name);
    }
    if (startDate != null) {
      query = query.where('orderDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      // Add a day to endDate to make it inclusive for the whole day
      final inclusiveEndDate = endDate.add(const Duration(days: 1));
      query = query.where('orderDate',
          isLessThan: Timestamp.fromDate(inclusiveEndDate));
    }

    final snapshot = await query.limit(100).get(); // Limit results
    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id))
        .toList();
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    final doc = await _firestore.collection(_ordersCollection).doc(id).get();
    if (!doc.exists) {
      throw Exception('Order with ID $id not found');
    }
    return OrderModel.fromJson(doc.data() as Map<String, dynamic>)
        .copyWith(id: doc.id);
  }

  @override
  Future<String> createOrder(OrderModel order) async {
    // Simple implementation, more complex logic (like stock check) might be in Repo/UseCase
    final data = order.toJson();
    final docRef = await _firestore.collection(_ordersCollection).add(data);
    return docRef.id;
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    final data = order.toJson();
    await _firestore.collection(_ordersCollection).doc(order.id).update(data);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status,
      {String? userId, String? notes}) async {
    final historyEntry = OrderStatusHistoryModel(
      status: status,
      timestamp: DateTime.now(),
      userId: userId,
      notes: notes,
    );

    await _firestore.collection(_ordersCollection).doc(orderId).update({
      'status': status.name, // Update status string
      'statusHistory':
          FieldValue.arrayUnion([historyEntry.toJson()]) // Add to history array
    });
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection(_ordersCollection).doc(orderId).delete();
  }

  @override
  Future<List<OrderModel>> searchOrders(String query) async {
    if (query.isEmpty) return [];
    final lowerCaseQuery = query.toLowerCase();

    // Simple search: Check order number OR customer name (requires querying twice or composite index)
    // Option 1: Query twice and merge (less efficient)
    final queryByOrderNum = _firestore
        .collection(_ordersCollection)
        .where('orderNumber', isGreaterThanOrEqualTo: lowerCaseQuery)
        .where('orderNumber', isLessThanOrEqualTo: '$lowerCaseQuery\uf8ff')
        .limit(10);

    final queryByCustName = _firestore
        .collection(_ordersCollection)
        .where('customerName',
            isGreaterThanOrEqualTo:
                lowerCaseQuery) // Case-sensitive search might be better with dedicated search field
        .where('customerName', isLessThanOrEqualTo: '$lowerCaseQuery\uf8ff')
        .limit(10);

    final results = await Future.wait([
      queryByOrderNum.get(),
      queryByCustName.get(),
    ]);

    final combinedDocs = <String, DocumentSnapshot>{};
    for (final snapshot in results) {
      for (final doc in snapshot.docs) {
        combinedDocs[doc.id] = doc;
      }
    }

    return combinedDocs.values
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id))
        .toList();

    // Option 2: Use a dedicated 'searchTerms' field similar to products (more robust)
  }

  // Analytics implementations
  @override
  Future<SalesAnalyticsModel> getSalesAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? customerId,
    String? productId,
    String? category,
  }) async {
    // Fetch orders in date range
    Query query = _firestore
        .collection(_ordersCollection)
        .where('orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('status', whereIn: [
      OrderStatus.completed.name,
      OrderStatus.shipped.name,
      OrderStatus.delivered.name
    ]);

    // Add filters if specified
    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    }

    final snapshot = await query.get();
    final orders = snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id))
        .toList();

    // Filter by product or category if needed
    List<OrderModel> filteredOrders = orders;
    if (productId != null || category != null) {
      filteredOrders = orders.where((order) {
        return order.items.any((item) {
          bool match = true;
          if (productId != null) {
            match = match && item.productId == productId;
          }
          if (category != null && item.productCategory != null) {
            match = match && item.productCategory == category;
          }
          return match;
        });
      }).toList();
    }

    // Calculate sales totals
    double totalSales = 0;
    Map<String, double> salesByCategory = {};
    Map<String, double> salesByProduct = {};
    Map<String, double> salesByCustomer = {};
    Map<String, int> productUnitsSold = {};

    for (final order in filteredOrders) {
      final orderTotal = order.totalAmount ?? 0.0;
      totalSales += orderTotal;

      // Aggregate by customer
      salesByCustomer.update(
        order.customerId,
        (value) => value + orderTotal,
        ifAbsent: () => orderTotal,
      );

      // Process order items
      for (final item in order.items) {
        // Aggregate by product
        salesByProduct.update(
          item.productId,
          (value) => value + (item.quantity * item.unitPrice),
          ifAbsent: () => item.quantity * item.unitPrice,
        );

        // Aggregate by category
        if (item.productCategory != null) {
          salesByCategory.update(
            item.productCategory!,
            (value) => value + (item.quantity * item.unitPrice),
            ifAbsent: () => item.quantity * item.unitPrice,
          );
        }

        // Units sold by product
        productUnitsSold.update(
          item.productId,
          (value) => value + item.quantity.toInt(),
          ifAbsent: () => item.quantity.toInt(),
        );
      }
    }

    // Get daily sales data
    final dailySales = await getDailySalesData(
      startDate: startDate,
      endDate: endDate,
      productId: productId,
      category: category,
    );

    // Get previous period data for comparison
    final previousPeriodStart =
        startDate.subtract(endDate.difference(startDate));
    final previousPeriodEnd = startDate.subtract(const Duration(days: 1));

    final previousPeriodAnalytics = await _getPreviousPeriodAnalytics(
      previousPeriodStart,
      previousPeriodEnd,
      customerId: customerId,
      productId: productId,
      category: category,
    );

    // Calculate growth metrics
    final previousPeriodSales =
        previousPeriodAnalytics['totalSales'] as double?;
    double? salesGrowth;

    if (previousPeriodSales != null && previousPeriodSales > 0) {
      salesGrowth =
          (totalSales - previousPeriodSales) / previousPeriodSales * 100;
    }

    // Calculate average order value
    final averageOrderValue =
        filteredOrders.isEmpty ? null : totalSales / filteredOrders.length;

    // Count new customers (customers who made their first purchase in this period)
    int newCustomerCount = 0;
    double newCustomerSales = 0;

    if (customerId == null) {
      // Only calculate for all customers
      final customerFirstOrderDates = await _getCustomerFirstOrderDates();

      for (final order in filteredOrders) {
        final firstOrderDate = customerFirstOrderDates[order.customerId];

        if (firstOrderDate != null &&
            firstOrderDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            firstOrderDate.isBefore(endDate.add(const Duration(days: 1)))) {
          newCustomerCount++;
          newCustomerSales += order.totalAmount ?? 0.0;
        }
      }
    }

    // Category growth calculations
    Map<String, double>? categoryGrowth;
    final previousCategorySales =
        previousPeriodAnalytics['salesByCategory'] as Map<String, double>?;

    if (previousCategorySales != null) {
      categoryGrowth = {};

      salesByCategory.forEach((category, sales) {
        final previousSales = previousCategorySales[category] ?? 0;
        if (previousSales > 0) {
          categoryGrowth![category] =
              (sales - previousSales) / previousSales * 100;
        } else {
          categoryGrowth![category] =
              100; // Default to 100% growth if previous was 0
        }
      });
    }

    // Customer growth calculations
    Map<String, double>? customerGrowth;
    final previousCustomerSales =
        previousPeriodAnalytics['salesByCustomer'] as Map<String, double>?;

    if (previousCustomerSales != null) {
      customerGrowth = {};

      salesByCustomer.forEach((customerId, sales) {
        final previousSales = previousCustomerSales[customerId] ?? 0;
        if (previousSales > 0) {
          customerGrowth![customerId] =
              (sales - previousSales) / previousSales * 100;
        } else {
          customerGrowth![customerId] =
              100; // Default to 100% growth if previous was 0
        }
      });
    }

    return SalesAnalyticsModel(
      periodStart: startDate,
      periodEnd: endDate,
      totalSales: totalSales,
      orderCount: filteredOrders.length,
      salesByCategory: salesByCategory,
      salesByProduct: salesByProduct,
      salesByCustomer: salesByCustomer,
      dailySales: dailySales,
      averageOrderValue: averageOrderValue,
      previousPeriodSales: previousPeriodSales,
      salesGrowth: salesGrowth,
      categoryGrowth: categoryGrowth,
      productUnitsSold: productUnitsSold,
      customerGrowth: customerGrowth,
      newCustomerCount: newCustomerCount > 0 ? newCustomerCount : null,
      newCustomerSales: newCustomerSales > 0 ? newCustomerSales : null,
    );
  }

  @override
  Future<List<DailySalesData>> getDailySalesData({
    required DateTime startDate,
    required DateTime endDate,
    String? productId,
    String? category,
  }) async {
    // Prepare date map for all days in range
    final Map<String, DailySalesData> dailyDataMap = {};

    // Create entries for all dates in range
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));

    while (current.isBefore(end)) {
      final dateString = current.toIso8601String().split('T')[0];
      dailyDataMap[dateString] = DailySalesData(
        date: current,
        sales: 0,
        orderCount: 0,
      );
      current = current.add(const Duration(days: 1));
    }

    // Fetch orders in date range
    final startTimestamp = Timestamp.fromDate(startDate);
    final endTimestamp = Timestamp.fromDate(endDate
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1)));

    Query query = _firestore
        .collection(_ordersCollection)
        .where('orderDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('orderDate', isLessThanOrEqualTo: endTimestamp)
        .where('status', whereIn: [
      OrderStatus.completed.name,
      OrderStatus.shipped.name,
      OrderStatus.delivered.name
    ]);

    final snapshot = await query.get();
    final orders = snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id))
        .toList();

    // Process orders
    for (final order in orders) {
      // Skip orders without dates
      final orderDate = order.orderDate;
      final dateString = orderDate.toIso8601String().split('T')[0];

      // Skip if date is outside range (shouldn't happen due to query, but just in case)
      if (!dailyDataMap.containsKey(dateString)) continue;

      double orderTotal = order.totalAmount ?? 0.0;

      // Filter by product or category if specified
      if (productId != null || category != null) {
        orderTotal = 0;

        for (final item in order.items) {
          if (productId != null && item.productId != productId) continue;
          if (category != null && item.productCategory != category) continue;

          orderTotal += item.quantity * item.unitPrice;
        }

        // Skip this order if it doesn't contain the specified product/category
        if (orderTotal <= 0) continue;
      }

      // Update daily data
      final dailyData = dailyDataMap[dateString]!;
      dailyDataMap[dateString] = DailySalesData(
        date: dailyData.date,
        sales: dailyData.sales + orderTotal,
        orderCount: dailyData.orderCount + 1,
        averageOrderValue:
            (dailyData.sales + orderTotal) / (dailyData.orderCount + 1),
      );
    }

    // Convert map to sorted list
    return dailyDataMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<Map<String, double>> getProductSalesTrends({
    required DateTime startDate,
    required DateTime endDate,
    int? topN,
  }) async {
    final analytics = await getSalesAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    // Sort products by sales
    final sortedProducts = analytics.salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get top N products if specified
    final selectedProducts =
        topN != null && topN > 0 && topN < sortedProducts.length
            ? sortedProducts.take(topN).toList()
            : sortedProducts;

    // Convert to map
    return Map.fromEntries(selectedProducts);
  }

  @override
  Future<Map<String, double>> getCustomerSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
    int? topN,
  }) async {
    final analytics = await getSalesAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    // Sort customers by sales
    final sortedCustomers = analytics.salesByCustomer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get top N customers if specified
    final selectedCustomers =
        topN != null && topN > 0 && topN < sortedCustomers.length
            ? sortedCustomers.take(topN).toList()
            : sortedCustomers;

    // Convert to map
    return Map.fromEntries(selectedCustomers);
  }

  @override
  Future<Map<String, double>> getCategorySalesTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final analytics = await getSalesAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    // Sort categories by sales
    final sortedCategories = analytics.salesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Convert to map
    return Map.fromEntries(sortedCategories);
  }

  // Helper method to get previous period analytics
  Future<Map<String, dynamic>> _getPreviousPeriodAnalytics(
    DateTime startDate,
    DateTime endDate, {
    String? customerId,
    String? productId,
    String? category,
  }) async {
    try {
      // Fetch orders in date range
      Query query = _firestore
          .collection(_ordersCollection)
          .where('orderDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('status', whereIn: [
        OrderStatus.completed.name,
        OrderStatus.shipped.name,
        OrderStatus.delivered.name
      ]);

      // Add filters if specified
      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }

      final snapshot = await query.get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>)
              .copyWith(id: doc.id))
          .toList();

      // Filter by product or category if needed
      List<OrderModel> filteredOrders = orders;
      if (productId != null || category != null) {
        filteredOrders = orders.where((order) {
          return order.items.any((item) {
            bool match = true;
            if (productId != null) {
              match = match && item.productId == productId;
            }
            if (category != null && item.productCategory != null) {
              match = match && item.productCategory == category;
            }
            return match;
          });
        }).toList();
      }

      // Calculate totals
      double totalSales = 0;
      Map<String, double> salesByCategory = {};
      Map<String, double> salesByCustomer = {};

      for (final order in filteredOrders) {
        final orderTotal = order.totalAmount ?? 0.0;
        totalSales += orderTotal;

        // Aggregate by customer
        salesByCustomer.update(
          order.customerId,
          (value) => value + orderTotal,
          ifAbsent: () => orderTotal,
        );

        // Process order items
        for (final item in order.items) {
          // Aggregate by category
          if (item.productCategory != null) {
            salesByCategory.update(
              item.productCategory!,
              (value) => value + (item.quantity * item.unitPrice),
              ifAbsent: () => item.quantity * item.unitPrice,
            );
          }
        }
      }

      return {
        'totalSales': totalSales,
        'salesByCategory': salesByCategory,
        'salesByCustomer': salesByCustomer,
      };
    } catch (e) {
      // Return empty results on error
      return {
        'totalSales': 0.0,
        'salesByCategory': <String, double>{},
        'salesByCustomer': <String, double>{},
      };
    }
  }

  // Helper method to get the first order date for each customer
  Future<Map<String, DateTime>> _getCustomerFirstOrderDates() async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .orderBy('orderDate', descending: false)
        .get();

    final orders = snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data())
            .copyWith(id: doc.id))
        .toList();

    final Map<String, DateTime> firstOrderDates = {};

    for (final order in orders) {
      if (order.customerId.isNotEmpty) {
        if (!firstOrderDates.containsKey(order.customerId)) {
          firstOrderDates[order.customerId] = order.orderDate;
        }
      }
    }

    return firstOrderDates;
  }

  // Existing helper methods
  List<String> _generateSearchTerms(String name, String? category) {
    final nameTerms = name.toLowerCase().split(' ');
    final categoryTerms =
        category != null ? [category.toLowerCase()] : <String>[];
    final Set<String> terms = {...nameTerms, ...categoryTerms};

    // Add partial matches (substrings)
    final nameLower = name.toLowerCase();
    for (int i = 0; i < nameLower.length; i++) {
      for (int j = i + 2; j <= nameLower.length; j++) {
        // Min length 2
        terms.add(nameLower.substring(i, j));
      }
    }
    return terms.toList();
  }
}
