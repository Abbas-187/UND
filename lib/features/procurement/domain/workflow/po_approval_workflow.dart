import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../entities/purchase_order.dart';
import '../entities/purchase_order_approval.dart';
import '../security/biometric_validator.dart';

/// Exception thrown when a user is not authorized to perform an approval action.
class UnauthorizedApprovalException implements Exception {

  UnauthorizedApprovalException(this.message);
  final String message;

  @override
  String toString() => 'UnauthorizedApprovalException: $message';
}

@immutable
class PurchaseOrderApprovalWorkflow {

  const PurchaseOrderApprovalWorkflow({
    required this.biometricValidator,
  });
  final BiometricValidator biometricValidator;
  final Uuid _uuid = const Uuid();

  /// Initiates the approval workflow for a purchase order.
  ///
  /// [purchaseOrder] - The purchase order to be approved
  /// Returns the initial approval history
  Future<PurchaseOrderApprovalHistory> initializeApproval(
      PurchaseOrder purchaseOrder) async {
    return PurchaseOrderApprovalHistory(
      purchaseOrderId: purchaseOrder.id,
      actions: [],
      currentStage: ApprovalStage.procurementManager,
      currentStatus: ApprovalStatus.pending,
      lastUpdated: DateTime.now(),
    );
  }

  /// Processes an approval action in the workflow.
  ///
  /// [approvalHistory] - The current approval history
  /// [userId] - ID of the user performing the action
  /// [userName] - Name of the user performing the action
  /// [decision] - The approval decision (approve/decline)
  /// [notes] - Optional notes explaining the decision
  /// [userRole] - Role of the user (procurement manager or CEO)
  /// Returns the updated approval history
  Future<PurchaseOrderApprovalHistory> processApprovalAction(
    PurchaseOrderApprovalHistory approvalHistory,
    String userId,
    String userName,
    ApprovalStatus decision,
    String? notes,
    String userRole,
  ) async {
    // Validate user role for current stage
    if (!_canUserApprovePO(userRole, approvalHistory.currentStage)) {
      throw Exception('User does not have permission to approve this stage');
    }

    // Validate with biometrics if approving
    if (decision == ApprovalStatus.approved) {
      final biometricSuccess = await biometricValidator.validateBiometrics(
        'Approve Purchase Order',
      );

      if (!biometricSuccess) {
        throw Exception('Biometric validation failed');
      }
    }

    // Create the approval action
    final action = ApprovalAction(
      id: _uuid.v4(),
      purchaseOrderId: approvalHistory.purchaseOrderId,
      userId: userId,
      userName: userName,
      timestamp: DateTime.now(),
      decision: decision,
      notes: notes,
      stage: approvalHistory.currentStage,
      isBiometricallyValidated: decision == ApprovalStatus.approved,
    );

    // Determine the next stage and status
    final nextStage = _determineNextStage(
      approvalHistory.currentStage,
      decision,
    );

    final nextStatus = _determineNextStatus(
      approvalHistory.currentStage,
      decision,
      nextStage,
    );

    // Update the approval history
    final updatedActions = List<ApprovalAction>.from(approvalHistory.actions)
      ..add(action);

    return approvalHistory.copyWith(
      actions: updatedActions,
      currentStage: nextStage,
      currentStatus: nextStatus,
      lastUpdated: DateTime.now(),
    );
  }

  bool _canUserApprovePO(String userRole, ApprovalStage stage) {
    switch (stage) {
      case ApprovalStage.procurementManager:
        return userRole == 'procurement_manager';
      case ApprovalStage.ceo:
        return userRole == 'ceo';
      default:
        return false;
    }
  }

  /// Determines the next stage in the workflow based on the current stage and decision.
  ApprovalStage _determineNextStage(
    ApprovalStage currentStage,
    ApprovalStatus decision,
  ) {
    if (decision == ApprovalStatus.declined) {
      return ApprovalStage.completed;
    }

    switch (currentStage) {
      case ApprovalStage.procurementManager:
        return ApprovalStage.ceo;
      case ApprovalStage.ceo:
        return ApprovalStage.completed;
      default:
        return currentStage;
    }
  }

  /// Determines the next status based on the current stage, decision, and next stage.
  ApprovalStatus _determineNextStatus(
    ApprovalStage currentStage,
    ApprovalStatus decision,
    ApprovalStage nextStage,
  ) {
    if (decision == ApprovalStatus.declined) {
      return ApprovalStatus.declined;
    }

    if (nextStage == ApprovalStage.completed) {
      return ApprovalStatus.approved;
    }

    return ApprovalStatus.pending;
  }

  /// Gets the current approval status of a purchase order.
  ApprovalStatus getCurrentStatus(
      PurchaseOrderApprovalHistory approvalHistory) {
    return approvalHistory.currentStatus;
  }

  /// Checks if a purchase order is fully approved.
  bool isFullyApproved(PurchaseOrderApprovalHistory approvalHistory) {
    return approvalHistory.currentStage == ApprovalStage.completed &&
        approvalHistory.currentStatus == ApprovalStatus.approved;
  }

  /// Creates an escalation action for a purchase order.
  ///
  /// [approvalHistory] - The current approval history
  /// [userId] - ID of the user performing the escalation
  /// [userName] - Name of the user performing the escalation
  /// [escalationReason] - Reason for the escalation
  /// Returns the updated approval history
  Future<PurchaseOrderApprovalHistory> escalate(
    PurchaseOrderApprovalHistory approvalHistory,
    String userId,
    String userName,
    String escalationReason,
  ) async {
    // Create the escalation action
    final action = ApprovalAction(
      id: _uuid.v4(),
      purchaseOrderId: approvalHistory.purchaseOrderId,
      userId: userId,
      userName: userName,
      timestamp: DateTime.now(),
      decision: ApprovalStatus.escalated,
      notes: escalationReason,
      stage: approvalHistory.currentStage,
      isBiometricallyValidated: false,
    );

    // Update the approval history
    final updatedActions = List<ApprovalAction>.from(approvalHistory.actions)
      ..add(action);

    return approvalHistory.copyWith(
      actions: updatedActions,
      currentStatus: ApprovalStatus.escalated,
      lastUpdated: DateTime.now(),
    );
  }
}
