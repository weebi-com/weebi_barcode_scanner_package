### Testing Infrastructure
- `rust-barcode/tests/integration_tests.rs`: Comprehensive test suite
- `rust-barcode/src/bin/compare_models.rs`: Model comparison tool
- `rust-barcode/src/bin/threshold_test.rs`: Threshold optimization tool
- `rust-barcode/src/debug_pipeline.rs`: Debug utilities

# test dart 

cd dart_barcode
dart test test/rust_ffi_test.dart

# rust testing main.rs

## helpers
when --sr-model is provided 
super resolution + unsharp + deskewing attemps (-5° && +5°) 
--binarization sauvola or wolf-jolion or adaptive
--clahe-clip-limit <float> and --clahe-grid-size <int>
--denoise-sigma 0.38 
--binarization sauvola --debug-images --sauvola-radius 15 --sauvola-k 0.3
--gamma 1.5
--process-all flag for power users who need to analyze every barcode in an image

cd rust-barcode

## images
../data/257670HA64SM.jpg
../data/019639CC3S.jpg
../data/2E2412D90236.jpg
../data/1H1406D40232.jpg
../data/070915CC76S.jpg
../data/071681FD18T4.jpg
../data/070901CKAAM.jpg
../data/0011041ADC.jpg
../data/000833G_OJ.jpg
../data/qrh.jpg

 --debug-images --sr-model super-resolution-10.rten

## OK
cargo run --release --bin rust-barcode best.rten ../data/257670HA64SM.jpg
cargo run --release --bin rust-barcode best.rten ../data/qr.png
cargo run --release --bin rust-barcode best.rten ../data/qrh.jpg
cargo run --release --bin rust-barcode best.rten ../data/019639CC3S.jpg 

cargo run --release --bin rust-barcode best.rten ../data/1H1406D40232.jpg --sr-model super-resolution-10.rten --debug-images
text 1N4066232 != 1H1406D40232

## No barcodes found

cargo run --release --bin rust-barcode best.rten ../data/2E2412D90236.jpg --sr-model super-resolution-10.rten --debug-images 

cargo run --release --bin rust-barcode best.rten ../data/800446E_01XL.jpg --debug-images --sr-model super-resolution-10.rten



### Test Super Resolution
`cargo run --release --bin rust-barcode best.rten ../data/019639CC3S.jpg --sr-model super-resolution-10.rten --debug-images`