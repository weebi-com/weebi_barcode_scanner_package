import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models/weebi_product.dart';
import 'models/weebi_language.dart';

/// Client for OpenBeautyFacts API integration
/// Based on: https://openbeautyfacts.org/
/// Provides access to cosmetic and beauty product data
class OpenBeautyFactsClient {
  static const String _baseUrl = 'https://openbeautyfacts.org/api/v0';
  static const String _userAgent = 'WeebiOpenFoodFactsService/1.3.0';
  
  /// HTTP client instance
  final http.Client _httpClient;
  
  OpenBeautyFactsClient({http.Client? httpClient}) 
    : _httpClient = httpClient ?? http.Client();
  
  /// Get beauty product information by barcode
  Future<Map<String, dynamic>?> getBeautyProduct(String barcode) async {
    try {
      debugPrint('🔍 OpenBeautyFacts: Fetching beauty product $barcode');
      
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
          
          // Verify this is actually a beauty product
          if (product['product_type'] == 'beauty') {
            debugPrint('✅ OpenBeautyFacts: Found beauty product $barcode');
            return product;
          } else {
            debugPrint('⚠️  OpenBeautyFacts: Product $barcode is not a beauty product (type: ${product['product_type']})');
            return null;
          }
        } else {
          debugPrint('❌ OpenBeautyFacts: Product $barcode not found');
          return null;
        }
      } else {
        debugPrint('❌ OpenBeautyFacts: HTTP error ${response.statusCode} for product $barcode');
        return null;
      }
    } catch (e) {
      debugPrint('❌ OpenBeautyFacts: Error fetching product $barcode: $e');
      return null;
    }
  }
  
  /// Convert OpenBeautyFacts API response to WeebiProduct
  WeebiProduct? convertToWeebiProduct(
    Map<String, dynamic> beautyProduct,
    WeebiLanguage language,
  ) {
    try {
      // Extract basic information
      final barcode = beautyProduct['code'] ?? '';
      final name = beautyProduct['product_name'] ?? 
                   beautyProduct['product_name_${language.code}'] ??
                   beautyProduct['generic_name'] ??
                   beautyProduct['generic_name_${language.code}'];
      final brand = beautyProduct['brands'];
      final ingredients = beautyProduct['ingredients_text'] ?? 
                         beautyProduct['ingredients_text_${language.code}'];
      
      // Extract allergens
      final allergens = <String>[];
      if (beautyProduct['allergens'] != null && beautyProduct['allergens'].toString().isNotEmpty) {
        allergens.addAll(beautyProduct['allergens'].toString().split(',').map((e) => e.trim()));
      }
      
      // Extract cosmetic-specific fields
      final periodAfterOpening = beautyProduct['periods_after_opening'];
      final cosmeticIngredients = <String>[];
      
      // Parse ingredients list if available
      if (beautyProduct['ingredients'] != null) {
        final ingredientsList = beautyProduct['ingredients'] as List;
        for (final ingredient in ingredientsList) {
          if (ingredient is Map<String, dynamic> && ingredient['text'] != null) {
            cosmeticIngredients.add(ingredient['text']);
          }
        }
      }
      
      // Extract images
      final imageUrl = beautyProduct['image_front_url'] ?? beautyProduct['image_url'];
      final ingredientsImageUrl = beautyProduct['image_ingredients_url'];
      
      return WeebiProduct(
        barcode: barcode,
        productType: WeebiProductType.beauty,
        name: name,
        brand: brand,
        ingredients: ingredients,
        allergens: allergens,
        imageUrl: imageUrl,
        ingredientsImageUrl: ingredientsImageUrl,
        language: language,
        cachedAt: DateTime.now(),
        periodAfterOpening: periodAfterOpening,
        cosmeticIngredients: cosmeticIngredients,
      );
    } catch (e) {
      debugPrint('❌ OpenBeautyFacts: Error converting product data: $e');
      return null;
    }
  }
  
  /// Search beauty products
  Future<List<Map<String, dynamic>>> searchBeautyProducts({
    String? query,
    String? brand,
    String? category,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 OpenBeautyFacts: Searching beauty products');
      
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
        
        debugPrint('✅ OpenBeautyFacts: Found ${products.length} beauty products');
        return products.cast<Map<String, dynamic>>();
      } else {
        debugPrint('❌ OpenBeautyFacts: HTTP error ${response.statusCode} for search');
        return [];
      }
    } catch (e) {
      debugPrint('❌ OpenBeautyFacts: Error searching products: $e');
      return [];
    }
  }
  
  /// Get beauty product categories
  Future<List<String>> getBeautyCategories() async {
    try {
      debugPrint('🔍 OpenBeautyFacts: Fetching beauty categories');
      
      // Try the categories endpoint
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
        
        // Filter for beauty-related categories
        final beautyCategories = <String>[];
        for (final category in categories) {
          if (category is Map<String, dynamic>) {
            final name = category['name']?.toString() ?? '';
            final id = category['id']?.toString() ?? '';
            
            // Filter for beauty-related categories
            if (id.contains('beauty') || 
                id.contains('cosmetic') || 
                id.contains('hygiene') ||
                id.contains('skincare') ||
                id.contains('makeup') ||
                id.contains('perfume') ||
                id.contains('mouthwash') ||
                id.contains('shampoo') ||
                id.contains('soap')) {
              beautyCategories.add(name);
            }
          }
        }
        
        debugPrint('✅ OpenBeautyFacts: Found ${beautyCategories.length} beauty categories');
        return beautyCategories;
      } else {
        debugPrint('❌ OpenBeautyFacts: HTTP error ${response.statusCode} for categories');
        
        // Fallback: return common beauty categories
        return [
          'Hygiene',
          'Mouthwash',
          'Shampoo',
          'Soap',
          'Skincare',
          'Makeup',
          'Perfume',
          'Cosmetics',
        ];
      }
    } catch (e) {
      debugPrint('❌ OpenBeautyFacts: Error fetching categories: $e');
      
      // Fallback: return common beauty categories
      return [
        'Hygiene',
        'Mouthwash',
        'Shampoo',
        'Soap',
        'Skincare',
        'Makeup',
        'Perfume',
        'Cosmetics',
      ];
    }
  }
} 