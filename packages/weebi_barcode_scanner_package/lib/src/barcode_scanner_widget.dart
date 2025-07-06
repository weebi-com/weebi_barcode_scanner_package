import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart_barcode/weebi_barcode_dart.dart' as core_barcode;

import 'barcode_result.dart';
import 'scanner_config.dart';
import 'platform_camera_manager.dart';

/// Simple barcode scanner widget for Windows
/// 
/// Handles all complexity internally:
/// - Automatic model loading and SDK initialization
/// - Windows-optimized camera setup
/// - Periodic barcode scanning with image processing
/// - Error handling and recovery
/// - Hot reload support
/// 
/// Usage:
/// ```dart
/// BarcodeScannerWidget(
///   onBarcodeDetected: (result) {
///     print('Detected: ${result.text}');
///   },
/// )
/// ```
class BarcodeScannerWidget extends StatefulWidget {
  /// Called when a barcode is detected
  final Function(BarcodeResult result) onBarcodeDetected;
  
  /// Scanner configuration
  final ScannerConfig config;
  
  /// Called when an error occurs
  final Function(String error)? onError;
  
  /// Widget to show while initializing
  final Widget? loadingWidget;
  
  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    this.config = ScannerConfig.continuousMode,
    this.onError,
    this.loadingWidget,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> with WidgetsBindingObserver {
  late final PlatformCameraManager _cameraManager;
  bool _detectorInitialized = false;
  BarcodeResult? _latestBarcode;
  DateTime? _lastDetectionTime;
  bool _isScanning = false;
  bool _isInitializing = false;
  String? _error;
  Timer? _scanTimer;
  bool _isDisposing = false;
  
  // Progress tracking for model download
  double _initializationProgress = 0.0;
  String _initializationStatus = 'Initializing...';
  
  // Detection visualization state
  Map<String, dynamic>? _latestDetectionCoordinates;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraManager = getGlobalCameraManager();
    _initializeScanner();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Handle hot reload - reinitialize the scanner
    if (kDebugMode) {
      debugPrint('Hot reload detected - reinitializing scanner');
      _reinitializeForHotReload();
    }
  }

