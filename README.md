# Weebi Barcode Scanner

A Flutter package for barcode scanning (1D & 2D) on __laptop__(Windows and MacOS) powered by YOLO object detection and ZXing decoding.

This package provides unprecedented support for windows barcode scanning in flutter. The only alternative was focused on QR code through a webview [simple_barcode_scanner](https://pub.dev/packages/simple_barcode_scanner).

Thanks to computer vision barcode detection (yolo) and adequate image enhancement logic (rust pipeline), decoding results are even more accurate than the FFI zxing integration included in [flutter_zxing](https://pub.dev/packages/flutter_zxing).

On Android for privacy-concerned scanning prefer [barcode_scan2](https://pub.dev/packages/barcode_scan2) which wraps zxing java APIs in a more performant way. For non private sensitive use-case go for [mobile_scanner](https://pub.dev/packages/mobile_scanner) which wraps the almighty Google ML Kit barcode.


## Features

- **Cross-Platform**: Windows and macOS support
- **AI-Powered Detection**: YOLO model for accurate barcode localization
- **Multiple Formats**: QR codes, Code 128, EAN-13, and more
- **Real-Time Processing**: Live camera feed with detection overlay
- **OpenFoodFacts Integration**: Automatic product information lookup

## 📁 **Directory Structure Example**

- yolo model is downloaded at class init 

```
your_flutter_app/
├── windows/
│   └── rust_barcode_lib.dll               # 10.87 MB (Windows only)
├── macos/
│   └── Frameworks/
│       └── librust_barcode_lib.dylib      # 22 MB (macOS only)
└── pubspec.yaml
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

## 🏪 OpenFoodFacts Integration

Product lookup :

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


## 📝 License

MIT License - see LICENSE file for details.

### Bundled Components

This package includes several bundled components to provide a seamless integration experience:

#### 1. Weebi YOLO Barcode Detection Model (`best.rten`)

- **File**: `assets/best.rten`
- **Source**: [Hugging Face - weebi/weebi_barcode_detector](https://huggingface.co/weebi/weebi_barcode_detector)
- **License**: AGPL-3.0 (Ultralytics YOLOv8)
- **Size**: ~12.2MB
- **Purpose**: Barcode detection AI model for accurate barcode localization


#### 2. Weebi Rust Barcode Library (`rust_barcode_lib.dll`)

- **File**: `windows/rust_barcode_lib.dll`
- **Architecture**: Windows x64
- **License**: Proprietary (Weebi.com)
- **Size**: ~2.1MB
- **Purpose**: High-performance barcode processing and rxing integration

##### Features
- YOLO model inference via RTEN runtime
- Image preprocessing and enhancement
- rxing barcode decoding
- Windows-optimized BGRA8888 image handling

#### 3. Dart FFI Bindings

- **Files**: `lib/dart_barcode/`
- **Purpose**: Flutter FFI integration with the Rust library

When using this package:

1. **Include attribution** in your app credits
2. **Respect AGPL-3.0** for the YOLO model

## Support

- hello@weebi.com