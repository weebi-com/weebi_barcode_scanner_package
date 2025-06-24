import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Represents the result of image processing operations
class ProcessedImage {
  final Uint8List bytes;
  final int width;
  final int height;
  final String format;

  ProcessedImage({
    required this.bytes,
    required this.width,
    required this.height,
    required this.format,
  });
}

/// Utility class for image processing operations
class ImageProcessor {
  /// Creates a debug visualization of detected barcodes
  /// Returns the bytes of the generated debug image
  static Future<Uint8List> createDebugImage({
    required Uint8List sourceImage,
    required List<BarcodeLocation> detections,
    bool showConfidence = true,
  }) async {
    final image = img.decodeImage(sourceImage);
    if (image == null) return sourceImage;

    for (final detection in detections) {
      // Draw rectangle around barcode
      img.drawRect(
        image,
        x1: detection.bounds.x.toInt(),
        y1: detection.bounds.y.toInt(),
        x2: (detection.bounds.x + detection.bounds.width).toInt(),
        y2: (detection.bounds.y + detection.bounds.height).toInt(),
        color: img.ColorRgb8(255, 0, 0), // Red
        thickness: 2,
      );

      if (showConfidence) {
        // Add text label above the rectangle if there's space
        final labelY = detection.bounds.y.toInt() - 20;
        if (labelY >= 0) {
          img.drawString(
            image,
            '${detection.text} (${detection.confidence.toStringAsFixed(2)})',
            font: img.arial14,
            x: detection.bounds.x.toInt(),
            y: labelY,
            color: img.ColorRgb8(255, 0, 0),
          );
        }
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }
}

/// Represents a rectangle with coordinates and dimensions
class BarcodeRect {
  final double x;
  final double y;
  final double width;
  final double height;

  BarcodeRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// Represents the location and metadata of a detected barcode
class BarcodeLocation {
  final String text;
  final double confidence;
  final BarcodeRect bounds;

  BarcodeLocation({
    required this.text,
    required this.confidence,
    required this.bounds,
  });
} 