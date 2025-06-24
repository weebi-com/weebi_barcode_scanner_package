library dart_barcode_base;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Helper to determine library path based on OS
String _libraryPath() {
  if (Platform.isWindows) {
    return 'rust_barcode_lib.dll';
  } else if (Platform.isAndroid) {
    return 'librust_barcode_lib.so';
  } else if (Platform.isLinux) {
    return 'librust_barcode_lib.so';
  } else if (Platform.isMacOS || Platform.isIOS) {
    return 'lib_rust_barcode_lib.dylib';
  } else {
    throw UnsupportedError('Unsupported platform for FFI library.');
  }
}

DynamicLibrary _loadNativeLibrary() {
  final libName = _libraryPath();
  // For desktop platforms, you might need to adjust the path
  // to where the compiled library is located.
  // Example for development:
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final devPath = '../rust-barcode-lib/target/release/$libName';
      if (File(devPath).existsSync()) {
          return DynamicLibrary.open(devPath);
      }
  }
  return DynamicLibrary.open(libName);
}

final DynamicLibrary _lib = _loadNativeLibrary();

/// Supported image formats for Rust processing
enum RustImageFormat {
  png,
  yuv,
  bgra8888,
  jpeg,
  yuv420,
}

/// FFI signature for process_image
typedef _ProcessImageNative = Pointer<Char> Function(
    Int32 imageFormat,
    Pointer<Uint8> data,
    IntPtr len,
    Uint32 width,
    Uint32 height,
    Uint32 bytesPerRow,
    Bool useSuperResolution);

typedef _ProcessImage = Pointer<Char> Function(
    int imageFormat,
    Pointer<Uint8> data,
    int len,
    int width,
    int height,
    int bytesPerRow,
    bool useSuperResolution);

final _processImage =
    _lib.lookupFunction<_ProcessImageNative, _ProcessImage>('process_image');

/// FFI signature for process_yuv420_image
typedef _ProcessYuv420ImageNative = Pointer<Char> Function(
  Pointer<Uint8> yData,
  IntPtr yLen,
  Pointer<Uint8> uData,
  IntPtr uLen,
  Pointer<Uint8> vData,
  IntPtr vLen,
  Uint32 width,
  Uint32 height,
  Uint32 uvRowStride,
  Uint32 uvPixelStride,
  Bool useSuperResolution,
);
typedef _ProcessYuv420Image = Pointer<Char> Function(
  Pointer<Uint8> yData,
  int yLen,
  Pointer<Uint8> uData,
  int uLen,
  Pointer<Uint8> vData,
  int vLen,
  int width,
  int height,
  int uvRowStride,
  int uvPixelStride,
  bool useSuperResolution,
);

final _processYuv420Image =
    _lib.lookupFunction<_ProcessYuv420ImageNative, _ProcessYuv420Image>(
        'process_yuv420_image');

/// FFI signature for sdk_init
typedef _SdkInitNative = Int32 Function(Pointer<Char> modelPath);
typedef _SdkInit = int Function(Pointer<Char> modelPath);

final _sdkInit = _lib.lookupFunction<_SdkInitNative, _SdkInit>('sdk_init');

/// FFI signature for free_rust_string
typedef _FreeRustStringNative = Void Function(Pointer<Char> ptr);
typedef _FreeRustString = void Function(Pointer<Char> ptr);

final _freeRustString =
    _lib.lookupFunction<_FreeRustStringNative, _FreeRustString>('free_rust_string');

/// Represents product information from OpenFoodFacts
class ProductInfo {
  final String? productName;
  final String? brand;
  final String? imageUrl;
  final String? category;
  final String? nutritionGrade;
  final String? error;
  final bool isLoading;

  const ProductInfo({
    this.productName,
    this.brand,
    this.imageUrl,
    this.category,
    this.nutritionGrade,
    this.error,
    this.isLoading = false,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      productName: json['product_name'],
      brand: json['brand'],
      imageUrl: json['image_url'],
      category: json['category'],
      nutritionGrade: json['nutrition_grade'],
      error: json['error'],
      isLoading: false,
    );
  }

