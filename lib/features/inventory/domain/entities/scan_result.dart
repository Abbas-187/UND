import 'package:flutter/foundation.dart';

/// Types of barcodes
enum BarcodeType {
  /// Linear barcode (e.g., EAN, UPC, Code 128)
  barcode,

  /// 2D QR code
  qrCode
}

/// Represents a barcode or QR code scan result
class ScanResult {
  /// The data content of the scanned code
  final String code;

  /// The type of code (barcode or QR code)
  final BarcodeType type;

  /// The specific format of the barcode (e.g., CODE_128, EAN_13, QR_CODE)
  final String format;

  /// When the code was scanned
  final DateTime timestamp;

  /// Optional associated item ID if found in the system
  final String? itemId;

  /// Optional associated item name if found in the system
  final String? itemName;

  const ScanResult({
    required this.code,
    required this.type,
    required this.format,
    required this.timestamp,
    this.itemId,
    this.itemName,
  });

  /// Create a copy of this scan result with optional new values
  ScanResult copyWith({
    String? code,
    BarcodeType? type,
    String? format,
    DateTime? timestamp,
    String? itemId,
    String? itemName,
  }) {
    return ScanResult(
      code: code ?? this.code,
      type: type ?? this.type,
      format: format ?? this.format,
      timestamp: timestamp ?? this.timestamp,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
    );
  }

  /// Create a new scan result with item information
  ScanResult withItemInfo(String itemId, String itemName) {
    return copyWith(
      itemId: itemId,
      itemName: itemName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResult &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          type == other.type &&
          format == other.format;

  @override
  int get hashCode => code.hashCode ^ type.hashCode ^ format.hashCode;

  @override
  String toString() =>
      'ScanResult{code: $code, type: $type, format: $format, timestamp: $timestamp}';
}
