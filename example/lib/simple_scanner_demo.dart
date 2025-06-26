import 'package:flutter/material.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';

/// Simple demo showing the elegant barcode_scan2-style API
/// 
/// Usage: var result = await WeebiBarcodeScanner.scan();
class SimpleScannerDemo extends StatefulWidget {
  const SimpleScannerDemo({super.key});

  @override
  State<SimpleScannerDemo> createState() => _SimpleScannerDemoState();
}

class _SimpleScannerDemoState extends State<SimpleScannerDemo> {
  WeebiBarcodeResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Barcode Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or icon
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.blue,
            ),
            
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Barcode Scanner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            const Text(
              'Tap the scan button to start scanning barcodes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Scan button
            ElevatedButton.icon(
              onPressed: _scanBarcode,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Barcode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Results section
            if (_lastResult != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              _buildResultCard(_lastResult!),
            ],
          ],
        ),
      ),
    );
  }

  /// Scan a barcode using the simple API
  Future<void> _scanBarcode() async {
    try {
      // This is the elegant API - just like barcode_scan2!
      final result = await WeebiBarcodeScanner.scan(
        context: context,
        title: 'Scan Product Barcode',
        subtitle: 'Point your camera at a barcode to scan it',
      );
      
      setState(() {
        _lastResult = result;
      });
      
      // Show result feedback
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanned: ${result.code}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result.isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Build a card showing the scan result
  Widget _buildResultCard(WeebiBarcodeResult result) {
    if (result.isSuccess) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Scan Successful',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildResultRow('Barcode', result.code ?? 'Unknown'),
              _buildResultRow('Format', result.format ?? 'Unknown'),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Copy to clipboard
                        // Clipboard.setData(ClipboardData(text: result.code ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scanBarcode,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (result.isCancelled) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Scan Cancelled',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error: ${result.error}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
} 