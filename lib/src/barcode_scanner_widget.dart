import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../dart_barcode/dart_barcode.dart' as dart_barcode;

import 'barcode_result.dart';
import 'scanner_config.dart';

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
    this.config = ScannerConfig.defaultConfig,
    this.onError,
    this.loadingWidget,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _error;
  Timer? _scanTimer;
  bool _sdkInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    try {
      // Initialize the SDK first
      await _initializeSDK();
      
      // Initialize camera (Windows-optimized)
      await _initializeCamera();
      
      // Start periodic scanning
      _startPeriodicScanning();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _handleError('Failed to initialize scanner: $e');
    }
  }

  Future<void> _initializeSDK() async {
    if (_sdkInitialized) return;
    
    try {
      debugPrint('🤖 Initializing YOLO Barcode Detection Model');
      debugPrint('📖 Source: https://huggingface.co/weebi/weebi_barcode_detector/blob/main/best.rten');
      debugPrint('⚖️  License: AGPL-3.0 (Ultralytics)');
      
      // Copy model from assets to writable location
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile = File(path.join(appDir.path, 'best.rten'));
      
      if (!await modelFile.exists()) {
        debugPrint('📦 Copying model from app bundle to: ${modelFile.path}');
        final assetData = await rootBundle.load(widget.config.modelPath);
        final bytes = assetData.buffer.asUint8List();
        await modelFile.writeAsBytes(bytes);
        debugPrint('💾 Model copied successfully. Size: ${bytes.length} bytes (${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB)');
      } else {
        debugPrint('✅ Model already exists at: ${modelFile.path}');
      }
      
      // Initialize the SDK with the model path
      final success = await dart_barcode.initializeBarcodeSDK(modelFile.path);
      
      if (success) {
        _sdkInitialized = true;
        debugPrint('✅ Barcode SDK initialized successfully');
      } else {
        throw Exception('Failed to initialize barcode SDK');
      }
    } catch (e) {
      throw Exception('SDK initialization failed: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Windows-optimized camera setup
      _cameraController = CameraController(
        cameras.first, // Use first available camera (typically main webcam)
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888, // Windows optimized
      );
      
      // Windows needs longer timeout for camera initialization
      await _cameraController!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Camera initialization timed out (15s)');
        },
      );
      
      // Set focus mode (non-critical if it fails)
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        debugPrint('Focus mode setting failed (non-critical): $e');
      }
      
      debugPrint('✅ Camera initialized successfully');
      debugPrint('📷 Camera resolution: ${_cameraController!.value.previewSize}');
    } catch (e) {
      throw Exception('Camera initialization failed: $e');
    }
  }

  void _startPeriodicScanning() {
    _scanTimer = Timer.periodic(widget.config.scanInterval, (timer) {
      if (!_isProcessing && _cameraController != null && _cameraController!.value.isInitialized) {
        _captureAndProcess();
      }
    });
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing || _cameraController == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // Capture image
      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      
      // Process with dart_barcode SDK
      final results = await dart_barcode.processImage(
        format: dart_barcode.RustImageFormat.Jpeg,
        bytes: bytes,
        useSuperResolution: widget.config.useSuperResolution,
      );
      
      // Handle results
      if (results.isNotEmpty) {
        final result = BarcodeResult.fromDartBarcodeResult(results.first);
        debugPrint('🎯 Barcode detected: ${result.text} (${result.format})');
        widget.onBarcodeDetected(result);
      }
      
      // Clean up temporary image file
      await File(image.path).delete().catchError((e) {
        debugPrint('Failed to delete temp image: $e');
      });
      
    } catch (e) {
      debugPrint('Processing error: $e');
      // Don't show error for normal processing failures (no barcode found, etc.)
      // Only show critical errors via _handleError
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleError(String error) {
    debugPrint('❌ Scanner error: $error');
    setState(() => _error = error);
    widget.onError?.call(error);
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _error = null;
      _isInitialized = false;
    });
    
    // Clean up existing resources
    _scanTimer?.cancel();
    await _cameraController?.dispose();
    _cameraController = null;
    
    // Wait a bit for cleanup on Windows
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Retry initialization
    _initializeScanner();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return widget.loadingWidget ?? 
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Initializing Scanner...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
    }
    
    if (_error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryInitialization,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Camera not available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        // Camera preview
        CameraPreview(_cameraController!),
        
        // Scanning overlay
        if (widget.config.showOverlay)
          CustomPaint(
            painter: _ScannerOverlayPainter(
              color: widget.config.overlayColor,
            ),
            child: Container(),
          ),
        
        // Processing indicator
        if (_isProcessing)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Scanning...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter for the scanning overlay
class _ScannerOverlayPainter extends CustomPainter {
  final Color color;
  
  _ScannerOverlayPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    const overlayWidth = 400.0;
    const overlayHeight = 150.0;
    
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: overlayWidth,
      height: overlayHeight,
    );
    
    canvas.drawRect(rect, paint);
    
    // Add corner indicators
    const cornerSize = 20.0;
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Draw corner brackets
    _drawCorner(canvas, cornerPaint, rect.topLeft, cornerSize, true, true);
    _drawCorner(canvas, cornerPaint, rect.topRight, cornerSize, false, true);
    _drawCorner(canvas, cornerPaint, rect.bottomLeft, cornerSize, true, false);
    _drawCorner(canvas, cornerPaint, rect.bottomRight, cornerSize, false, false);
  }
  
  void _drawCorner(Canvas canvas, Paint paint, Offset corner, double size, bool isLeft, bool isTop) {
    final horizontalEnd = isLeft ? corner.dx + size : corner.dx - size;
    final verticalEnd = isTop ? corner.dy + size : corner.dy - size;
    
    // Horizontal line
    canvas.drawLine(corner, Offset(horizontalEnd, corner.dy), paint);
    // Vertical line
    canvas.drawLine(corner, Offset(corner.dx, verticalEnd), paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 