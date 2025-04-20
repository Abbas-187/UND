import 'package:flutter/foundation.dart';

enum ApprovalStatus {
  pending,
  approved,
  declined,
}

enum ApprovalStage {
  procurementManager,
  ceo,
  completed,
}

@immutable
class PurchaseOrderApprovalHistory {
  final String purchaseOrderId;
  final ApprovalStage currentStage;
  final ApprovalStatus currentStatus;
  final List<ApprovalAction> actions;

  const PurchaseOrderApprovalHistory({
    required this.purchaseOrderId,
    required this.currentStage,
    required this.currentStatus,
    required this.actions,
  });
}

@immutable
class ApprovalAction {
  final String userId;
  final String userName;
  final ApprovalStage stage;
  final ApprovalStatus decision;
  final DateTime timestamp;
  final String? notes;

  const ApprovalAction({
    required this.userId,
    required this.userName,
    required this.stage,
    required this.decision,
    required this.timestamp,
    this.notes,
  });
}
