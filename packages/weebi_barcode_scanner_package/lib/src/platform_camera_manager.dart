import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

// Global camera manager instance to prevent multiple cameras
PlatformCameraManager? _globalCameraManager;
bool _isGlobalCameraDisposing = false;

/// Get or create the global camera manager instance
PlatformCameraManager getGlobalCameraManager() {
  if (_globalCameraManager == null || _isGlobalCameraDisposing) {
    _globalCameraManager = PlatformCameraManager.create();
    _isGlobalCameraDisposing = false;
  }
  return _globalCameraManager!;
}

/// Dispose the global camera manager
Future<void> disposeGlobalCameraManager() async {
  if (_globalCameraManager != null && !_isGlobalCameraDisposing) {
    _isGlobalCameraDisposing = true;
    await _globalCameraManager!.dispose();
    _globalCameraManager = null;
    _isGlobalCameraDisposing = false;
  }
}

/// Windows/Linux camera implementation using the standard camera package
class WindowsCameraManager extends PlatformCameraManager {
  camera.CameraController? _controller;
  bool _isDisposing = false;
  
  @override
  Future<void> initialize(ScannerConfig config) async {
    if (_isDisposing) return;
    
    try {
      debugPrint('🔍 WindowsCameraManager: Starting initialization...');
      
      // Ensure any existing camera is properly disposed first
      if (_controller != null) {
        debugPrint('🔍 WindowsCameraManager: Disposing existing camera...');
        await dispose();
        // Wait a bit more for Windows to fully release the camera
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      
      final cameras = await camera.availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Ensure we're on the main thread for camera operations
      if (!WidgetsBinding.instance.isRootWidgetAttached) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      _controller = camera.CameraController(
        cameras.first,
        camera.ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: camera.ImageFormatGroup.bgra8888,
      );
      
      // Add error listener to handle threading issues
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          debugPrint('⚠️ WindowsCameraManager: Camera error: ${_controller!.value.errorDescription}');
        }
      });
      
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
    } catch (e) {
      debugPrint('❌ WindowsCameraManager: Initialization failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    _isDisposing = true;
    
    try {
      debugPrint('🔍 WindowsCameraManager: Disposing camera...');
      
      // Remove listener before disposing
      _controller?.removeListener(() {});
      
      // Ensure proper disposal with timeout
      if (_controller != null) {
        await _controller!.dispose().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⚠️ WindowsCameraManager: Camera disposal timed out');
          },
        );
      }
      
      _controller = null;
      
      // Add delay to ensure camera resources are fully released
      await Future.delayed(const Duration(milliseconds: 1000));
      
      debugPrint('✅ WindowsCameraManager: Camera disposed successfully');
    } catch (e) {
      debugPrint('⚠️ WindowsCameraManager: Error during disposal: $e');
    }
  }
  
  @override
  Future<Uint8List> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isDisposing) {
      throw Exception('Camera not initialized');
    }
    
    try {
      final image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      
      // Clean up temporary file
      try {
        await File(image.path).delete();
      } catch (e) {
        debugPrint('Failed to delete temp image: $e');
      }
      
      return bytes;
    } catch (e) {
      debugPrint('❌ WindowsCameraManager: Picture taking failed: $e');
      rethrow;
    }
  }
  
  @override
  Widget buildPreviewWidget() {
    if (_controller == null || !_controller!.value.isInitialized || _isDisposing) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: camera.CameraPreview(_controller!),
        ),
      ),
    );
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
    debugPrint('🔍 MacOSCameraManager: Starting initialization...');
    
    try {
      // Note: macOS camera initialization is handled in the widget
      // This is due to the architecture of camera_macos package
      debugPrint('✅ MacOSCameraManager: Ready for widget-based initialization');
      
      // For now, we'll simulate successful initialization
      // The actual camera will be initialized when the widget is built
      _isInitialized = true;
      debugPrint('✅ MacOSCameraManager: Initialization completed (simulated)');
    } catch (e) {
      debugPrint('❌ MacOSCameraManager: Initialization failed: $e');
      rethrow;
    }
  }
  
  void _onCameraInitialized(CameraMacOSController controller) {
    debugPrint('🔍 MacOSCameraManager: Camera controller initialized');
    _controller = controller;
    _isInitialized = true;
    
    // Set focus point to center for better barcode detection
    try {
      _controller!.setFocusPoint(const Offset(0.5, 0.5));
      debugPrint('✅ macOS: Focus point set to center');
    } catch (e) {
      debugPrint('⚠️ macOS focus point setting failed (non-critical): $e');
    }
    
    debugPrint('✅ macOS camera initialized successfully');
  }
  
  @override
  Future<void> dispose() async {
    debugPrint('🔍 MacOSCameraManager: Disposing...');
    _controller = null;
    _isInitialized = false;
    debugPrint('✅ MacOSCameraManager: Disposed');
  }
  
  @override
  Future<Uint8List> takePicture() async {
    debugPrint('🔍 MacOSCameraManager: Taking picture...');
    
    if (_controller == null || !_isInitialized) {
      debugPrint('❌ MacOSCameraManager: Camera not initialized for picture');
      throw Exception('macOS camera not initialized');
    }
    
    try {
      final file = await _controller!.takePicture();
      if (file?.bytes == null) {
        debugPrint('❌ MacOSCameraManager: Failed to capture image');
        throw Exception('Failed to capture image on macOS');
      }
      
      debugPrint('✅ MacOSCameraManager: Picture taken successfully (${file!.bytes!.length} bytes)');
      return file!.bytes!;
    } catch (e) {
      debugPrint('❌ MacOSCameraManager: Picture taking failed: $e');
      rethrow;
    }
  }
  
  @override
  Widget buildPreviewWidget() {
    debugPrint('🔍 MacOSCameraManager: Building preview widget...');
    
    if (!_isInitialized) {
      debugPrint('⚠️ MacOSCameraManager: Not initialized, showing loading widget');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing macOS camera...'),
          ],
        ),
      );
    }
    
    debugPrint('✅ MacOSCameraManager: Building camera preview widget');
    
    // For macOS, we need to use the camera_macos widget
    return CameraMacOSView(
      key: _cameraKey,
      cameraMode: CameraMacOSMode.photo,
      onCameraInizialized: _onCameraInitialized,
      onCameraLoading: (error) {
        debugPrint('🔍 MacOSCameraManager: Camera loading: $error');
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading macOS camera...'),
            ],
          ),
        );
      },
    );
  }
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Size? get previewSize {
    if (_controller != null) {
      // Return a default size for macOS
      return const Size(640, 480);
    }
    return null;
  }
} 