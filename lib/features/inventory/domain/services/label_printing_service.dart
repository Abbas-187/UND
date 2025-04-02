import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../data/models/inventory_item_model.dart';

class LabelPrintingService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Generate PDF document containing labels for the given inventory items
  Future<Uint8List> generateLabelsPdf(List<InventoryItemModel> items) async {
    final pdf = pw.Document();

    // Create a 2x2 grid of labels per page (4 labels per page)
    final int labelsPerRow = 2;
    final int rowsPerPage = 2;
    final int labelsPerPage = labelsPerRow * rowsPerPage;

    // Split items into pages
    for (int pageStart = 0;
        pageStart < items.length;
        pageStart += labelsPerPage) {
      final pageItems = items.skip(pageStart).take(labelsPerPage).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            // Create a grid layout
            return pw.GridView(
              crossAxisCount: labelsPerRow,
              childAspectRatio: 1.5, // Width to height ratio
              children: List.generate(pageItems.length, (index) {
                return _buildLabelWidget(pageItems[index]);
              }),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// Build a single label widget
  pw.Widget _buildLabelWidget(InventoryItemModel item) {
    // Create barcode data - we'll use a format like "ITEM-{id}"
    final barcodeData = 'ITEM-${item.id}';

    return pw.Container(
      margin: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Item name and category
          pw.Text(
            item.name,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.Text(
            'Category: ${item.category}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 4),

          // Barcode
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: barcodeData,
              width: 120,
              height: 50,
            ),
          ),
          pw.Center(
            child: pw.Text(
              barcodeData,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 4),

          // Item details
          pw.Text('Unit: ${item.unit}', style: const pw.TextStyle(fontSize: 8)),
          if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
            pw.Text('Batch: ${item.batchNumber}',
                style: const pw.TextStyle(fontSize: 8)),
          if (item.expiryDate != null)
            pw.Text(
              'Expiry: ${_dateFormat.format(item.expiryDate!)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          pw.Text(
            'Location: ${item.location}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  /// Print the generated PDF
  Future<void> printLabels(List<InventoryItemModel> items) async {
    final pdf = await generateLabelsPdf(items);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf,
      name: 'Inventory_Labels_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Share the generated PDF
  Future<void> shareLabelsPdf(List<InventoryItemModel> items) async {
    final pdf = await generateLabelsPdf(items);
    await Printing.sharePdf(
      bytes: pdf,
      filename: 'Inventory_Labels_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
