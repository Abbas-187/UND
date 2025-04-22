import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../entities/purchase_order.dart';

/// Service responsible for generating and printing purchase order documents
class PurchaseOrderPrintService {
  /// Generate and print a purchase order document
  Future<void> printPurchaseOrder(PurchaseOrder purchaseOrder) async {
    final pdf = await _generatePurchaseOrderPdf(purchaseOrder);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf,
      name: 'PO_${purchaseOrder.poNumber}.pdf',
      format: PdfPageFormat.a4,
    );
  }

  /// Generate a PDF document for the purchase order
  Future<Uint8List> _generatePurchaseOrderPdf(
      PurchaseOrder purchaseOrder) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    final fontItalic = await PdfGoogleFonts.nunitoLightItalic();

    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with company logo and PO details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PURCHASE ORDER',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 24,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'PO #${purchaseOrder.poNumber}',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Date: ${dateFormat.format(purchaseOrder.requestDate)}',
                        style: pw.TextStyle(font: font),
                      ),
                      if (purchaseOrder.approvalDate != null)
                        pw.Text(
                          'Approval Date: ${dateFormat.format(purchaseOrder.approvalDate!)}',
                          style: pw.TextStyle(font: font),
                        ),
                    ],
                  ),
                  // Company Logo Placeholder - replace with actual logo if available
                  pw.Container(
                    width: 120,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'COMPANY LOGO',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Supplier and Company Information
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Supplier Info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SUPPLIER:',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          purchaseOrder.supplierName,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'ID: ${purchaseOrder.supplierId}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Company Info (Placeholder - replace with actual company details)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SHIP TO:',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Your Company Name',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '123 Business Street\nCity, State ZIP\nPhone: (123) 456-7890',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Order Details
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    color: PdfColors.grey200,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text(
                            'DESCRIPTION',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'QUANTITY',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'UNIT PRICE',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'AMOUNT',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Items list
                  ...purchaseOrder.items.map((item) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.grey300,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                flex: 5,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      item.itemName,
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (item.notes != null &&
                                        item.notes!.isNotEmpty)
                                      pw.SizedBox(height: 2),
                                    if (item.notes != null &&
                                        item.notes!.isNotEmpty)
                                      pw.Text(
                                        'Notes: ${item.notes}',
                                        style: pw.TextStyle(
                                          font: fontItalic,
                                          fontSize: 9,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  '${item.quantity} ${item.unit}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  currencyFormat.format(item.unitPrice),
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  currencyFormat.format(item.totalPrice),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Required by: ${dateFormat.format(item.requiredByDate)}',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 8,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Total
                  pw.Container(
                    padding: const pw.EdgeInsets.only(top: 12, bottom: 12),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 9,
                          child: pw.Text(
                            'TOTAL',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            currencyFormat.format(purchaseOrder.totalAmount),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Purpose information
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PURPOSE',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Reason for Request:',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      purchaseOrder.reasonForRequest,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Intended Use:',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      purchaseOrder.intendedUse,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Quantity Justification:',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      purchaseOrder.quantityJustification,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Approval section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REQUESTED BY:',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(width: 1),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        purchaseOrder.requestedBy,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  if (purchaseOrder.approvedBy != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'APPROVED BY:',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 10,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Container(
                          width: 120,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 1),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          purchaseOrder.approvedBy!,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 40),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'THIS IS AN OFFICIAL PURCHASE ORDER',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

// Provider for the PurchaseOrderPrintService
final purchaseOrderPrintServiceProvider =
    Provider<PurchaseOrderPrintService>((ref) {
  return PurchaseOrderPrintService();
});
