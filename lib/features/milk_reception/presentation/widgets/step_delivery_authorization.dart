import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget for delivery authorization in the milk reception process
class StepDeliveryAuthorization extends ConsumerStatefulWidget {
  /// Creates a step for delivery authorization
  const StepDeliveryAuthorization({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  /// Callback when the user wants to go back to the previous step
  final VoidCallback onBack;

  /// Callback when the user completes the entire process
  final VoidCallback onComplete;

  @override
  ConsumerState<StepDeliveryAuthorization> createState() =>
      _StepDeliveryAuthorizationState();
}

class _StepDeliveryAuthorizationState
    extends ConsumerState<StepDeliveryAuthorization> {
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
                'Authorize milk delivery:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Authorization form fields would go here
              // This is a placeholder implementation
              const Center(
                child: Text(
                  'Delivery Authorization Form',
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
                        widget.onComplete();
                      }
                    },
                    child: const Text('Complete Reception'),
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
