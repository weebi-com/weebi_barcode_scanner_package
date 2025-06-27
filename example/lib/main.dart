import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';
import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

import 'simple_scanner_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the OpenFoodFacts service
  await WeebiOpenFoodFactsService.initialize(appName: 'barcode_scanner_example');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HorizontalScannerScreen(),
    );
  }
}

class HorizontalScannerScreen extends StatefulWidget {
  const HorizontalScannerScreen({super.key});

  @override
  State<HorizontalScannerScreen> createState() => _HorizontalScannerScreenState();
}

class _HorizontalScannerScreenState extends State<HorizontalScannerScreen> {
  bool _isScanning = true;
  BarcodeResult? _lastResult;
  WeebiProduct? _currentProduct;
  bool _isLoadingProduct = false;
  String? _productError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleBarcodeDetected(BarcodeResult result) {
    if (_lastResult?.text == result.text) {
      return; // Same barcode, don't reload
    }

    setState(() {
      _lastResult = result;
      _currentProduct = null;
      _productError = null;
      _isLoadingProduct = true;
    });

    _loadProductInfo(result.text);
  }

  Future<void> _loadProductInfo(String barcode) async {
    try {
      final product = await WeebiOpenFoodFactsService.getProduct(barcode);
      
      if (mounted) {
        setState(() {
          _currentProduct = product;
          _isLoadingProduct = false;
          _productError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentProduct = null;
          _isLoadingProduct = false;
          _productError = e.toString();
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
            },
            tooltip: _isScanning ? 'Pause Scanning' : 'Start Scanning',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _lastResult = null;
                _currentProduct = null;
                _productError = null;
                _isLoadingProduct = false;
              });
            },
            tooltip: 'Clear Results',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Camera Preview
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _buildCameraPreview(),
            ),
          ),
          
          // Right side - Product Information
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              child: _buildProductInfoPanel(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SimpleScannerDemo(),
            ),
          );
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Simple Scanner'),
        tooltip: 'Open simple barcode_scan2-style scanner',
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Scanning Paused'),
            SizedBox(height: 8),
            Text(
              'Press play to resume scanning',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Use the BarcodeScannerWidget for camera preview and scanning
        Positioned.fill(
          child: BarcodeScannerWidget(
            onBarcodeDetected: _handleBarcodeDetected,
            onError: (error) => _showError(error),
            config: ScannerConfig.continuousMode,
          ),
        ),
        
        // Status indicator
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'SCANNING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

  Widget _buildProductInfoPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Product Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Barcode info
          if (_lastResult != null) ...[
            _buildInfoCard(
              'Barcode Detected',
              [
                _buildInfoRow('Type', _lastResult!.format),
                _buildInfoRow('Value', _lastResult!.text),
              ],
              icon: Icons.qr_code,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
          ],
          
          // Product info
          Expanded(
            child: _buildProductCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    if (_lastResult == null) {
      return _buildInfoCard(
        'No Barcode Detected',
        [
          const Text(
            'Point the camera at a barcode to get product information.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
        icon: Icons.search,
        color: Colors.grey,
      );
    }

    if (_isLoadingProduct) {
      return _buildInfoCard(
        'Loading Product...',
        [
          const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Fetching product information...'),
            ],
          ),
        ],
        icon: Icons.hourglass_empty,
        color: Colors.orange,
      );
    }

    if (_productError != null) {
      return _buildInfoCard(
        'Product Not Found',
        [
          Text(
            'Could not find product information for this barcode.',
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Error: $_productError',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }

    if (_currentProduct == null) {
      return _buildInfoCard(
        'No Product Information',
        [
          const Text(
            'No product information available for this barcode.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
        icon: Icons.help_outline,
        color: Colors.grey,
      );
    }

    // Product found - display full information
    return SingleChildScrollView(
      child: _buildInfoCard(
        _currentProduct!.name ?? 'Unknown Product',
        [
          // Product image
          if (_currentProduct!.imageUrl != null) ...[
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _currentProduct!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Product details
          if (_currentProduct!.brand != null)
            _buildInfoRow('Brand', _currentProduct!.brand!),
          if (_currentProduct!.ingredients != null)
            _buildInfoRow('Ingredients', _currentProduct!.ingredients!),
          if (_currentProduct!.nutriScore != null)
            _buildNutritionGrade(_currentProduct!.nutriScore!),
          
          const SizedBox(height: 16),
          
          // Allergens
          if (_currentProduct!.allergens.isNotEmpty) ...[
            const Text(
              'Allergens:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentProduct!.allergens.join(', '),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ],
        ],
        icon: Icons.shopping_basket,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children, {
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionGrade(String grade) {
    Color gradeColor;
    switch (grade.toLowerCase()) {
      case 'a':
        gradeColor = Colors.green;
        break;
      case 'b':
        gradeColor = Colors.lightGreen;
        break;
      case 'c':
        gradeColor = Colors.orange;
        break;
      case 'd':
        gradeColor = Colors.deepOrange;
        break;
      case 'e':
        gradeColor = Colors.red;
        break;
      default:
        gradeColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              'Nutrition:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gradeColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Grade ${grade.toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 