import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Represents an enhanced image buffer returned from the Rust FFI layer
base class EnhancedImageBuffer extends Struct {
  /// Raw image data pointer
  external Pointer<Uint8> data;
  
  /// Length of the data buffer
  @Int64()
  external int len;
  
  /// Width of the image
  @Int32()
  external int width;
  
  /// Height of the image
  @Int32()
  external int height;
}

/// Extension to help with memory management
extension EnhancedImageBufferExt on EnhancedImageBuffer {
  void free() {
    calloc.free(data);
  }
}
