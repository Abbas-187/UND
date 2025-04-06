import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/step_delivery_authorization.dart';
import '../widgets/step_initial_inspection.dart';
import '../widgets/step_lab_results.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/step_quality_inspection.dart';
import '../widgets/step_sample_collection.dart';
import '../widgets/step_supplier_info.dart';

/// A screen that guides users through the milk reception process
class MilkReceptionWizardScreen extends ConsumerStatefulWidget {
  const MilkReceptionWizardScreen({super.key});

  @override
  ConsumerState<MilkReceptionWizardScreen> createState() =>
      _MilkReceptionWizardScreenState();
}

class _MilkReceptionWizardScreenState
    extends ConsumerState<MilkReceptionWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  final List<String> _stepTitles = [
    'Supplier Information',
    'Initial Inspection',
    'Quality Inspection',
    'Sample Collection',
    'Laboratory Results',
    'Delivery Authorization',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Reception Wizard'),
      ),
      body: Column(
        children: [
          // Progress indicator and step title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                StepProgressIndicator(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  stepTitles: _stepTitles,
                ),
                const SizedBox(height: 16),
                Text(
                  _stepTitles[_currentStep],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Supplier Information
                StepSupplierInfo(
                  onContinue: _goToNextStep,
                ),

                // Step 2: Initial Inspection
                StepInitialInspection(
                  onContinue: _goToNextStep,
                  onBack: _goToPreviousStep,
                ),

                // Step 3: Quality Inspection
                StepQualityInspection(
                  onContinue: _goToNextStep,
                  onBack: _goToPreviousStep,
                ),

                // Step 4: Sample Collection
                StepSampleCollection(
                  onContinue: _goToNextStep,
                  onBack: _goToPreviousStep,
                ),

                // Step 5: Laboratory Results
                StepLabResults(
                  onContinue: _goToNextStep,
                  onBack: _goToPreviousStep,
                ),

                // Step 6: Delivery Authorization
                StepDeliveryAuthorization(
                  onBack: _goToPreviousStep,
                  onComplete: () {
                    // Handle completion
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Bottom navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentStep > 0 ? _goToPreviousStep : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed:
                      _currentStep < _totalSteps - 1 ? _goToNextStep : null,
                  child: Text(
                      _currentStep < _totalSteps - 1 ? 'Next' : 'Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
