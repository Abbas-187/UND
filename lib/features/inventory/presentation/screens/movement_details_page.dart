import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/services/inventory_movement_service.dart';
import '../../models/inventory_movement_item_model.dart';
import '../../models/inventory_movement_model.dart';
import '../../models/inventory_movement_type.dart';
import '../../providers/inventory_movement_providers.dart';
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
    final theme = Theme.of(context);
    final movementAsync =
        ref.watch(inventoryMovementProvider(widget.movementId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movement Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Generate PDF',
            onPressed: () => movementAsync.maybeWhen(
              data: (movement) => _generatePdf(movement),
              orElse: () {},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => movementAsync.maybeWhen(
              data: (movement) => _shareMovementDetails(movement),
              orElse: () {},
            ),
          ),
        ],
      ),
      body: movementAsync.when(
        data: (movement) => _buildMovementDetails(context, movement),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading movement details',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () {
                  ref.invalidate(inventoryMovementProvider(widget.movementId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovementDetails(
      BuildContext context, InventoryMovementModel movement) {
    final theme = Theme.of(context);

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
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      _buildStatusChip(context, movement.approvalStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${movement.movementId}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Date: ${DateFormat('MMM d, yyyy h:mm a').format(movement.timestamp)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Locations section
          _buildSectionTitle(context, 'Locations'),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source location
                  Text(
                    'Source:',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.sourceLocationName.isNotEmpty
                        ? movement.sourceLocationName
                        : 'N/A',
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (movement.sourceLocationId.isNotEmpty)
                    Text(
                      'ID: ${movement.sourceLocationId}',
                      style: theme.textTheme.bodySmall,
                    ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Destination location
                  Text(
                    'Destination:',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.destinationLocationName.isNotEmpty
                        ? movement.destinationLocationName
                        : 'N/A',
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (movement.destinationLocationId.isNotEmpty)
                    Text(
                      'ID: ${movement.destinationLocationId}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Personnel section
          _buildSectionTitle(context, 'Personnel'),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Initiator
                  Text(
                    'Initiated by:',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.initiatingEmployeeName,
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'ID: ${movement.initiatingEmployeeId}',
                    style: theme.textTheme.bodySmall,
                  ),

                  if (movement.approvalStatus != ApprovalStatus.PENDING) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Approver (if applicable)
                    Text(
                      'Reviewed by:',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movement.approverEmployeeName ?? 'N/A',
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (movement.approverEmployeeId != null)
                      Text(
                        'ID: ${movement.approverEmployeeId}',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes section
          if (movement.reasonNotes.isNotEmpty) ...[
            _buildSectionTitle(context, 'Notes'),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(movement.reasonNotes),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reference documents
          if (movement.referenceDocuments.isNotEmpty) ...[
            _buildSectionTitle(context, 'Reference Documents'),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: movement.referenceDocuments.map((doc) {
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
            'Items (${movement.items.length} ${movement.items.length == 1 ? 'item' : 'items'})',
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
          if (movement.approvalStatus == ApprovalStatus.PENDING)
            _buildApprovalButtons(context, movement),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ApprovalStatus status) {
    final theme = Theme.of(context);

    Color chipColor;
    IconData iconData;

    switch (status) {
      case ApprovalStatus.PENDING:
        chipColor = Colors.orange;
        iconData = Icons.pending;
        break;
      case ApprovalStatus.APPROVED:
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case ApprovalStatus.REJECTED:
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
    }

    return Chip(
      avatar: Icon(
        iconData,
        color: theme.colorScheme.onPrimary,
        size: 16,
      ),
      label: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildItemTile(BuildContext context, InventoryMovementItemModel item) {
    final theme = Theme.of(context);

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
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'Batch: ${item.batchLotNumber}',
                      style: theme.textTheme.bodyMedium,
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
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${item.quantity} ${item.unitOfMeasurement}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
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
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Chip(
                label: Text(item.qualityStatus.toString().split('.').last),
                backgroundColor: _getQualityStatusColor(item.qualityStatus),
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                ),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Production: ${DateFormat.yMd().format(item.productionDate)}',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Expiration: ${DateFormat.yMd().format(item.expirationDate)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalButtons(
      BuildContext context, InventoryMovementModel movement) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Reject'),
            onPressed: _isApproving
                ? null
                : () => _showApprovalDialog(context, movement, false),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Approve'),
            onPressed: _isApproving
                ? null
                : () => _showApprovalDialog(context, movement, true),
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
          isApproval ? ApprovalStatus.APPROVED : ApprovalStatus.REJECTED,
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
      ref.invalidate(inventoryMovementProvider(id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Movement successfully ${status == ApprovalStatus.APPROVED ? 'approved' : 'rejected'}'),
            backgroundColor:
                status == ApprovalStatus.APPROVED ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  Color _getQualityStatusColor(QualityStatus status) {
    switch (status) {
      case QualityStatus.REGULAR:
        return Colors.blue;
      case QualityStatus.QUARANTINE:
        return Colors.orange;
      case QualityStatus.APPROVED:
        return Colors.green;
      case QualityStatus.REJECTED:
        return Colors.red;
      default:
        return Colors.grey;
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
                      pw.Text('From: ${movement.sourceLocationName}'),
                      pw.Text('To: ${movement.destinationLocationName}'),
                      pw.Divider(),

                      // Personnel
                      pw.Text(
                        'Personnel',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                          'Initiated by: ${movement.initiatingEmployeeName}'),
                      if (movement.approverEmployeeName != null)
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
                              child: pw.Text(item.batchLotNumber),
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
                  ],
                ),

                // Notes if available
                if (movement.reasonNotes.isNotEmpty) ...[
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
                    child: pw.Text(movement.reasonNotes),
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

      // Open the PDF
      // await OpenFile.open(file.path);

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
      buffer.writeln('From: ${movement.sourceLocationName}');
      buffer.writeln('To: ${movement.destinationLocationName}');
      buffer.writeln('');

      buffer.writeln('PERSONNEL');
      buffer.writeln('Initiated by: ${movement.initiatingEmployeeName}');
      if (movement.approverEmployeeName != null) {
        buffer.writeln('Approved by: ${movement.approverEmployeeName}');
      }
      buffer.writeln('');

      buffer.writeln('ITEMS');
      for (int i = 0; i < movement.items.length; i++) {
        final item = movement.items[i];
        buffer.writeln('${i + 1}. ${item.productName}');
        buffer.writeln('   Batch: ${item.batchLotNumber}');
        buffer
            .writeln('   Quantity: ${item.quantity} ${item.unitOfMeasurement}');
        buffer.writeln('   Status: ${item.status.toString().split('.').last}');
        buffer.writeln('');
      }

      if (movement.reasonNotes.isNotEmpty) {
        buffer.writeln('NOTES');
        buffer.writeln(movement.reasonNotes);
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
