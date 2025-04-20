import 'package:flutter/foundation.dart';
import '../models/purchase_order_approval_history.dart';
import '../security/biometric_validator.dart';

@immutable
class PurchaseOrderApprovalWorkflow {
  final BiometricValidator biometricValidator;

  const PurchaseOrderApprovalWorkflow({
    required this.biometricValidator,
  });

  Future<void> processApprovalAction(
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

    // At this point, the approval action would be saved to the repository
    // and the next stage would be determined

    // For now, this is a stub implementation
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
}
