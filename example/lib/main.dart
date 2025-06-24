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
      title: 'Barcode Scanner Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
  bool _isPointOfSaleMode = true;
  BarcodeResult? _lastResult;
  List<BarcodeResult> _scanHistory = [];

  ScannerConfig get _currentConfig => _isPointOfSaleMode 
    ? ScannerConfig.pointOfSaleMode 
    : ScannerConfig.continuousMode;

  void _onBarcodeDetected(BarcodeResult result) {
    setState(() {
      _lastResult = result;
      _scanHistory.insert(0, result); // Add to beginning of list
      if (_scanHistory.length > 10) {
        _scanHistory = _scanHistory.take(10).toList(); // Keep last 10
      }
    });
  }

  void _onScannerError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanner Error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isPointOfSaleMode = !_isPointOfSaleMode;
    });
  }

  void _clearHistory() {
    setState(() {
      _scanHistory.clear();
      _lastResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Switch(
            value: _isPointOfSaleMode,
            onChanged: (value) => _toggleMode(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _isPointOfSaleMode ? 'POS' : 'Continuous',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Scanner area (left side)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              clipBehavior: Clip.antiAlias,
              child: BarcodeScannerWidget(
                key: ValueKey(_isPointOfSaleMode), // Rebuild when mode changes
                config: _currentConfig,
                onBarcodeDetected: _onBarcodeDetected,
                onError: _onScannerError,
                loadingWidget: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing Camera...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Product info / results area (right side)
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode indicator
                  Row(
                    children: [
                      Icon(
                        _isPointOfSaleMode ? Icons.point_of_sale : Icons.repeat,
                        color: _isPointOfSaleMode ? Colors.green : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isPointOfSaleMode ? 'Point of Sale' : 'Continuous Scan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Last scanned result
                  if (_lastResult != null) ...[
                    const Text(
                      'Last Scanned:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _lastResult!.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Format: ${_lastResult!.format}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          if (_lastResult!.productName != null)
                            Text(
                              'Product: ${_lastResult!.productName}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          if (_lastResult!.productBrand != null)
                            Text(
                              'Brand: ${_lastResult!.productBrand}',
                              style: const TextStyle(fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Scan history
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Scans:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_scanHistory.isNotEmpty)
                        TextButton(
                          onPressed: _clearHistory,
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: _scanHistory.isEmpty
                        ? Center(
                            child: Text(
                              _isPointOfSaleMode 
                                ? 'Point camera at barcode\nScanning will stop after detection'
                                : 'Point camera at barcode\nContinuous scanning mode',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _scanHistory.length,
                            itemBuilder: (context, index) {
                              final result = _scanHistory[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.text,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      result.format,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
    );
  }
} 