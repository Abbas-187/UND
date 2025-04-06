import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/production_line_allocation_model.dart';

class ProductionLineTimeline extends ConsumerWidget {
  const ProductionLineTimeline({
    super.key,
    required this.lineAllocation,
    this.onTimeBlockSelected,
  });
  final ProductionLineAllocationModel lineAllocation;
  final Function(DateTime startTime, DateTime endTime)? onTimeBlockSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              lineAllocation.lineName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lineAllocation.availableTimeBlocks.length,
              itemBuilder: (context, index) {
                final timeBlock = lineAllocation.availableTimeBlocks[index];
                return GestureDetector(
                  onTap: () {
                    if (!timeBlock.isAllocated && onTimeBlockSelected != null) {
                      onTimeBlockSelected!(
                          timeBlock.startTime, timeBlock.endTime);
                    }
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: timeBlock.isAllocated
                          ? Colors.grey.shade300
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            timeBlock.isAllocated ? Colors.grey : Colors.green,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${timeBlock.startTime.hour}:00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${timeBlock.endTime.hour}:00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (timeBlock.isAllocated &&
                            timeBlock.allocationName != null)
                          Text(
                            timeBlock.allocationName!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
