Pod::Spec.new do |spec|
  spec.name          = 'weebi_barcode_scanner'
  spec.version       = '0.0.1'
  spec.license       = { :file => '../LICENSE' }
  spec.homepage      = 'https://github.com/weebi-com/weebi_barcode_scanner'
  spec.authors       = { 'Weebi' => 'contact@weebi.com' }
  spec.summary       = 'Advanced barcode scanner using YOLO-based detection with Rust backend'
  spec.description   = <<-DESC
Advanced barcode scanner with YOLO-based detection, featuring high accuracy barcode recognition 
for damaged and low-quality barcodes using a Rust-powered backend.
                       DESC

  spec.source        = { :path => '.' }
  spec.source_files  = 'Classes/**/*'
  spec.dependency 'FlutterMacOS'

  spec.platform = :osx, '10.11'
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
  spec.swift_version = '5.0'

  # Native library configuration
  spec.vendored_libraries = 'Frameworks/librust_barcode_lib_*.dylib'
  
  # Prepare command to select correct architecture
  spec.prepare_command = <<-CMD
    # Create universal binary for better compatibility
    if [ -f "Frameworks/librust_barcode_lib_x86_64.dylib" ] && [ -f "Frameworks/librust_barcode_lib_aarch64.dylib" ]; then
      lipo -create "Frameworks/librust_barcode_lib_x86_64.dylib" "Frameworks/librust_barcode_lib_aarch64.dylib" -output "Frameworks/librust_barcode_lib.dylib"
    elif [ -f "Frameworks/librust_barcode_lib_x86_64.dylib" ]; then
      cp "Frameworks/librust_barcode_lib_x86_64.dylib" "Frameworks/librust_barcode_lib.dylib"
    elif [ -f "Frameworks/librust_barcode_lib_aarch64.dylib" ]; then
      cp "Frameworks/librust_barcode_lib_aarch64.dylib" "Frameworks/librust_barcode_lib.dylib"
    fi
  CMD
end 