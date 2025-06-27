import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Manages YOLO model downloading and storage
/// 
/// Model Attribution:
/// Source: https://huggingface.co/weebi/weebi_barcode_detector/blob/main/best.rten
/// License: AGPL-3.0 (Ultralytics)
/// SHA256: 48fc65ec220954859f147c85bc7422abd590d62648429d490ef61a08b973a10f
class ModelManager {
  static const String _modelUrl = 'https://huggingface.co/weebi/weebi_barcode_detector/resolve/main/best.rten';
  static const String _modelFileName = 'best.rten';
  static const int _expectedSizeBytes = 12800000; // ~12.2MB
  
  /// Get the default model storage directory (app documents)
  static Future<String> getDefaultModelDirectory() async {
    try {
      // Use proper app directories based on platform
      Directory appDir;
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop platforms, use application support directory
        appDir = await getApplicationSupportDirectory();
      } else {
        // For mobile platforms, use documents directory
        appDir = await getApplicationDocumentsDirectory();
      }
      
      // Create weebi_barcode_scanner subdirectory
      final modelsDir = Directory(path.join(appDir.path, 'weebi_barcode_scanner', 'models'));
      await modelsDir.create(recursive: true);
      return modelsDir.path;
      
    } catch (e) {
      // Fallback to temporary directory if app directories are not available
      final tempDir = await getTemporaryDirectory();
      final modelsDir = Directory(path.join(tempDir.path, 'weebi_barcode_scanner', 'models'));
      await modelsDir.create(recursive: true);
      return modelsDir.path;
    }
  }
  
  /// Get the default model file path
  static Future<String> getDefaultModelPath() async {
    final dir = await getDefaultModelDirectory();
    return path.join(dir, _modelFileName);
  }
  
  /// Check if model exists at the given path
  static bool modelExists(String modelPath) {
    final file = File(modelPath);
    if (!file.existsSync()) return false;
    
    // Basic size check to ensure it's not corrupted
    final size = file.lengthSync();
    return size > (_expectedSizeBytes * 0.8); // Allow 20% variance
  }
  
  /// Download the model from Hugging Face
  static Future<void> downloadModel(String modelPath) async {
    final file = File(modelPath);
    
    // Create directory if it doesn't exist
    await file.parent.create(recursive: true);
    
    try {
      print('📥 Downloading YOLO model from Hugging Face...');
      print('🔗 Source: $_modelUrl');
      print('📁 Destination: $modelPath');
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      
      final request = await client.getUrl(Uri.parse(_modelUrl));
      final response = await request.close();
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download model: HTTP ${response.statusCode}');
      }
      
      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      
      await file.writeAsBytes(bytes);
      client.close();
      
      // Verify download
      final downloadedSize = file.lengthSync();
      print('✅ Model downloaded successfully: ${(downloadedSize / 1024 / 1024).toStringAsFixed(1)} MB');
      
      if (downloadedSize < (_expectedSizeBytes * 0.8)) {
        throw Exception('Downloaded model appears corrupted (size: $downloadedSize bytes)');
      }
      
    } catch (e) {
      // Clean up partial download
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }
  
  /// Ensure model exists at path, download if missing
  static Future<void> ensureModel(String modelPath) async {
    if (!modelExists(modelPath)) {
      await downloadModel(modelPath);
    } else {
      final size = File(modelPath).lengthSync();
      print('✅ Found existing model: $modelPath (${(size / 1024 / 1024).toStringAsFixed(1)} MB)');
    }
  }
} 