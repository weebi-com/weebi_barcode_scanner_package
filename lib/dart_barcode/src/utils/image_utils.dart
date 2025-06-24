import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Utility class for handling image operations
class ImageUtils {
  // Target dimensions for YOLO model
  static const int yoloInputSize = 640;

  // Helper function to create a blank RGB image
  static img.Image _createRgbImage(int width, int height) {
    // Create a new image with RGBA format
    final image = img.Image(width: width, height: height, numChannels: 4);
    
    // Fill with black (0, 0, 0, 255)
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        pixel.setRgba(0, 0, 0, 255);
      }
    }
    return image;
  }

  // Convert any image to RGB format
  static img.Image _convertToRgb(img.Image image) {
    // If already in RGB/RGBA format, return as is
    if (image.numChannels >= 3) {
      return image;
    }
    
    // Create a new RGBA image
    final rgbaImage = img.Image(width: image.width, height: image.height, numChannels: 4);
    
    // Convert grayscale to RGBA by iterating through each pixel
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        // Get the grayscale value (0-255) - use the first channel for grayscale
        // since grayscale images only have one channel
        final pixel = image.getPixel(x, y);
        final value = pixel.r;  // For grayscale, r=g=b=value
        
        // Set the same value for RGB channels and 255 for alpha
        rgbaImage.setPixelRgba(x, y, value, value, value, 255);
      }
    }
    
    return rgbaImage;
  }

  /// Converts image bytes to RGBA format and returns the converted image.
  /// Returns null if the image format is not supported or if the input is empty.
  static ({Uint8List bytes, int width, int height})? convertToRgba(Uint8List imageData) {
    if (imageData.isEmpty) {
      print('convertToRgba: Empty image data provided');
      return null;
    }

    try {
      print('convertToRgba: Decoding image (${imageData.length} bytes)');
      final image = img.decodeImage(imageData);
      if (image == null) {
        print('convertToRgba: Failed to decode image');
        return null;
      }

      print('convertToRgba: Decoded image - ${image.width}x${image.height}, ${image.numChannels} channels, format: ${image.format}');
      
      // Convert to RGBA format
      final rgbaImage = _convertToRgb(image);
      final rgbaBytes = Uint8List.fromList(rgbaImage.getBytes(order: img.ChannelOrder.rgba));
      
      print('convertToRgba: Converted to RGBA - ${rgbaImage.width}x${rgbaImage.height}, ${rgbaBytes.length} bytes');
      
      // Debug: Print first pixel
      if (rgbaBytes.length >= 4) {
        print('First pixel: R=${rgbaBytes[0]}, G=${rgbaBytes[1]}, B=${rgbaBytes[2]}, A=${rgbaBytes[3]}');
      }
      
      return (
        bytes: rgbaBytes,
        width: rgbaImage.width,
        height: rgbaImage.height,
      );
    } catch (e) {
      print('convertToRgba error: $e');
      throw Exception('Failed to convert image to RGBA format: $e');
    }
  }

  /// Extracts width and height from raw image bytes.
  /// Returns a tuple of (width, height) if successful, or null if the image format is not supported.
  static (int width, int height)? getImageDimensions(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;
      return (image.width, image.height);
    } catch (e) {
      print('getImageDimensions error: $e');
      return null;
    }
  }

  /// Prepares an image for YOLO model input by resizing to 640x640 with padding
  /// and converting to RGB format.
  /// Returns the processed image bytes and dimensions, or null on failure.
  static ({Uint8List bytes, int width, int height})? prepareForYolo(Uint8List imageBytes) {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        print('prepareForYolo: Failed to decode image');
        return null;
      }

      // Convert to RGB if needed
      final rgbImage = _convertToRgb(image);
      
      // Calculate scaling factor to maintain aspect ratio
      final widthRatio = yoloInputSize / rgbImage.width;
      final heightRatio = yoloInputSize / rgbImage.height;
      final scale = widthRatio < heightRatio ? widthRatio : heightRatio;
      
      // Calculate new dimensions
      final newWidth = (rgbImage.width * scale).round();
      final newHeight = (rgbImage.height * scale).round();
      
      // Create a new image with the target size and black background
      final paddedImage = _createRgbImage(yoloInputSize, yoloInputSize);
      
      // Resize the original image
      final resized = img.copyResize(
        rgbImage,
        width: newWidth,
        height: newHeight,
      );
      
      // Calculate padding to center the image
      final padX = (yoloInputSize - newWidth) ~/ 2;
      final padY = (yoloInputSize - newHeight) ~/ 2;
      
      // Copy the resized image to the center of the padded image
      for (var y = 0; y < resized.height; y++) {
        for (var x = 0; x < resized.width; x++) {
          final srcPixel = resized.getPixel(x, y);
          final dstX = padX + x;
          final dstY = padY + y;
          
          if (dstX < yoloInputSize && dstY < yoloInputSize) {
            final dstPixel = paddedImage.getPixel(dstX, dstY);
            dstPixel.r = srcPixel.r.toInt();
            dstPixel.g = srcPixel.g.toInt();
            dstPixel.b = srcPixel.b.toInt();
          }
        }
      }
      
      // Convert to RGB format (3 channels per pixel)
      final rgbBytes = Uint8List(yoloInputSize * yoloInputSize * 3);
      var idx = 0;
      
      for (var y = 0; y < yoloInputSize; y++) {
        for (var x = 0; x < yoloInputSize; x++) {
          final pixel = paddedImage.getPixel(x, y);
          rgbBytes[idx++] = pixel.r.toInt();
          rgbBytes[idx++] = pixel.g.toInt();
          rgbBytes[idx++] = pixel.b.toInt();
        }
      }
      
      print('Prepared image: ${yoloInputSize}x$yoloInputSize, ${rgbBytes.length} bytes (RGB)');
      
      return (
        bytes: rgbBytes,
        width: yoloInputSize,
        height: yoloInputSize,
      );
    } catch (e, stackTrace) {
      print('Error preparing image for YOLO: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Convert image bytes to grayscale format
  static ImageData? convertToGrayscale(Uint8List imageBytes) {
    print('convertToGrayscale: Decoding image (${imageBytes.length} bytes)');
    
    // Decode the image bytes
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      print('convertToGrayscale: Failed to decode image');
      return null;
    }
    
    print('convertToGrayscale: Decoded image - ${image.width}x${image.height}, ${image.numChannels} channels, format: ${image.format}');
    
    // Convert to grayscale
    final grayImage = img.grayscale(image);
    
    // Get raw bytes (each pixel is one byte)
    final bytes = Uint8List(grayImage.width * grayImage.height);
    var i = 0;
    for (var y = 0; y < grayImage.height; y++) {
      for (var x = 0; x < grayImage.width; x++) {
        final pixel = grayImage.getPixel(x, y);
        // Get red channel which now contains the grayscale value
        bytes[i++] = pixel.r.toInt();
      }
    }
    
    print('convertToGrayscale: Converted to grayscale - ${grayImage.width}x${grayImage.height}, ${bytes.length} bytes');
    
    // Print first few pixel values for debugging
    if (bytes.isNotEmpty) {
      final firstPixels = bytes.take(5).toList();
      print('First 5 pixel values: $firstPixels');
    }
    
    return ImageData(bytes, grayImage.width, grayImage.height);
  }
}

class ImageData {
  final Uint8List bytes;
  final int width;
  final int height;

  ImageData(this.bytes, this.width, this.height);
}
