# 🎉 New Auto-Download Barcode Scanner

The weebi barcode scanner now supports **automatic model downloading** from [Hugging Face](https://huggingface.co/weebi/weebi_barcode_detector/blob/main/best.rten)! No more manual setup required.

## ✨ What's New

- **Zero Configuration**: No need to manually download or bundle the YOLO model
- **Automatic Downloads**: Model is downloaded from Hugging Face on first use
- **Local Caching**: Model is cached locally for offline use after first download  
- **Flexible Paths**: Use default location or specify custom model path
- **Error Handling**: Clear error messages if download fails

## 🚀 Quick Start

### Simple Scanner Widget

```dart
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleBarcodeScanner(
        onBarcodeDetected: (barcode) {
          print('Scanned: ${barcode.text}');
        },
      ),
    );
  }
}
```

That's it! The scanner will:
1. Automatically download the model from Hugging Face on first use (~12MB)
2. Cache it locally for future use
3. Work completely offline after first download

### Advanced Usage with Custom Model Path

```dart
SimpleBarcodeScanner(
  modelPath: '/custom/path/to/model.rten',
  onBarcodeDetected: (barcode) {
    print('Scanned: ${barcode.text}');
  },
  onError: (error) {
    print('Scanner error: $error');
  },
)
```

### Manual Initialization (Optional)

```dart
// Initialize manually if you want to handle errors separately
try {
  await BarcodeScanner.initialize();
  print('Scanner ready!');
} catch (e) {
  print('Failed to initialize: $e');
}

// Or with custom path
await BarcodeScanner.initialize('/custom/path/to/model.rten');
```

## 🔧 API Options

### BarcodeScanner Class (Static Methods)

```dart
// Initialize with default model location
await BarcodeScanner.initialize();

// Initialize with custom path
await BarcodeScanner.initialize('/path/to/model.rten');

// Check if initialized
bool ready = BarcodeScanner.isInitialized;

// Get default model path
String path = await BarcodeScanner.getDefaultModelPath();

// Check if model exists
bool exists = BarcodeScanner.modelExists('/path/to/model.rten');

// Download model to specific path
await BarcodeScanner.downloadModel('/path/to/model.rten');
```

### SimpleBarcodeScanner Widget

```dart
SimpleBarcodeScanner(
  onBarcodeDetected: (BarcodeResult result) {
    // Handle scanned barcode
  },
  modelPath: '/optional/custom/path.rten',  // Optional
  config: ScannerConfig.pointOfSale(),      // Optional
  onError: (String error) {                 // Optional
    // Handle errors
  },
  loadingWidget: CircularProgressIndicator(), // Optional
)
```

## 📁 Model Storage

### Default Location
- **Desktop**: `./models/best.rten` (relative to current directory)
- **Mobile**: App documents directory (when using path_provider)

### Custom Location
Pass any path to `modelPath` parameter:
```dart
SimpleBarcodeScanner(
  modelPath: '/my/custom/models/best.rten',
  // ... other parameters
)
```

## 🌐 Model Source

- **URL**: https://huggingface.co/weebi/weebi_barcode_detector/resolve/main/best.rten
- **Size**: ~12.2 MB
- **License**: AGPL-3.0 (Ultralytics)
- **SHA256**: `48fc65ec220954859f147c85bc7422abd590d62648429d490ef61a08b973a10f`

## 🚨 Error Handling

The scanner will throw clear error messages:

```dart
try {
  await BarcodeScanner.initialize();
} catch (e) {
  if (e.toString().contains('HTTP')) {
    // Network error - check internet connection
    print('Download failed: Check internet connection');
  } else if (e.toString().contains('corrupted')) {
    // File corruption - will retry download
    print('Model corrupted - trying to re-download');
  } else {
    // Other initialization errors
    print('Scanner initialization failed: $e');
  }
}
```

## 📱 Migration from Asset-Based Setup

### Old Way (Manual Setup)
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/best.rten  # 12MB bundle size increase
```

```dart
// Had to manually copy model to assets
await BarcodeDetector.initialize('assets/best.rten');
```

### New Way (Auto-Download)
```dart
// No pubspec.yaml changes needed!
// No manual model management!

SimpleBarcodeScanner(
  onBarcodeDetected: (barcode) => print(barcode.text),
)
```

## 🏗️ Architecture

```
SimpleBarcodeScanner
    ↓
BarcodeScannerWidget  
    ↓
BarcodeDetector.initializeOrDownload()
    ↓
ModelManager.ensureModel()
    ↓
[Download from Hugging Face if needed]
    ↓
Initialize Rust FFI with model path
```

## 🎯 Benefits

1. **Smaller App Size**: No 12MB model bundled in APK/IPA
2. **Better UX**: No manual setup steps for developers
3. **Offline Support**: Works offline after first download  
4. **Flexibility**: Custom model paths supported
5. **Error Recovery**: Automatic retry and error handling
6. **Hot Reload Friendly**: Handles development scenarios gracefully

## 🔒 License Compliance

The YOLO model is licensed under AGPL-3.0. By automatically downloading it:
- ✅ Model is not embedded in your app binary
- ✅ Clear attribution and source documentation provided  
- ✅ License requirements are met through external loading

For commercial use, consider [Ultralytics Enterprise License](https://ultralytics.com/license).

---

**Ready to scan without the setup hassle!** 🎉 