enum DeliveryStatus { pending, inTransit, delivered, failed, cancelled }

extension DeliveryStatusExtension on DeliveryStatus {
  String get name {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }
}
