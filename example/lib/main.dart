import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weebi_barcode_scanner/weebi_barcode_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner with OpenFoodFacts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  ScannerConfig _currentConfig = ScannerConfig.continuous();
  final List<BarcodeResult> _scanHistory = [];
  BarcodeResult? _lastScanned;
  off.Product? _currentProduct;
  bool _isLoadingProduct = false;

  @override
  void initState() {
    super.initState();
    // Initialize OpenFoodFacts
    OpenFoodFactsService.initialize(
      appName: 'Weebi Barcode Scanner Demo',
      appUrl: 'https://github.com/weebi-com/weebi_barcode_scanner',
    );
  }

  void _onBarcodeScanned(BarcodeResult result) async {
    setState(() {
      _lastScanned = result;
      _scanHistory.insert(0, result);
      if (_scanHistory.length > 10) {
        _scanHistory.removeLast();
      }
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Look up product information if it's likely a food product
    if (OpenFoodFactsService.isLikelyFoodProduct(result.text)) {
      setState(() {
        _isLoadingProduct = true;
        _currentProduct = null;
      });

      try {
        final product = await OpenFoodFactsService.getProduct(result.text);
        setState(() {
          _currentProduct = product;
          _isLoadingProduct = false;
        });
      } catch (e) {
        debugPrint('Error loading product: $e');
        setState(() {
          _isLoadingProduct = false;
        });
      }
    } else {
      setState(() {
        _currentProduct = null;
        _isLoadingProduct = false;
      });
    }
  }

  void _clearHistory() {
    setState(() {
      _scanHistory.clear();
      _lastScanned = null;
      _currentProduct = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Barcode Scanner + OpenFoodFacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Row(
        children: [
          // Camera Preview (Left 2/3)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Mode Selection
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: _currentConfig.scanOnce ? Colors.green.shade100 : Colors.blue.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentConfig.scanOnce ? Icons.point_of_sale : Icons.repeat,
                        color: _currentConfig.scanOnce ? Colors.green : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentConfig.scanOnce ? 'Point-of-Sale Mode' : 'Continuous Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentConfig.scanOnce ? Colors.green.shade700 : Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Switch(
                        value: _currentConfig.scanOnce,
                        onChanged: (value) {
                          setState(() {
                            _currentConfig = value 
                                ? ScannerConfig.pointOfSale()
                                : ScannerConfig.continuous();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                                 // Camera Scanner
                 Expanded(
                   child: BarcodeScannerWidget(
                     config: _currentConfig,
                     onBarcodeDetected: _onBarcodeScanned,
                   ),
                 ),
                // Last Scanned Result
                if (_lastScanned != null)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Last: ${_lastScanned!.text}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Product Info Panel (Right 1/3)
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  // Product Info Header
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.orange.shade100,
                    child: const Row(
                      children: [
                        Icon(Icons.restaurant, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Product Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Product Details
                  Expanded(
                    child: _buildProductInfo(),
                  ),
                  // Scan History
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.blue.shade100,
                          child: const Row(
                            children: [
                              Icon(Icons.history, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Scan History',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _scanHistory.length,
                            itemBuilder: (context, index) {
                              final result = _scanHistory[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.qr_code, size: 16),
                                title: Text(
                                  result.text,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                subtitle: Text(
                                  result.format,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                onTap: () {
                                  setState(() {
                                    _lastScanned = result;
                                  });
                                  _onBarcodeScanned(result);
                                },
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildProductInfo() {
    if (_isLoadingProduct) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading product info...'),
          ],
        ),
      );
    }

    if (_currentProduct == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Scan a food product\nto see information',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final product = _currentProduct!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name & Brand
          if (product.productName != null) ...[
            Text(
              product.productName!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (product.brands != null) ...[
            Text(
              product.brands!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Nutri-Score
          if (product.nutriscore != null) ...[
            _buildInfoCard(
              'Nutri-Score',
              product.nutriscore!.toUpperCase(),
              OpenFoodFactsService.getNutriScoreColor(product.nutriscore),
            ),
            const SizedBox(height: 12),
          ],
          
          // NOVA Group
          if (product.novaGroup != null) ...[
            _buildInfoCard(
              'NOVA Group',
              'Group ${product.novaGroup}',
              _getNovaColor(product.novaGroup!),
              subtitle: OpenFoodFactsService.getNovaGroupDescription(product.novaGroup),
            ),
            const SizedBox(height: 12),
          ],
          
          // Allergens
          if (product.allergens?.names.isNotEmpty == true) ...[
            const Text(
              'Allergens',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: product.allergens!.names.map((allergen) {
                return Chip(
                  label: Text(
                    allergen,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.red.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Ingredients
          if (product.ingredientsText != null) ...[
            const Text(
              'Ingredients',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              product.ingredientsText!,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color? color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: color ?? Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color ?? Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getNovaColor(int novaGroup) {
    switch (novaGroup) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 