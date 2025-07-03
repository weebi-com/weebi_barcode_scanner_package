import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models/product.dart';
import 'models/language.dart';

/// Client for OpenProductsFacts API integration
/// Based on: https://openproductsfacts.org/
/// Provides access to general consumer product data
class OpenProductsFactsClient {
  static const String _baseUrl = 'https://openproductsfacts.org/api/v0';
  static const String _userAgent = 'WeebiOpenFoodFactsService/1.3.0';
  
  /// HTTP client instance
  final http.Client _httpClient;
  
  OpenProductsFactsClient({http.Client? httpClient}) 
    : _httpClient = httpClient ?? http.Client();
  
  /// Get general product information by barcode
  Future<Map<String, dynamic>?> getProduct(String barcode) async {
    try {
      debugPrint('🔍 OpenProductsFacts: Fetching product $barcode');
      
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/product/$barcode.json'),
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'] as Map<String, dynamic>;
          
          // Verify this is actually a general product
          if (product['product_type'] == 'product') {
            debugPrint('✅ OpenProductsFacts: Found product $barcode');
            return product;
          } else {
            debugPrint('⚠️  OpenProductsFacts: Product $barcode is not a general product (type: ${product['product_type']})');
            return null;
          }
        } else {
          debugPrint('❌ OpenProductsFacts: Product $barcode not found');
          return null;
        }
      } else {
        debugPrint('❌ OpenProductsFacts: HTTP error ${response.statusCode} for product $barcode');
        return null;
      }
    } catch (e) {
      debugPrint('❌ OpenProductsFacts: Error fetching product $barcode: $e');
      return null;
    }
  }
  
  /// Convert OpenProductsFacts API response to OFFProduct
  OFFProduct? convertToWeebiProduct(
    Map<String, dynamic> productData,
    AppLanguage language,
  ) {
    try {
      // Extract basic information
      final barcode = productData['code'] ?? '';
      final name = productData['product_name'] ?? 
                   productData['product_name_${language.code}'] ??
                   productData['generic_name'] ??
                   productData['generic_name_${language.code}'];
      final brand = productData['brands'];
      final ingredients = productData['ingredients_text'] ?? 
                         productData['ingredients_text_${language.code}'];
      
      // Extract allergens/traces
      final allergens = <String>[];
      if (productData['allergens'] != null && productData['allergens'].toString().isNotEmpty) {
        allergens.addAll(productData['allergens'].toString().split(',').map((e) => e.trim()));
      }
      if (productData['traces'] != null && productData['traces'].toString().isNotEmpty) {
        allergens.addAll(productData['traces'].toString().split(',').map((e) => e.trim()));
      }
      
      // Extract product-specific fields
      final categories = productData['categories'] ?? '';
      final packaging = productData['packaging'] ?? '';
      final quantity = productData['quantity'] ?? '';
      
      // Extract images
      final imageUrl = productData['image_front_url'] ?? productData['image_url'];
      final ingredientsImageUrl = productData['image_ingredients_url'];
      
              return OFFProduct(
          barcode: barcode,
          productType: OFFProductType.general,
        name: name,
        brand: brand,
        ingredients: ingredients,
        allergens: allergens,
        imageUrl: imageUrl,
        ingredientsImageUrl: ingredientsImageUrl,
        language: language,
        cachedAt: DateTime.now(),
        // General product specific fields (can be extended later)
        periodAfterOpening: null,
        cosmeticIngredients: [],
      );
    } catch (e) {
      debugPrint('❌ OpenProductsFacts: Error converting product data: $e');
      return null;
    }
  }
  
  /// Search general products
  Future<List<Map<String, dynamic>>> searchProducts({
    String? query,
    String? brand,
    String? category,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 OpenProductsFacts: Searching products');
      
      final queryParams = <String, String>{
        'search_terms': query ?? '',
        'json': '1',
        'page_size': limit.toString(),
      };
      
      if (brand != null) queryParams['brands'] = brand;
      if (category != null) queryParams['categories'] = category;
      
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);
      
      final response = await _httpClient.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List? ?? [];
        
        debugPrint('✅ OpenProductsFacts: Found ${products.length} products');
        return products.cast<Map<String, dynamic>>();
      } else {
        debugPrint('❌ OpenProductsFacts: HTTP error ${response.statusCode} for search');
        return [];
      }
    } catch (e) {
      debugPrint('❌ OpenProductsFacts: Error searching products: $e');
      return [];
    }
  }
  
  /// Get product categories
  Future<List<String>> getProductCategories() async {
    try {
      debugPrint('🔍 OpenProductsFacts: Fetching product categories');
      
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/categories.json'),
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final categories = data['tags'] as List? ?? [];
        
        // Extract category names
        final categoryNames = <String>[];
        for (final category in categories) {
          if (category is Map<String, dynamic>) {
            final name = category['name']?.toString() ?? '';
            if (name.isNotEmpty) {
              categoryNames.add(name);
            }
          }
        }
        
        debugPrint('✅ OpenProductsFacts: Found ${categoryNames.length} product categories');
        return categoryNames;
      } else {
        debugPrint('❌ OpenProductsFacts: HTTP error ${response.statusCode} for categories');
        
        // Fallback: return common product categories
        return [
          'Electronics',
          'Clothing',
          'Home & Garden',
          'Sports & Leisure',
          'Books & Media',
          'Toys & Games',
          'Automotive',
          'Tools & Hardware',
        ];
      }
    } catch (e) {
      debugPrint('❌ OpenProductsFacts: Error fetching categories: $e');
      
      // Fallback: return common product categories
      return [
        'Electronics',
        'Clothing',
        'Home & Garden',
        'Sports & Leisure',
        'Books & Media',
        'Toys & Games',
        'Automotive',
        'Tools & Hardware',
      ];
    }
  }
} 