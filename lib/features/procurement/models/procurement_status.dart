// Procurement status enums to represent the status of procurement requests
// Used by the ProcurementService and ProcurementRequest model

/// Represents the status of a procurement request
enum ProcurementRequestStatus {
  pending,
  inProgress,
  fulfilled,
  cancelled,
  rejected;

  /// Get the display name of this status
  String get displayName {
    switch (this) {
      case ProcurementRequestStatus.pending:
        return 'Pending';
      case ProcurementRequestStatus.inProgress:
        return 'In Progress';
      case ProcurementRequestStatus.fulfilled:
        return 'Fulfilled';
      case ProcurementRequestStatus.cancelled:
        return 'Cancelled';
      case ProcurementRequestStatus.rejected:
        return 'Rejected';
    }
  }

  /// Create a status from a string
  static ProcurementRequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ProcurementRequestStatus.pending;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return ProcurementRequestStatus.inProgress;
      case 'fulfilled':
      case 'complete':
      case 'completed':
        return ProcurementRequestStatus.fulfilled;
      case 'cancelled':
      case 'canceled':
        return ProcurementRequestStatus.cancelled;
      case 'rejected':
        return ProcurementRequestStatus.rejected;
      default:
        throw ArgumentError('Invalid procurement request status: $status');
    }
  }

  @override
  String toString() {
    switch (this) {
      case ProcurementRequestStatus.pending:
        return 'pending';
      case ProcurementRequestStatus.inProgress:
        return 'in_progress';
      case ProcurementRequestStatus.fulfilled:
        return 'fulfilled';
      case ProcurementRequestStatus.cancelled:
        return 'cancelled';
      case ProcurementRequestStatus.rejected:
        return 'rejected';
    }
  }
}
