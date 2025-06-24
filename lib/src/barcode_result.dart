import '../dart_barcode/dart_barcode.dart' as dart_barcode;

/// Simple barcode scan result
class BarcodeResult {
  /// The barcode text/data
  final String text;
  
  /// The barcode format (e.g., "Code128", "QR", "EAN-13")
  final String format;
  
  /// Product name from OpenFoodFacts (if available)
  final String? productName;
  
  /// Product brand from OpenFoodFacts (if available)
  final String? productBrand;
  
  const BarcodeResult({
    required this.text,
    required this.format,
    this.productName,
    this.productBrand,
  });
  
  /// Convert from internal dart_barcode result
  static BarcodeResult fromDartBarcodeResult(dart_barcode.BarcodeResult result) {
    return BarcodeResult(
      text: result.text,
      format: result.format,
      productName: null, // Not available in current version
      productBrand: null, // Not available in current version
    );
  }
  
  @override
  String toString() => 'BarcodeResult(text: $text, format: $format)';
  
  /// Whether this result has product information
  bool get hasProductInfo => productName != null || productBrand != null;
} 