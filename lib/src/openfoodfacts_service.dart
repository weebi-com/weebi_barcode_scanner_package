import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;

/// Service for integrating with OpenFoodFacts API
class OpenFoodFactsService {
  static bool _initialized = false;
  
  /// Initialize the OpenFoodFacts SDK
  static void initialize({
    String appName = 'Weebi Barcode Scanner',
    String? appUrl,
  }) {
    if (_initialized) return;
    
    off.OpenFoodAPIConfiguration.userAgent = off.UserAgent(
      name: appName,
      url: appUrl,
    );
    
    off.OpenFoodAPIConfiguration.globalLanguages = <off.OpenFoodFactsLanguage>[
      off.OpenFoodFactsLanguage.ENGLISH,
      off.OpenFoodFactsLanguage.FRENCH,
    ];
    
    // Use FRANCE as default - it works for worldwide queries
    off.OpenFoodAPIConfiguration.globalCountry = off.OpenFoodFactsCountry.FRANCE;
    
    _initialized = true;
    debugPrint('OpenFoodFacts SDK initialized');
  }
  
  /// Lookup product information by barcode
  static Future<off.Product?> getProduct(String barcode) async {
    if (!_initialized) {
      initialize();
    }
    
    try {
      debugPrint('Looking up product: $barcode');
      
      final configuration = off.ProductQueryConfiguration(
        barcode,
        language: off.OpenFoodFactsLanguage.ENGLISH,
        fields: [
          off.ProductField.BARCODE,
          off.ProductField.NAME,
          off.ProductField.BRANDS,
          off.ProductField.INGREDIENTS_TEXT,
          off.ProductField.ALLERGENS,
          off.ProductField.NUTRISCORE,
          off.ProductField.NOVA_GROUP,
          off.ProductField.NUTRIMENTS,
          off.ProductField.IMAGES,
          off.ProductField.IMAGE_FRONT_URL,
          off.ProductField.IMAGE_INGREDIENTS_URL,
          off.ProductField.IMAGE_NUTRITION_URL,
        ],
        version: off.ProductQueryVersion.v3,
      );
      
      final result = await off.OpenFoodAPIClient.getProductV3(configuration);
      
      if (result.status == off.ProductResultV3.statusSuccess) {
        debugPrint('Product found: ${result.product?.productName}');
        return result.product;
      } else {
        debugPrint('Product not found: ${result.status}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }
  
  /// Get nutrition grade color for UI
  static Color? getNutriScoreColor(String? nutriScore) {
    if (nutriScore == null) return null;
    
    switch (nutriScore.toUpperCase()) {
      case 'A':
        return const Color(0xFF008856); // Dark green
      case 'B':
        return const Color(0xFF85BB2F); // Light green  
      case 'C':
        return const Color(0xFFFFD100); // Yellow
      case 'D':
        return const Color(0xFFFF8C00); // Orange
      case 'E':
        return const Color(0xFFE63946); // Red
      default:
        return null;
    }
  }
  
  /// Get NOVA group description
  static String getNovaGroupDescription(int? novaGroup) {
    switch (novaGroup) {
      case 1:
        return 'Unprocessed or minimally processed foods';
      case 2:
        return 'Processed culinary ingredients';
      case 3:
        return 'Processed foods';
      case 4:
        return 'Ultra-processed foods';
      default:
        return 'Processing level unknown';
    }
  }
  
  /// Format energy value for display
  static String formatEnergy(double? energyKcal) {
    if (energyKcal == null) return 'N/A';
    return '${energyKcal.round()} kcal';
  }
  
  /// Check if barcode is likely a food product (EAN-13 starting with certain prefixes)
  static bool isLikelyFoodProduct(String barcode) {
    if (barcode.length != 13) return false;
    
    // Common food product prefixes (this is a simplified check)
    final foodPrefixes = ['3', '4', '5', '6', '7', '8', '9'];
    return foodPrefixes.any((prefix) => barcode.startsWith(prefix));
  }
}

// Re-export Color for convenience
export 'package:flutter/material.dart' show Color; 