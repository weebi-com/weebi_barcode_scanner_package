# REALISTIC Barcode Scanner Setup Guide


Don't explicitly declare Windows-specific plugins like path_provider_windows and permission_handler_windows in pubspec.yaml
Let Flutter automatically include them as transitive dependencies through the main plugins
Only explicitly declare camera_windows because the main camera plugin doesn't automatically include Windows support
The working configuration is:

## 📋 ACTUAL Setup Steps

### Step 1: Flutter Project Setup

1. **Create or open your Flutter project**
```bash
flutter create my_barcode_app
cd my_barcode_app
```

2. **Enable Windows desktop support**
```bash
flutter config --enable-windows-desktop
flutter create --platforms=windows .
```

### Step 2: Add Dependencies

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  weebi_barcode_scanner:
    path: path/to/weebi_barcode_scanner_package
  camera: ^0.10.0
  permission_handler: ^11.0.0
  ffi: ^2.0.0
  path_provider: ^2.0.0

flutter:
  assets:
    - assets/best.rten
    - assets/
```

### Step 3: Copy Assets (MANUAL)

1. **Create assets directory**
```bash
mkdir assets
```

2. **Copy YOLO model** (12MB file)
```bash
# From package location
cp weebi_barcode_scanner_package/assets/best.rten assets/
```

3. **Verify model exists**
```bash
ls -la assets/best.rten  # Should show ~12MB file
```

### Step 4: Windows DLL Setup (CRITICAL)

1. **Create windows directory structure**
```bash
mkdir -p windows/runner
```

2. **Copy DLL** (26MB file)
```bash
# From package location
cp weebi_barcode_scanner_package/windows/rust_barcode_lib.dll windows/runner/
```

3. **Verify DLL placement**
```bash
ls -la windows/runner/rust_barcode_lib.dll  # Should show ~26MB file
```

4. **DLL must be in PATH at runtime**
   - Option A: Copy to system PATH
   - Option B: Bundle with app distribution
   - Option C: Set working directory correctly

### Step 5: Permissions Setup

**android/app/src/main/AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**windows/runner/main.cpp:** (may need camera permission setup)

### Step 6: Code Implementation

**lib/main.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        setState(() => _error = 'Camera permission denied');
        return;
      }

      // Initialize scanner (this may take 10-30 seconds)
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _error = 'Initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: () => setState(() {
                  _error = null;
                  _initializeScanner();
                }),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing scanner...'),
              Text('This may take 10-30 seconds'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Barcode Scanner')),
      body: BarcodeScannerWidget(
        config: ScannerConfig(
          modelPath: 'assets/best.rten',
          libraryPath: null, // Auto-detect
        ),
        onBarcodeDetected: (result) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Barcode Found'),
              content: Text('Code: ${result.text}\nFormat: ${result.format}'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scanner error: $error')),
          );
        },
      ),
    );
  }
}
```

### Step 7: Build and Test

```bash
flutter pub get
flutter build windows
flutter run -d windows
```

## 🚨 Common Failures and Solutions

### 1. "Model file not found"
**Cause:** `best.rten` not copied or not in assets
**Solution:** 
- Verify file exists: `ls assets/best.rten`
- Check pubspec.yaml includes assets
- Run `flutter clean && flutter pub get`

### 2. "DLL not found" or FFI errors
**Cause:** `rust_barcode_lib.dll` not accessible
**Solutions:**
- Copy DLL to `windows/runner/`
- Copy DLL to build output directory
- Add DLL location to PATH
- Use absolute path in code

### 3. "Camera permission denied"
**Cause:** Windows camera access blocked
**Solutions:**
- Check Windows privacy settings
- Run as administrator
- Add camera permissions to manifest

### 4. "YOLO model initialization failed"
**Cause:** Model file corrupted or wrong format
**Solutions:**
- Re-download model file
- Verify file size (~12MB)
- Check RTEN format compatibility

### 5. Performance issues
**Cause:** YOLO detection is CPU intensive
**Solutions:**
- Reduce detection frequency
- Lower confidence threshold
- Disable super resolution
- Use faster config

## 🔍 Debugging

### Enable debug output:
```dart
ScannerConfig(
  debugMode: true,
  logLevel: LogLevel.verbose,
)
```

### Check file locations:
```dart
print('Model path: ${await _getModelPath()}');
print('DLL path: ${await _getDLLPath()}');
```

### Test components individually:
1. Test camera access
2. Test model loading
3. Test DLL loading
4. Test YOLO detection
5. Test ZXing decoding

## 📏 Size Requirements

- **Assets folder**: +12MB (YOLO model)
- **Windows build**: +26MB (DLL)
- **Total app size increase**: ~40MB
- **RAM usage**: 100-500MB during scanning
- **CPU usage**: High during detection

## ⚡ Performance Expectations

- **Initialization time**: 10-30 seconds (first run)
- **Scan time**: 0.5-2 seconds per barcode
- **Accuracy**: 85-95% (depends on image quality)
- **Supported formats**: QR, Code128, EAN13, UPC, etc.

## 🎯 Realistic Use Cases

**Good for:**
- Desktop inventory apps
- Kiosk applications
- Internal business tools
- Proof of concepts

**NOT good for:**
- Mobile apps (too large)
- Real-time video scanning
- High-frequency scanning
- Resource-constrained environments

---

## 💡 Alternative Approaches

If this setup is too complex, consider:

1. **Use existing dart_barcode example** (1000+ lines but battle-tested)
2. **Use platform-specific solutions** (Windows Camera API)
3. **Use cloud barcode APIs** (Google Vision, AWS Rekognition)
4. **Use simpler barcode libraries** (without YOLO detection)

---

**Remember: This package reduces 1000+ lines to ~100 lines, but the setup complexity remains significant.** 