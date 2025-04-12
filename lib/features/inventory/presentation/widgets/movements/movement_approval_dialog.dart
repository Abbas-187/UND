import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

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
        widget.isApproval ? l10n.approveMovement : l10n.rejectMovement,
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
                    ? l10n.aboutToApprove(widget.movementId)
                    : l10n.aboutToReject(widget.movementId),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _approverIdController,
                decoration: InputDecoration(
                  labelText: l10n.approverId,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.approverIdRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _approverNameController,
                decoration: InputDecoration(
                  labelText: l10n.approverName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.approverNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: widget.isApproval
                      ? l10n.additionalNotes
                      : l10n.rejectionReason,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (!widget.isApproval && (value == null || value.isEmpty)) {
                    return l10n.provideRejectionReason;
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
          child: Text(l10n.cancel),
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
              : Text(widget.isApproval ? l10n.approve : l10n.reject),
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
