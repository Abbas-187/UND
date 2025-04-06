import 'package:flutter/material.dart';

/// A widget that displays the progress of a multi-step process
class StepProgressIndicator extends StatelessWidget {
  /// Creates a step progress indicator
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles,
  });

  /// The current step (0-based)
  final int currentStep;

  /// The total number of steps
  final int totalSteps;

  /// Optional labels for each step
  final List<String>? stepTitles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step circles and connecting lines
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            final isFirst = index == 0;
            final isLast = index == totalSteps - 1;

            return Expanded(
              child: Row(
                children: [
                  // Circle indicator
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Line connector (except for the last item)
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index < currentStep
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        // Step labels (if provided)
        if (stepTitles != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index <= currentStep;

                return Expanded(
                  child: Text(
                    stepTitles![index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
