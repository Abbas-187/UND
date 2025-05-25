import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_form_provider.dart';

class DueDatePicker extends ConsumerWidget {
  const DueDatePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDate =
        ref.watch(orderFormProvider.select((state) => state.dueDate));

    return Row(
      children: [
        Expanded(
          child: Text(
            dueDate != null
                ? 'Due Date: \\${dueDate.toLocal().toString().split(' ')[0]}'
                : 'No Due Date Selected',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              ref.read(orderFormProvider.notifier).setDueDate(selectedDate);
            }
          },
        ),
      ],
    );
  }
}
