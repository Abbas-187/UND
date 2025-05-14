import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/inventory_movement_model.dart';

class InventoryReportPdfOptions {

  const InventoryReportPdfOptions({
    required this.startDate,
    required this.endDate,
    this.includeImages = false,
    this.includeCharts = true,
    this.includeDetails = true,
  });
  final DateTime startDate;
  final DateTime endDate;
  final bool includeImages;
  final bool includeCharts;
  final bool includeDetails;
}

class InventoryReportPdfService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<Uint8List> generateMovementReport({
    required List<InventoryMovementModel> movements,
    required InventoryReportPdfOptions options,
    List<Map<String, dynamic>> charts = const [], // [{title, imageBytes}]
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final widgets = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                'Inventory Movement Report',
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Text(
              'Date Range: ${_dateFormat.format(options.startDate)} - ${_dateFormat.format(options.endDate)}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            _buildSummarySection(movements),
            pw.SizedBox(height: 16),
            _buildMovementsTable(movements, options),
          ];

          // Insert charts if provided
          if (charts.isNotEmpty) {
            widgets.add(pw.SizedBox(height: 16));
            widgets.add(pw.Text('Charts',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 16)));
            for (final chart in charts) {
              if (chart['imageBytes'] != null &&
                  (chart['imageBytes'] as List<int>).isNotEmpty) {
                widgets.add(pw.SizedBox(height: 16));
                widgets.add(pw.Text(chart['title'] ?? '',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14)));
                widgets.add(pw.SizedBox(height: 8));
                widgets.add(
                  pw.Center(
                    child: pw.Image(
                      pw.MemoryImage(chart['imageBytes']),
                      width: 400,
                      height: 250,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                );
              }
            }
          }

          if (options.includeDetails) {
            widgets.add(pw.SizedBox(height: 16));
            widgets.add(_buildDetailsSection(movements));
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSummarySection(List<InventoryMovementModel> movements) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Total Movements: \\${movements.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          // Add more summary stats as needed
        ],
      ),
    );
  }

  pw.Widget _buildMovementsTable(List<InventoryMovementModel> movements,
      InventoryReportPdfOptions options) {
    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: [
        'Date',
        'Type',
        'Status',
        'From',
        'To',
        'Initiated By',
        'Approved By',
        'Items',
      ],
      data: movements
          .map((m) => [
                _dateFormat.format(m.timestamp),
                m.movementType.toString().split('.').last,
                m.approvalStatus.toString().split('.').last,
                m.sourceLocationName,
                m.destinationLocationName,
                m.initiatingEmployeeName,
                m.approverEmployeeName ?? '-',
                m.items.length.toString(),
              ])
          .toList(),
    );
  }

  pw.Widget _buildDetailsSection(List<InventoryMovementModel> movements) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Movement Details',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        ...movements.map((m) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ID: ${m.movementId}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Type: ${m.movementType.toString().split('.').last}'),
                  pw.Text('Date: ${_dateFormat.format(m.timestamp)}'),
                  pw.Text('From: ${m.sourceLocationName}'),
                  pw.Text('To: ${m.destinationLocationName}'),
                  pw.Text('Initiated By: ${m.initiatingEmployeeName}'),
                  if (m.approverEmployeeName != null)
                    pw.Text('Approved By: ${m.approverEmployeeName}'),
                  pw.Text(
                      'Status: ${m.approvalStatus.toString().split('.').last}'),
                  if (m.reasonNotes.isNotEmpty)
                    pw.Text('Notes: ${m.reasonNotes}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Items:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (final item in m.items)
                        pw.Bullet(
                          text:
                              '${item.productName} (Batch: ${item.batchLotNumber}, Qty: ${item.quantity} ${item.unitOfMeasurement})',
                        ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
