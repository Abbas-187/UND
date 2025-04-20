import 'package:meta/meta.dart';

/// Approval status for a purchase order.
enum ApprovalStatus {
  pending,
  approved,
  declined,
  escalated,
}

/// Approval stage in the workflow.
enum ApprovalStage {
  procurementManager,
  ceo,
  completed,
}

/// Represents an approval action in the purchase order workflow.
@immutable
class ApprovalAction {
  final String id;
  final String purchaseOrderId;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final ApprovalStatus decision;
  final String? notes;
  final ApprovalStage stage;
  final bool isBiometricallyValidated;

  const ApprovalAction({
    required this.id,
    required this.purchaseOrderId,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.decision,
    required this.stage,
    required this.isBiometricallyValidated,
    this.notes,
  });

  ApprovalAction copyWith({
    String? id,
    String? purchaseOrderId,
    String? userId,
    String? userName,
    DateTime? timestamp,
    ApprovalStatus? decision,
    String? notes,
    ApprovalStage? stage,
    bool? isBiometricallyValidated,
  }) {
    return ApprovalAction(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
      decision: decision ?? this.decision,
      notes: notes ?? this.notes,
      stage: stage ?? this.stage,
      isBiometricallyValidated:
          isBiometricallyValidated ?? this.isBiometricallyValidated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovalAction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          purchaseOrderId == other.purchaseOrderId &&
          userId == other.userId &&
          userName == other.userName &&
          timestamp == other.timestamp &&
          decision == other.decision &&
          notes == other.notes &&
          stage == other.stage &&
          isBiometricallyValidated == other.isBiometricallyValidated;

  @override
  int get hashCode =>
      id.hashCode ^
      purchaseOrderId.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      timestamp.hashCode ^
      decision.hashCode ^
      notes.hashCode ^
      stage.hashCode ^
      isBiometricallyValidated.hashCode;
}

/// Represents the complete approval history for a purchase order.
@immutable
class PurchaseOrderApprovalHistory {
  final String purchaseOrderId;
  final List<ApprovalAction> actions;
  final ApprovalStage currentStage;
  final ApprovalStatus currentStatus;
  final DateTime lastUpdated;

  const PurchaseOrderApprovalHistory({
    required this.purchaseOrderId,
    required this.actions,
    required this.currentStage,
    required this.currentStatus,
    required this.lastUpdated,
  });

  PurchaseOrderApprovalHistory copyWith({
    String? purchaseOrderId,
    List<ApprovalAction>? actions,
    ApprovalStage? currentStage,
    ApprovalStatus? currentStatus,
    DateTime? lastUpdated,
  }) {
    return PurchaseOrderApprovalHistory(
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      actions: actions ?? this.actions,
      currentStage: currentStage ?? this.currentStage,
      currentStatus: currentStatus ?? this.currentStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderApprovalHistory &&
          runtimeType == other.runtimeType &&
          purchaseOrderId == other.purchaseOrderId &&
          actions == other.actions &&
          currentStage == other.currentStage &&
          currentStatus == other.currentStatus &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      purchaseOrderId.hashCode ^
      actions.hashCode ^
      currentStage.hashCode ^
      currentStatus.hashCode ^
      lastUpdated.hashCode;
}
