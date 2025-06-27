# macOS Build Guide for Rust Barcode Library

This guide explains how to build the Rust barcode library for macOS from a Windows development environment.

## 🚨 **Challenge: Cross-Compilation Limitations**

Building Rust libraries for macOS from Windows faces significant challenges:

### **Primary Issue: C Dependencies**
- Our Rust library uses `ring` (cryptographic library) which contains C code
- Cross-compiling C code requires target-specific toolchain (headers, libraries, linker)
- macOS SDK and toolchain are not available on Windows/Linux by default
- Apple's licensing restricts redistribution of macOS development tools

### **What Fails During Cross-Compilation**
```
error: failed to find tool "x86_64-apple-darwin-clang": program not found
```

The build system looks for macOS-specific C compiler that doesn't exist on Windows.

## 🛠️ **Solution Options**

### **Option 1: GitHub Actions (RECOMMENDED) ✅**

Use macOS runners in CI/CD for automatic builds.

**Advantages:**
- ✅ Official macOS environment with proper toolchain
- ✅ Automatic builds on code changes  
- ✅ No local setup required
- ✅ Supports both Intel and Apple Silicon
- ✅ Free for public repositories

**Setup:**
1. The workflow is already configured in `.github/workflows/build-macos.yml`
2. Push your code to GitHub
3. Download artifacts from the Actions tab
4. Place libraries in appropriate directories

**Workflow Details:**
```yaml
name: Cross-compile to macOS
on: [push, pull_request]
jobs:
  build-macos:
    runs-on: macos-latest
    strategy:
      matrix:
        target: [x86_64-apple-darwin, aarch64-apple-darwin]
```

### **Option 2: Docker with OSXCross 🐳**

Use Linux container with OSXCross toolchain.

**Advantages:**
- ✅ Consistent build environment
- ✅ Works on any platform with Docker
- ✅ Reproducible builds

**Disadvantages:**
- ❌ Requires macOS SDK (must download from Apple)
- ❌ Complex setup process
- ❌ Licensing considerations for SDK

**Setup:**
1. Download macOS SDK from Apple Developer portal
2. Use provided `docker-macos-cross.dockerfile`
3. Build container and compile

### **Option 3: WSL + OSXCross 🐧**

Similar to Docker but using Windows Subsystem for Linux.

**Setup:**
```bash
# In WSL Ubuntu
sudo apt update
sudo apt install clang git cmake

# Clone and setup OSXCross
git clone https://github.com/tpoechtrager/osxcross.git
cd osxcross

# Download MacOSX SDK and place in tarballs/
# Build toolchain
./build.sh

# Add to PATH
export PATH="$PWD/target/bin:$PATH"

# Cross-compile
cd /path/to/rust-barcode-lib
CC=x86_64-apple-darwin22-clang \
RUSTFLAGS="-Clinker=x86_64-apple-darwin22-clang" \
cargo build --release --target x86_64-apple-darwin
```

### **Option 4: Remote macOS Machine 🖥️**

Build directly on macOS hardware.

**Advantages:**
- ✅ Native environment, no complications
- ✅ All toolchain available by default
- ✅ Can test immediately

**Disadvantages:**
- ❌ Requires access to Mac hardware
- ❌ Manual build process

## 🎯 **Recommended Workflow**

### **For Development:**
Use **GitHub Actions** (Option 1) for automatic builds:

1. **Code on Windows** - Develop using the existing Windows setup
2. **Test Cross-Platform** - Push to GitHub to trigger macOS builds
3. **Download Artifacts** - Get compiled `.dylib` files from Actions
4. **Integrate Locally** - Place libraries in Flutter project for testing

### **For Production:**
Set up **automated release pipeline**:

1. **Tag Release** - Create version tag (e.g., `v1.3.0`)
2. **Auto-Build** - GitHub Actions builds all platforms
3. **Create Release** - Automatically create GitHub release with binaries
4. **Distribute** - Users download platform-specific packages

## 📁 **Library Placement**

After building, place the macOS libraries in these directories:

```
dart_barcode/macos/
├── librust_barcode_lib.dylib              # Default (ARM64)
├── librust_barcode_lib_x86_64.dylib       # Intel
└── librust_barcode_lib_aarch64.dylib      # Apple Silicon

weebi_barcode_scanner_package/macos/
├── librust_barcode_lib.dylib
├── librust_barcode_lib_x86_64.dylib  
└── librust_barcode_lib_aarch64.dylib

weebi_barcode_scanner_package/example/macos/
├── librust_barcode_lib.dylib
├── librust_barcode_lib_x86_64.dylib
└── librust_barcode_lib_aarch64.dylib
```

## 🧪 **Testing macOS Builds**

### **On macOS Machine:**
```bash
cd weebi_barcode_scanner_package/example
flutter run -d macos
```

### **Universal Binary Creation:**
If you have both architecture libraries, create universal binary on macOS:
```bash
lipo -create \
  librust_barcode_lib_x86_64.dylib \
  librust_barcode_lib_aarch64.dylib \
  -output librust_barcode_lib.dylib
```

## 🔧 **Troubleshooting**

### **Common Issues:**

**1. "dylib not found" errors:**
- Ensure library is in correct directory
- Check file permissions
- Verify architecture matches

**2. GitHub Actions failing:**
- Check workflow file syntax
- Ensure repository has Actions enabled
- Review build logs for specific errors

**3. Library architecture mismatch:**
- Intel Macs need `x86_64` version
- Apple Silicon Macs need `aarch64` version
- Universal binary works on both

### **Debug Commands:**
```bash
# Check library architecture
file librust_barcode_lib.dylib

# List dependencies
otool -L librust_barcode_lib.dylib

# Verify universal binary
lipo -info librust_barcode_lib.dylib
```

## 📝 **Summary**

**✅ WORKING SOLUTION:**
- Use GitHub Actions for automated macOS builds
- Download artifacts and place in Flutter project
- Test on actual macOS hardware

**⚠️ LIMITATIONS:**
- Cannot cross-compile directly from Windows due to C dependencies
- Requires CI/CD or actual macOS machine for building
- Manual artifact download and placement required

**🚀 NEXT STEPS:**
1. Push code to GitHub to trigger first macOS build
2. Download artifacts from Actions tab
3. Test on macOS machine with `flutter run -d macos`
4. Set up automated release pipeline for production

This approach provides a practical solution for developing cross-platform Rust libraries while working primarily on Windows. 