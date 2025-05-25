import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart'; // Import OrderStatus enum
import 'notification_service.dart';
import 'order_audit_trail_service.dart';

class OrderStatusAutomationService {
  final OrderRepository orderRepository;
  final OrderAuditTrailService auditTrailService;
  final NotificationService notificationService;

  OrderStatusAutomationService({
    required this.orderRepository,
    required this.auditTrailService,
    required this.notificationService,
  });

  Future<void> automateStatusTransition(OrderEntity order) async {
    final prevStatus = order.status;
    OrderStatus? newStatus;

    // Example rules for automation
    if (order.items.every((item) => item['fulfillmentStatus'] == 'fulfilled')) {
      newStatus = OrderStatus.fulfilled;
    } else if (order.items
        .any((item) => item['fulfillmentStatus'] == 'backordered')) {
      newStatus = OrderStatus.backordered;
    }
    // Add more rules as needed (e.g., shipped, delivered, etc.)

    if (newStatus != null && newStatus != prevStatus) {
      // TODO: Refactor OrderEntity to support status in copyWith for maintainability
      final updatedOrder = OrderEntity(
        id: order.id,
        orderNumber: order.orderNumber,
        orderDate: order.orderDate,
        customerId: order.customerId,
        customerName: order.customerName,
        billingAddress: order.billingAddress,
        shippingAddress: order.shippingAddress,
        status: newStatus,
        items: order.items,
        subtotal: order.subtotal,
        taxAmount: order.taxAmount,
        shippingCost: order.shippingCost,
        totalAmount: order.totalAmount,
        notes: order.notes,
        createdByUserId: order.createdByUserId,
        requiredDeliveryDate: order.requiredDeliveryDate,
        actualShipmentDate: order.actualShipmentDate,
        actualDeliveryDate: order.actualDeliveryDate,
        shippingMethod: order.shippingMethod,
        trackingNumber: order.trackingNumber,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        statusHistory: order.statusHistory,
        branchId: order.branchId,
        partialFulfillment: order.partialFulfillment,
        backorderedItems: order.backorderedItems,
      );
      await orderRepository.updateOrder(updatedOrder);

      // TODO: Implement logOrderStatusChange in auditTrailService
      // await auditTrailService.logOrderStatusChange(order.id, prevStatus, newStatus, automated: true);

      // Send notification
      await notificationService.sendNotification(
        recipientId: order.createdByUserId ?? '',
        type: 'ORDER_STATUS_AUTOMATED',
        title: 'Order Status Updated',
        message:
            'Order ${order.orderNumber} status changed to $newStatus automatically.',
      );
    }
  }
}
