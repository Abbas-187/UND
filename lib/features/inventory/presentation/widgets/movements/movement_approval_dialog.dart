import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MovementApprovalDialog extends StatefulWidget {
  const MovementApprovalDialog({
    super.key,
    required this.movementId,
    required this.isApproval,
    required this.onApprove,
  });
  final String movementId;
  final bool isApproval;
  final Function(String approverId, String approverName, String notes)
      onApprove;

  @override
  State<MovementApprovalDialog> createState() => _MovementApprovalDialogState();
}

class _MovementApprovalDialogState extends State<MovementApprovalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _approverIdController = TextEditingController();
  final _approverNameController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _approverIdController.dispose();
    _approverNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(
        widget.isApproval
            ? (l10n?.approveMovement ?? 'Approve Movement')
            : (l10n?.rejectMovement ?? 'Reject Movement'),
        style: TextStyle(
          color: widget.isApproval ? Colors.green : Colors.red,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isApproval
                    ? (l10n != null && l10n.aboutToApprove != null
                        ? l10n.aboutToApprove(widget.movementId)
                        : 'About to approve ${widget.movementId}')
                    : (l10n != null && l10n.aboutToReject != null
                        ? l10n.aboutToReject(widget.movementId)
                        : 'About to reject ${widget.movementId}'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _approverIdController,
                decoration: InputDecoration(
                  labelText: l10n?.approverId ?? 'Approver ID',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n?.approverIdRequired ??
                        'Approver ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _approverNameController,
                decoration: InputDecoration(
                  labelText: l10n?.approverName ?? 'Approver Name',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n?.approverNameRequired ??
                        'Approver Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: widget.isApproval
                      ? (l10n?.additionalNotes ?? 'Additional Notes')
                      : (l10n?.rejectionReason ?? 'Rejection Reason'),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (!widget.isApproval && (value == null || value.isEmpty)) {
                    return l10n?.provideRejectionReason ??
                        'Please provide a rejection reason';
                  }
                  return null;
                },
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: FilledButton.styleFrom(
            backgroundColor: widget.isApproval ? Colors.green : Colors.red,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.isApproval
                  ? (l10n?.approve ?? 'Approve')
                  : (l10n?.reject ?? 'Reject')),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      widget.onApprove(
        _approverIdController.text.trim(),
        _approverNameController.text.trim(),
        _notesController.text.trim(),
      );

      Navigator.of(context).pop();
    }
  }
}
