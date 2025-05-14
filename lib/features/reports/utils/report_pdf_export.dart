import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPdfExport {
  static Future<pw.Font> _loadNotoSansFont() async {
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<void> exportStockReportPdf({
    required BuildContext context,
    required List<Map<String, dynamic>> data,
    String? categoryFilter,
    Uint8List? chartImage,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final ttf = await _loadNotoSansFont();
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
          italic: ttf,
          boldItalic: ttf,
        ),
        build: (context) => [
          pw.Text('Stock Report',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.SizedBox(height: 8),
          pw.Text('Date: ${DateFormat.yMMMMd().format(now)}',
              style: pw.TextStyle(font: ttf)),
          if (categoryFilter != null)
            pw.Text('Category: $categoryFilter',
                style: pw.TextStyle(font: ttf)),
          pw.SizedBox(height: 16),
          if (chartImage != null)
            pw.Center(child: pw.Image(pw.MemoryImage(chartImage), height: 200)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Item', 'Category', 'Quantity', 'Unit'],
            data: data
                .map((row) => [
                      row['name'].toString(),
                      row['category'].toString(),
                      row['quantity'].toString(),
                      row['unit'].toString(),
                    ])
                .toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> exportExpiryReportPdf({
    required BuildContext context,
    required List<Map<String, dynamic>> data,
    String? statusFilter,
    Uint8List? chartImage,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final ttf = await _loadNotoSansFont();
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
          italic: ttf,
          boldItalic: ttf,
        ),
        build: (context) => [
          pw.Text('Expiry Status Report',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.SizedBox(height: 8),
          pw.Text('Date: ${DateFormat.yMMMMd().format(now)}',
              style: pw.TextStyle(font: ttf)),
          if (statusFilter != null)
            pw.Text('Status: $statusFilter', style: pw.TextStyle(font: ttf)),
          pw.SizedBox(height: 16),
          if (chartImage != null)
            pw.Center(child: pw.Image(pw.MemoryImage(chartImage), height: 200)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Item', 'Expiry Date', 'Status'],
            data: data
                .map((row) => [
                      row['name'].toString(),
                      row['expiryDate']?.toString() ?? '-',
                      row['status'].toString(),
                    ])
                .toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> exportValuationReportPdf({
    required BuildContext context,
    required List<Map<String, dynamic>> data,
    String? categoryFilter,
    Uint8List? chartImage,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final ttf = await _loadNotoSansFont();
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
          italic: ttf,
          boldItalic: ttf,
        ),
        build: (context) => [
          pw.Text('Valuation Report',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.SizedBox(height: 8),
          pw.Text('Date: ${DateFormat.yMMMMd().format(now)}',
              style: pw.TextStyle(font: ttf)),
          if (categoryFilter != null)
            pw.Text('Category: $categoryFilter',
                style: pw.TextStyle(font: ttf)),
          pw.SizedBox(height: 16),
          if (chartImage != null)
            pw.Center(child: pw.Image(pw.MemoryImage(chartImage), height: 200)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: [
              'Item',
              'Category',
              'Quantity',
              'Unit',
              'Unit Cost (﷼)',
              'Total Value (﷼)'
            ],
            data: data
                .map((row) => [
                      row['name'].toString(),
                      row['category'].toString(),
                      row['quantity'].toString(),
                      row['unit'].toString(),
                      row['unitCost'].toString(),
                      row['totalValue'].toString(),
                    ])
                .toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> exportMovementsReportPdf({
    required BuildContext context,
    required List<Map<String, dynamic>> data,
    String? breakdown,
    DateTimeRange? dateRange,
    Uint8List? chartImage,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final ttf = await _loadNotoSansFont();
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
          italic: ttf,
          boldItalic: ttf,
        ),
        build: (context) => [
          pw.Text('Movements Report',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.SizedBox(height: 8),
          pw.Text('Date: ${DateFormat.yMMMMd().format(now)}',
              style: pw.TextStyle(font: ttf)),
          if (breakdown != null)
            pw.Text('Breakdown: $breakdown', style: pw.TextStyle(font: ttf)),
          if (dateRange != null)
            pw.Text(
                'Date Range: ${DateFormat.yMd().format(dateRange.start)} - ${DateFormat.yMd().format(dateRange.end)}',
                style: pw.TextStyle(font: ttf)),
          pw.SizedBox(height: 16),
          if (chartImage != null)
            pw.Center(child: pw.Image(pw.MemoryImage(chartImage), height: 200)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: [
              'Movement ID',
              'Date',
              'Type',
              'Status',
              'Item',
              'Quantity',
              'Unit',
              'Source',
              'Destination',
            ],
            data: data
                .map((row) => [
                      row['movementId'].toString(),
                      row['timestamp'].toString().substring(0, 16),
                      row['type'].toString(),
                      row['status'].toString(),
                      row['item'].toString(),
                      row['quantity'].toString(),
                      row['unit'].toString(),
                      row['source'].toString(),
                      row['destination'].toString(),
                    ])
                .toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
