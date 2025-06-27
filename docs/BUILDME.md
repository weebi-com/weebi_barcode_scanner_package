BUILDME.md

## BUILD For Flutter app
```bash
.\build_android.ps1
.\build_windows.ps1
```

If you prefer the .so to be self-contained use the feature-flag

If the embed_model feature is enabled during the build (e.g., cargo build --features embed_model), it will use include_bytes!("models/best.rten") and Model::decode().
--features embed_model

cd rust-barcode-lib
cargo build --target aarch64-linux-android --release 

// Then copy it to flutter_zxing/example/
copy target\aarch64-linux-android\release\librust_barcode_lib.so ..\flutter_zxing\example\

cd ../flutter_zxing/example

## BUILD For DART FFI tests
cargo clean
cd rust-barcode-lib
$env:RUST_LOG="debug"
cargo build --release --features embed_model
// Then copy rust-barcode-lib.dll from rust-barcode-lib/target/release/ to dart_barcode/
copy target\release\rust_barcode_lib.dll ..\dart_barcode\
