import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget for capturing supplier information in the milk reception process
class StepSupplierInfo extends ConsumerStatefulWidget {
  /// Creates a step for supplier information
  const StepSupplierInfo({
    super.key,
    required this.onContinue,
  });

  /// Callback when the user wants to continue to the next step
  final VoidCallback onContinue;

  @override
  ConsumerState<StepSupplierInfo> createState() => _StepSupplierInfoState();
}

class _StepSupplierInfoState extends ConsumerState<StepSupplierInfo> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _supplierIdController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _routeNumberController = TextEditingController();

  @override
  void dispose() {
    _supplierNameController.dispose();
    _supplierIdController.dispose();
    _driverNameController.dispose();
    _vehiclePlateController.dispose();
    _routeNumberController.dispose();
    super.dispose();
  }

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
                'Enter supplier and transport information:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Supplier Details
              Text(
                'Supplier Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supplierNameController,
                decoration: const InputDecoration(
                  labelText: 'Supplier Name',
                  hintText: 'Enter the name of the supplier',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the supplier name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supplierIdController,
                decoration: const InputDecoration(
                  labelText: 'Supplier ID',
                  hintText: 'Enter the supplier ID',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the supplier ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Transport Details
              Text(
                'Transport Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _driverNameController,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                  hintText: 'Enter the name of the driver',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the driver name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehiclePlateController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Plate Number',
                  hintText: 'Enter the vehicle plate number',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle plate number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routeNumberController,
                decoration: const InputDecoration(
                  labelText: 'Route Number (Optional)',
                  hintText: 'Enter the route number if applicable',
                  prefixIcon: Icon(Icons.route),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save the data here
                      // Could dispatch to a provider
                      widget.onContinue();
                    }
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
