import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/app_bar_with_back.dart';
import '../../../../../core/widgets/loading_overlay.dart';
import '../../../production/domain/models/production_execution_model.dart';
import '../../../production/presentation/providers/production_execution_providers.dart';
import '../widgets/production_execution_form.dart';

/// Screen for creating a new production execution record
class CreateProductionExecutionScreen extends ConsumerWidget {

  /// Creates a [CreateProductionExecutionScreen] widget.
  /// If [productionExecution] is provided, the screen operates in edit mode.
  const CreateProductionExecutionScreen({
    super.key,
    this.productionExecution,
  });
  /// Route name for navigation
  static const routeName = '/create-production-execution';

  /// Production execution for editing mode, null for create mode
  final ProductionExecutionModel? productionExecution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = productionExecution != null;
    final title =
        isEditing ? 'Edit Production Execution' : 'Create Production Execution';

    // Watch the state for loading, success, or error
    final controllerState = ref.watch(productionExecutionControllerProvider);

    return LoadingOverlay(
      isLoading: controllerState is AsyncLoading,
      child: Scaffold(
        appBar: AppBarWithBack(
          title: title,
          actions: [
            if (isEditing)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: ProductionExecutionForm(
          initialValue: productionExecution,
          isEditing: isEditing,
          onSubmit: (updatedExecution) =>
              _handleSubmit(context, ref, updatedExecution),
        ),
      ),
    );
  }

  /// Handles form submission
  void _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    ProductionExecutionModel execution,
  ) async {
    final controller = ref.read(productionExecutionControllerProvider.notifier);

    if (productionExecution != null) {
      // Edit mode - update existing execution
      await controller.updateExecution(execution);
    } else {
      // Create mode - create new execution
      await controller.createExecution(execution);
    }

    // Handle the result
    if (context.mounted) {
      final state = ref.read(productionExecutionControllerProvider);

      if (state is AsyncError) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (state is AsyncData) {
        // Show success message and pop back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              productionExecution != null
                  ? 'Production execution updated successfully'
                  : 'Production execution created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  /// Confirm deletion with a dialog
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this production execution? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleDelete(context, ref);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Handle the actual deletion
  void _handleDelete(BuildContext context, WidgetRef ref) async {
    if (productionExecution != null) {
      final controller =
          ref.read(productionExecutionControllerProvider.notifier);
      await controller.deleteExecution(productionExecution!.id);

      if (context.mounted) {
        final state = ref.read(productionExecutionControllerProvider);

        if (state is AsyncError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AsyncData) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Production execution deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }
}
