import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget for capturing quality inspection data in the milk reception process
class StepQualityInspection extends ConsumerStatefulWidget {
  /// Creates a step for quality inspection
  const StepQualityInspection({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  /// Callback when the user wants to continue to the next step
  final VoidCallback onContinue;

  /// Callback when the user wants to go back to the previous step
  final VoidCallback onBack;

  @override
  ConsumerState<StepQualityInspection> createState() =>
      _StepQualityInspectionState();
}

class _StepQualityInspectionState extends ConsumerState<StepQualityInspection> {
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
                'Assess the quality parameters of the milk:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Quality inspection form fields would go here
              // This is a placeholder implementation
              const Center(
                child: Text(
                  'Quality Inspection Form',
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
