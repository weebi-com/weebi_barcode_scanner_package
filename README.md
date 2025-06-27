# Weebi Barcode Scanner

A Flutter package for barcode and QR code scanning on Windows and macOS powered by YOLO object detection and ZXing decoding. **Self-contained and ready for pub.dev publication.**

## Features

- **Cross-Platform**: Windows and macOS support
- **AI-Powered Detection**: YOLO model for accurate barcode localization
- **Multiple Formats**: QR codes, Code 128, EAN-13, and more
- **Real-Time Processing**: Live camera feed with detection overlay
- **Point-of-Sale Ready**: Optimized scanning modes for retail use
- **OpenFoodFacts Integration**: Automatic product information lookup
- **Self-Contained**: No external dependencies or manual asset copying

## 📦 Installation

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/best.rten  # 11.68 MB - YOLO barcode detection model
```

**Download**: [best.rten from Hugging Face](https://huggingface.co/weebi/weebi_barcode_detector/blob/main/best.rten)  
**License**: AGPL-3.0 (Ultralytics)  
**Attribution Required**: See [Model License](MODEL_LICENSE.md)

### 🪟 **Windows** 
```yaml
# pubspec.yaml
flutter:
  assets:
    - windows/rust_barcode_lib.dll  # 10.87 MB
```

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  # Camera permissions (automatically included)
  permission_handler: ^11.0.0
```

Then run:
```bash
flutter pub get
```

## Quick Start


```dart
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

// Scan a barcode with one line of code!
var result = await WeebiBarcodeScanner.scan();

if (result.isSuccess) {
  print('Scanned: ${result.code}');
  print('Format: ${result.format}');
} else if (result.isCancelled) {
  print('User cancelled the scan');
} else if (result.hasError) {
  print('Error: ${result.error}');
}
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

class ScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Scanner')),
      body: BarcodeScannerWidget(
        onBarcodeDetected: (result) {
          print('Scanned: ${result.text}');
          print('Format: ${result.format}');
          
          // Show result dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Barcode Detected'),
              content: Text('${result.format}: ${result.text}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
        onError: (error) {
          print('Scanner error: $error');
        },
      ),
    );
  }
}
```

### Point-of-Sale Mode

```dart
BarcodeScannerWidget(
  config: ScannerConfig.pointOfSale(),  // Single scan, haptic feedback
  onBarcodeDetected: (result) {
    // Automatically stops scanning after first detection
    Navigator.pop(context, result);
  },
)
```

### Continuous Scanning Mode

```dart
BarcodeScannerWidget(
  config: ScannerConfig.continuous(),  // Continuous scanning
  onBarcodeDetected: (result) {
    // Keeps scanning for multiple barcodes
    addToCart(result);
  },
)
```

## 🎯 Scanner Configurations

### Custom Configuration

```dart
ScannerConfig(
  // Detection frequency
  detectionInterval: Duration(milliseconds: 500),
  
  // AI model confidence threshold (0.0-1.0)
  confidenceThreshold: 0.6,
  
  // Image enhancement for damaged barcodes
  enableSuperResolution: true,
  
  // Auto-stop after first detection
  stopAfterFirstScan: true,
  
  // Haptic feedback on detection
  enableHapticFeedback: true,
)
```

## 📊 BarcodeResult

```dart
class BarcodeResult {
  final String text;                    // Decoded barcode text
  final String format;                  // Barcode format (QR_CODE, EAN_13, etc.)
  final String? productName;            // Product name (via OpenFoodFacts)
  final String? productBrand;           // Product brand
  final Map<String, dynamic>? location; // Barcode location in image
  final double? confidence;             // Detection confidence (0.0-1.0)
  
  bool get hasProductInfo => productName != null;
  bool get hasLocationInfo => location != null;
}
```

## 🖼️ Visual Detection Feedback

The package automatically displays:
- **Detection Overlay**: Shows barcode location even before decoding
- **Confidence Indicators**: Visual feedback on detection quality
- **Real-Time Tracking**: Bounding boxes follow detected barcodes
- **Status Messages**: Clear feedback on scanning progress

## 🏪 OpenFoodFacts Integration

Automatic product lookup for food barcodes:

```dart
BarcodeScannerWidget(
  onBarcodeDetected: (result) {
    if (result.hasProductInfo) {
      print('Product: ${result.productName}');
      print('Brand: ${result.productBrand}');
      // Additional product data available
    }
  },
)
```

To enable full product features, add credentials (optional):
```bash
# Copy template and add your credentials
cp open_prices_credentials.json.example open_prices_credentials.json
# Edit with your OpenFoodFacts account details
```

## 🎨 UI Customization

### Split-Screen Layout

```dart
BarcodeScannerWidget(
  showProductInfo: true,  // Enables split-screen with product details
  onBarcodeDetected: (result) {
    // Product info automatically displayed on right side
  },
)
```

### Custom Overlay

```dart
BarcodeScannerWidget(
  overlayBuilder: (context, detections) {
    return CustomPaint(
      painter: YourCustomOverlayPainter(detections),
    );
  },
)
```

## 🔧 Platform Setup

### Self-Contained Design
- **Embedded AI Model**: YOLO detection model included
- **Native Libraries**: Rust FFI libraries bundled

## 🚨 Troubleshooting
### Common Issues

1. **Camera not working**
   - Ensure camera permissions are granted
   - Check that camera is not in use by another app
   - Restart the app if camera appears frozen

2. **Poor detection accuracy**
   - Ensure good lighting conditions
   - Try adjusting `confidenceThreshold` (lower = more sensitive)
   - Enable `enableSuperResolution` for damaged barcodes

3. **Performance issues**
   - Increase `detectionInterval` (less frequent detection)
   - Disable `enableSuperResolution` if not needed

### Debug Information

```dart
BarcodeScannerWidget(
  config: ScannerConfig(
    // Enable detailed logging
    enableDebugMode: true,
  ),
  onError: (error) {
    print('Detailed error: $error');
  },
)
```

## 📝 License

MIT License - see LICENSE file for details.