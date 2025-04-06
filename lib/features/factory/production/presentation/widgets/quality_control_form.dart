import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/quality_control_result_model.dart';
import '../providers/quality_control_providers.dart';

/// Widget for recording quality control checks during production
class QualityControlForm extends ConsumerStatefulWidget {
  const QualityControlForm({
    super.key,
    required this.batchId,
    required this.executionId,
    required this.productId,
  });
  final String batchId;
  final String executionId;
  final String productId;

  @override
  ConsumerState<QualityControlForm> createState() => _QualityControlFormState();
}

class _QualityControlFormState extends ConsumerState<QualityControlForm> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final TextEditingController _checkpointController = TextEditingController();
  final TextEditingController _parametersController = TextEditingController();
  final TextEditingController _deviationDetailsController =
      TextEditingController();

  late String _performedBy;
  QualityCheckResult _result = QualityCheckResult.pass;
  bool _isCritical = false;

  final Map<String, TextEditingController> _measurementControllers = {};
  final List<String> _measurementNames = [];

  @override
  void initState() {
    super.initState();
    // Initialize with some common measurements for dairy products
    _addMeasurement('Temperature');
    _addMeasurement('pH');
    _addMeasurement('Density');
    _addMeasurement('Fat Content');
    _addMeasurement('Protein Content');

    // Get the current user name (in a real app, this would come from auth)
    _performedBy = 'Current User'; // Placeholder
  }

  @override
  void dispose() {
    _checkpointController.dispose();
    _parametersController.dispose();
    _deviationDetailsController.dispose();

    // Dispose all measurement controllers
    for (final controller in _measurementControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _addMeasurement(String name) {
    if (!_measurementNames.contains(name) && name.isNotEmpty) {
      setState(() {
        _measurementNames.add(name);
        _measurementControllers[name] = TextEditingController();
      });
    }
  }

  void _removeMeasurement(String name) {
    setState(() {
      _measurementNames.remove(name);
      _measurementControllers[name]?.dispose();
      _measurementControllers.remove(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quality Control Check',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Checkpoint name
              TextFormField(
                controller: _checkpointController,
                decoration: const InputDecoration(
                  labelText: 'Checkpoint Name *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Pre-Pasteurization Check',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a checkpoint name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Parameters
              TextFormField(
                controller: _parametersController,
                decoration: const InputDecoration(
                  labelText: 'Control Parameters *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Temperature range, pH requirements',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter control parameters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Result selection
              const Text(
                'Check Result',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Row(
                children: [
                  Radio<QualityCheckResult>(
                    value: QualityCheckResult.pass,
                    groupValue: _result,
                    onChanged: (value) {
                      setState(() {
                        _result = value!;
                      });
                    },
                  ),
                  const Text('Pass'),
                  const SizedBox(width: 16.0),
                  Radio<QualityCheckResult>(
                    value: QualityCheckResult.conditional,
                    groupValue: _result,
                    onChanged: (value) {
                      setState(() {
                        _result = value!;
                      });
                    },
                  ),
                  const Text('Conditional'),
                  const SizedBox(width: 16.0),
                  Radio<QualityCheckResult>(
                    value: QualityCheckResult.fail,
                    groupValue: _result,
                    onChanged: (value) {
                      setState(() {
                        _result = value!;
                      });
                    },
                  ),
                  const Text('Fail'),
                ],
              ),

              // Criticality checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isCritical,
                    onChanged: (value) {
                      setState(() {
                        _isCritical = value!;
                      });
                    },
                  ),
                  const Text('Mark as Critical Check'),
                ],
              ),
              const SizedBox(height: 16.0),

              // Deviation details for conditional or fail results
              if (_result != QualityCheckResult.pass) ...[
                TextFormField(
                  controller: _deviationDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Deviation Details *',
                    border: OutlineInputBorder(),
                    hintText: 'Describe the deviation from expected parameters',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_result != QualityCheckResult.pass &&
                        (value == null || value.isEmpty)) {
                      return 'Please describe the deviation';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
              ],

              // Measurements section
              const Text(
                'Measurements',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),

              ..._measurementNames.map((name) => _buildMeasurementField(name)),

              // Add new measurement button
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Measurement'),
                onPressed: _showAddMeasurementDialog,
              ),
              const SizedBox(height: 24.0),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Record Quality Check'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitQualityCheck,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _measurementControllers[name],
              decoration: InputDecoration(
                labelText: name,
                border: const OutlineInputBorder(),
                hintText: 'Enter value',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeMeasurement(name),
          ),
        ],
      ),
    );
  }

  void _showAddMeasurementDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Measurement'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Measurement Name',
            hintText: 'e.g., Viscosity, Acidity',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _addMeasurement(textController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => textController.dispose());
  }

  void _submitQualityCheck() {
    if (_formKey.currentState?.validate() ?? false) {
      // Collect measurements
      final measurements = <String, dynamic>{};
      for (final name in _measurementNames) {
        final value = _measurementControllers[name]?.text;
        if (value != null && value.isNotEmpty) {
          // Try to parse as number, otherwise keep as string
          measurements[name] = double.tryParse(value) ?? value;
        }
      }

      // Create quality control result model
      final result = QualityControlResultModel(
        id: _uuid.v4(),
        batchId: widget.batchId,
        executionId: widget.executionId,
        productId: widget.productId,
        checkpointName: _checkpointController.text,
        parameters: _parametersController.text,
        result: _result,
        measurements: measurements,
        deviationDetails: _deviationDetailsController.text.isEmpty
            ? null
            : _deviationDetailsController.text,
        correctiveAction: null, // To be added later if needed
        performedBy: _performedBy,
        performedAt: DateTime.now(),
        reviewedBy: null, // To be reviewed later
        reviewedAt: null,
        isCritical: _isCritical,
        createdAt: DateTime.now(),
        createdBy: _performedBy,
        updatedAt: DateTime.now(),
        updatedBy: _performedBy,
      );

      // Save to repository using provider and listen to the result
      ref.read(recordQualityControlResultProvider(result).future).then((_) {
        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Quality check ${_result == QualityCheckResult.pass ? 'passed' : 'recorded'}'),
            backgroundColor: _result == QualityCheckResult.pass
                ? Colors.green
                : Colors.orange,
          ),
        );

        // Clear form
        _formKey.currentState?.reset();
        _checkpointController.clear();
        _parametersController.clear();
        _deviationDetailsController.clear();

        for (final controller in _measurementControllers.values) {
          controller.clear();
        }

        setState(() {
          _result = QualityCheckResult.pass;
          _isCritical = false;
        });
      }).catchError((error) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }
}
