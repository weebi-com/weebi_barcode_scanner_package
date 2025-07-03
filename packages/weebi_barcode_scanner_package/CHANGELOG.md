## 1.7.1

- fix windows example by removing permission handler

## 1.7.0

- bump openfood fact dep
- mono repo

## 1.6.8

- cleaning

## 1.6.7

- lower dart SDK

## 1.6.6

- bump weebi_openfoodfacts_service
- no need for credentials for open food fact calling
- richer integration (beauty facts + products fact) 

## 1.6.5

- fix windows dll path 
- UX reworked in simple case 
- example app refactored to use only the scanner package's API—no direct dependency or import of weebi_openfoodfacts_service.

## 1.6.4 

- add BarcodeDetector class

## 1.6.4

- **FIXED**: Improved automatic Navigator context detection in WeebiBarcodeScanner.scan() method
- Fixed Navigator context issues - now works like barcode_scan2 without requiring context parameter
- WeebiBarcodeScanner.scan() now properly finds Navigator context automatically

## 1.6.3

- **CRITICAL FIX**: Fixed missing dart_barcode model classes in published package
- Fixed .gitignore excluding required Dart source files
- Package now works properly when installed from pub.dev

## 1.6.2

- fix missing windows dep

## 1.6.1

- simple single scan example

## 1.5.0 - 2025-06-26

- lighter, faster, etc

## 1.4.0 - 2025-06-26

- better example
- macos
- bump dart_barcode

## 1.3.0 - 2025-06-25

- fix example

## 1.2.0 

- decouple dependencies

## 1.1.0 - 2025-01-16

- Removed dependency on separate `dart_barcode` package
- **Live Detection Overlay**: Green bounding boxes appear instantly when barcodes are detected
- **Visual Feedback**: Shows barcode location before successful decoding
- **Crosshair Guidance**: Blue crosshair helps users position camera when no barcode detected
- **Clean Interface**: Minimalist overlay without text clutter
- **User Reassurance**: Visual confirmation that detection system is actively working

- **Point-of-Sale Mode**: `ScannerConfig.pointOfSale()` - Single scan with haptic feedback
- **Continuous Mode**: `ScannerConfig.continuous()` - Multiple scans for inventory use
- **Simplified Configuration**: Removed complex Fast/Accurate modes for cleaner API

**🖥️ Cross-Platform Support:**
- **macOS Support**: Added `camera_macos` integration alongside Windows support
- **Platform Detection**: Automatic camera manager selection based on platform
- **Native Performance**: Platform-optimized camera handling

**📊 Enhanced Results:**
- **Location Data**: BarcodeResult now includes precise barcode coordinates
- **Confidence Scoring**: Detection confidence available (though not displayed by default)
- **Better Metadata**: Enhanced barcode format and positioning information
- Cleaner separation between public API and internal implementation

**🎨 User Interface:**
- **Split-Screen Example**: Camera preview (2/3) + product info panel (1/3)
- **Clean Scan History**: Simple display without technical clutter
- **Modern Design**: Professional point-of-sale ready interface
- **Responsive Layout**: Adapts to different screen sizes

**⚡ Performance Optimizations:**
- **Embedded Assets**: All models and libraries bundled efficiently
- **Memory Management**: Improved detection coordinate tracking
- **Real-Time Updates**: Smooth overlay rendering with minimal performance impact
- **Resource Cleanup**: Proper disposal of detection state

**🎯 Configuration Examples:**
```dart
// Point-of-sale: Single scan with haptic feedback
ScannerConfig.pointOfSale()

// Continuous: Multiple scans for inventory
ScannerConfig.continuous()
```

## 0.2.0+1 FFI Integration Fixed!

- Camera integration testing
- Full barcode detection pipeline verification
- Re-enable OpenFoodFacts product lookup
- Performance optimization

---

## 0.1.0+1 Initial Release

## 0.5.0

### BREAKING CHANGES - Core Architecture Separation

**Major refactoring**: Extracted core barcode detection logic into separate `weebi_barcode_dart` package for better modularity and reusability.

