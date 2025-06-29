# Weebi Barcode Scanner

A Flutter package for barcode scanning (1D & 2D) on __laptop__(Windows and MacOS) powered by [YOLO](https://arxiv.org/abs/1506.02640) object detection and [ZXing](https://zxing.org/w/decode.jspx) decoding.

This package provides unprecedented __free support__ for windows barcode scanning. The only free alternative in 2025 only handles QR code through a webview [simple_barcode_scanner](https://pub.dev/packages/simple_barcode_scanner).

Thanks to computer vision and adequate image preprocessing, decoding results are enhanced and superior to raw zxing integration, i.e. [flutter_zxing](https://pub.dev/packages/flutter_zxing).

On Android for privacy-concerned scanning consider [barcode_scan2](https://pub.dev/packages/barcode_scan2) which wraps zxing java APIs in a seamless way. For non private sensitive use-case prefer [mobile_scanner](https://pub.dev/packages/mobile_scanner) which provides the almighty Google ML Kit barcode.

## Features

- **Cross-Platform**: Windows and macOS support
- **AI-Powered Detection**: YOLO model for accurate barcode localization
- **Multiple Formats**: QR codes, Code 128, EAN-13, and more
- **Real-Time Processing**: Live camera feed with detection overlay
- **OpenFoodFacts Integration**: Automatic product information lookup for demo purposes
- **macOS Compatible**: Tested and working on macOS Monterey 12.6.5+

## Set-up

- yolo model is downloaded at class init 
- native libs are handled by the package
- so just add this package in your yaml and run:

```bash
flutter pub get
```

### Set-up Macos
**macOS Entitlements**
- **Files:** 
  - `your_app/macos/Runner/DebugProfile.entitlements`
  - `your_app/macos/Runner/Release.entitlements`

```xml
<key>com.apple.security.device.camera</key>
<true/>
```
**macOS info.plist**
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan barcodes and QR codes.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs camera access to scan barcodes and QR codes.</string>
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

### BarcodeResult

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

To enable also price features, add credentials (optional):
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

## 🚨 Troubleshooting
### Common Issues

- **Camera not working**
   - Ensure camera permissions are granted
   - Check that camera is not in use by another app
   - Restart the app if camera appears frozen

- **Poor detection accuracy**
   - Ensure good lighting conditions
   - Try adjusting `confidenceThreshold` (lower = more sensitive)
   - Enable `enableSuperResolution` for damaged barcodes

- **Performance issues**
   - Increase `detectionInterval` (less frequent detection)
   - Disable `enableSuperResolution` if not needed

- **Swift Compilation Error Fix**
**Problem:** `camera_macos` plugin used macOS 14+ APIs that don't exist on macOS Monterey 12.6.5
```
error: initializer for conditional binding must have Optional type, not 'Bundle'
error: value of type 'AVCaptureConnection' has no member 'isVideoRotationAngleSupported'
```

**Solution:** Commented out problematic lines in the cached plugin file
**File:** `/Users/mac/.pub-cache/hosted/pub.dev/camera_macos-0.0.9/macos/Classes/CameraMacosPlugin.swift`

**Lines to comment out:**
```swift
// Comment out these lines around line 520-530:
//                                #if compiler(<5.8.1)
//                                    if #available(macOS 14.0, *), connection.isVideoRotationAngleSupported(self.orientation){
//                                        connection.videoRotationAngle = self.orientation
//                                    }
//                                #endif
```

## 📝 License

MIT License - see LICENSE file for details.
Free for enterprise and commercial use-case

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

1. **Include weebi attribution** in your app credits
2. **Respect AGPL-3.0** for the YOLO model

## Support && custom use-case

- hello@weebi.com