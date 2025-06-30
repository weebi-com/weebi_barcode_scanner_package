// Copyright 2025 Weebi SAS
// Licensed under the Apache License, Version 2.0

import 'package:flutter_test/flutter_test.dart';

import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

void main() {
  group('BarcodeResult', () {
    test('creates a valid BarcodeResult', () {
      const result = BarcodeResult(
        text: '1234567890123',
        format: 'EAN-13',
      );
      
      expect(result.text, '1234567890123');
      expect(result.format, 'EAN-13');
      expect(result.productName, isNull);
      expect(result.productBrand, isNull);
      expect(result.hasProductInfo, isFalse);
    });
    
    test('creates BarcodeResult with product info', () {
      const result = BarcodeResult(
        text: '1234567890123',
        format: 'EAN-13',
        productName: 'Test Product',
        productBrand: 'Test Brand',
        product: null,
      );
      
      expect(result.hasProductInfo, isFalse);
      expect(result.productName, 'Test Product');
      expect(result.productBrand, 'Test Brand');
    });
    
    test('toString returns expected format', () {
      const result = BarcodeResult(
        text: '1234567890123',
        format: 'EAN-13',
      );
      
      expect(result.toString(), 'BarcodeResult(text: 1234567890123, format: EAN-13)');
    });
  });
  
  group('ScannerConfig', () {
    test('creates continuous config', () {
      const config = ScannerConfig.continuous();
      
      expect(config.timeout, const Duration(seconds: 15));
      expect(config.enableImageEnhancement, isTrue);
      expect(config.enablePreprocessing, isTrue);
      expect(config.debugMode, isFalse);
      expect(config.scanOnce, isFalse);
    });
    
    test('creates point-of-sale config', () {
      const config = ScannerConfig.pointOfSale();
      
      expect(config.timeout, const Duration(seconds: 10));
      expect(config.scanInterval, const Duration(milliseconds: 500));
      expect(config.scanOnce, isTrue);
      expect(config.enableHapticFeedback, isTrue);
    });
    
    test('creates default config', () {
      const config = ScannerConfig();
      
      expect(config.timeout, const Duration(seconds: 15));
      expect(config.enableImageEnhancement, isTrue);
      expect(config.enablePreprocessing, isTrue);
      expect(config.debugMode, isFalse);
      expect(config.scanOnce, isFalse);
    });
  });
}
