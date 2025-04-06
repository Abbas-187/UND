import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/production_batch_providers.dart';

/// Widget for recording and updating process parameters during production
class ProcessParametersForm extends ConsumerStatefulWidget {

  const ProcessParametersForm({
    super.key,
    required this.batchId,
  });
  final String batchId;

  @override
  ConsumerState<ProcessParametersForm> createState() =>
      _ProcessParametersFormState();
}

class _ProcessParametersFormState extends ConsumerState<ProcessParametersForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _viscosityController = TextEditingController();
  final TextEditingController _mixingSpeedController = TextEditingController();
  final TextEditingController _customParamController = TextEditingController();
  final TextEditingController _customValueController = TextEditingController();

  String? _selectedCustomParam;
  final List<String> _commonCustomParams = [
    'Acidity',
    'Fat Content',
    'Protein Content',
    'Moisture Content',
    'Density',
    'Homogenization Pressure',
    'Pasteurization Time',
    'Cooling Rate',
    'Other',
  ];

  @override
  void dispose() {
    _temperatureController.dispose();
    _phController.dispose();
    _viscosityController.dispose();
    _mixingSpeedController.dispose();
    _customParamController.dispose();
    _customValueController.dispose();
    super.dispose();
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
                'Process Parameters',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Standard parameters
              _buildParameterField(
                label: 'Temperature (°C)',
                controller: _temperatureController,
                icon: Icons.thermostat,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              _buildParameterField(
                label: 'pH Level',
                controller: _phController,
                icon: Icons.science,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              _buildParameterField(
                label: 'Viscosity (cP)',
                controller: _viscosityController,
                icon: Icons.water,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              _buildParameterField(
                label: 'Mixing Speed (RPM)',
                controller: _mixingSpeedController,
                icon: Icons.speed,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),

              // Custom parameter
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Custom Parameter',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select parameter'),
                      value: _selectedCustomParam,
                      items: _commonCustomParams.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCustomParam = newValue;
                          if (newValue == 'Other') {
                            _customParamController.clear();
                          } else {
                            _customParamController.text = newValue ?? '';
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildParameterField(
                      label: 'Value',
                      controller: _customValueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),

              if (_selectedCustomParam == 'Other') ...[
                const SizedBox(height: 16.0),
                _buildParameterField(
                  label: 'Parameter Name',
                  controller: _customParamController,
                  keyboardType: TextInputType.text,
                ),
              ],

              const SizedBox(height: 24.0),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Record Parameters'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: _submitParameters,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  void _submitParameters() {
    if (_formKey.currentState?.validate() ?? false) {
      // Build parameters map from form values
      final parameters = <String, dynamic>{};

      if (_temperatureController.text.isNotEmpty) {
        parameters['temperature'] = double.parse(_temperatureController.text);
      }

      if (_phController.text.isNotEmpty) {
        parameters['pH'] = double.parse(_phController.text);
      }

      if (_viscosityController.text.isNotEmpty) {
        parameters['viscosity'] = double.parse(_viscosityController.text);
      }

      if (_mixingSpeedController.text.isNotEmpty) {
        parameters['mixingSpeed'] = int.parse(_mixingSpeedController.text);
      }

      // Add custom parameter if provided
      if (_selectedCustomParam != null &&
          _customValueController.text.isNotEmpty) {
        final paramName = _selectedCustomParam == 'Other'
            ? _customParamController.text
            : _selectedCustomParam!;

        if (paramName.isNotEmpty) {
          final value = double.tryParse(_customValueController.text) ??
              _customValueController.text;
          parameters[_formatParameterKey(paramName)] = value;
        }
      }

      // Only update if we have parameters to record
      if (parameters.isNotEmpty) {
        final params = UpdateBatchParametersParams(
          batchId: widget.batchId,
          parameters: parameters,
        );

        // Call the provider to update parameters
        ref.read(updateBatchParametersProvider(params));

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Process parameters recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear custom fields
        _customValueController.clear();
        setState(() {
          _selectedCustomParam = null;
        });
      }
    }
  }

  String _formatParameterKey(String name) {
    // Convert spaces to camelCase
    final parts = name.split(' ');
    return parts.first.toLowerCase() +
        parts
            .skip(1)
            .map((part) => part.isEmpty
                ? ''
                : part[0].toUpperCase() + part.substring(1).toLowerCase())
            .join('');
  }
}
