import 'package:flutter/material.dart';

/// Configuration for the barcode scanner
class ScannerConfig {
  /// Path to the YOLO model file (best.rten)
  /// Defaults to 'assets/best.rten'
  final String modelPath;
  
  /// Whether to use super resolution for better 1D barcode reading
  /// Improves accuracy for damaged or low-quality barcodes
  final bool useSuperResolution;
  
  /// Whether to enable product lookup (OpenFoodFacts integration)
  /// Requires internet connection for product information
  final bool enableProductLookup;
  
  /// Whether to show the scanning overlay rectangle
  final bool showOverlay;
  
  /// Custom overlay color (default: green)
  final Color overlayColor;
  
  /// Scanning interval in seconds (default: 1 second)
  /// Lower values = faster scanning but more CPU usage
  final Duration scanInterval;
  
  const ScannerConfig({
    this.modelPath = 'assets/best.rten',
    this.useSuperResolution = true,
    this.enableProductLookup = true,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.scanInterval = const Duration(seconds: 1),
  });
  
  /// Default configuration - works out of the box
  static const ScannerConfig defaultConfig = ScannerConfig();
  
  /// High-performance configuration - faster scanning
  static const ScannerConfig fastConfig = ScannerConfig(
    scanInterval: Duration(milliseconds: 500),
    useSuperResolution: false, // Faster processing
  );
  
  /// Accuracy-focused configuration - best results
  static const ScannerConfig accurateConfig = ScannerConfig(
    useSuperResolution: true,
    scanInterval: Duration(milliseconds: 1500), // More time per scan
  );
} 