  @override
  void didUpdateWidget(BarcodeScannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the config changed significantly, reinitialize
    if (oldWidget.config.modelPath != widget.config.modelPath) {
      _reinitializeScanner();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      debugPrint('🔍 BarcodeScannerWidget: App paused, stopping camera...');
      _stopScanning();
      // Dispose camera when app is paused
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!_isDisposing) {
          try {
            await _cameraManager.dispose();
          } catch (e) {
            debugPrint('Error disposing camera on app pause: $e');
          }
        }
      });
    } else if (state == AppLifecycleState.resumed && !_isDisposing) {
      debugPrint('🔍 BarcodeScannerWidget: App resumed, reinitializing camera...');
      // Give a longer delay after resuming to ensure camera is fully released
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!_isDisposing) {
          _initializeScanner();
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopScanning();
    
    // Use global camera disposal
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        await disposeGlobalCameraManager();
      } catch (e) {
        debugPrint('Error disposing global camera in widget dispose: $e');
      }
    });
    
    _scanTimer?.cancel();
    super.dispose();
  }

  void _pauseScanning() {
    _scanTimer?.cancel();
    setState(() {
      _isScanning = false;
    });
  }

  void _resumeScanning() {
    if (!_isDisposing && _detectorInitialized) {
      setState(() {
        _isScanning = true;
      });
      _startScanning();
    }
  }

  Future<void> _reinitializeScanner() async {
    if (_isDisposing) return;
    
    // Stop current operations
    _stopScanning();
    
    // Reset state
    setState(() {
      _isInitializing = false;
      _error = null;
      _detectorInitialized = false;
      _initializationProgress = 0.0;
      _initializationStatus = 'Initializing...';
    });
    
    // Properly dispose camera before reinitializing
    try {
      await _cameraManager.dispose();
    } catch (e) {
      debugPrint('Error disposing camera during reinitialize: $e');
    }
    
    // Extended wait for camera resource cleanup, especially important on Windows
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Reinitialize
    if (!_isDisposing) {
      _initializeScanner();
    }
  }

  Future<void> _initializeScanner() async {
    if (_isInitializing || _isDisposing) {
      debugPrint('🔍 BarcodeScannerWidget: Already initializing or disposing, skipping');
      return;
    }

    // Add a small delay to prevent rapid reinitialization attempts
    if (_cameraManager.isInitialized) {
      debugPrint('🔍 BarcodeScannerWidget: Camera already initialized, skipping');
      return;
    }

    debugPrint('🔍 BarcodeScannerWidget: Starting scanner initialization...');

    setState(() {
      _isInitializing = true;
      _error = null;
      _initializationProgress = 0.0;
      _initializationStatus = 'Initializing camera...';
    });

    try {
      debugPrint('🔍 BarcodeScannerWidget: Initializing camera manager...');
      
      // Ensure we're on the main thread for camera operations
      if (!WidgetsBinding.instance.isRootWidgetAttached) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Initialize camera with enhanced disposal handling
      await _cameraManager.initialize(widget.config);
      
      if (_isDisposing) return;
      
      debugPrint('🔍 BarcodeScannerWidget: Camera initialized, initializing detector...');
      setState(() {
        _initializationStatus = 'Initializing AI detector...';
        _initializationProgress = 0.3;
      });
      
      // Initialize the barcode detector
      await core_barcode.BarcodeDetector.initializeOrDownload(
        widget.config.modelPath,
        (progress, status) {
          if (!_isDisposing) {
            setState(() {
              _initializationProgress = 0.3 + (progress * 0.6);
              _initializationStatus = status;
            });
          }
        },
      );
      
      if (_isDisposing) return;
      
      debugPrint('🔍 BarcodeScannerWidget: Detector initialized, starting scanning...');
      setState(() {
        _initializationProgress = 1.0;
        _initializationStatus = 'Ready to scan';
        _detectorInitialized = true;
        _isInitializing = false;
      });
      
      // Start scanning after a brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isDisposing) {
        _startScanning();
      }
      
    } catch (e) {
      debugPrint('❌ BarcodeScannerWidget: Initialization failed: $e');
      if (!_isDisposing) {
        setState(() {
          _error = 'Failed to initialize scanner: $e';
          _isInitializing = false;
        });
        
        widget.onError?.call('Scanner initialization failed: $e');
      }
    }
  }

  void _startScanning() {
    if (_isDisposing || !_detectorInitialized || !_cameraManager.isInitialized) {
      debugPrint('🔍 BarcodeScannerWidget: Cannot start scanning - not ready');
      return;
    }

    debugPrint('🔍 BarcodeScannerWidget: Starting scanning...');
    setState(() {
      _isScanning = true;
    });

    _scanTimer = Timer.periodic(widget.config.scanInterval, (timer) async {
      if (_isDisposing || !_isScanning || !_detectorInitialized) {
        timer.cancel();
        return;
      }

      try {
        // Ensure we're on the main thread for camera operations
        if (!WidgetsBinding.instance.isRootWidgetAttached) {
          await Future.delayed(const Duration(milliseconds: 50));
          return;
        }

        final imageBytes = await _cameraManager.takePicture();
        
        if (_isDisposing) return;

        final results = await core_barcode.BarcodeDetector.processImage(
          format: core_barcode.ImageFormat.jpeg,
          bytes: imageBytes,
          useSuperResolution: widget.config.useSuperResolution,
        );

        if (_isDisposing) return;

        if (results.isNotEmpty) {
          final result = results.first;
          final now = DateTime.now();
          
          // Debounce detections to avoid spam
          if (_lastDetectionTime == null || 
              now.difference(_lastDetectionTime!).inMilliseconds > 1000) { // Use 1 second debounce
            
            if (_latestBarcode?.text != result.text) {
              debugPrint('🔍 BarcodeScannerWidget: Detected barcode: ${result.text}');
              
              // Convert core BarcodeResult to widget BarcodeResult
              final widgetResult = BarcodeResult(
                text: result.text,
                format: result.format,
                confidence: result.bounds?.confidence,
                location: result.bounds != null ? {
                  'left': result.bounds!.left,
                  'top': result.bounds!.top,
                  'right': result.bounds!.right,
                  'bottom': result.bounds!.bottom,
                } : null,
              );
              
              _latestBarcode = widgetResult;
              _lastDetectionTime = now;
              
              // Call callback on main thread
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_isDisposing) {
                  widget.onBarcodeDetected(widgetResult);
                }
              });
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ BarcodeScannerWidget: Scanning error: $e');
        // Don't call onError for every frame error, only for critical errors
        if (e.toString().contains('Camera not initialized') || 
            e.toString().contains('thread')) {
          widget.onError?.call('Camera error: $e');
        }
      }
    });
  }

  Future<void> _stopScanning() async {
    _isScanning = false;
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  Future<void> _reinitializeForHotReload() async {
    if (_isInitializing) return;
    
    setState(() {
      _isInitializing = true;
      _error = null;
      _initializationProgress = 0.0;
      _initializationStatus = 'Hot reload: reinitializing...';
    });

    try {
      // Stop current scanning
      _stopScanning();
      
      // Dispose camera for hot reload
      try {
        await _cameraManager.dispose();
      } catch (e) {
        debugPrint('Error disposing camera during hot reload: $e');
      }
      
      // Reset detector state
      _detectorInitialized = false;
      _latestBarcode = null;
      _lastDetectionTime = null;
      
      // Extended wait for camera resource cleanup, especially important on Windows
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Reinitialize
      if (!_isDisposing) {
        await _initializeScanner();
      }
    } catch (e) {
      debugPrint('Error during hot reload reinitialize: $e');
      if (mounted && !_isDisposing) {
        setState(() {
          _error = 'Hot reload error - restart app if issues persist';
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          if (_isInitializing)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show progress indicator for downloads
                  if (_initializationProgress > 0.0)
                    Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: _initializationProgress,
                            backgroundColor: Colors.grey[800],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_initializationProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                      ],
                    ),
                  
                  Text(
                    _initializationStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Show helpful message for downloads
                  if (_initializationStatus.contains('Downloading'))
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'First-time setup: downloading AI model',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            )
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeScanner,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_cameraManager.isInitialized)
            _buildCameraPreview(context),
          
          // Only show overlay if camera is working
          if (_cameraManager.isInitialized && !_isInitializing && _error == null)
            Positioned.fill(
              child: CustomPaint(
                painter: DirectBarcodeOverlayPainter(
                  barcodeResult: _latestBarcode,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 4/3, // Standard camera aspect ratio
          child: _cameraManager.buildPreviewWidget(),
        ),
      ),
    );
  }
}

/// Custom painter for drawing barcode detection bounds
class BarcodeOverlayPainter extends CustomPainter {
  final Map<String, dynamic> detectionBounds;
  final Size previewSize;

  BarcodeOverlayPainter({
    required this.detectionBounds,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Calculate the actual display area of the camera preview
    // CameraPreview maintains aspect ratio and may letterbox or crop
    final previewAspectRatio = previewSize.width / previewSize.height;
    final widgetAspectRatio = size.width / size.height;
    
    late final Rect displayRect;
    
    if (previewAspectRatio > widgetAspectRatio) {
      // Preview is wider - will be letterboxed top/bottom
      final displayHeight = size.width / previewAspectRatio;
      final yOffset = (size.height - displayHeight) / 2;
      displayRect = Rect.fromLTWH(0, yOffset, size.width, displayHeight);
    } else {
      // Preview is taller - will be letterboxed left/right
      final displayWidth = size.height * previewAspectRatio;
      final xOffset = (size.width - displayWidth) / 2;
      displayRect = Rect.fromLTWH(xOffset, 0, displayWidth, size.height);
    }

    // Scale detection bounds to the actual display area
    final scaleX = displayRect.width / previewSize.width;
    final scaleY = displayRect.height / previewSize.height;

    final left = displayRect.left + (detectionBounds['left'] * scaleX);
    final top = displayRect.top + (detectionBounds['top'] * scaleY);
    final right = displayRect.left + (detectionBounds['right'] * scaleX);
    final bottom = displayRect.top + (detectionBounds['bottom'] * scaleY);

    final rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);

    // Draw corner markers
    final cornerSize = 20.0;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerSize, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerSize),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(right, top),
      Offset(right - cornerSize, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerSize),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerSize, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left, bottom - cornerSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - cornerSize, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerSize),
      cornerPaint,
    );
    
    // Debug: Draw the actual display area (optional - can be removed)
    if (false) { // Set to true for debugging
      final debugPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(displayRect, debugPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Scaled overlay painter that properly handles coordinate transformation
class ScaledBarcodeOverlayPainter extends CustomPainter {
  final BarcodeResult? barcodeResult;
  final Size? cameraPreviewSize;

  ScaledBarcodeOverlayPainter({
    this.barcodeResult, 
    this.cameraPreviewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeResult?.location == null || cameraPreviewSize == null) {
      _drawCenterCrosshair(canvas, size);
      return;
    }

    final location = barcodeResult!.location!;
    
    // Calculate scaling factors from camera preview to widget
    final double scaleX = size.width / cameraPreviewSize!.width;
    final double scaleY = size.height / cameraPreviewSize!.height;
    
    // Apply scaling to coordinates
    final double left = (location['left'] ?? 0).toDouble() * scaleX;
    final double top = (location['top'] ?? 0).toDouble() * scaleY;
    final double right = (location['right'] ?? 0).toDouble() * scaleX;
    final double bottom = (location['bottom'] ?? 0).toDouble() * scaleY;

    // Add some padding to make the box more visible
    final double barcodeWidth = right - left;
    final double padding = barcodeWidth * 0.1; // 10% padding
    
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw bounding rectangle with padding
    canvas.drawRect(
      Rect.fromLTRB(
        (left - padding).clamp(0, size.width),
        top,
        (right + padding).clamp(0, size.width),
        bottom,
      ),
      paint,
    );

    // Draw confidence score if available
    final double confidence = barcodeResult!.confidence ?? 0.0;
    final String format = barcodeResult!.format;
    
    if (confidence > 0) {
      final textStyle = TextStyle(
        color: Colors.green,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.black54,
      );
      
      final textSpan = TextSpan(
        text: '${(confidence * 100).toStringAsFixed(1)}% $format',
        style: textStyle,
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(left, (top - 25).clamp(0, size.height)));
    }
  }

  void _drawCenterCrosshair(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double crosshairSize = 20.0;

    // Draw crosshair
    canvas.drawLine(
      Offset(centerX - crosshairSize, centerY), 
      Offset(centerX + crosshairSize, centerY), 
      paint
    );
    canvas.drawLine(
      Offset(centerX, centerY - crosshairSize), 
      Offset(centerX, centerY + crosshairSize), 
      paint
    );

    // Draw center circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      3.0,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(ScaledBarcodeOverlayPainter oldDelegate) {
    return oldDelegate.barcodeResult != barcodeResult || 
           oldDelegate.cameraPreviewSize != cameraPreviewSize;
  }
}

class DirectBarcodeOverlayPainter extends CustomPainter {
  final BarcodeResult? barcodeResult;

  DirectBarcodeOverlayPainter({
    this.barcodeResult,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeResult?.location == null) {
      _drawCenterCrosshair(canvas, size);
      return;
    }

    final location = barcodeResult!.location!;
    
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final left = location['left']! * size.width;
    final top = location['top']! * size.height;
    final right = location['right']! * size.width;
    final bottom = location['bottom']! * size.height;

    final rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);

    // Draw corner markers
    final cornerSize = 20.0;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerSize, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerSize),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(right, top),
      Offset(right - cornerSize, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerSize),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerSize, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left, bottom - cornerSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - cornerSize, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerSize),
      cornerPaint,
    );
  }

  void _drawCenterCrosshair(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double crosshairSize = 20.0;

    // Draw crosshair
    canvas.drawLine(
      Offset(centerX - crosshairSize, centerY), 
      Offset(centerX + crosshairSize, centerY), 
      paint
    );
    canvas.drawLine(
      Offset(centerX, centerY - crosshairSize), 
      Offset(centerX, centerY + crosshairSize), 
      paint
    );

    // Draw center circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      3.0,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(DirectBarcodeOverlayPainter oldDelegate) {
    return oldDelegate.barcodeResult != barcodeResult;
  }
} 