  bool get hasError => error != null;
  bool get hasData => productName != null || brand != null || imageUrl != null;
  
  static const ProductInfo loading = ProductInfo(isLoading: true);
  
  ProductInfo withError(String error) => ProductInfo(error: error);
  
  ProductInfo withData({
    String? productName,
    String? brand,
    String? imageUrl,
    String? category,
    String? nutritionGrade,
  }) => ProductInfo(
    productName: productName,
    brand: brand,
    imageUrl: imageUrl,
    category: category,
    nutritionGrade: nutritionGrade,
  );
}

/// Normalizes a barcode according to OpenFoodFacts standards
Future<String> normalizeBarcode(String barcode) async {
  // Temporarily disabled - OpenFoodFacts integration not available
  return barcode; // Return original barcode unchanged
  
  /*
  final barcodePtr = barcode.toNativeUtf8();
  Pointer<Char> resultPtr = nullptr;
  
  try {
    resultPtr = _normalizeBarcode(barcodePtr.cast<Char>());
    if (resultPtr == nullptr) {
      return barcode; // Return original if normalization fails
    }
    
    final result = resultPtr.cast<Utf8>().toDartString();
    return result;
  } finally {
    malloc.free(barcodePtr);
    if (resultPtr != nullptr) {
      _freeProductInfoString(resultPtr);
    }
  }
  */
}

/// Fetches product information from OpenFoodFacts API
Future<ProductInfo> fetchProductInfo(String barcode) async {
  // Temporarily disabled - OpenFoodFacts integration not available
  return const ProductInfo(error: 'OpenFoodFacts integration temporarily disabled');
  
  /*
  final barcodePtr = barcode.toNativeUtf8();
  Pointer<Char> resultPtr = nullptr;
  
  try {
    resultPtr = _fetchProductInfo(barcodePtr.cast<Char>());
    if (resultPtr == nullptr) {
      return ProductInfo(error: 'Failed to fetch product information');
    }
    
    final jsonString = resultPtr.cast<Utf8>().toDartString();
    final result = jsonDecode(jsonString);
    return ProductInfo.fromJson(result);
  } catch (e) {
    return ProductInfo(error: 'Error parsing product information: $e');
  } finally {
    malloc.free(barcodePtr);
    if (resultPtr != nullptr) {
      _freeProductInfoString(resultPtr);
    }
  }
  */
}

/// Represents the raw detection data from the YOLO model
class BarcodeDetection {
  final int left;
  final int top;
  final int right;
  final int bottom;
  final double confidence;
  final String barcodeType;

  BarcodeDetection({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.confidence,
    required this.barcodeType,
  });

  factory BarcodeDetection.fromJson(Map<String, dynamic> json) {
    return BarcodeDetection(
      left: json['left'],
      top: json['top'],
      right: json['right'],
      bottom: json['bottom'],
      confidence: (json['confidence'] as num).toDouble(),
      barcodeType: json['barcode_type'],
    );
  }
}

/// Represents a barcode detection result
class BarcodeResult {
  final String text;
  final String format;
  final BarcodeDetection? detection;
  final Uint8List? image;
  final int? width;
  final int? height;

  BarcodeResult({
    required this.text,
    required this.format,
    this.detection,
    this.image,
    this.width,
    this.height,
  });

  factory BarcodeResult.fromJson(Map<String, dynamic> json) {
    return BarcodeResult(
      text: json['text'],
      format: json['format'],
      detection: json['detection'] != null
          ? BarcodeDetection.fromJson(json['detection'])
          : null,
    );
  }

