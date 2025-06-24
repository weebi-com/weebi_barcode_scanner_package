# Bundled Components

This package includes several bundled components to provide a seamless integration experience:

## 1. Weebi YOLO Barcode Detection Model (`best.rten`)

- **File**: `assets/best.rten`
- **Source**: [Hugging Face - weebi/weebi_barcode_detector](https://huggingface.co/weebi/weebi_barcode_detector)
- **License**: AGPL-3.0 (Ultralytics YOLOv8)
- **Size**: ~12.2MB
- **Purpose**: Barcode detection AI model for accurate barcode localization

### Commercial Use
For commercial applications, you must obtain:
- **Ultralytics Enterprise License** for the YOLO model
- **Weebi Enterprise License** for commercial model usage

## 2. Weebi Rust Barcode Library (`rust_barcode_lib.dll`)

- **File**: `windows/rust_barcode_lib.dll`
- **Architecture**: Windows x64
- **License**: Proprietary (Weebi SAS)
- **Size**: ~2.1MB
- **Purpose**: High-performance barcode processing and rxing integration

### Features
- YOLO model inference via RTEN runtime
- Image preprocessing and enhancement
- rxing barcode decoding
- Windows-optimized BGRA8888 image handling

### Commercial Use
Commercial usage requires a **Weebi Enterprise License**.
The bundled DLL is provided for evaluation purposes only.

## 3. Dart FFI Bindings

- **Files**: `lib/dart_barcode/`
- **License**: Proprietary (Weebi SAS)
- **Purpose**: Flutter FFI integration with the Rust library

### Key Components
- `dart_barcode_base.dart`: Core FFI bindings
- `image_processing.dart`: Image format handling
- `models/enhanced_image_buffer.dart`: Image buffer management
- `utils/image_utils.dart`: Utility functions

## License Compliance

When using this package:

1. **Include attribution** in your app credits
2. **Respect AGPL-3.0** for the YOLO model
3. **Contact Weebi** for enterprise licensing
4. **Review usage rights** for your specific use case

## Support

For questions about bundled components:
- **Technical Support**: hello@weebi.com