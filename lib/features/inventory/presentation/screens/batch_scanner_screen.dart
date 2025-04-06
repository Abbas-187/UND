import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/models/inventory_item_model.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/services/barcode_scanning_service.dart';
import '../../domain/services/label_printing_service.dart';

final barcodeScanningServiceProvider = Provider<BarcodeScanningService>((ref) {
  final service = BarcodeScanningService();
  ref.onDispose(() => service.dispose());
  return service;
});

class BatchScannerScreen extends ConsumerStatefulWidget {
  const BatchScannerScreen({super.key});

  @override
  ConsumerState<BatchScannerScreen> createState() => _BatchScannerScreenState();
}

class _BatchScannerScreenState extends ConsumerState<BatchScannerScreen> {
  final List<InventoryItemModel> _scannedItems = [];
  bool _isScanning = false;
  bool _torchEnabled = false;
  LabelCodeType _selectedLabelType = LabelCodeType.barcode;

  @override
  void initState() {
    super.initState();
    final scanningService = ref.read(barcodeScanningServiceProvider);
    scanningService.initialize();
    scanningService.startBatchMode();

    // Listen for scan results
    scanningService.scanResults.listen(_handleScanResult);

    _isScanning = true;
  }

  void _handleScanResult(ScanResult result) {
    // In a real app, we would look up the inventory item from the database
    // For demo purposes, we'll create a mock item
    if (!mounted) return;

    // Show a snackbar when a code is scanned
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned: ${result.code}'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Add a mock item to the list - in a real app, we would fetch from DB
    setState(() {
      if (!_scannedItems.any((item) => item.id == result.code)) {
        _scannedItems.add(_createMockItem(result));
      }
    });
  }

  InventoryItemModel _createMockItem(ScanResult result) {
    // Extract the ID from the result.code (format is ITEM-{id})
    final id = result.code.startsWith('ITEM-')
        ? result.code.substring(5)
        : result.code;

    return InventoryItemModel(
      id: id,
      name: 'Item ${_scannedItems.length + 1}',
      category: 'Scanned Items',
      unit: 'pcs',
      quantity: 10,
      minimumQuantity: 5,
      reorderPoint: 3,
      location: 'Warehouse A',
      lastUpdated: DateTime.now(),
    );
  }

  void _toggleScanning() {
    final scanningService = ref.read(barcodeScanningServiceProvider);
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        scanningService.startBatchMode();
      } else {
        scanningService.endBatchMode();
      }
    });
  }

  void _toggleFlash() async {
    final scanningService = ref.read(barcodeScanningServiceProvider);
    await scanningService.toggleFlash();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  void _switchCamera() async {
    final scanningService = ref.read(barcodeScanningServiceProvider);
    await scanningService.switchCamera();
  }

  void _printLabels() async {
    if (_scannedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to print')),
      );
      return;
    }

    final labelService = LabelPrintingService();
    await labelService.printLabels(_scannedItems, codeType: _selectedLabelType);
  }

  void _clearItems() {
    setState(() {
      _scannedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanningService = ref.watch(barcodeScanningServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Barcode Scanner'),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(_torchEnabled ? Icons.flash_off : Icons.flash_on),
          ),
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_ios),
          ),
          PopupMenuButton<LabelCodeType>(
            icon: const Icon(Icons.more_vert),
            onSelected: (LabelCodeType type) {
              setState(() {
                _selectedLabelType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: LabelCodeType.barcode,
                child: Text('Barcodes Only'),
              ),
              const PopupMenuItem(
                value: LabelCodeType.qrCode,
                child: Text('QR Codes Only'),
              ),
              const PopupMenuItem(
                value: LabelCodeType.both,
                child: Text('Both Barcode & QR'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _isScanning
                ? MobileScanner(
                    controller: scanningService.scannerController,
                    fit: BoxFit.contain,
                    onDetect: (capture) {
                      // Handled by the service
                    },
                  )
                : const Center(
                    child: Text('Scanner paused'),
                  ),
          ),
          Expanded(
            flex: 2,
            child: _buildItemList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _toggleScanning,
              icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
              tooltip: _isScanning ? 'Pause Scanning' : 'Resume Scanning',
            ),
            IconButton(
              onPressed: _printLabels,
              icon: const Icon(Icons.print),
              tooltip: 'Print Labels',
            ),
            IconButton(
              onPressed: _clearItems,
              icon: const Icon(Icons.delete),
              tooltip: 'Clear Items',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    if (_scannedItems.isEmpty) {
      return const Center(
        child: Text('Scan inventory items to add them to the batch'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Scanned Items (${_scannedItems.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _scannedItems.length,
            itemBuilder: (context, index) {
              final item = _scannedItems[index];
              return ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(item.name),
                subtitle: Text('ID: ${item.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      _scannedItems.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
