import 'package:mobile_scanner/mobile_scanner.dart';

enum ScanMode {
  item,
  location,
  batch,
}

class BarcodeScannerService {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  MobileScannerController get controller => _controller;

  Future<void> toggleTorch() async {
    await _controller.toggleTorch();
  }

  Future<void> switchCamera() async {
    await _controller.switchCamera();
  }

  void dispose() {
    _controller.dispose();
  }

  // Validate and format scanned result based on scan mode
  String? processScannedResult(String rawValue, ScanMode mode) {
    try {
      switch (mode) {
        case ScanMode.item:
          // For items, expects a valid SKU format
          // Example: "SKU-12345" or "ITEM-12345"
          if (RegExp(r'^(SKU|ITEM)-\d+$').hasMatch(rawValue)) {
            return rawValue;
          }
          return null;

        case ScanMode.location:
          // For locations, expects a valid location format
          // Example: "LOC-A1-B2-C3"
          if (RegExp(r'^LOC-[A-Z0-9]+-[A-Z0-9]+-[A-Z0-9]+$')
              .hasMatch(rawValue)) {
            return rawValue;
          }
          return null;

        case ScanMode.batch:
          // For batches, expects a valid batch number format
          // Example: "BATCH-20230501-001"
          if (RegExp(r'^BATCH-\d{8}-\d{3}$').hasMatch(rawValue)) {
            return rawValue;
          }
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}
