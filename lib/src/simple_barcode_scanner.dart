import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'barcode_result.dart';
import 'barcode_scanner_widget.dart';
import 'scanner_config.dart';

/// Simple barcode scanner API similar to barcode_scan2
/// 
/// Provides a clean, one-line API to scan barcodes:
/// ```dart
/// var result = await WeebiBarcodeScanner.scan();
/// ```
class WeebiBarcodeScanner {
  /// Scan a single barcode using the camera
  /// 
  /// Opens a full-screen scanning interface and returns when a barcode
  /// is detected or the user cancels.
  /// 
  /// Returns a [WeebiBarcodeResult] containing the scanned data or error information.
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final result = await WeebiBarcodeScanner.scan();
  ///   if (result.isSuccess) {
  ///     print('Scanned: ${result.code}');
  ///   } else {
  ///     print('Scan cancelled or failed');
  ///   }
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  static Future<WeebiBarcodeResult> scan({
    ScannerConfig? config,
    String? title,
    String? subtitle,
    bool showFlashToggle = true,
    bool showGalleryButton = false,
  }) async {
    try {
      // Get current context automatically
      final navigatorContext = _getCurrentContext();
      if (navigatorContext == null) {
        return WeebiBarcodeResult.error('No valid context found. Ensure you have a MaterialApp in your widget tree and call scan() from within a widget.');
      }

      // Use default config if none provided
      final scannerConfig = config ?? ScannerConfig();

      // Navigate to full-screen scanner
      final result = await Navigator.of(navigatorContext).push<WeebiBarcodeResult>(
        MaterialPageRoute(
          builder: (context) => _SimpleScannerScreen(
            config: scannerConfig,
            title: title ?? 'Scan Barcode',
            subtitle: subtitle,
            showFlashToggle: showFlashToggle,
            showGalleryButton: showGalleryButton,
          ),
          fullscreenDialog: true,
        ),
      );

      return result ?? WeebiBarcodeResult.cancelled();
      
    } catch (e) {
      return WeebiBarcodeResult.error('Failed to start scanner: $e');
    }
  }

  /// Get the current navigator context (best effort)
  static BuildContext? _getCurrentContext() {
    try {
      // Try to get the root context
      final rootElement = WidgetsBinding.instance.rootElement;
      if (rootElement != null) {
        return rootElement;
      }
    } catch (e) {
      // Fallback failed
    }
    return null;
  }
}

/// Simple result class similar to barcode_scan2's ScanResult
class WeebiBarcodeResult {
  final String? code;
  final String? format;
  final String? error;
  final bool cancelled;

  const WeebiBarcodeResult._({
    this.code,
    this.format,
    this.error,
    this.cancelled = false,
  });

  /// Create a successful scan result
  factory WeebiBarcodeResult.success(String code, String format) {
    return WeebiBarcodeResult._(code: code, format: format);
  }

  /// Create a cancelled result
  factory WeebiBarcodeResult.cancelled() {
    return const WeebiBarcodeResult._(cancelled: true);
  }

  /// Create an error result
  factory WeebiBarcodeResult.error(String error) {
    return WeebiBarcodeResult._(error: error);
  }

  /// Check if the scan was successful
  bool get isSuccess => code != null && error == null && !cancelled;

  /// Check if the scan was cancelled
  bool get isCancelled => cancelled;

  /// Check if there was an error
  bool get hasError => error != null;

  @override
  String toString() {
    if (isSuccess) return 'WeebiBarcodeResult.success(code: $code, format: $format)';
    if (isCancelled) return 'WeebiBarcodeResult.cancelled()';
    if (hasError) return 'WeebiBarcodeResult.error($error)';
    return 'WeebiBarcodeResult.unknown()';
  }
}

/// Simple full-screen scanner screen
class _SimpleScannerScreen extends StatefulWidget {
  final ScannerConfig config;
  final String title;
  final String? subtitle;
  final bool showFlashToggle;
  final bool showGalleryButton;

  const _SimpleScannerScreen({
    required this.config,
    required this.title,
    this.subtitle,
    this.showFlashToggle = true,
    this.showGalleryButton = false,
  });

  @override
  State<_SimpleScannerScreen> createState() => _SimpleScannerScreenState();
}

class _SimpleScannerScreenState extends State<_SimpleScannerScreen> {
  bool _flashEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(WeebiBarcodeResult.cancelled()),
        ),
        actions: [
          if (widget.showFlashToggle)
            IconButton(
              icon: Icon(_flashEnabled ? Icons.flash_on : Icons.flash_off),
              onPressed: () {
                setState(() {
                  _flashEnabled = !_flashEnabled;
                });
                // TODO: Implement flash toggle
                HapticFeedback.lightImpact();
              },
            ),
          if (widget.showGalleryButton)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () {
                // TODO: Implement gallery picker
                HapticFeedback.lightImpact();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera/Scanner view
          BarcodeScannerWidget(
            config: widget.config,
            onBarcodeDetected: (barcode) {
                             // Return the first successful scan
               HapticFeedback.mediumImpact();
               Navigator.of(context).pop(
                 WeebiBarcodeResult.success(barcode.text, barcode.format),
               );
            },
          ),
          
          // Overlay with scanning area
          _buildScanningOverlay(),
          
          // Bottom instruction text
          if (widget.subtitle != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.subtitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          // Create a hole in the overlay for the scanning area
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          
          // Scanning line animation
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: _buildScanningLine(),
            ),
          ),
          
          // Instructions
          const Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Text(
              'Position the barcode within the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningLine() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Stack(
          children: [
            Positioned(
              top: value * 220, // Animate from top to bottom
              left: 10,
              right: 10,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.red,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      onEnd: () {
        // Restart the animation
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
} 