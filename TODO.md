to merge the two macos libs

lipo -create \
  path/to/x86_64/binary \
  path/to/arm64/binary \
  -output path/to/universal/binary
