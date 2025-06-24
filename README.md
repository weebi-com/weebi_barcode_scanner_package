<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Weebi Barcode Scanner Package

**A simple, high-performance barcode scanner for Windows Flutter apps. Privacy-first and offline.**

## 🎯 **The Problem This Solves**

The existing `dart_barcode/example` requires **1000+ lines of code** and understanding **15+ files** to integrate barcode scanning. This package reduces that to **~20 lines** with a single widget.

## ✨ **Features**

- 🔒 **Privacy-first**: All processing happens locally, no telemetry
- 🚀 **High accuracy**: YOLO + rxing detection pipeline 
- 🪟 **Windows optimized**: Built specifically for Windows desktop
- 📦 **Single widget**: Just add `BarcodeScannerWidget()` to your app
- 🔧 **Zero configuration**: Works out of the box with sensible defaults
- ⚡ **Auto-initialization**: Handles model loading, camera setup, SDK init
- 🔄 **Hot reload support**: Properly handles Flutter development workflow
- 🛠️ **Error recovery**: Automatic retry and graceful error handling

## 🚀 **Quick Start**

### 1. Add to your pubspec.yaml

```yaml
dependencies:
  weebi_barcode_scanner: ^1.0.0
```

### 2. Use the widget (that's it!)

**No additional setup required!** The model and native libraries are bundled.

```dart
import 'package:weebi_barcode_scanner_package/weebi_barcode_scanner_package.dart';

// Add to any screen in your app:
BarcodeScannerWidget(
  onBarcodeDetected: (result) {
    print('Detected: ${result.text}');
    print('Format: ${result.format}');
    if (result.productName != null) {
      print('Product: ${result.productName}');
    }
  },
)
```

## 📱 **Complete Example**

See [example/main.dart](example/main.dart) for a complete working app. Here's the core:

```dart
class _ScannerPageState extends State<ScannerPage> {
  String? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Scanner')),
      body: Column(
        children: [
          // Scanner widget - this is all you need!
          Expanded(
            child: BarcodeScannerWidget(
              onBarcodeDetected: (result) {
                setState(() => _lastResult = result.text);
                _showResultDialog(result);
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              },
            ),
          ),
          // Status display
          Text(_lastResult ?? 'Point camera at a barcode'),
        ],
      ),
    );
  }
}
```

## ⚙️ **Configuration Options**

```dart
BarcodeScannerWidget(
  config: ScannerConfig(
    modelPath: 'assets/best.rten',        // Model file path
    useSuperResolution: true,             // Better 1D barcode accuracy
    enableProductLookup: true,            // OpenFoodFacts integration
    showOverlay: true,                    // Show scanning rectangle
    overlayColor: Colors.green,           // Overlay color
    scanInterval: Duration(seconds: 1),   // Scan frequency
  ),
  onBarcodeDetected: (result) { /* ... */ },
)
```

### **Pre-configured Options**

```dart
// Default config - balanced performance and accuracy
BarcodeScannerWidget(config: ScannerConfig.defaultConfig, ...)

// Fast config - optimized for speed
BarcodeScannerWidget(config: ScannerConfig.fastConfig, ...)

// Accurate config - optimized for difficult barcodes
BarcodeScannerWidget(config: ScannerConfig.accurateConfig, ...)
```

## 🆚 **Before vs After**

### **Before** (Current `dart_barcode/example`)

❌ **Complex Integration:**
- 15+ files to understand
- 1000+ lines of boilerplate code
- Manual model management (`ModelManager`)
- Manual camera setup (`CameraManager`)
- Manual isolate handling (`IsolateHandler`)
- Complex error handling and state management
- Hot reload issues
- Platform-specific code paths

```dart
// Complex setup with multiple files and managers
class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = ScannerController(
      onBarcodeDetected: _handleDetection,
      onError: _showToast,
      continuousMode: true,
    );
    _controller.addListener(_onControllerUpdate);
    _initializeScanner(); // 50+ lines of initialization
  }
  
  Future<void> _initializeScanner() async {
    // 50+ lines of complex initialization...
    final modelInitialized = await ModelManager.initialize();
    final initialized = await _controller.initialize();
    // ... more complexity
  }
  
  // 400+ more lines of state management, error handling, etc.
}
```

