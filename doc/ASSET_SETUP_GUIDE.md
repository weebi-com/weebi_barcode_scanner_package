# Asset Setup Guide 📦

This package requires native assets that **must be provided by the consuming application**. The package intentionally does NOT bundle these assets to avoid bloating your app with unnecessary platform libraries.

## 🎯 **Why External Assets?**

- **Package Size**: Avoids 78+ MB of bloat in the package
- **Platform Optimization**: Only include assets for your target platforms  
- **Licensing Compliance**: Model files require separate attribution
- **CI/CD Efficiency**: Faster package downloads and builds

---

## 📋 **Required Assets by Platform**

### 🔧 **All Platforms**
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

**Source**: Build from `rust-barcode-lib/` or download from GitHub releases  
**Architecture**: x64  
**Dependencies**: Visual C++ Redistributable 2019+

### 🍎 **macOS**
```yaml
# pubspec.yaml  
flutter:
  assets:
    - macos/Frameworks/librust_barcode_lib.dylib  # 22 MB (universal)
```

**Source**: Build via GitHub Actions or locally on macOS  
**Architectures**: Universal (Intel + Apple Silicon)  
**Framework**: Place in `macos/Frameworks/` directory
***

flutter:
  assets:
    - assets/best.rten
    # Include only your target platforms:
    - windows/rust_barcode_lib.dll        # Windows
    - macos/Frameworks/                    # macOS
    - android/jniLibs/                     # Android
    - ios/Frameworks/                      # iOS
```

---

## 📁 **Directory Structure Example**

```
your_flutter_app/
├── assets/
│   └── best.rten                           # 11.68 MB (all platforms)
├── windows/
│   └── rust_barcode_lib.dll               # 10.87 MB (Windows only)
├── macos/
│   └── Frameworks/
│       └── librust_barcode_lib.dylib      # 22 MB (macOS only)
├── android/
│   └── jniLibs/
│       ├── arm64-v8a/librust_barcode_lib.so
│       ├── armeabi-v7a/librust_barcode_lib.so
│       └── x86_64/librust_barcode_lib.so
├── ios/
│   └── Frameworks/
│       └── librust_barcode_lib.dylib
└── pubspec.yaml
```

---


### **Conditional Loading**
The package automatically detects available assets and loads only what's needed for the current platform.

---

## 🔍 **Verification**

Check that assets are properly configured:

```dart
// Verify native library availability
final isAvailable = await WeebiBarcodeScanner.isNativeLibraryAvailable();
print('Native library available: $isAvailable');

// Check model file
final hasModel = await WeebiBarcodeScanner.hasModelFile();
print('Model file available: $hasModel');
```

---

## 🆘 **Troubleshooting**

### **"Native library not found"**
- ✅ Check that `.dll`/`.dylib`/`.so` files are in `flutter/assets/` 
- ✅ Verify `pubspec.yaml` includes the correct asset paths
- ✅ Run `flutter clean && flutter pub get`

### **"Model file not found"**  
- ✅ Download `best.rten` from Hugging Face
- ✅ Place in `assets/best.rten`
- ✅ Verify file size is ~11.68 MB

### **Windows: "DLL load failed"**
- ✅ Install Visual C++ Redistributable 2019+
- ✅ Check Windows version compatibility

### **macOS: "dylib cannot be opened"**
- ✅ Run `codesign --force --deep --sign - path/to/lib.dylib`
- ✅ Check security settings allow unsigned libraries

---

## 📄 **License Attribution**

When using the YOLO model (`best.rten`), include this attribution:

```
Model: YOLO Barcode Detector
Source: https://huggingface.co/weebi/weebi_barcode_detector  
License: AGPL-3.0 (Ultralytics)
```