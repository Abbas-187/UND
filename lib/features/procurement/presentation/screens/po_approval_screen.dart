import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/purchase_order_approval.dart';
import '../../domain/workflow/po_approval_workflow.dart';
import '../../domain/security/biometric_validator.dart';
import '../providers/po_approval_provider.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';

/// Screen for approving or declining purchase orders.
class POApprovalScreen extends ConsumerStatefulWidget {
  final String purchaseOrderId;

  const POApprovalScreen({
    Key? key,
    required this.purchaseOrderId,
  }) : super(key: key);

  @override
  ConsumerState<POApprovalScreen> createState() => _POApprovalScreenState();
}

class _POApprovalScreenState extends ConsumerState<POApprovalScreen> {
  final _rejectionReasonController = TextEditingController();
  bool _isLoading = false;
  bool _showBiometricError = false;
  String? _errorMessage;

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseOrderAsync =
        ref.watch(purchaseOrderProvider(widget.purchaseOrderId));
    final approvalHistoryAsync =
        ref.watch(poApprovalHistoryProvider(widget.purchaseOrderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Order Approval'),
      ),
      body: purchaseOrderAsync.when(
        data: (purchaseOrder) {
          return approvalHistoryAsync.when(
            data: (approvalHistory) {
              return _buildApprovalContent(
                context,
                purchaseOrder,
                approvalHistory,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Error loading approval history: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading purchase order: $error'),
        ),
      ),
    );
  }

  Widget _buildApprovalContent(
    BuildContext context,
    PurchaseOrder po,
    PurchaseOrderApprovalHistory approvalHistory,
  ) {
    final currentStage = approvalHistory.currentStage;
    final currentStatus = approvalHistory.currentStatus;
    final userRole = ref.watch(userRoleProvider);
    final userName = ref.watch(userNameProvider);
    final userId = ref.watch(userIdProvider);

    // Check if this PO is pending approval and user has the right role
    final canApprove = currentStatus == ApprovalStatus.pending &&
        _canUserApprovePO(userRole, currentStage);

    // Check if this is complete
    final isComplete = currentStage == ApprovalStage.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPOInfoCard(po, ref),
          const SizedBox(height: 16),
          _buildApprovalRequirementsCard(po),
          const SizedBox(height: 16),
          _buildItemsCard(po),
          const SizedBox(height: 16),
          _buildApprovalHistoryCard(approvalHistory),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_showBiometricError)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Biometric authentication failed. Please try again.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (canApprove) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _showDeclineDialog(context, approvalHistory),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('DECLINE'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _handleApprove(
                            context, userId, userName, approvalHistory),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('APPROVE'),
                  ),
                ),
              ],
            ),
          ] else if (isComplete) ...[
            Center(
              child: Text(
                currentStatus == ApprovalStatus.approved
                    ? 'This purchase order has been fully approved.'
                    : 'This purchase order has been declined.',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                'Waiting for ${_getStageName(currentStage)} approval',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPOInfoCard(PurchaseOrder po, WidgetRef ref) {
    final supplierId = po.supplierId;
    final supplierAsync = (supplierId.isNotEmpty)
        ? ref.watch(supplierProvider(supplierId))
        : null;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PO #${po.poNumber}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            supplierAsync != null
                ? supplierAsync.when(
                    data: (supplier) =>
                        _buildInfoRow('Supplier', supplier.name),
                    loading: () => _buildInfoRow('Supplier', 'Loading...'),
                    error: (error, stack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Supplier', po.supplierName),
                        const Text('Supplier info unavailable'),
                      ],
                    ),
                  )
                : _buildInfoRow('Supplier', po.supplierName),
            _buildInfoRow(
                'Total Amount', '\$${po.totalAmount.toStringAsFixed(2)}'),
            _buildInfoRow('Request Date', _formatDate(po.requestDate)),
            _buildInfoRow('Status', po.status.toString().split('.').last),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRequirementsCard(PurchaseOrder po) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approval Requirements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Reason for Request', po.reasonForRequest),
            _buildInfoRow('Intended Use', po.intendedUse),
            _buildInfoRow('Quantity Justification', po.quantityJustification),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(PurchaseOrder po) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: po.items.length,
              itemBuilder: (context, index) {
                final item = po.items[index];
                return ListTile(
                  title: Text(item.itemName),
                  subtitle: Text(
                      '${item.quantity} ${item.unit} @ \$${item.unitPrice.toStringAsFixed(2)}'),
                  trailing: Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalHistoryCard(PurchaseOrderApprovalHistory history) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approval History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            history.actions.isEmpty
                ? const Text('No approval actions yet')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.actions.length,
                    itemBuilder: (context, index) {
                      final action = history.actions[index];
                      return ListTile(
                        leading: Icon(
                          action.decision == ApprovalStatus.approved
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: action.decision == ApprovalStatus.approved
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(
                          '${action.userName} ${action.decision.toString().split('.').last}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${_getStageName(action.stage)} stage'),
                            if (action.notes != null &&
                                action.notes!.isNotEmpty)
                              Text('Notes: ${action.notes}'),
                          ],
                        ),
                        trailing: Text(_formatDate(action.timestamp)),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    String userId,
    String userName,
    PurchaseOrderApprovalHistory approvalHistory,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showBiometricError = false;
    });

    try {
      final userRole = ref.read(userRoleProvider);

      await ref.read(poApprovalWorkflowProvider).processApprovalAction(
            approvalHistory,
            userId,
            userName,
            ApprovalStatus.approved,
            null,
            userRole,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase order approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('Biometric validation failed')) {
          _showBiometricError = true;
        } else {
          _errorMessage = 'Error: ${e.toString()}';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeclineDialog(
    BuildContext context,
    PurchaseOrderApprovalHistory approvalHistory,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Purchase Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Please provide a reason for declining this purchase order:'),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final reason = _rejectionReasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for declining'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(reason);
            },
            child: const Text('DECLINE'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final userId = ref.read(userIdProvider);
        final userName = ref.read(userNameProvider);
        final userRole = ref.read(userRoleProvider);

        await ref.read(poApprovalWorkflowProvider).processApprovalAction(
              approvalHistory,
              userId,
              userName,
              ApprovalStatus.declined,
              result,
              userRole,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase order declined'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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

  String _getStageName(ApprovalStage stage) {
    switch (stage) {
      case ApprovalStage.procurementManager:
        return 'Procurement Manager';
      case ApprovalStage.ceo:
        return 'CEO';
      case ApprovalStage.completed:
        return 'Final';
      default:
        return stage.toString().split('.').last;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
