import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weebi Barcode Scanner Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String? _lastResult;
  String? _lastFormat;
  String? _lastProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Scanner widget - this is all you need!
          Expanded(
            child: BarcodeScannerWidget(
              onBarcodeDetected: (result) {
                setState(() {
                  _lastResult = result.text;
                  _lastFormat = result.format;
                  _lastProduct = result.productName;
                });
                
                // Show result dialog
                _showResultDialog(result);
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Scanner Error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              // Optional: Use different config
              // config: ScannerConfig.fastConfig, // or ScannerConfig.accurateConfig
            ),
          ),
          
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lastResult != null 
                    ? 'Last scanned: $_lastResult'
                    : 'Point camera at a barcode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_lastFormat != null)
                  Text(
                    'Format: $_lastFormat',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                if (_lastProduct != null)
                  Text(
                    'Product: $_lastProduct',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BarcodeResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.green),
            SizedBox(width: 8),
            Text('Barcode Found!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow('Code:', result.text),
            _buildResultRow('Format:', result.format),
            if (result.productName != null)
              _buildResultRow('Product:', result.productName!),
            if (result.productBrand != null)
              _buildResultRow('Brand:', result.productBrand!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (result.hasProductInfo)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Could navigate to product details page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product: ${result.productName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('View Product'),
            ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
} 