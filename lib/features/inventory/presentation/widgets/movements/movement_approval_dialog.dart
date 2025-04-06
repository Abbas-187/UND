import 'package:flutter/material.dart';

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

    return AlertDialog(
      title: Text(
        widget.isApproval ? 'Approve Movement' : 'Reject Movement',
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
                    ? 'You are about to approve movement ${widget.movementId}.'
                    : 'You are about to reject movement ${widget.movementId}.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _approverIdController,
                decoration: const InputDecoration(
                  labelText: 'Approver ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Approver ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _approverNameController,
                decoration: const InputDecoration(
                  labelText: 'Approver Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Approver name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: widget.isApproval
                      ? 'Additional Notes (Optional)'
                      : 'Reason for Rejection',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (!widget.isApproval && (value == null || value.isEmpty)) {
                    return 'Please provide a reason for rejection';
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
          child: const Text('Cancel'),
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
              : Text(widget.isApproval ? 'Approve' : 'Reject'),
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
