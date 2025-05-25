import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/inventory_movement_model.dart';
import '../../data/repositories/inventory_movement_repository.dart';
import '../../domain/usecases/get_inventory_movement_history_usecase.dart';

class InventoryAuditTrailScreen extends ConsumerStatefulWidget {
  const InventoryAuditTrailScreen({super.key});

  @override
  ConsumerState<InventoryAuditTrailScreen> createState() =>
      _InventoryAuditTrailScreenState();
}

class _InventoryAuditTrailScreenState
    extends ConsumerState<InventoryAuditTrailScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _itemId;
  String? _batchLotNumber;
  DateTime? _startDate;
  DateTime? _endDate;
  InventoryMovementType? _movementType;
  String? _employeeId;
  String? _referenceDocument;
  String? _locationId;
  final int _rowsPerPage = 10;
  int _page = 0;
  String? _sortField;
  bool _sortAsc = true;
  List<InventoryMovementModel> _cachedMovements = [];

  bool get _hasAccess => true; // TODO: Replace with real role check
  void _exportCSV(List<InventoryMovementModel> movements) async {
    final rows = [
      [
        'Timestamp',
        'Type',
        'Item(s)',
        'Batch',
        'Qty',
        'From',
        'To',
        'Employee',
        'Reason',
        'References'
      ],
      ...movements.map((m) => [
            m.timestamp.toIso8601String(),
            m.movementType.toString().split('.').last,
            m.items.map((i) => i.productName).join(', '),
            m.items.map((i) => i.batchLotNumber).join(', '),
            m.items.map((i) => i.quantity).join(', '),
            m.sourceLocationName,
            m.destinationLocationName,
            '${m.initiatingEmployeeName} (${m.initiatingEmployeeId})',
            m.reasonNotes,
            m.referenceDocuments?.join(', ') ?? '',
          ])
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(csv.codeUnits);
    await Printing.sharePdf(bytes: bytes, filename: 'audit_trail.csv');
  }

  void _exportExcel(List<InventoryMovementModel> movements) async {
    final excel = ex.Excel.createExcel();
    final sheet = excel['AuditTrail'];
    // Write header row
    sheet.appendRow([
      ex.TextCellValue('Timestamp'),
      ex.TextCellValue('Type'),
      ex.TextCellValue('Item(s)'),
      ex.TextCellValue('Batch'),
      ex.TextCellValue('Qty'),
      ex.TextCellValue('From'),
      ex.TextCellValue('To'),
      ex.TextCellValue('Employee'),
      ex.TextCellValue('Reason'),
      ex.TextCellValue('References'),
    ]);
    // Write data rows
    for (final m in movements) {
      sheet.appendRow([
        ex.TextCellValue(m.timestamp.toIso8601String()),
        ex.TextCellValue(m.movementType.toString().split('.').last),
        ex.TextCellValue(m.items.map((i) => i.productName).join(', ')),
        ex.TextCellValue(m.items.map((i) => i.batchLotNumber).join(', ')),
        ex.TextCellValue(m.items.map((i) => i.quantity).join(', ')),
        ex.TextCellValue(m.sourceLocationName ?? ''),
        ex.TextCellValue(m.destinationLocationName ?? ''),
        ex.TextCellValue(
            '${m.initiatingEmployeeName} (${m.initiatingEmployeeId})'),
        ex.TextCellValue(m.reasonNotes ?? ''),
        ex.TextCellValue(m.referenceDocuments?.join(', ') ?? ''),
      ]);
    }
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final bytes = Uint8List.fromList(fileBytes);
      await Printing.sharePdf(bytes: bytes, filename: 'audit_trail.xlsx');
    }
  }

  void _exportPDF(List<InventoryMovementModel> movements) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.TableHelper.fromTextArray(
          headers: [
            'Timestamp',
            'Type',
            'Item(s)',
            'Batch',
            'Qty',
            'From',
            'To',
            'Employee',
            'Reason',
            'References'
          ],
          data: movements
              .map((m) => [
                    m.timestamp.toIso8601String(),
                    m.movementType.toString().split('.').last,
                    m.items.map((i) => i.productName).join(', '),
                    m.items.map((i) => i.batchLotNumber).join(', '),
                    m.items.map((i) => i.quantity).join(', '),
                    m.sourceLocationName,
                    m.destinationLocationName,
                    '${m.initiatingEmployeeName} (${m.initiatingEmployeeId})',
                    m.reasonNotes,
                    m.referenceDocuments?.join(', ') ?? '',
                  ])
              .toList(),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => await pdf.save());
  }

  void _print(List<InventoryMovementModel> movements) {
    _exportPDF(movements); // Reuse PDF export for printing
  }

  void _showDetailDialog(InventoryMovementModel m) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Movement Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${m.movementId}'),
              Text('Timestamp: ${m.timestamp}'),
              Text('Type: ${m.movementType.toString().split('.').last}'),
              Text('From: ${m.sourceLocationName}'),
              Text('To: ${m.destinationLocationName}'),
              Text(
                  'Employee: ${m.initiatingEmployeeName} (${m.initiatingEmployeeId})'),
              Text('Reason: ${m.reasonNotes}'),
              Text('References: ${m.referenceDocuments?.join(', ') ?? ''}'),
              const Divider(),
              ...m.items.map((i) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item: ${i.productName} (${i.productId})'),
                      Text('Batch: ${i.batchLotNumber}'),
                      Text('Qty: ${i.quantity} ${i.unitOfMeasurement}'),
                      Text('Production: ${i.productionDate}'),
                      Text('Expiry: ${i.expirationDate}'),
                      Text(
                          'Quality: ${i.qualityStatus.toString().split('.').last}'),
                      const Divider(),
                    ],
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  List<InventoryMovementModel> _sortAndPaginate(
      List<InventoryMovementModel> movements) {
    List<InventoryMovementModel> sorted = List.from(movements);
    if (_sortField != null) {
      sorted.sort((a, b) {
        int cmp;
        switch (_sortField) {
          case 'timestamp':
            cmp = a.timestamp.compareTo(b.timestamp);
            break;
          case 'type':
            cmp =
                a.movementType.toString().compareTo(b.movementType.toString());
            break;
          default:
            cmp = 0;
        }
        return _sortAsc ? cmp : -cmp;
      });
    }
    final start = _page * _rowsPerPage;
    final end = (_page + 1) * _rowsPerPage;
    return sorted.sublist(start, end > sorted.length ? sorted.length : end);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAccess) {
      return const Scaffold(body: Center(child: Text('Access Denied')));
    }
    final movementHistoryProvider =
        FutureProvider<List<InventoryMovementModel>>((ref) async {
      final useCase = GetInventoryMovementHistoryUseCase(
        ref.read(inventoryMovementRepositoryProvider),
      );
      return useCase.execute(
        itemId: _itemId,
        batchLotNumber: _batchLotNumber,
        startDate: _startDate,
        endDate: _endDate,
        movementType: _movementType,
        initiatingEmployeeId: _employeeId,
        referenceDocument: _referenceDocument,
        locationId: _locationId,
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Audit Trail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Item ID'),
                      onChanged: (v) =>
                          setState(() => _itemId = v.isEmpty ? null : v),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Batch/Lot Number'),
                      onChanged: (v) => setState(
                          () => _batchLotNumber = v.isEmpty ? null : v),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Employee ID'),
                      onChanged: (v) =>
                          setState(() => _employeeId = v.isEmpty ? null : v),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Reference Document'),
                      onChanged: (v) => setState(
                          () => _referenceDocument = v.isEmpty ? null : v),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Location ID'),
                      onChanged: (v) =>
                          setState(() => _locationId = v.isEmpty ? null : v),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<InventoryMovementType>(
                      decoration:
                          const InputDecoration(labelText: 'Movement Type'),
                      value: _movementType,
                      items: InventoryMovementType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.toString().split('.').last),
                              ))
                          .toList(),
                      onChanged: (type) => setState(() => _movementType = type),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: InputDatePickerFormField(
                      fieldLabelText: 'Start Date',
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      onDateSubmitted: (date) =>
                          setState(() => _startDate = date),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: InputDatePickerFormField(
                      fieldLabelText: 'End Date',
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      onDateSubmitted: (date) =>
                          setState(() => _endDate = date),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                  onPressed: _cachedMovements.isEmpty
                      ? null
                      : () => _exportCSV(_cachedMovements),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  onPressed: _cachedMovements.isEmpty
                      ? null
                      : () => _exportExcel(_cachedMovements),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  onPressed: _cachedMovements.isEmpty
                      ? null
                      : () => _exportPDF(_cachedMovements),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  onPressed: _cachedMovements.isEmpty
                      ? null
                      : () => _print(_cachedMovements),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final asyncMovements = ref.watch(movementHistoryProvider);
                  return asyncMovements.when(
                    data: (movements) {
                      _cachedMovements = movements;
                      if (movements.isEmpty) {
                        return const Center(child: Text('No movements found.'));
                      }
                      final paged = _sortAndPaginate(movements);
                      return Column(
                        children: [
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _sortField = 'timestamp';
                                    _sortAsc = !_sortAsc;
                                  });
                                },
                                child: const Text('Sort by Date'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _sortField = 'type';
                                    _sortAsc = !_sortAsc;
                                  });
                                },
                                child: const Text('Sort by Type'),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: paged.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, idx) {
                                final m = paged[idx];
                                return ListTile(
                                  title: Text(
                                      '${m.movementType.toString().split('.').last} | ${m.timestamp.toLocal()}'),
                                  subtitle: Text(
                                      'Item(s): ${m.items.map((i) => i.productName).join(', ')}\nBatch: ${m.items.map((i) => i.batchLotNumber).join(', ')}\nQty: ${m.items.map((i) => i.quantity).join(', ')}\nFrom: ${m.sourceLocationName} To: ${m.destinationLocationName}\nBy: ${m.initiatingEmployeeName} (${m.initiatingEmployeeId})\nReason: ${m.reasonNotes}\nRefs: ${m.referenceDocuments?.join(', ') ?? ''}'),
                                  isThreeLine: true,
                                  onTap: () => _showDetailDialog(m),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _page > 0
                                    ? () => setState(() => _page--)
                                    : null,
                              ),
                              Text('Page ${_page + 1}'),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: (_page + 1) * _rowsPerPage <
                                        movements.length
                                    ? () => setState(() => _page++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
