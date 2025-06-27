import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'models/barcode_result.dart';
import 'models/image_format.dart';
import 'utils/model_manager.dart';

/// Main barcode detection class providing high-level API
class BarcodeDetector {
  static DynamicLibrary? _lib;
  static bool _initialized = false;

  // FFI function signatures
  static late final _ProcessImage _processImage;
  static late final _ProcessYuv420Image _processYuv420Image;
  static late final _SdkInit _sdkInit;
  static late final _FreeRustString _freeRustString;

  /// Initialize the barcode SDK with the model file path
  /// This must be called before any barcode processing functions
  /// Returns true on success, false on error
  static Future<bool> initialize(String modelFilePath) async {
    if (_initialized) return true;

    try {
      _lib = _loadNativeLibrary();
      _bindFunctions();
      
      final pathPointer = modelFilePath.toNativeUtf8();
      try {
        final result = _sdkInit(pathPointer.cast<Char>());
        _initialized = result == 0; // 0 means success in C
        return _initialized;
      } finally {
        malloc.free(pathPointer);
      }
    } catch (e) {
      return false;
    }
  }

  /// Initialize the barcode SDK with automatic model download if needed
  /// If modelPath is null, uses default location in app documents
  /// Downloads model from Hugging Face if not found locally
  /// Throws exception if model not found and download fails
  static Future<void> initializeOrDownload([String? modelPath]) async {
    if (_initialized) return;

    try {
      // Use provided path or default
      final finalModelPath = modelPath ?? await ModelManager.getDefaultModelPath();
      
      // Ensure model exists (download if needed)
      await ModelManager.ensureModel(finalModelPath);
      
      // Initialize SDK
      final success = await initialize(finalModelPath);
      if (!success) {
        throw Exception('Failed to initialize barcode SDK with model: $finalModelPath');
      }
      
    } catch (e) {
      throw Exception('Failed to initialize barcode detector: $e');
    }
  }

  /// Process an image and return detected barcodes
  static Future<List<BarcodeResult>> processImage({
    required ImageFormat format,
    required Uint8List bytes,
    int width = 0,
    int height = 0,
    int bytesPerRow = 0,
    bool useSuperResolution = true,
  }) async {
    if (!_initialized) {
      throw StateError('BarcodeDetector not initialized. Call initialize() first.');
    }

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
        useSuperResolution,
      );
      
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

  /// Process YUV420 image data directly
  /// This is more efficient than converting to JPEG first
  static Future<List<BarcodeResult>> processYuv420Image({
    required Uint8List yPlane,
    required Uint8List uPlane,
    required Uint8List vPlane,
    required int width,
    required int height,
    required int uvRowStride,
    required int uvPixelStride,
    bool useSuperResolution = true,
  }) async {
    if (!_initialized) {
      throw StateError('BarcodeDetector not initialized. Call initialize() first.');
    }

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

  /// Check if the SDK is initialized
  static bool get isInitialized => _initialized;

  // Private helper methods
  static String _libraryPath() {
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

  static DynamicLibrary _loadNativeLibrary() {
    final libName = _libraryPath();
    // For desktop platforms, check development path first
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final devPath = '../rust-barcode-lib/target/release/$libName';
      if (File(devPath).existsSync()) {
        return DynamicLibrary.open(devPath);
      }
    }
    return DynamicLibrary.open(libName);
  }

  static void _bindFunctions() {
    _processImage = _lib!.lookupFunction<_ProcessImageNative, _ProcessImage>('process_image');
    _processYuv420Image = _lib!.lookupFunction<_ProcessYuv420ImageNative, _ProcessYuv420Image>('process_yuv420_image');
    _sdkInit = _lib!.lookupFunction<_SdkInitNative, _SdkInit>('sdk_init');
    _freeRustString = _lib!.lookupFunction<_FreeRustStringNative, _FreeRustString>('free_rust_string');
  }
}

// FFI type definitions
typedef _ProcessImageNative = Pointer<Char> Function(
  Int32 imageFormat,
  Pointer<Uint8> data,
  IntPtr len,
  Uint32 width,
  Uint32 height,
  Uint32 bytesPerRow,
  Bool useSuperResolution,
);

typedef _ProcessImage = Pointer<Char> Function(
  int imageFormat,
  Pointer<Uint8> data,
  int len,
  int width,
  int height,
  int bytesPerRow,
  bool useSuperResolution,
);

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

typedef _SdkInitNative = Int32 Function(Pointer<Char> modelPath);
typedef _SdkInit = int Function(Pointer<Char> modelPath);

typedef _FreeRustStringNative = Void Function(Pointer<Char> ptr);
typedef _FreeRustString = void Function(Pointer<Char> ptr);
