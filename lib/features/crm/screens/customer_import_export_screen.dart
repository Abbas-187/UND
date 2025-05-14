import 'dart:io';

import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../utils/customer_csv_utils.dart';

class CustomerImportExportScreen extends StatefulWidget {

  const CustomerImportExportScreen(
      {super.key, required this.customers, required this.onImport});
  final List<Customer> customers;
  final void Function(List<Customer> imported) onImport;

  @override
  State<CustomerImportExportScreen> createState() =>
      _CustomerImportExportScreenState();
}

class _CustomerImportExportScreenState
    extends State<CustomerImportExportScreen> {
  String? _importStatus;
  String? _exportStatus;

  Future<void> _exportCustomers() async {
    final csv = CustomerCsvUtils.exportToCsv(widget.customers);
    final file = File('exported_customers.csv');
    await file.writeAsString(csv);
    setState(() {
      _exportStatus = 'Exported to exported_customers.csv';
    });
  }

  Future<void> _importCustomers() async {
    final file = File('import_customers.csv');
    if (await file.exists()) {
      final csv = await file.readAsString();
      final imported = CustomerCsvUtils.importFromCsv(csv);
      widget.onImport(imported);
      setState(() {
        _importStatus = 'Imported ${imported.length} customers.';
      });
    } else {
      setState(() {
        _importStatus = 'import_customers.csv not found.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Import/Export Customers')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _exportCustomers,
              child: Text('Export Customers to CSV'),
            ),
            if (_exportStatus != null) Text(_exportStatus!),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _importCustomers,
              child: Text('Import Customers from CSV'),
            ),
            if (_importStatus != null) Text(_importStatus!),
            SizedBox(height: 16),
            Text(
                'For import, place a file named import_customers.csv in the app directory.'),
          ],
        ),
      ),
    );
  }
}
