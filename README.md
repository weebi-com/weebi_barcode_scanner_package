# Weebi Barcode Scanner

## ✅ PACKAGE STATUS: FFI ISSUE FIXED!

**[📋 See Current Status Report](doc/CURRENT_STATUS.md)** - ✅ **sdk_init now working!**

**Update: The FFI symbol resolution issue has been FIXED by rebuilding the DLL with current source code.**

---

## ⚠️ IMPORTANT: This is NOT a simple plug-and-play solution

**Before you continue, please read:** [REALISTIC Setup Guide](doc/REALISTIC_SETUP_GUIDE.md)

**Reality check:**
- **38MB of assets** (12MB model + 26MB DLL) must be manually copied
- **Windows and MACOS only** (no mobile support)
- **Complex dependencies** (FFI, native libraries, camera permissions)
- **Manual asset management** required

---

A simplified Flutter package for barcode and QR code scanning on Windows, powered by YOLO object detection and ZXing decoding.

## ❗ Important Setup Requirements
### Prerequisites

1. **Windows Development Environment**
2. **Flutter SDK 3.0+**
3. **Camera permissions configured**
4. **Manual asset and DLL setup (required)**

## 📦 Installation

### Step 1: Add Dependency

```yaml
dependencies:
  weebi_barcode_scanner:
    git:
      url: https://github.com/your-repo/weebi_barcode_scanner.git
  camera: ^0.10.0
  permission_handler: ^11.0.0
```

### Step 2: Copy Required Assets

**You MUST manually copy these files to your project:**

1. **Copy the YOLO Model:**
   ```bash
   # Copy from the package to your project
   cp node_modules/weebi_barcode_scanner/assets/best.rten assets/
   ```

2. **Update pubspec.yaml to include assets:**
   ```yaml
   flutter:
     assets:
       - assets/best.rten
       - assets/  # Include all assets
   ```

### Step 3: Windows DLL Setup

**For Windows, you MUST manually copy the DLL:**

1. **Copy the DLL to your Windows directory:**
   ```bash
   # Create windows directory if it doesn't exist
   mkdir windows
   
   # Copy DLL from package
   cp node_modules/weebi_barcode_scanner/windows/rust_barcode_lib.dll windows/
   ```

2. **The DLL must be accessible at runtime.** You may need to:
   - Copy it to your build output directory
   - Add it to your PATH
   - Bundle it with your app distribution

### Step 4: Permissions

Add camera permissions to your app:

**android/app/src/main/AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**windows/runner/main.cpp:** (if targeting Windows)
```cpp
// Camera access may require additional Windows permissions
```

## 🚀 Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

class ScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BarcodeScannerWidget(
        onBarcodeDetected: (result) {
          print('Scanned: ${result.text}');
          print('Format: ${result.format}');
          if (result.hasProductInfo) {
            print('Product: ${result.productName}');
          }
        },
        onError: (error) {
          print('Scanner error: $error');
        },
      ),
    );
  }
}
```

### Advanced Configuration

```dart
BarcodeScannerWidget(
  config: ScannerConfig(
    // Performance vs accuracy tradeoff
    detectionInterval: Duration(milliseconds: 100), // How often to detect
    confidenceThreshold: 0.8,  // YOLO detection confidence (0.0-1.0)
    enableSuperResolution: true, // Enhance image quality (slower)
    modelPath: 'assets/best.rten', // Path to YOLO model
    libraryPath: null, // Auto-detect DLL location
  ),
  onBarcodeDetected: (result) {
    // Handle successful scan
  },
  onError: (error) {
    // Handle errors (camera, model loading, DLL issues, etc.)
  },
)
```

## 🎯 Scanner Configurations

### Quick Scan (Fast, Less Accurate)
```dart
config: ScannerConfig.fastConfig
```

### Accurate Scan (Slower, More Accurate)
```dart
config: ScannerConfig.accurateConfig
```

### Custom Configuration
```dart
config: ScannerConfig(
  detectionInterval: Duration(milliseconds: 200),
  confidenceThreshold: 0.7,
  enableSuperResolution: false,
)
```

## 📊 BarcodeResult

```dart
class BarcodeResult {
  final String text;           // The decoded barcode text
  final String format;         // Barcode format (QR_CODE, CODE_128, etc.)
  final String? productName;   // Product name (if found in OpenFoodFacts)
  final String? productBrand;  // Product brand
  final Map<String, dynamic>? rawDetection; // Raw YOLO detection data
  
  bool get hasProductInfo => productName != null;
}
```

## ⚠️ Troubleshooting

### Common Issues

1. **"Target file lib\main.dart not found"**
   - Make sure you're running from the correct directory
   - Ensure pubspec.yaml exists in your project root

2. **"Model file not found"**
   - Verify `assets/best.rten` exists in your project
   - Check pubspec.yaml includes the asset
   - Run `flutter clean` and `flutter pub get`

3. **"DLL not found" or FFI errors**
   - Ensure `rust_barcode_lib.dll` is in your windows/ directory
   - Try copying the DLL to your build output directory
   - On Windows, the DLL must be in PATH or same directory as executable

4. **Camera permission denied**
   - Add camera permissions to AndroidManifest.xml
   - Request permissions at runtime using permission_handler

5. **Poor detection accuracy**
   - Increase `confidenceThreshold` (0.8+)
   - Enable `enableSuperResolution`
   - Ensure good lighting and steady camera

### Debug Mode

Enable detailed debugging:

```dart
ScannerConfig(
  debugMode: true, // Saves debug images and logs
  // ... other config
)
```

This will save detection images to help diagnose issues.

## 🔧 Architecture

This package combines:
- **YOLO v8 Object Detection** (finds barcode regions)
- **ZXing Decoding** (reads barcode text)
- **Super Resolution Enhancement** (improves image quality)
- **OpenFoodFacts Integration** (product information)

The processing pipeline:
1. Camera frame → YUV420 conversion
2. YOLO model detects barcode regions
3. Super resolution enhancement (optional)
4. ZXing decodes barcode text
5. OpenFoodFacts lookup for product info

## 📄 Licensing

- **Package Code**: Apache 2.0 License
- **YOLO Model**: AGPL-3.0 (requires commercial license for commercial use)
- **Rust SDK**: Proprietary (included binaries)

For commercial use, contact: enterprise@weebi.com

## 🐛 Known Limitations

1. **Windows Only**: Currently only supports Windows Flutter apps
2. **Large Assets**: Model file is ~12MB, DLL is ~26MB
3. **Manual Setup**: Requires copying assets and DLLs manually
4. **Performance**: YOLO detection can be CPU intensive
5. **Dependencies**: Requires specific Flutter and camera plugin versions

## 📞 Support

- **Issues**: GitHub Issues
- **Commercial Support**: enterprise@weebi.com
- **Documentation**: See `/docs` folder

## 🚧 Development Status

This is a simplified wrapper around a complex barcode detection system. While we've reduced the integration from 1000+ lines to ~20 lines, the underlying system still requires:

- Manual asset management
- Platform-specific DLL handling  
- Camera permission setup
- Performance tuning

**This package makes barcode scanning easier, but not trivial.**
