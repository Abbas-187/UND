// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:und_app/core/firebase/test_helper.dart';
// import 'package:und_app/features/order_management/data/integrations/customer_profile_integration.dart';
// import 'package:und_app/features/order_management/data/models/order.dart';
// import 'package:und_app/features/order_management/data/models/order_model.dart';
// import 'package:und_app/features/order_management/data/services/order_service.dart';
// import 'package:uuid/uuid.dart';

// void main() {
//   late ProviderContainer container;
//   late OrderService orderService;
//   late CustomerProfileIntegrationService integrationService;
//
//   setUp(() {
//     // Create a test container with mock Firebase implementations
//     container = FirebaseTestHelper.createTestContainer();
//
//     // Initialize services
//     orderService = OrderService();
//     integrationService = CustomerProfileIntegrationService(
//       orderService: orderService,
//     );
//   });
//
//   tearDown(() async {
//     // Clean up after each test
//     await FirebaseTestHelper.clearTestData(container);
//     integrationService.dispose();
//   });
//
//   group('Order Model Tests', () {
//     test('should create an immutable order with correct values', () {
//       // Create a test order
//       final order = Order(
//         id: 'order-123',
//         customer: 'customer-456',
//         items: [
//           OrderItem(
//             name: 'Test Item',
//             quantity: 5,
//             unit: 'kg',
//           ),
//         ],
//         location: 'Warehouse A',
//         status: OrderStatus.draft,
//         createdBy: 'user-789',
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//         priorityLevel: PriorityLevel.high,
//       );
//
//       // Test immutability
//       expect(
//           () => order.items.add(OrderItem(
//                 name: 'Another Item',
//                 quantity: 10,
//                 unit: 'pcs',
//               )),
//           throwsUnsupportedError);
//
//       // Test values
//       expect(order.id, 'order-123');
//       expect(order.customer, 'customer-456');
//       expect(order.items.length, 1);
//       expect(order.status, OrderStatus.draft);
//       expect(order.priorityLevel, PriorityLevel.high);
//     });
//
//     test('should correctly implement equality', () {
//       final now = DateTime.now();
//
//       // Create two orders with same values
//       final order1 = Order(
//         id: 'order-123',
//         customer: 'customer-456',
//         items: [
//           OrderItem(
//             name: 'Test Item',
//             quantity: 5,
//             unit: 'kg',
//           ),
//         ],
//         location: 'Warehouse A',
//         status: OrderStatus.draft,
//         createdBy: 'user-789',
//         createdAt: now,
//         updatedAt: now,
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//       );
//
//       final order2 = Order(
//         id: 'order-123',
//         customer: 'customer-456',
//         items: [
//           OrderItem(
//             name: 'Test Item',
//             quantity: 5,
//             unit: 'kg',
//           ),
//         ],
//         location: 'Warehouse A',
//         status: OrderStatus.draft,
//         createdBy: 'user-789',
//         createdAt: now,
//         updatedAt: now,
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//       );
//
//       // Test equality
//       expect(order1, order2);
//       expect(order1.hashCode, order2.hashCode);
//
//       // Test inequality
//       final order3 = Order(
//         id: 'order-123',
//         customer: 'customer-456',
//         items: [
//           OrderItem(
//             name: 'Test Item',
//             quantity: 10, // Different quantity
//             unit: 'kg',
//           ),
//         ],
//         location: 'Warehouse A',
//         status: OrderStatus.draft,
//         createdBy: 'user-789',
//         createdAt: now,
//         updatedAt: now,
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//       );
//
//       expect(order1, isNot(order3));
//     });
//
//     test('should correctly copy with new values', () {
//       final now = DateTime.now();
//
//       // Create an order
//       final order = Order(
//         id: 'order-123',
//         customer: 'customer-456',
//         items: [
//           OrderItem(
//             name: 'Test Item',
//             quantity: 5,
//             unit: 'kg',
//           ),
//         ],
//         location: 'Warehouse A',
//         status: OrderStatus.draft,
//         createdBy: 'user-789',
//         createdAt: now,
//         updatedAt: now,
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//       );
//
//       // Copy with new status
//       final updatedOrder = order.copyWith(
//         status: OrderStatus.inProduction,
//         priorityLevel: PriorityLevel.urgent,
//       );
//
//       // Test that only specified fields changed
//       expect(updatedOrder.id, order.id);
//       expect(updatedOrder.customer, order.customer);
//       expect(updatedOrder.items, order.items);
//       expect(updatedOrder.status, OrderStatus.inProduction);
//       expect(updatedOrder.priorityLevel, PriorityLevel.urgent);
//     });
//   });
//
//   group('Customer Profile Integration Tests', () {
//     test('should enhance order with customer information', () async {
//       final now = DateTime.now();
//
//       // Create a basic order
//       final order = Order(
//         id: const Uuid().v4(),
//         customer: 'customer-123',
//         items: [
//           OrderItem(
//             name: 'Test Product',
//             quantity: 2,
//             unit: 'pcs',
//           ),
//         ],
//         location: 'Store B',
//         status: OrderStatus.draft,
//         createdBy: 'user-123',
//         createdAt: now,
//         updatedAt: now,
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//       );
//
//       // Enhance the order with customer information
//       final enhancedOrder =
//           await integrationService.enhanceOrderWithCustomerContext(order);
//
//       // Verify the order was enhanced
//       expect(enhancedOrder.id, order.id);
//       expect(enhancedOrder.customer, order.customer);
//       expect(enhancedOrder.customerPreferences, isNotNull);
//       expect(enhancedOrder.customerAllergies, isNotNull);
//       expect(enhancedOrder.customerNotes, isNotNull);
//     });
//
//     test('should handle errors gracefully when enhancing orders', () async {
//       final now = DateTime.now();
//
//       // Create an order with an invalid customer ID
//       final order = Order(
//         id: const Uuid().v4(),
//         customer: 'invalid-customer',
//         items: [],
//         location: 'Store C',
//         status: OrderStatus.draft,
//         createdBy: 'user-123',
//         createdAt: now,
//         updatedAt: now,
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//       );
//
//       // Enhance the order should not throw
//       final enhancedOrder =
//           await integrationService.enhanceOrderWithCustomerContext(order);
//
//       // Should return the original order on error
//       expect(enhancedOrder, order);
//     });
//   });
//
//   group('Order Service Tests', () {
//     test('should fetch orders with filters', () async {
//       // Fetch orders by location filter
//       final orders = await orderService.fetchOrders(
//         location: 'Nairobi',
//       );
//
//       // Verify we get orders with the right location
//       expect(orders, isNotEmpty);
//       for (final order in orders) {
//         expect(order.location, 'Nairobi');
//       }
//     });
//
//     test('should create a new order', () async {
//       final now = DateTime.now();
//
//       // Create new order data
//       final newOrder = Order(
//         id: const Uuid().v4(),
//         customer: 'customer-789',
//         items: [
//           OrderItem(
//             name: 'Test Product',
//             quantity: 3,
//             unit: 'pcs',
//           ),
//         ],
//         location: 'Store D',
//         status: OrderStatus.draft,
//         createdBy: 'user-123',
//         createdAt: now,
//         updatedAt: now,
//         productionStatus: ProductionStatus.notStarted,
//         procurementStatus: ProcurementStatus.notRequired,
//       );
//
//       // Save the order
//       final savedOrder = await orderService.createOrder(newOrder);
//
//       // Verify the order was saved
//       expect(savedOrder.id, newOrder.id);
//       expect(savedOrder.customer, newOrder.customer);
//       expect(savedOrder.status, OrderStatus.draft);
//     });
//
//     test('should update an existing order', () async {
//       final now = DateTime.now();
//
//       // Create an order first
//       final order = await orderService.createOrder(
//         Order(
//           id: const Uuid().v4(),
//           customer: 'customer-456',
//           items: [
//             OrderItem(
//               name: 'Test Item',
//               quantity: 1,
//               unit: 'kg',
//             ),
//           ],
//           location: 'Store E',
//           status: OrderStatus.draft,
//           createdBy: 'user-123',
//           createdAt: now,
//           updatedAt: now,
//           productionStatus: ProductionStatus.notStarted,
//           procurementStatus: ProcurementStatus.notRequired,
//         ),
//       );
//
//       // Update the order
//       final updatedOrder = await orderService.updateOrder(
//         order.copyWith(
//           status: OrderStatus.inProduction,
//           priorityLevel: PriorityLevel.urgent,
//         ),
//       );
//
//       // Verify the update
//       expect(updatedOrder.id, order.id);
//       expect(updatedOrder.status, OrderStatus.inProduction);
//       expect(updatedOrder.priorityLevel, PriorityLevel.urgent);
//     });
//   });
// }
