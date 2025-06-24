import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../dart_barcode/dart_barcode.dart' as dart_barcode;
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

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  PlatformCameraManager? _cameraManager;
  Timer? _scanTimer;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isScanning = true;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cameraManager?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Initialize the barcode SDK first
      await _initializeSDK();
      
      _cameraManager = PlatformCameraManager.create();
      await _cameraManager!.initialize(widget.config);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        _startScanning();
      }
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
        widget.onError?.call(_errorMessage!);
      }
    }
  }

  Future<void> _initializeSDK() async {
    try {
      debugPrint('🤖 Initializing YOLO Barcode Detection Model');
      
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
        debugPrint('✅ Barcode SDK initialized successfully');
      } else {
        throw Exception('Failed to initialize barcode SDK');
      }
    } catch (e) {
      throw Exception('SDK initialization failed: $e');
    }
  }

  void _startScanning() {
    if (!_isScanning) return;
    
    _scanTimer = Timer.periodic(widget.config.scanInterval, (timer) async {
      if (!_isScanning || !mounted || _cameraManager == null) {
        timer.cancel();
        return;
      }
      
      try {
        await _captureAndProcess();
      } catch (e) {
        debugPrint('❌ Scanning error: $e');
        widget.onError?.call('Scanning error: $e');
      }
    });
  }

  Future<void> _captureAndProcess() async {
    if (_cameraManager == null || !_cameraManager!.isInitialized) {
      return;
    }
    
    try {
      final imageBytes = await _cameraManager!.takePicture();
      final result = await _processImage(imageBytes);
      
      if (result != null && mounted) {
        _handleBarcodeDetected(result);
      }
    } catch (e) {
      debugPrint('❌ Image capture/processing failed: $e');
      // Don't call error callback for individual capture failures
      // as they're often temporary (camera busy, etc.)
    }
  }

  Future<BarcodeResult?> _processImage(Uint8List imageBytes) async {
    try {
      // Process the image using the dart_barcode SDK
      final results = await dart_barcode.processImage(
        format: dart_barcode.RustImageFormat.jpeg,
        bytes: imageBytes,
        useSuperResolution: widget.config.useSuperResolution,
      );
      
      if (results.isNotEmpty) {
        final result = results.first;
        return BarcodeResult(
          text: result.text,
          format: result.format,
          productName: null, // TODO: Add product lookup if enabled
          productBrand: null,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Image processing failed: $e');
      return null;
    }
  }

  void _handleBarcodeDetected(BarcodeResult result) {
    debugPrint('🎯 Barcode detected: ${result.text} (${result.format})');
    
    // Play haptic feedback if enabled
    if (widget.config.enableHapticFeedback) {
      _playSuccessSound();
    }
    
    widget.onBarcodeDetected(result);
    
    // Stop scanning if configured for single scan
    if (widget.config.scanOnce) {
      _stopScanning();
    }
  }

  void _playSuccessSound() {
    try {
      HapticFeedback.lightImpact();
      debugPrint('✅ Haptic feedback played');
    } catch (e) {
      debugPrint('❌ Failed to play haptic feedback: $e');
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanTimer?.cancel();
    debugPrint('⏹️ Scanning stopped');
  }

  void resumeScanning() {
    if (!_isScanning && _isInitialized) {
      setState(() {
        _isScanning = true;
      });
      _startScanning();
      debugPrint('▶️ Scanning resumed');
    }
  }

  void stopScanning() {
    _stopScanning();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isInitialized = false;
                });
                _initializeCamera();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (!_isInitialized || _cameraManager == null) {
      return widget.loadingWidget ?? 
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing Camera...'),
            ],
          ),
        );
    }
    
    return Stack(
      children: [
        // Camera preview
        _cameraManager!.buildPreviewWidget(),
        
        // Overlay
        if (widget.config.showOverlay)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.config.overlayColor,
                width: 2.0,
              ),
            ),
          ),
        
        // Scanning status indicator
        if (!_isScanning)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pause_circle, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Scanning Paused',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
} 