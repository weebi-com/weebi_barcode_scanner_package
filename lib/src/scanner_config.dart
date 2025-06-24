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
  
  /// Timeout for scanning operations
  final Duration timeout;
  
  /// Whether to enable image enhancement
  final bool enableImageEnhancement;
  
  /// Whether to enable preprocessing
  final bool enablePreprocessing;
  
  /// Whether to enable debug mode
  final bool debugMode;
  
  const ScannerConfig({
    this.modelPath = 'assets/best.rten',
    this.useSuperResolution = true,
    this.enableProductLookup = true,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.scanInterval = const Duration(seconds: 1),
    this.timeout = const Duration(seconds: 15),
    this.enableImageEnhancement = true,
    this.enablePreprocessing = true,
    this.debugMode = false,
  });
  
  /// Default configuration - works out of the box
  const ScannerConfig.defaultConfig({
    this.modelPath = 'assets/best.rten',
    this.useSuperResolution = true,
    this.enableProductLookup = true,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.scanInterval = const Duration(seconds: 1),
    this.timeout = const Duration(seconds: 15),
    this.enableImageEnhancement = true,
    this.enablePreprocessing = true,
    this.debugMode = false,
  });
  
  /// High-performance configuration - faster scanning
  const ScannerConfig.fast({
    this.modelPath = 'assets/best.rten',
    this.useSuperResolution = false, // Faster processing
    this.enableProductLookup = false, // Skip product lookup for speed
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.scanInterval = const Duration(milliseconds: 500),
    this.timeout = const Duration(seconds: 5),
    this.enableImageEnhancement = false,
    this.enablePreprocessing = false,
    this.debugMode = false,
  });
  
  /// Accuracy-focused configuration - best results
  const ScannerConfig.accurate({
    this.modelPath = 'assets/best.rten',
    this.useSuperResolution = true,
    this.enableProductLookup = true,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.scanInterval = const Duration(milliseconds: 1500), // More time per scan
    this.timeout = const Duration(seconds: 30),
    this.enableImageEnhancement = true,
    this.enablePreprocessing = true,
    this.debugMode = false,
  });
  
  // Keep static constants for backward compatibility
  static const ScannerConfig defaultConfiguration = ScannerConfig.defaultConfig();
  static const ScannerConfig fastConfiguration = ScannerConfig.fast();
  static const ScannerConfig accurateConfiguration = ScannerConfig.accurate();
} 