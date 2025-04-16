import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../domain/entities/inventory_adjustment.dart';
import '../../../../l10n/app_localizations.dart';

class AdjustmentDetailsDialog extends StatelessWidget {
  final InventoryAdjustment adjustment;

  const AdjustmentDetailsDialog({
    super.key,
    required this.adjustment,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        width: math.min(MediaQuery.of(context).size.width * 0.9, 500),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: _getAdjustmentTypeColor(adjustment.adjustmentType),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getAdjustmentTypeIcon(adjustment.adjustmentType),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          adjustment.itemName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${adjustment.id}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    'Date: ${dateFormat.format(adjustment.performedAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quantity Information
                      _buildSectionTitle(context, l10n.currentStock),
                      const SizedBox(height: 8),
                      _buildDetailRow(context, l10n.previousStock,
                          adjustment.previousQuantity.toString()),
                      _buildDetailRow(context, l10n.adjustedStock,
                          adjustment.adjustedQuantity.toString()),
                      _buildDetailRow(context, l10n.netChange,
                          '${adjustment.quantity >= 0 ? '+' : ''}${adjustment.quantity}'),
                      const Divider(height: 32),

                      // Reason and Notes
                      _buildSectionTitle(context, l10n.reasonNotes),
                      const SizedBox(height: 8),
                      _buildDetailRow(context, l10n.adjustmentTypeLabel,
                          _formatAdjustmentType(adjustment.adjustmentType)),
                      _buildDetailRow(
                          context, l10n.reasonLabel, adjustment.reason),
                      if (adjustment.notes != null &&
                          adjustment.notes!.isNotEmpty)
                        _buildDetailRow(context, l10n.notes, adjustment.notes!),
                      const Divider(height: 32),

                      // Personnel
                      _buildSectionTitle(context, l10n.personnel),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          context, l10n.performedBy, adjustment.performedBy),
                      _buildDetailRow(context, l10n.statusLabel,
                          _formatStatus(context, adjustment.approvalStatus)),
                      if (adjustment.approvedBy != null)
                        _buildDetailRow(
                            context, l10n.reviewedBy, adjustment.approvedBy!),
                      if (adjustment.approvedAt != null)
                        _buildDetailRow(context, l10n.approvedDate,
                            dateFormat.format(adjustment.approvedAt!)),
                      const Divider(height: 32),

                      // Category and Reference
                      if (adjustment.categoryName != null ||
                          adjustment.documentReference != null) ...[
                        _buildSectionTitle(context, l10n.additionalInfo),
                        const SizedBox(height: 8),
                        if (adjustment.categoryName != null)
                          _buildDetailRow(
                              context, l10n.category, adjustment.categoryName!),
                        if (adjustment.documentReference != null)
                          _buildDetailRow(context, l10n.referenceDocuments,
                              adjustment.documentReference!),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAdjustmentType(AdjustmentType type) {
    final typeString = type.toString().split('.').last;
    final words = typeString.split('_');
    return words
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatStatus(BuildContext context, AdjustmentApprovalStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case AdjustmentApprovalStatus.pending:
        return l10n.pendingApproval;
      case AdjustmentApprovalStatus.approved:
        return l10n.approved;
      case AdjustmentApprovalStatus.rejected:
        return l10n.rejected;
    }
  }

  Color _getAdjustmentTypeColor(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.manual:
        return Colors.blue;
      case AdjustmentType.stockCount:
        return Colors.green;
      case AdjustmentType.expiry:
        return Colors.red;
      case AdjustmentType.damage:
        return Colors.orange;
      case AdjustmentType.loss:
        return Colors.deepOrange;
      case AdjustmentType.return_to_supplier:
        return Colors.purple;
      case AdjustmentType.system_correction:
        return Colors.teal;
      case AdjustmentType.transfer:
        return Colors.indigo;
    }
  }

  IconData _getAdjustmentTypeIcon(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.manual:
        return Icons.edit;
      case AdjustmentType.stockCount:
        return Icons.inventory;
      case AdjustmentType.expiry:
        return Icons.timer_off;
      case AdjustmentType.damage:
        return Icons.warning;
      case AdjustmentType.loss:
        return Icons.clear;
      case AdjustmentType.return_to_supplier:
        return Icons.assignment_return;
      case AdjustmentType.system_correction:
        return Icons.settings;
      case AdjustmentType.transfer:
        return Icons.swap_horiz;
    }
  }
}
