import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

/// Simple demo of the new auto-download barcode scanner
/// 
/// This demo shows how easy it is to use the scanner now:
/// - No need to manually download or bundle the model
/// - No asset configuration required
/// - Just use SimpleBarcodeScanner and it handles everything
class SimpleScannerDemo extends StatefulWidget {
  const SimpleScannerDemo({super.key});

  @override
  State<SimpleScannerDemo> createState() => _SimpleScannerDemoState();
}

class _SimpleScannerDemoState extends State<SimpleScannerDemo> {
  List<BarcodeResult> _scannedCodes = [];
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Scanner Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Information card
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎉 New Auto-Download Feature',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• No need to manually download or bundle the model\n'
                    '• First scan will automatically download from Hugging Face\n'  
                    '• Model is cached for future use\n'
                    '• Works completely offline after first download',
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error: $_error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Scanner view
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SimpleBarcodeScanner(
                  onBarcodeDetected: (result) {
                    setState(() {
                      // Add to beginning of list to show newest first
                      _scannedCodes.insert(0, result);
                      // Keep only last 10 scans
                      if (_scannedCodes.length > 10) {
                        _scannedCodes = _scannedCodes.take(10).toList();
                      }
                      _error = null; // Clear any previous errors
                    });
                  },
                  onError: (error) {
                    setState(() {
                      _error = error;
                    });
                  },
                  loadingWidget: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing scanner...'),
                        SizedBox(height: 8),
                        Text(
                          'First time? Downloading model from Hugging Face',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Scanned codes list
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned Codes (${_scannedCodes.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _scannedCodes.isEmpty
                        ? const Center(
                            child: Text(
                              'No codes scanned yet.\nPoint camera at a barcode to scan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _scannedCodes.length,
                            itemBuilder: (context, index) {
                              final code = _scannedCodes[index];
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    _getIconForFormat(code.format),
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    code.text,
                                    style: const TextStyle(fontFamily: 'Courier'),
                                  ),
                                                                     subtitle: Text(
                                     '${code.format} • Confidence: ${((code.confidence ?? 0.0) * 100).toStringAsFixed(1)}%',
                                   ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      // In a real app, you'd copy to clipboard
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Copied: ${code.text}')),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _scannedCodes.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _scannedCodes.clear();
                });
              },
              child: const Icon(Icons.clear),
            )
          : null,
    );
  }

  IconData _getIconForFormat(String format) {
    switch (format.toLowerCase()) {
      case 'qr_code':
        return Icons.qr_code;
      case 'ean_13':
      case 'ean_8':
      case 'code_128':
      case 'code_39':
        return Icons.barcode_reader;
      default:
        return Icons.document_scanner;
    }
  }
} 