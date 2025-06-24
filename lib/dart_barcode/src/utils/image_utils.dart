import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Utility functions for image processing and conversion
class ImageUtils {
  /// Convert image data to RGBA format suitable for processing
  static ({Uint8List bytes, int width, int height})? convertToRgba(Uint8List imageData) {
    if (imageData.isEmpty) {
      debugPrint('convertToRgba: Empty image data provided');
      return null;
    }

    try {
      debugPrint('convertToRgba: Decoding image (${imageData.length} bytes)');
      final image = img.decodeImage(imageData);
      if (image == null) {
        debugPrint('convertToRgba: Failed to decode image');
        return null;
      }

      debugPrint('convertToRgba: Decoded image - ${image.width}x${image.height}, ${image.numChannels} channels, format: ${image.format}');
      
      // Convert to RGBA format
      final rgbaImage = _convertToRgb(image);
      final rgbaBytes = Uint8List.fromList(rgbaImage.getBytes(order: img.ChannelOrder.rgba));
      
      debugPrint('convertToRgba: Converted to RGBA - ${rgbaImage.width}x${rgbaImage.height}, ${rgbaBytes.length} bytes');
      
      // Debug: Print first pixel
      if (rgbaBytes.length >= 4) {
        debugPrint('First pixel: R=${rgbaBytes[0]}, G=${rgbaBytes[1]}, B=${rgbaBytes[2]}, A=${rgbaBytes[3]}');
      }
      
      return (
        bytes: rgbaBytes,
        width: rgbaImage.width,
        height: rgbaImage.height
      );
    } catch (e) {
      debugPrint('convertToRgba error: $e');
      throw Exception('Failed to convert image to RGBA format: $e');
    }
  }

  /// Convert image to RGB format (ensure 3 channels)
  static img.Image _convertToRgb(img.Image image) {
    if (image.numChannels == 3) {
      return image; // Already RGB
    }
    
    // Convert to RGB using the proper image package API
    return img.copyResize(image, width: image.width, height: image.height);
  }

