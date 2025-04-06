import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget for capturing initial inspection data in the milk reception process
class StepInitialInspection extends ConsumerStatefulWidget {
  /// Creates a step for initial inspection
  const StepInitialInspection({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  /// Callback when the user wants to continue to the next step
  final VoidCallback onContinue;

  /// Callback when the user wants to go back to the previous step
  final VoidCallback onBack;

  @override
  ConsumerState<StepInitialInspection> createState() =>
      _StepInitialInspectionState();
}

class _StepInitialInspectionState extends ConsumerState<StepInitialInspection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Initial visual inspection of the milk:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Initial inspection form fields would go here
              // This is a placeholder implementation
              const Center(
                child: Text(
                  'Initial Inspection Form',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Implementation in progress...',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 32),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: widget.onBack,
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Process the data
                        widget.onContinue();
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
