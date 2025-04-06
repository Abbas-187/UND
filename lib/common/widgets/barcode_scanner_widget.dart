import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../features/inventory/domain/services/barcode_scanner_service.dart';

typedef BarcodeResultCallback = void Function(String value);

class BarcodeScannerWidget extends StatefulWidget {

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    required this.scanMode,
    this.instructionText = 'Align the barcode within the frame',
  });
  final BarcodeResultCallback onBarcodeDetected;
  final ScanMode scanMode;
  final String instructionText;

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  bool _hasScanned = false;
  String? _lastScannedValue;
  bool _torchOn = false;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return; // Prevent multiple scans

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;

      final rawValue = barcode.rawValue!;
      final processedValue =
          _scannerService.processScannedResult(rawValue, widget.scanMode);

      if (processedValue != null) {
        // Valid barcode for this scan mode
        setState(() {
          _hasScanned = true;
          _lastScannedValue = processedValue;
        });

        widget.onBarcodeDetected(processedValue);

        // Vibrate to give feedback
        HapticFeedback.mediumImpact();

        // Automatically pop after successful scan
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });

        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_off : Icons.flash_on),
            onPressed: () async {
              await _scannerService.toggleTorch();
              setState(() {
                _torchOn = !_torchOn;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerService.controller,
                  onDetect: _onDetect,
                ),
                // Scanning overlay
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Instruction text
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.instructionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_lastScannedValue != null)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Detected: $_lastScannedValue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _scannerService.switchCamera();
                  },
                  icon: const Icon(Icons.flip_camera_ios),
                  label: const Text('Switch Camera'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