  /// Get image dimensions from bytes
  static (int, int)? getImageDimensions(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;
      return (image.width, image.height);
    } catch (e) {
      debugPrint('getImageDimensions error: $e');
      return null;
    }
  }

  /// Prepare image for YOLO processing (resize to square, convert to RGB)
  static ({Uint8List bytes, int width, int height})? prepareForYolo(
    Uint8List imageBytes, {
    int yoloInputSize = 640,
  }) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('prepareForYolo: Failed to decode image');
        return null;
      }

      // Resize to square maintaining aspect ratio
      final resized = img.copyResize(
        image,
        width: yoloInputSize,
        height: yoloInputSize,
        interpolation: img.Interpolation.linear,
      );

      // Convert to RGB
      final rgbImage = _convertToRgb(resized);
      final rgbBytes = Uint8List.fromList(rgbImage.getBytes(order: img.ChannelOrder.rgb));
      
      debugPrint('Prepared image: ${yoloInputSize}x$yoloInputSize, ${rgbBytes.length} bytes (RGB)');
      
      return (
        bytes: rgbBytes,
        width: rgbImage.width,
        height: rgbImage.height,
      );
    } catch (e, stackTrace) {
      debugPrint('Error preparing image for YOLO: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Convert image bytes to grayscale format
  static ImageData? convertToGrayscale(Uint8List imageBytes) {
    debugPrint('convertToGrayscale: Decoding image (${imageBytes.length} bytes)');
    
    // Decode the image bytes
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      debugPrint('convertToGrayscale: Failed to decode image');
      return null;
    }
    
    debugPrint('convertToGrayscale: Decoded image - ${image.width}x${image.height}, ${image.numChannels} channels, format: ${image.format}');
    
    // Convert to grayscale
    final grayImage = img.grayscale(image);
    
    // Get the bytes as Uint8List
    final bytes = Uint8List.fromList(grayImage.getBytes());
    
    debugPrint('convertToGrayscale: Converted to grayscale - ${grayImage.width}x${grayImage.height}, ${bytes.length} bytes');
    
    // Print first few pixel values for debugging
    if (bytes.isNotEmpty) {
      final firstPixels = bytes.take(5).toList();
      debugPrint('First 5 pixel values: $firstPixels');
    }
    
    return ImageData(bytes, grayImage.width, grayImage.height);
  }

  /// Convert Flutter Image to Uint8List (PNG format)
  static Future<Uint8List> imageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Convert Uint8List to Flutter Image
  static Future<ui.Image> bytesToImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Convert YUV420 to RGB
  /// This is a simplified conversion - production code should use optimized libraries
  static Uint8List yuv420ToRgb(
    Uint8List yPlane,
    Uint8List uPlane,
    Uint8List vPlane,
    int width,
    int height,
  ) {
    final rgb = Uint8List(width * height * 3);
    int rgbIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * width + x;
        final uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

        if (yIndex >= yPlane.length || uvIndex >= uPlane.length || uvIndex >= vPlane.length) {
          debugPrint('Index out of bounds in YUV conversion');
          continue;
        }

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        // YUV to RGB conversion
        final c = yValue - 16;
        final d = uValue - 128;
        final e = vValue - 128;

        debugPrint('YUV values: Y=$yValue, U=$uValue, V=$vValue');

        final r = ((298 * c + 409 * e + 128) >> 8).clamp(0, 255);
        final g = ((298 * c - 100 * d - 208 * e + 128) >> 8).clamp(0, 255);
        final b = ((298 * c + 516 * d + 128) >> 8).clamp(0, 255);

        rgb[rgbIndex++] = r;
        rgb[rgbIndex++] = g;
        rgb[rgbIndex++] = b;

        debugPrint('RGB values: R=$r, G=$g, B=$b');
      }
    }

    return rgb;
  }

  /// Enhanced YUV420 to RGB conversion with proper stride handling
  static Uint8List yuv420ToRgbEnhanced(
    Uint8List yPlane,
    Uint8List uPlane,
    Uint8List vPlane,
    int width,
    int height,
    int uvRowStride,
    int uvPixelStride,
  ) {
    final rgb = Uint8List(width * height * 3);
    int rgbIndex = 0;

    debugPrint('YUV420 conversion: ${width}x$height, uvRowStride=$uvRowStride, uvPixelStride=$uvPixelStride');

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * width + x;
        
        // Calculate UV indices with stride
        final uvY = y ~/ 2;
        final uvX = x ~/ 2;
        final uIndex = uvY * uvRowStride + uvX * uvPixelStride;
        final vIndex = uvY * uvRowStride + uvX * uvPixelStride;

        if (yIndex >= yPlane.length || uIndex >= uPlane.length || vIndex >= vPlane.length) {
          if (kDebugMode) {
            debugPrint('Index out of bounds: yIndex=$yIndex (max=${yPlane.length}), uIndex=$uIndex (max=${uPlane.length}), vIndex=$vIndex (max=${vPlane.length})');
          }
          // Use safe fallback values
          rgb[rgbIndex++] = 128; // R
          rgb[rgbIndex++] = 128; // G
          rgb[rgbIndex++] = 128; // B
          continue;
        }

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uIndex];
        final vValue = vPlane[vIndex];

        // YUV to RGB conversion (ITU-R BT.601)
        final c = yValue - 16;
        final d = uValue - 128;
        final e = vValue - 128;

        final r = ((298 * c + 409 * e + 128) >> 8).clamp(0, 255);
        final g = ((298 * c - 100 * d - 208 * e + 128) >> 8).clamp(0, 255);
        final b = ((298 * c + 516 * d + 128) >> 8).clamp(0, 255);

        rgb[rgbIndex++] = r;
        rgb[rgbIndex++] = g;
        rgb[rgbIndex++] = b;
      }
    }

    return rgb;
  }

  /// Convert RGB bytes to PNG
  static Uint8List rgbToPng(Uint8List rgbBytes, int width, int height) {
    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgbBytes.buffer,
      numChannels: 3,
    );
    return Uint8List.fromList(img.encodePng(image));
  }

  /// Resize image maintaining aspect ratio
  static Uint8List resizeImage(
    Uint8List imageBytes,
    int targetWidth,
    int targetHeight,
  ) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );

      return Uint8List.fromList(img.encodePng(resized));
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return imageBytes; // Return original on error
    }
  }

  /// Enhance image for better barcode detection
  static Uint8List enhanceForBarcode(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Apply enhancements
      var enhanced = img.contrast(image, contrast: 1.2);
      enhanced = img.adjustColor(enhanced, brightness: 1.1);
      
      // Convert to grayscale for better barcode detection
      enhanced = img.grayscale(enhanced);

      return Uint8List.fromList(img.encodePng(enhanced));
    } catch (e) {
      debugPrint('Error enhancing image: $e');
      return imageBytes; // Return original on error
    }
  }

  /// Check if image format is supported
  static bool isSupportedFormat(String? mimeType) {
    if (mimeType == null) return false;
    
    const supportedFormats = [
      'image/jpeg',
      'image/jpg', 
      'image/png',
      'image/webp',
    ];
    
    return supportedFormats.contains(mimeType.toLowerCase());
  }


}

class ImageData {
  final Uint8List bytes;
  final int width;
  final int height;

  ImageData(this.bytes, this.width, this.height);
}