  BarcodeResult copyWith({
    String? text,
    String? format,
    BarcodeDetection? detection,
    Uint8List? image,
    int? width,
    int? height,
  }) {
    return BarcodeResult(
      text: text ?? this.text,
      format: format ?? this.format,
      detection: detection ?? this.detection,
      image: image ?? this.image,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

/// Initialize the barcode SDK with the model file path
/// This must be called before any barcode processing functions
/// Returns true on success, false on error
Future<bool> initializeBarcodeSDK(String modelFilePath) async {
  final pathPointer = modelFilePath.toNativeUtf8();
  try {
    final result = _sdkInit(pathPointer.cast<Char>());
    return result == 0; // 0 means success in C
  } finally {
    malloc.free(pathPointer);
  }
}

/// Processes an image using the Rust library and returns detected barcodes.
Future<List<BarcodeResult>> processImage(
    {required RustImageFormat format,
    required Uint8List bytes,
    int width = 0,
    int height = 0,
    int bytesPerRow = 0,
    bool useSuperResolution = true}) async {
  // Allocate memory for the image bytes
  final pBytes = malloc.allocate<Uint8>(bytes.length);
  pBytes.asTypedList(bytes.length).setAll(0, bytes);

  Pointer<Char> resultPtr = nullptr;
  try {
    resultPtr = _processImage(
        format.index,
        pBytes,
        bytes.length,
        width,
        height,
        bytesPerRow,
        useSuperResolution);
    if (resultPtr == nullptr) {
      throw Exception('Rust process_image function returned a null pointer.');
    }

    final jsonString = resultPtr.cast<Utf8>().toDartString();
    final result = jsonDecode(jsonString);

    if (result['error'] != null) {
      throw Exception('Error from Rust library: ${result['error']}');
    }

    final barcodesJson = result['barcodes'] as List;
    return barcodesJson
        .map((json) => BarcodeResult.fromJson(json))
        .toList();
  } finally {
    // Free the memory
    malloc.free(pBytes);
    if (resultPtr != nullptr) {
      _freeRustString(resultPtr);
    }
  }
}

/// Processes YUV420 image data directly using the Rust library and returns detected barcodes.
/// This is more efficient than converting to JPEG first.
Future<List<BarcodeResult>> processYuv420Image({
  required Uint8List yPlane,
  required Uint8List uPlane,
  required Uint8List vPlane,
  required int width,
  required int height,
  required int uvRowStride,
  required int uvPixelStride,
  bool useSuperResolution = true,
}) async {
  // Allocate memory for the YUV planes
  final pYPlane = malloc.allocate<Uint8>(yPlane.length);
  final pUPlane = malloc.allocate<Uint8>(uPlane.length);
  final pVPlane = malloc.allocate<Uint8>(vPlane.length);
  
  pYPlane.asTypedList(yPlane.length).setAll(0, yPlane);
  pUPlane.asTypedList(uPlane.length).setAll(0, uPlane);
  pVPlane.asTypedList(vPlane.length).setAll(0, vPlane);

  Pointer<Char> resultPtr = nullptr;
  try {
    resultPtr = _processYuv420Image(
      pYPlane,
      yPlane.length,
      pUPlane,
      uPlane.length,
      pVPlane,
      vPlane.length,
      width,
      height,
      uvRowStride,
      uvPixelStride,
      useSuperResolution,
    );
    
    if (resultPtr == nullptr) {
      throw Exception('Rust process_yuv420_image function returned a null pointer.');
    }

    final jsonString = resultPtr.cast<Utf8>().toDartString();
    final result = jsonDecode(jsonString);

    if (result['error'] != null) {
      throw Exception('Error from Rust library: ${result['error']}');
    }

    final barcodesJson = result['barcodes'] as List;
    return barcodesJson
        .map((json) => BarcodeResult.fromJson(json))
        .toList();
  } finally {
    // Free the memory
    malloc.free(pYPlane);
    malloc.free(pUPlane);
    malloc.free(pVPlane);
    if (resultPtr != nullptr) {
      _freeRustString(resultPtr);
    }
  }
}



