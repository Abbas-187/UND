import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/inventory_item.dart';
import '../controllers/inventory_database_controller.dart';

class InventoryImportExport extends ConsumerStatefulWidget {

  const InventoryImportExport({
    super.key,
    required this.onImportComplete,
  });
  final VoidCallback onImportComplete;

  @override
  ConsumerState<InventoryImportExport> createState() =>
      _InventoryImportExportState();
}

class _InventoryImportExportState extends ConsumerState<InventoryImportExport> {
  bool _isImporting = false;
  bool _isExporting = false;
  String _statusMessage = '';
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import/Export Inventory Database',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Use this feature to import inventory data from JSON files or export your current inventory to a JSON file for backup and transfer purposes.',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import from JSON'),
                    onPressed:
                        _isImporting || _isExporting ? null : _importFromJson,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export to JSON'),
                    onPressed:
                        _isImporting || _isExporting ? null : _exportToJson,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isImporting || _isExporting)
              const LinearProgressIndicator()
            else if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _hasError ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        _hasError ? Colors.red.shade200 : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasError ? Icons.error : Icons.check_circle,
                      color: _hasError ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_statusMessage),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          _statusMessage = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Data Format Guidelines',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'The JSON file for import should contain an array of inventory items with the following structure:',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText('''
[
  {
    "id": "unique-id-1",
    "name": "Whole Milk",
    "category": "Raw Dairy",
    "unit": "liters",
    "quantity": 500.0,
    "minimumQuantity": 100.0,
    "reorderPoint": 200.0,
    "location": "Cold Storage A",
    "batchNumber": "BN-2023-001",
    "expiryDate": "2023-12-31",
    "cost": 1.5,
    "lowStockThreshold": 150,
    "additionalAttributes": {
      "pasteurized": true,
      "fatContent": 3.5,
      "processingDate": "2023-10-15"
    }
  },
  ...
]
'''),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFromJson() async {
    setState(() {
      _isImporting = true;
      _statusMessage = '';
      _hasError = false;
    });

    try {
      // Request storage permission
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isImporting = false;
          _statusMessage = 'Import cancelled';
          _hasError = true;
        });
        return;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);

      // Convert JSON to inventory items
      final List<InventoryItem> items = [];
      for (final json in jsonData) {
        final Map<String, dynamic> itemJson = json as Map<String, dynamic>;

        // Convert date strings to DateTime objects
        if (itemJson['expiryDate'] != null &&
            itemJson['expiryDate'] is String) {
          itemJson['expiryDate'] = DateTime.parse(itemJson['expiryDate']);
        }

        // Process additionalAttributes for dates
        if (itemJson['additionalAttributes'] != null &&
            itemJson['additionalAttributes'] is Map<String, dynamic>) {
          final attributes =
              itemJson['additionalAttributes'] as Map<String, dynamic>;
          if (attributes['processingDate'] != null &&
              attributes['processingDate'] is String) {
            attributes['processingDate'] =
                DateTime.parse(attributes['processingDate']);
          }
        }

        items.add(InventoryItem.fromJson(itemJson));
      }

      // Import items to database
      await ref
          .read(inventoryDatabaseControllerProvider.notifier)
          .importInventoryItems(items);

      setState(() {
        _isImporting = false;
        _statusMessage =
            'Successfully imported ${items.length} inventory items';
        _hasError = false;
      });

      widget.onImportComplete();
    } catch (e) {
      setState(() {
        _isImporting = false;
        _statusMessage = 'Error importing inventory: ${e.toString()}';
        _hasError = true;
      });
    }
  }

  Future<void> _exportToJson() async {
    setState(() {
      _isExporting = true;
      _statusMessage = '';
      _hasError = false;
    });

    try {
      // Request storage permission
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Get inventory items
      final items = await ref
          .read(inventoryDatabaseControllerProvider.notifier)
          .exportInventoryItems();

      // Convert to JSON
      final List<Map<String, dynamic>> jsonItems = items.map((item) {
        final json = item.toJson();

        // Convert DateTime objects to strings
        if (json['expiryDate'] != null && json['expiryDate'] is DateTime) {
          json['expiryDate'] =
              (json['expiryDate'] as DateTime).toIso8601String();
        }

        // Process additionalAttributes for dates
        if (json['additionalAttributes'] != null &&
            json['additionalAttributes'] is Map<String, dynamic>) {
          final attributes =
              json['additionalAttributes'] as Map<String, dynamic>;
          if (attributes['processingDate'] != null &&
              attributes['processingDate'] is DateTime) {
            attributes['processingDate'] =
                (attributes['processingDate'] as DateTime).toIso8601String();
          }
        }

        return json;
      }).toList();

      final jsonString = jsonEncode(jsonItems);

      // Get directory to save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'inventory_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';

      // Save file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share file or inform success
      setState(() {
        _isExporting = false;
        _statusMessage =
            'Successfully exported ${items.length} inventory items to $filePath';
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _statusMessage = 'Error exporting inventory: ${e.toString()}';
        _hasError = true;
      });
    }
  }
}
