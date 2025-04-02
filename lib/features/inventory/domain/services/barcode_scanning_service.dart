import 'package:mobile_scanner/mobile_scanner.dart' as scanner;
import '../entities/scan_result.dart';
import 'dart:async';

/// Service for managing barcode and QR code scanning
class BarcodeScanningService {
  /// Controller for mobile scanner
  final scanner.MobileScannerController _scannerController =
      scanner.MobileScannerController(
    detectionSpeed: scanner.DetectionSpeed.normal,
    facing: scanner.CameraFacing.back,
    torchEnabled: false,
  );

  /// Getter for the scanner controller
  scanner.MobileScannerController get scannerController => _scannerController;

  /// Stream controller to emit scan results
  final StreamController<ScanResult> _scanResultController =
      StreamController<ScanResult>.broadcast();

  /// Stream of scan results
  Stream<ScanResult> get scanResults => _scanResultController.stream;

  /// List to keep track of scanned barcodes in batch mode
  final List<ScanResult> _batchResults = [];

  /// Whether we're in batch scanning mode
  bool _batchModeActive = false;

  /// Get batch scan mode status
  bool get isBatchModeActive => _batchModeActive;

  /// Get current batch results
  List<ScanResult> get batchResults => List.unmodifiable(_batchResults);

  /// Initialize the service and start listening
  void initialize() {
    _scannerController.barcodes.listen((barcodeCapture) {
      if (barcodeCapture.barcodes.isEmpty) return;

      final barcode = barcodeCapture.barcodes.first;

      // Ignore if no raw value
      if (barcode.rawValue == null) return;

      final rawValue = barcode.rawValue!;
      final barcodeType = _mapToBarcodeType(barcode.format);
      final scanResult = ScanResult(
        code: rawValue,
        type: barcodeType,
        format: barcode.format.name,
        timestamp: DateTime.now(),
      );

      // For batch mode, check if we've already scanned this one
      if (_batchModeActive) {
        if (!_batchResults.any((result) => result.code == rawValue)) {
          _batchResults.add(scanResult);
        }
      }

      // Always emit the result to the stream
      _scanResultController.add(scanResult);
    });
  }

  /// Map Mobile Scanner barcode format to our custom type
  BarcodeType _mapToBarcodeType(scanner.BarcodeFormat format) {
    switch (format) {
      case scanner.BarcodeFormat.qrCode:
        return BarcodeType.qrCode;
      default:
        return BarcodeType.barcode;
    }
  }

  /// Start batch scanning mode
  void startBatchMode() {
    _batchModeActive = true;
    _batchResults.clear();
  }

  /// End batch scanning mode and return the results
  List<ScanResult> endBatchMode() {
    _batchModeActive = false;
    final results = List<ScanResult>.from(_batchResults);
    _batchResults.clear();
    return results;
  }

  /// Toggle the device's flashlight
  Future<void> toggleFlash() async {
    await _scannerController.toggleTorch();
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    await _scannerController.switchCamera();
  }

  /// Dispose resources
  void dispose() {
    _scannerController.dispose();
    _scanResultController.close();
  }
}
