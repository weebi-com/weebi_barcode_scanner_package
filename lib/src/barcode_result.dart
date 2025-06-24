import '../dart_barcode/dart_barcode.dart' as dart_barcode;

/// Represents a barcode scanning result
class BarcodeResult {
  /// The decoded text content of the barcode
  final String text;
  
  /// The barcode format (e.g., 'EAN-13', 'QR_CODE', etc.)
  final String format;
  
  /// Product name from OpenFoodFacts lookup (optional)
  final String? productName;
  
  /// Product brand from OpenFoodFacts lookup (optional)
  final String? productBrand;
  
  /// Additional product information (optional)
  final Map<String, dynamic>? productInfo;
  
  /// Confidence score of the detection (0.0 to 1.0)
  final double? confidence;
  
  /// Location of the barcode in the image (optional)
  final Map<String, int>? location;
  
  const BarcodeResult({
    required this.text,
    required this.format,
    this.productName,
    this.productBrand,
    this.productInfo,
    this.confidence,
    this.location,
  });
  
  /// Convert from internal dart_barcode result
  static BarcodeResult fromDartBarcodeResult(dart_barcode.BarcodeResult result) {
    return BarcodeResult(
      text: result.text,
      format: result.format,
      productName: null, // Not available in current version
      productBrand: null, // Not available in current version
      productInfo: null, // Not available in current version
      confidence: null, // Not available in current version
      location: null, // Not available in current version
    );
  }
  
  /// Whether this result has product information
  bool get hasProductInfo => productName != null || productBrand != null;
  
  /// Create a copy with updated fields
  BarcodeResult copyWith({
    String? text,
    String? format,
    String? productName,
    String? productBrand,
    Map<String, dynamic>? productInfo,
    double? confidence,
    Map<String, int>? location,
  }) {
    return BarcodeResult(
      text: text ?? this.text,
      format: format ?? this.format,
      productName: productName ?? this.productName,
      productBrand: productBrand ?? this.productBrand,
      productInfo: productInfo ?? this.productInfo,
      confidence: confidence ?? this.confidence,
      location: location ?? this.location,
    );
  }
  
  @override
  String toString() {
    return 'BarcodeResult(text: $text, format: $format)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BarcodeResult &&
        other.text == text &&
        other.format == format &&
        other.productName == productName &&
        other.productBrand == productBrand;
  }
  
  @override
  int get hashCode {
    return text.hashCode ^
        format.hashCode ^
        productName.hashCode ^
        productBrand.hashCode;
  }
} 