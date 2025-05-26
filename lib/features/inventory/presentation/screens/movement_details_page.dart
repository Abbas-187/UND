import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/models/quality_status.dart';
import '../../domain/services/inventory_movement_service.dart';
import '../providers/inventory_movement_provider.dart';
import '../widgets/movements/movement_approval_dialog.dart';

class MovementDetailsPage extends ConsumerStatefulWidget {
  const MovementDetailsPage({
    super.key,
    required this.movementId,
  });
  final String movementId;

  @override
  ConsumerState<MovementDetailsPage> createState() =>
      _MovementDetailsPageState();
}

class _MovementDetailsPageState extends ConsumerState<MovementDetailsPage> {
  bool _isApproving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final movementState = ref.watch(inventoryMovementProvider);
    final movement = movementState.currentMovement;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.movementDetails ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: l10n?.generatePdf ?? '',
            onPressed: movement != null ? () => _generatePdf(movement) : null,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n?.share ?? '',
            onPressed:
                movement != null ? () => _shareMovementDetails(movement) : null,
          ),
        ],
      ),
      body: movement == null
          ? const Center(child: CircularProgressIndicator())
          : _buildMovementDetails(context, movement),
    );
  }

  Widget _buildMovementDetails(
      BuildContext context, InventoryMovementModel movement) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and type
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          movement.movementType.toString().split('.').last,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      _buildStatusChip(context, movement.approvalStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n?.id ?? 'ID'}: ${movement.movementId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${l10n?.date ?? 'Date'}: ${DateFormat('MMM d, yyyy h:mm a').format(movement.timestamp)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Locations section
          _buildSectionTitle(context, l10n?.locations ?? ''),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source location
                  Text(
                    l10n?.source ?? '',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.sourceLocationName?.isNotEmpty == true
                        ? movement.sourceLocationName!
                        : l10n?.notAvailable ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if ((movement.sourceLocationId ?? '').isNotEmpty)
                    Text(
                      '${l10n?.id ?? 'ID'}: ${movement.sourceLocationId ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Destination location
                  Text(
                    l10n?.destination ?? '',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.destinationLocationName?.isNotEmpty == true
                        ? movement.destinationLocationName!
                        : l10n?.notAvailable ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if ((movement.destinationLocationId ?? '').isNotEmpty)
                    Text(
                      '${l10n?.id ?? 'ID'}: ${movement.destinationLocationId ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Personnel section
          _buildSectionTitle(context, l10n?.personnel ?? ''),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Initiator
                  Text(
                    l10n?.initiatedBy ?? '',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.initiatingEmployeeName ?? l10n?.notAvailable ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${l10n?.id ?? 'ID'}: ${movement.initiatingEmployeeId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  if (movement.approvalStatus != ApprovalStatus.pending) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Approver (if applicable)
                    Text(
                      l10n?.reviewedBy ?? '',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movement.approverEmployeeName ?? l10n?.notAvailable ?? '',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if ((movement.approverEmployeeId ?? '').isNotEmpty)
                      Text(
                        '${l10n?.id ?? 'ID'}: ${movement.approverEmployeeId ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes section
          if ((movement.reasonNotes ?? '').isNotEmpty) ...[
            _buildSectionTitle(context, l10n?.notes ?? ''),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(movement.reasonNotes ?? ''),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reference documents
          if ((movement.referenceDocuments ?? []).isNotEmpty) ...[
            _buildSectionTitle(context, l10n?.referenceDocuments ?? ''),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (movement.referenceDocuments ?? []).map((doc) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.description, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(doc)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Items section
          _buildSectionTitle(
            context,
            'Items (${movement.items.length})',
          ),
          Card(
            margin: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movement.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildItemTile(context, movement.items[index]);
              },
            ),
          ),

          const SizedBox(height: 32),

          // Approval actions
          if (movement.approvalStatus == ApprovalStatus.pending)
            _buildApprovalButtons(context, movement),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ApprovalStatus status) {
    Color chipColor;
    IconData iconData;

    switch (status) {
      case ApprovalStatus.pending:
        chipColor = Colors.orange;
        iconData = Icons.pending;
        break;
      case ApprovalStatus.approved:
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case ApprovalStatus.rejected:
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
      case ApprovalStatus.cancelled:
        chipColor = Colors.grey;
        iconData = Icons.block;
        break;
    }

    return Chip(
      avatar: Icon(
        iconData,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 16,
      ),
      label: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildItemTile(BuildContext context, InventoryMovementItemModel item) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${l10n?.batch ?? 'Batch'}: ${item.batchLotNumber ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${item.quantity} ${item.unitOfMeasurement}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(item.status.toString().split('.').last),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Chip(
                label: Text(item.qualityStatus.toString().split('.').last),
                backgroundColor: _getQualityStatusColor(
                    _parseQualityStatus(item.qualityStatus)),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                ),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n?.production ?? 'Production'}: ${DateFormat.yMd().format(item.productionDate ?? DateTime.now())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${l10n?.expiration ?? 'Expiration'}: ${DateFormat.yMd().format(item.expirationDate ?? DateTime.now())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getQualityStatusColor(QualityStatus status) {
    switch (status) {
      case QualityStatus.excellent:
        return Colors.green;
      case QualityStatus.good:
        return Colors.blue;
      case QualityStatus.acceptable:
        return Colors.teal;
      case QualityStatus.warning:
        return Colors.orange;
      case QualityStatus.critical:
        return Colors.deepOrange;
      case QualityStatus.rejected:
        return Colors.red;
      case QualityStatus.available:
        return Colors.lightBlue;
      case QualityStatus.pendingInspection:
        return Colors.grey;
      case QualityStatus.rework:
        return Colors.deepOrange;
      case QualityStatus.blocked:
        return Colors.brown;
    }
  }

  QualityStatus _parseQualityStatus(String? status) {
    switch (status) {
      case 'excellent':
        return QualityStatus.excellent;
      case 'good':
        return QualityStatus.good;
      case 'acceptable':
        return QualityStatus.acceptable;
      case 'warning':
        return QualityStatus.warning;
      case 'critical':
        return QualityStatus.critical;
      case 'rejected':
        return QualityStatus.rejected;
      default:
        return QualityStatus.acceptable;
    }
  }

  Widget _buildApprovalButtons(
      BuildContext context, InventoryMovementModel movement) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle),
            label: Text(l10n?.approve ?? ''),
            onPressed: _isApproving
                ? null
                : () => _showApprovalDialog(context, movement, true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cancel),
            label: Text(l10n?.reject ?? ''),
            onPressed: _isApproving
                ? null
                : () => _showApprovalDialog(context, movement, false),
          ),
        ),
      ],
    );
  }

  void _showApprovalDialog(
    BuildContext context,
    InventoryMovementModel movement,
    bool isApproval,
  ) {
    showDialog(
      context: context,
      builder: (context) => MovementApprovalDialog(
        movementId: movement.movementId,
        isApproval: isApproval,
        onApprove: (approverId, approverName, notes) =>
            _approveOrRejectMovement(
          movement.movementId,
          isApproval ? ApprovalStatus.approved : ApprovalStatus.rejected,
          approverId,
          approverName,
          notes,
        ),
      ),
    );
  }

  Future<void> _approveOrRejectMovement(
    String id,
    ApprovalStatus status,
    String approverId,
    String approverName,
    String notes,
  ) async {
    setState(() {
      _isApproving = true;
    });

    try {
      final service = ref.read(inventoryMovementServiceProvider);
      await service.approveOrRejectMovement(
          id, status, approverId, approverName);

      // Invalidate the provider to refresh the data
      ref.invalidate(inventoryMovementProvider);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == ApprovalStatus.approved
                ? (l10n?.movementSuccessfullyApproved ?? '')
                : (l10n?.movementSuccessfullyRejected ?? '')),
            backgroundColor:
                status == ApprovalStatus.approved ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10n?.error != null ? '${l10n!.error}: $e' : 'Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApproving = false;
        });
      }
    }
  }

  Future<void> _generatePdf(InventoryMovementModel movement) async {
    try {
      // Request storage permission if needed
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          return;
        }
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add pages to the document
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Header(
                  level: 0,
                  child: pw.Text('Inventory Movement Report'),
                ),
                pw.SizedBox(height: 20),

                // Movement details
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Movement Type: ${movement.movementType.toString().split('.').last}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Status: ${movement.approvalStatus.toString().split('.').last}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text('ID: ${movement.movementId}'),
                      pw.Text(
                          'Date: ${DateFormat('MMM d, yyyy h:mm a').format(movement.timestamp)}'),
                      pw.Divider(),

                      // Locations
                      pw.Text(
                        'Locations',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('From: ${movement.sourceLocationName ?? ''}'),
                      pw.Text('To: ${movement.destinationLocationName ?? ''}'),
                      pw.Divider(),

                      // Personnel
                      pw.Text(
                        'Personnel',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                          'Initiated by: ${movement.initiatingEmployeeName ?? ''}'),
                      if ((movement.approverEmployeeName ?? '').isNotEmpty)
                        pw.Text(
                            'Approved by: ${movement.approverEmployeeName}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Items table
                pw.Text(
                  'Items',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Table header
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Product',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Batch',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Quantity',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Status',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),

                    // Table rows for each item
                    ...movement.items.map((item) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(item.productName),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(item.batchLotNumber ?? ''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                  '${item.quantity} ${item.unitOfMeasurement}'),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                  item.status.toString().split('.').last),
                            ),
                          ],
                        )),
                  ].toList(),
                ),

                // Notes if available
                if ((movement.reasonNotes ?? '').isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Notes',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Text(movement.reasonNotes ?? ''),
                  ),
                ],

                // Footer with date and page number
                pw.Positioned(
                  bottom: 20,
                  right: 0,
                  child: pw.Text(
                    'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF document
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/movement_${movement.movementId}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share the PDF instead of just opening it
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Inventory Movement ${movement.movementId}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully'),
          ),
        );
      }

      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareMovementDetails(InventoryMovementModel movement) async {
    try {
      // Create a text summary of the movement
      final buffer = StringBuffer();

      buffer.writeln('INVENTORY MOVEMENT DETAILS');
      buffer.writeln('-------------------------');
      buffer.writeln('ID: ${movement.movementId}');
      buffer
          .writeln('Type: ${movement.movementType.toString().split('.').last}');
      buffer.writeln(
          'Status: ${movement.approvalStatus.toString().split('.').last}');
      buffer.writeln(
          'Date: ${DateFormat('MMM d, yyyy h:mm a').format(movement.timestamp)}');
      buffer.writeln('');

      buffer.writeln('LOCATIONS');
      buffer.writeln('From: ${movement.sourceLocationName ?? ''}');
      buffer.writeln('To: ${movement.destinationLocationName ?? ''}');
      buffer.writeln('');

      buffer.writeln('PERSONNEL');
      buffer.writeln('Initiated by: ${movement.initiatingEmployeeName ?? ''}');
      if ((movement.approverEmployeeName ?? '').isNotEmpty) {
        buffer.writeln('Approved by: ${movement.approverEmployeeName}');
      }
      buffer.writeln('');

      buffer.writeln('ITEMS');
      for (int i = 0; i < movement.items.length; i++) {
        final item = movement.items[i];
        buffer.writeln('${i + 1}. ${item.productName}');
        buffer.writeln('   Batch: ${item.batchLotNumber ?? ''}');
        buffer
            .writeln('   Quantity: ${item.quantity} ${item.unitOfMeasurement}');
        buffer.writeln('   Status: ${item.status.toString().split('.').last}');
        buffer.writeln('');
      }

      if ((movement.reasonNotes ?? '').isNotEmpty) {
        buffer.writeln('NOTES');
        buffer.writeln(movement.reasonNotes ?? '');
      }

      // Share the text
      await Share.share(buffer.toString(),
          subject: 'Inventory Movement ${movement.movementId}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing movement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
