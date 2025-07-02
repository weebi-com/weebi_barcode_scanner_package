import 'package:flutter_test/flutter_test.dart';
import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

void main() {
  group('OpenBeautyFacts Integration Tests', () {
    setUpAll(() async {
      // Initialize the service
      await WeebiOpenFoodFactsService.initialize(
        appName: 'TestApp',
        enableBeautyProducts: true,
        enablePricing: false,
      );
    });

    test('should fetch beauty product by barcode', () async {
      // Test with a known beauty product barcode
      final product = await WeebiOpenFoodFactsService.getBeautyProduct('3560070791460');
      
      expect(product, isNotNull);
      expect(product!.productType, equals(OFFProductType.beauty));
      expect(product.barcode, equals('3560070791460'));
      expect(product.name, isNotNull);
      expect(product.brand, isNotNull);
      
      // Beauty-specific fields should be available
      expect(product.periodAfterOpening, isNotNull);
      expect(product.cosmeticIngredients, isNotEmpty);
      
      print('✅ Beauty product found: ${product.name} (${product.brand})');
      print('   Period after opening: ${product.periodAfterOpening}');
      print('   Ingredients: ${product.cosmeticIngredients.length} items');
    });

    test('should return null for non-beauty product', () async {
      // Test with a food product barcode
      final product = await WeebiOpenFoodFactsService.getBeautyProduct('3017620422003');
      
      expect(product, isNull);
    });

    test('should return null for invalid barcode', () async {
      final product = await WeebiOpenFoodFactsService.getBeautyProduct('invalid');
      
      expect(product, isNull);
    });

    test('should get beauty categories', () async {
      final categories = await WeebiOpenFoodFactsService.getBeautyCategories();
      
      expect(categories, isNotEmpty);
      expect(categories, isA<List<String>>());
      
      // Should contain common beauty categories (fallback or API)
      expect(categories.any((cat) => cat.toLowerCase().contains('hygiene')), isTrue);
      
      print('✅ Found ${categories.length} beauty categories');
      print('   Sample categories: ${categories.take(5).toList()}');
    });

    test('should search beauty products', () async {
      final products = await WeebiOpenFoodFactsService.searchBeautyProducts(
        query: 'shampoo',
        limit: 5,
      );
      
      expect(products, isA<List<OFFProduct>>());
      
      if (products.isNotEmpty) {
        expect(products.first.productType, equals(OFFProductType.beauty));
        print('✅ Found ${products.length} beauty products for "shampoo"');
        print('   Sample: ${products.first.name} (${products.first.brand})');
      }
    });

    test('should show beauty products in available features', () {
      final features = WeebiOpenFoodFactsService.getAvailableFeatures();
      
      expect(features['beauty_products'], isTrue);
      expect(features['food_products'], isTrue);
      
      print('✅ Available features:');
      features.forEach((feature, available) {
        print('   ${available ? '✅' : '❌'} $feature');
      });
    });
  });
} 