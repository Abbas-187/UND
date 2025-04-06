import 'package:flutter/material.dart';
import '../../../production/domain/models/production_execution_model.dart';

/// Widget to display materials used in production in a table format
class MaterialConsumptionTable extends StatelessWidget {

  const MaterialConsumptionTable({
    super.key,
    required this.materials,
    this.allowEditing = false,
    this.onMaterialUpdated,
  });
  /// List of materials used in the production
  final List<MaterialUsage> materials;

  /// Whether to allow editing of actual quantity values
  final bool allowEditing;

  /// Callback when material usage is updated
  final Function(String materialId, double newActualQuantity)?
      onMaterialUpdated;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Material Consumption',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (materials.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No materials recorded for this production',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor:
                      WidgetStateProperty.all(Colors.grey.shade100),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Material',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Planned',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Actual',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Unit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Variance',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows: materials.map((material) {
                    // Calculate variance percentage
                    final variance =
                        material.actualQuantity - material.plannedQuantity;
                    final variancePercentage = material.plannedQuantity > 0
                        ? (variance / material.plannedQuantity) * 100
                        : 0.0;

                    // Determine variance color
                    Color varianceColor = Colors.green;
                    if (variancePercentage > 5) {
                      varianceColor = Colors.red.shade700;
                    } else if (variancePercentage < -5) {
                      varianceColor = Colors.orange;
                    }

                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                material.materialName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              if (material.batchNumber != null)
                                Text(
                                  'Batch: ${material.batchNumber}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(material.plannedQuantity.toStringAsFixed(2)),
                        ),
                        allowEditing
                            ? DataCell(
                                TextFormField(
                                  initialValue: material.actualQuantity
                                      .toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final newValue = double.tryParse(value);
                                    if (newValue != null &&
                                        onMaterialUpdated != null) {
                                      onMaterialUpdated!(
                                          material.materialId, newValue);
                                    }
                                  },
                                ),
                              )
                            : DataCell(
                                Text(
                                    material.actualQuantity.toStringAsFixed(2)),
                              ),
                        DataCell(
                          Text(material.unitOfMeasure),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Text(
                                '${variance >= 0 ? '+' : ''}${variance.toStringAsFixed(2)} '
                                '(${variancePercentage.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  color: varianceColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

            // Button to add new material if editing is allowed
            if (allowEditing)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Material'),
                  onPressed: () {
                    // This would typically open a dialog to add a new material
                    // Implementation would depend on the app's state management approach
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