### **After** (New Package)

✅ **Simple Integration:**
- Single widget
- ~20 lines of code
- Everything handled automatically
- Zero configuration required

```dart
// Simple, single widget approach
BarcodeScannerWidget(
  onBarcodeDetected: (result) {
    print('Detected: ${result.text}');
  },
)
```

## 📊 **Comparison Table**

| Feature | Current Example | New Package |
|---------|----------------|-------------|
| **Setup complexity** | High (15+ files) | Low (1 widget) |
| **Lines of code** | 1000+ | ~20 |
| **Configuration** | Manual everything | Automatic |
| **Platform handling** | Manual detection | Built-in |
| **Error handling** | Manual | Automatic |
| **Camera management** | Manual | Automatic |
| **Model loading** | Manual | Automatic |
| **Hot reload support** | Complex/broken | Built-in |
| **State management** | Manual | Automatic |
| **Resource cleanup** | Manual | Automatic |

## 🔧 **What's Handled Automatically**

The widget automatically handles:

1. **Model Management**
   - Copying model from assets to documents directory
   - SDK initialization with proper error handling
   - Model caching and reuse

2. **Camera Setup**
   - Windows-optimized camera initialization
   - Proper resolution and format selection (`BGRA8888`)
   - Extended timeout for Windows hardware
   - Automatic retry on initialization failures

3. **Scanning Process**
   - Periodic image capture at configurable intervals
   - Background image processing with isolates
   - Barcode detection and decoding
   - Temporary file cleanup

4. **Error Handling**
   - Graceful error recovery
   - User-friendly error messages
   - Automatic retry functionality
   - Proper resource cleanup

5. **UI Management**
   - Loading states during initialization
   - Processing indicators
   - Error states with retry options
   - Scanning overlay with corner brackets

## 🎯 **Use Cases**

Perfect for:
- **Inventory management apps**
- **Point of sale systems** 
- **Product lookup tools**
- **Document scanning**
- **Asset tracking**
- **Windows desktop business apps**

## 🔍 **Supported Barcode Types**

- **1D Barcodes**: Code 128, EAN-13, UPC-A, UPC-E, Code 39, etc.
- **2D Codes**: QR codes, DataMatrix, PDF417, Aztec
- **Product Integration**: OpenFoodFacts lookup for retail barcodes

## 🛠️ **Development**

### Running the Example

```bash
cd weebi_barcode_scanner_package/example
flutter run -d windows
```

### Package Structure

```
weebi_barcode_scanner_package/
├── lib/
│   ├── weebi_barcode_scanner_package.dart    # Main export
│   └── src/
│       ├── barcode_scanner_widget.dart       # Main widget
│       ├── barcode_result.dart               # Result wrapper
│       └── scanner_config.dart               # Configuration
├── example/
│   └── main.dart                             # Simple usage example
└── README.md                                 # This file
```

## 💼 **Commercial Use & Licensing**

### **Free for Personal/Educational Use**
✅ Personal projects  
✅ Educational purposes  
✅ Internal business tools  
✅ Proof of concepts  

### **Enterprise License Required For**
💼 Commercial products or services  
💼 Redistribution or resale  

**Contact for Enterprise Licensing:**  
📧 hello@weebi.com  
🌐 https://weebi.com  

### **License Details**
- **Flutter Package**: Apache 2.0 License
- **YOLO Model**: AGPL-3.0 (Ultralytics) - bundled for evaluation
- **Rust SDK**: Proprietary (bundled for evaluation)
- **Commercial Use**: Requires Weebi Enterprise License

**Attribution Required:**  
*"Barcode scanning powered by Weebi Barcode Technology"*

## 🤝 **Contributing**

This package is designed to be a simple wrapper around the existing `dart_barcode` SDK. For core barcode detection improvements, contribute to the main SDK.

For UI/UX improvements or additional configuration options, PRs are welcome!

---

**🎉 This package transforms 1000+ lines of complex integration code into 20 lines of simple widget usage.**
