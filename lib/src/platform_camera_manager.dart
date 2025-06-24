import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Windows/Linux camera support
import 'package:camera/camera.dart' as camera;

// macOS camera support  
import 'package:camera_macos/camera_macos.dart';

import 'scanner_config.dart';

/// Abstract interface for platform-specific camera operations
abstract class PlatformCameraManager {
  /// Initialize the camera with the given configuration
  Future<void> initialize(ScannerConfig config);
  
  /// Dispose of camera resources
  Future<void> dispose();
  
  /// Take a picture and return the image bytes
  Future<Uint8List> takePicture();
  
  /// Get the camera preview widget
  Widget buildPreviewWidget();
  
  /// Check if the camera is initialized
  bool get isInitialized;
  
  /// Get the camera preview size
  Size? get previewSize;
  
  /// Factory method to create the appropriate camera manager for the current platform
  static PlatformCameraManager create() {
    if (Platform.isMacOS) {
      return MacOSCameraManager();
    } else {
      return WindowsCameraManager();
    }
  }
}

/// Windows/Linux camera implementation using the standard camera package
class WindowsCameraManager extends PlatformCameraManager {
  camera.CameraController? _controller;
  
  @override
  Future<void> initialize(ScannerConfig config) async {
    final cameras = await camera.availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    
    _controller = camera.CameraController(
      cameras.first,
      camera.ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: camera.ImageFormatGroup.bgra8888,
    );
    
    await _controller!.initialize().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Camera initialization timed out (15s)');
      },
    );
    
    // Set focus mode
    try {
      if (config.enableContinuousAutoFocus) {
        await _controller!.setFocusMode(camera.FocusMode.auto);
        debugPrint('✅ Windows: Continuous auto-focus enabled');
      } else {
        await _controller!.setFocusMode(camera.FocusMode.locked);
        debugPrint('✅ Windows: Focus locked for performance');
      }
    } catch (e) {
      debugPrint('Windows focus mode setting failed (non-critical): $e');
    }
    
    debugPrint('✅ Windows camera initialized successfully');
    debugPrint('📷 Windows camera resolution: ${_controller!.value.previewSize}');
  }
  
  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
  
  @override
  Future<Uint8List> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    final image = await _controller!.takePicture();
    final bytes = await File(image.path).readAsBytes();
    
    // Clean up temporary file
    try {
      await File(image.path).delete();
    } catch (e) {
      debugPrint('Failed to delete temp image: $e');
    }
    
    return bytes;
  }
  
  @override
  Widget buildPreviewWidget() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return camera.CameraPreview(_controller!);
  }
  
  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  
  @override
  Size? get previewSize => _controller?.value.previewSize;
}

/// macOS camera implementation using camera_macos package
class MacOSCameraManager extends PlatformCameraManager {
  CameraMacOSController? _controller;
  final GlobalKey _cameraKey = GlobalKey();
  bool _isInitialized = false;
  
  @override
  Future<void> initialize(ScannerConfig config) async {
    // Note: macOS camera initialization is handled in the widget
    // This is due to the architecture of camera_macos package
    debugPrint('✅ macOS camera manager ready for initialization');
  }
  
  void _onCameraInitialized(CameraMacOSController controller) {
    _controller = controller;
    _isInitialized = true;
    
    // Set focus point to center for better barcode detection
    try {
      _controller!.setFocusPoint(const Offset(0.5, 0.5));
      debugPrint('✅ macOS: Focus point set to center');
    } catch (e) {
      debugPrint('macOS focus point setting failed (non-critical): $e');
    }
    
    debugPrint('✅ macOS camera initialized successfully');
  }
  
  @override
  Future<void> dispose() async {
    _controller = null;
    _isInitialized = false;
  }
  
  @override
  Future<Uint8List> takePicture() async {
    if (_controller == null || !_isInitialized) {
      throw Exception('macOS camera not initialized');
    }
    
    final file = await _controller!.takePicture();
    if (file?.bytes == null) {
      throw Exception('Failed to capture image on macOS');
    }
    
    return file!.bytes!;
  }
  
  @override
  Widget buildPreviewWidget() {
    return CameraMacOSView(
      key: _cameraKey,
      fit: BoxFit.cover,
      cameraMode: CameraMacOSMode.photo,
      onCameraInizialized: _onCameraInitialized,
    );
  }
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Size? get previewSize => null; // macOS doesn't expose preview size easily
} 