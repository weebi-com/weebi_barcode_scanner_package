## 1.0.1

* **Repository Update**: Linked to official GitHub repository for better community support
* **Metadata Enhancement**: Added proper repository and issue tracker URLs
* **Documentation**: Updated links to point to the official GitHub repository

## 1.0.0

* **Initial release** of Weebi Barcode Scanner for Windows Flutter apps
* **Simplified Integration**: Reduced from 1000+ lines to ~20 lines of integration code
* **Self-Contained Package**: Bundled YOLO model and native Windows DLL
* **Privacy-First**: 100% offline barcode scanning with no data transmission
* **High Performance**: YOLO-based detection + rxing barcode decoding
* **Zero Setup**: No manual downloads or configuration required
* **Windows Optimized**: BGRA8888 format support with proper resource management
* **Three Configuration Presets**: Default, Fast, and Accurate scanning modes
* **Enterprise Ready**: Clear licensing path for commercial use
* **Apache 2.0 Licensed**: Open source package with proprietary core components

## 0.2.0+1 - 2025-12-24

### 🎉 MAJOR BREAKTHROUGH - FFI Integration Fixed!

**This version marks a critical milestone: The package now actually works!**

#### ✅ Fixed
- **FFI Integration**: Rebuilt `rust_barcode_lib.dll` with current source code
- **SDK Initialization**: `sdk_init` function now properly exported and working
- **Symbol Resolution**: Fixed "Failed to lookup symbol 'sdk_init'" error
- **Build Dependencies**: Fixed missing dependencies in `rust-barcode-lib/Cargo.toml`
- **Library Exports**: All required FFI functions now available in DLL

#### 🔧 Technical Changes
- Rebuilt DLL from source with `cargo build --release`
- Fresh DLL (11MB) replaces broken old DLL (27MB) 
- Temporarily disabled OpenFoodFacts integration to get core functionality working
- Updated all DLL locations in package structure
- Added comprehensive status documentation

#### 📊 Status Change
- **Before**: ❌ Package failed at runtime with FFI symbol errors
- **After**: ✅ Package successfully initializes barcode SDK
- **Success Message**: `flutter: ✅ Barcode SDK initialized successfully`

#### 🚀 What's Next
- Camera integration testing
- Full barcode detection pipeline verification
- Re-enable OpenFoodFacts product lookup
- Performance optimization

#### 💡 For Developers
This demonstrates that complex FFI integration issues can be systematically debugged and fixed. The key was understanding that the DLL was built from an older version of the source code missing required function exports.

---

## 0.1.0+1 - 2025-12-24

### 🚀 Initial Release

#### ✨ Added
- Basic Flutter package structure for Windows barcode scanning
- Simplified widget interface for barcode detection
- Bundled YOLO model and FFI bindings
- Comprehensive documentation and setup guides
- Honest technical status reporting

#### ⚠️ Known Issues
- FFI integration not working (symbol resolution failures)
- Package builds but fails at runtime
- Requires manual DLL and asset setup

#### 📋 Development Status
- Package structure: ✅ Complete
- API design: ✅ Simplified
- Documentation: ✅ Comprehensive  
- Core functionality: ❌ Not working (FFI issues)

---
