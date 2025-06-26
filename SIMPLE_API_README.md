# Simple Barcode Scanner API

This package provides an elegant, one-line API for barcode scanning, similar to the popular `barcode_scan2` package.

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

## Features

✅ **One-line API** - Just like `barcode_scan2`  
✅ **Full-screen scanner** - Beautiful, professional UI  
✅ **Automatic detection** - Returns immediately when barcode is found  
✅ **User-friendly** - Cancel button, flash toggle, clear instructions  
✅ **Cross-platform** - Works on Windows, macOS, Android, iOS  

## API Reference

### WeebiBarcodeScanner.scan()

```dart
static Future<WeebiBarcodeResult> scan({
  BuildContext? context,           // Optional: provide context
  ScannerConfig? config,          // Optional: scanner configuration  
  String? title,                  // Optional: custom title
  String? subtitle,               // Optional: instruction text
  bool showFlashToggle = true,    // Show flash button
  bool showGalleryButton = false, // Show gallery picker button
})
```

### WeebiBarcodeResult

```dart
class WeebiBarcodeResult {
  final String? code;      // The scanned barcode text
  final String? format;    // Barcode format (QR_CODE, EAN_13, etc.)
  final String? error;     // Error message if failed
  final bool cancelled;    // True if user cancelled
  
  bool get isSuccess;      // True if scan was successful
  bool get isCancelled;    // True if user cancelled
  bool get hasError;       // True if there was an error
}
```

## Examples

### Basic Usage

```dart
// Simple scan
final result = await WeebiBarcodeScanner.scan();
```

### With Custom Options

```dart
final result = await WeebiBarcodeScanner.scan(
  context: context,
  title: 'Scan Product Barcode',
  subtitle: 'Point your camera at a product barcode',
  showFlashToggle: true,
  showGalleryButton: false,
);
```

### Handling Results

```dart
try {
  final result = await WeebiBarcodeScanner.scan();
  
  if (result.isSuccess) {
    // Successfully scanned
    String barcode = result.code!;
    String format = result.format!;
    
    // Do something with the barcode
    await processBarcode(barcode);
    
  } else if (result.isCancelled) {
    // User pressed cancel or back button
    showMessage('Scan cancelled');
    
  } else if (result.hasError) {
    // Something went wrong
    showError('Scan failed: ${result.error}');
  }
  
} catch (e) {
  // Handle exceptions
  showError('Failed to start scanner: $e');
}
```

## Comparison with barcode_scan2

| Feature | barcode_scan2 | WeebiBarcodeScanner |
|---------|---------------|-------------------|
| API Style | `BarcodeScanner.scan()` | `WeebiBarcodeScanner.scan()` |
| Result Type | `ScanResult` | `WeebiBarcodeResult` |
| Platforms | Android, iOS | Windows, macOS, Android, iOS |
| Dependencies | Native plugins | Pure Dart + Camera |
| Model | External scanner | Built-in YOLO detection |
| Customization | Limited | Highly customizable |

## Migration from barcode_scan2

Replace this:
```dart
import 'package:barcode_scan2/barcode_scan2.dart';

var result = await BarcodeScanner.scan();
print(result.rawContent);
```

With this:
```dart
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

var result = await WeebiBarcodeScanner.scan();
print(result.code);
```

## Advanced Usage

For more complex scenarios, you can still use the full `BarcodeScannerWidget`:

```dart
BarcodeScannerWidget(
  onBarcodeDetected: (barcode) {
    // Handle continuous scanning
  },
  config: ScannerConfig.continuousMode,
)
```

## Demo

See `example/lib/simple_scanner_demo.dart` for a complete working example.

The main example app includes a "Simple Scanner" button that demonstrates this API. 