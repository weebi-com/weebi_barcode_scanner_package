library weebi_barcode_scanner;

import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

// Export the main widget and supporting classes
export 'src/barcode_scanner_widget.dart';
export 'src/barcode_result.dart';
export 'src/scanner_config.dart';
export 'src/platform_camera_manager.dart';
export 'src/simple_barcode_scanner.dart';

// Export OpenFoodFacts service and models
export 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';
export 'package:weebi_openfoodfacts_service/src/models/weebi_product.dart';
export 'package:weebi_openfoodfacts_service/src/models/weebi_language.dart';

/// Public API for OpenFoodFacts integration
class WeebiBarcodeScannerAPI {
  /// Initialize OpenFoodFacts (no credentials required)
  static Future<void> initializeOpenFoodFacts({
    String appName = 'WeebiBarcodeScannerApp',
    bool enablePricing = false,
    bool enableBeautyProducts = true,
    bool enableGeneralProducts = true,
  }) async {
    await WeebiOpenFoodFactsService.initialize(
      appName: appName,
      enablePricing: enablePricing,
      enableBeautyProducts: enableBeautyProducts,
      enableGeneralProducts: enableGeneralProducts,
    );
  }

  /// Fetch product info by barcode (food, beauty, or general)
  static Future<WeebiProduct?> fetchProduct(String barcode) async {
    // Get current configuration to respect enabled features
    final features = getAvailableFeatures();
    final enableBeautyProducts = features['beauty_products'] ?? true;
    final enableGeneralProducts = features['general_products'] ?? true;
    
    // Try food first (always enabled)
    final food = await WeebiOpenFoodFactsService.getProduct(barcode);
    if (food != null) return food;
    
    // Try beauty products only if enabled
    if (enableBeautyProducts) {
      final beauty = await WeebiOpenFoodFactsService.getBeautyProduct(barcode);
      if (beauty != null) return beauty;
    }
    
    // Try general products only if enabled
    if (enableGeneralProducts) {
      return await WeebiOpenFoodFactsService.getGeneralProduct(barcode);
    }
    
    // No product found and no additional categories enabled
    return null;
  }

  /// Fetch food product only
  static Future<WeebiProduct?> fetchFoodProduct(String barcode) =>
      WeebiOpenFoodFactsService.getProduct(barcode);

  /// Fetch beauty product only (returns null if beauty products are disabled)
  static Future<WeebiProduct?> fetchBeautyProduct(String barcode) async {
    final features = getAvailableFeatures();
    final enableBeautyProducts = features['beauty_products'] ?? true;
    
    if (!enableBeautyProducts) {
      return null; // Feature disabled
    }
    
    return await WeebiOpenFoodFactsService.getBeautyProduct(barcode);
  }

  /// Fetch general product only (returns null if general products are disabled)
  static Future<WeebiProduct?> fetchGeneralProduct(String barcode) async {
    final features = getAvailableFeatures();
    final enableGeneralProducts = features['general_products'] ?? true;
    
    if (!enableGeneralProducts) {
      return null; // Feature disabled
    }
    
    return await WeebiOpenFoodFactsService.getGeneralProduct(barcode);
  }

  /// Get available OpenFoodFacts features
  static Map<String, bool> getAvailableFeatures() =>
      WeebiOpenFoodFactsService.getAvailableFeatures();

  /// Get credential setup info (for pricing, etc.)
  static String getCredentialSetupInfo() =>
      WeebiOpenFoodFactsService.getCredentialSetupInfo();
}