#### New Architecture
- **Core Package**: [`weebi_barcode_dart`](https://github.com/weebi-com/weebi_barcode_dart) - Pure Dart barcode detection with FFI interface
- **UI Package**: `weebi_barcode_scanner` - Flutter widget layer with camera integration
- **Service Package**: [`weebi_openfoodfacts_service`](https://github.com/weebi-com/weebi_openfoodfacts_service) - Product information service

#### Changes Made
- ✅ Extracted embedded `dart_barcode` logic to external `weebi_barcode_dart` package
- ✅ Simplified dependency management - no more embedded FFI code
- ✅ Improved modularity - core detection can be used in any Dart/Flutter project
- ✅ Enhanced API consistency between packages
- ✅ Added comprehensive documentation and examples

#### Migration Guide
No changes required for existing users - the public API remains the same:
```dart
BarcodeScannerWidget(
  onBarcodeDetected: (result) {
    print('Detected: ${result.text}');
  },
)
```

#### Benefits
- 🎯 **Reusable Core**: Use barcode detection in any Dart project
- 🏗️ **Better Architecture**: Clear separation between detection, UI, and services
- 📦 **Simplified Dependencies**: Cleaner package structure
- 🔧 **Framework Agnostic**: Core detection works outside Flutter
- 📚 **Better Documentation**: Each package has focused documentation

---

## 0.4.0

### OpenFoodFacts Integration & Point-of-Sale Features

#### New Features
- ✅ **OpenFoodFacts Integration**: Automatic product information lookup for food barcodes
- ✅ **Point-of-Sale Mode**: Optimized for single quick scans with haptic feedback
- ✅ **Split-Screen UI**: Camera preview (left) + product information (right)
- ✅ **Cross-Platform Camera**: Added macOS support via `camera_macos` package
- ✅ **Enhanced Product Display**: Nutri-Score, NOVA groups, allergen warnings

#### Scanner Configurations
- `ScannerConfig.continuous()` - Continuous scanning for inventory management
- `ScannerConfig.pointOfSale()` - Single scan mode with haptic feedback and auto-stop

#### OpenFoodFacts Features
- Real-time product information display
- Nutri-Score with color coding (A-E)
- NOVA group classification (1-4)
- Allergen warnings with visual chips
- Ingredients display
- Product images and branding

#### Technical Improvements
- Enhanced error handling for API calls
- Loading states during product lookup
- Barcode format validation for food products
- Professional point-of-sale ready interface

---

## 0.3.0

### Quality & Reliability Improvements

#### Code Quality Fixes
- ✅ **Zero Linting Issues**: Fixed all snake_case to camelCase naming
- ✅ **All Tests Passing**: Added missing ScannerConfig factory methods
- ✅ **API Completeness**: Fixed BarcodeResult missing properties
- ✅ **Performance**: Applied const constructors throughout

#### Critical Bug Fixes
- ✅ **FFI Integration**: Fixed "Failed to lookup symbol 'sdk_init'" error
- ✅ **DLL Rebuild**: Updated rust_barcode_lib.dll with all required function exports
- ✅ **Dependency Issues**: Resolved missing dependencies in Rust build

#### Enhanced API
- Added `BarcodeResult.toString()` method
- Added `hasProductInfo` property
- Fixed constructor vs static constant naming conflicts
- Improved error messages and debugging output

---

## 0.2.0+1

### Initial Working Release

#### Core Features
- ✅ **YOLO Detection**: Embedded neural network for high-accuracy barcode detection
- ✅ **Windows Support**: Optimized for Windows development with proper FFI integration
- ✅ **Camera Integration**: Real-time camera preview with detection overlay
- ✅ **Multiple Formats**: Support for EAN-13, Code 128, QR codes, and more

#### Technical Implementation
- Fixed Flutter example project structure
- Rebuilt Rust FFI library with correct function exports
- Added comprehensive error handling
- Implemented hot reload support

#### Package Structure
- Complete pub package with proper pubspec.yaml
- Example Flutter application
- Asset bundling for YOLO model files
- Cross-platform build configuration

---

## 0.1.0

### Initial Release (Non-functional)

- Basic package structure
- Embedded YOLO model
- Initial FFI bindings (broken)
- Basic documentation
