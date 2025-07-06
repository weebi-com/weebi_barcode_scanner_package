import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'language.dart';

/// Product type enumeration
enum OFFProductType {
  food('Food Product'),
  beauty('Beauty/Cosmetic Product'),
  general('General Product');
  
  const OFFProductType(this.displayName);
  final String displayName;
}

/// Price information from Open Prices API
class OFFPrice {
  /// Price value
  final double price;
  
  /// Currency code (EUR, USD, etc.)
  final String currency;
  
  /// Store/location where price was recorded
  final String? storeName;
  
  /// Store brand/chain
  final String? storeBrand;
  
  /// Location (city, country)
  final String? location;
  
  /// Date when price was recorded
  final DateTime date;
  
  /// Price per unit (if applicable)
  final double? pricePerUnit;
  
  /// Unit (kg, L, etc.)
  final String? unit;
  
  /// Whether this is a promotional price
  final bool isPromo;
  
  /// Source of the price data
  final String source;
  
  const OFFPrice({
    required this.price,
    required this.currency,
    this.storeName,
    this.storeBrand,
    this.location,
    required this.date,
    this.pricePerUnit,
    this.unit,
    this.isPromo = false,
    this.source = 'Open Prices',
  });
  
  /// Create from Open Prices API response
  factory OFFPrice.fromOpenPrices(Map<String, dynamic> json) {
    return OFFPrice(
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] ?? 'EUR',
      storeName: json['location_osm_name'],
      storeBrand: json['location_osm_display_name'],
      location: json['location_osm_address_city'],
      date: DateTime.parse(json['date']),
      pricePerUnit: json['price_per'] != null ? (json['price_per'] as num).toDouble() : null,
      unit: json['price_per_unit'],
      isPromo: json['labels_tags']?.contains('en:promotion') ?? false,
      source: 'Open Prices',
    );
  }
  
  @override
  String toString() {
    return '$price $currency${storeName != null ? ' at $storeName' : ''}';
  }
}

/// Price statistics for a product
class OFFPriceStats {
  /// Current average price
  final double? averagePrice;
  
  /// Minimum price found
  final double? minPrice;
  
  /// Maximum price found
  final double? maxPrice;
  
  /// Number of price records
  final int priceCount;
  
  /// Currency for the statistics
  final String currency;
  
  /// Last updated date
  final DateTime? lastUpdated;
  
  const OFFPriceStats({
    this.averagePrice,
    this.minPrice,
    this.maxPrice,
    required this.priceCount,
    required this.currency,
    this.lastUpdated,
  });
  
  /// Create from multiple price records
  factory OFFPriceStats.fromPrices(List<OFFPrice> prices) {
    if (prices.isEmpty) {
      return const OFFPriceStats(priceCount: 0, currency: 'EUR');
    }
    
    final priceValues = prices.map((p) => p.price).toList();
    final currency = prices.first.currency;
    
    return OFFPriceStats(
      averagePrice: priceValues.reduce((a, b) => a + b) / priceValues.length,
      minPrice: priceValues.reduce((a, b) => a < b ? a : b),
      maxPrice: priceValues.reduce((a, b) => a > b ? a : b),
      priceCount: prices.length,
      currency: currency,
      lastUpdated: prices.map((p) => p.date).reduce((a, b) => a.isAfter(b) ? a : b),
    );
  }
}

/// Enhanced product model with multi-language support and pricing data
class OFFProduct {
  /// Product barcode
  final String barcode;
  
  /// Product type (food, beauty, or general)
  final OFFProductType productType;
  
  /// Product name (in the fetched language)
  final String? name;
  
  /// Product brand
  final String? brand;
  
  /// Ingredients text (in the fetched language)
  final String? ingredients;
  
  /// List of allergens
  final List<String> allergens;
  
  /// Nutri-Score (A, B, C, D, E)
  final String? nutriScore;
  
  /// NOVA group (1-4, food processing level)
  final int? novaGroup;
  
  /// Main product image URL
  final String? imageUrl;
  
  /// Ingredients image URL
  final String? ingredientsImageUrl;
  
  /// Nutrition facts image URL
  final String? nutritionImageUrl;
  
  /// Language of the fetched data
  final AppLanguage language;
  
  /// When this product data was cached
  final DateTime cachedAt;
  
  /// Current price information (latest available)
  final OFFPrice? currentPrice;
  
  /// Recent price history (last 30 days)
  final List<OFFPrice> recentPrices;
  
  /// Price statistics
  final OFFPriceStats? priceStats;
  
  /// Whether price data is available for this product
  bool get hasPriceData => currentPrice != null || recentPrices.isNotEmpty;
  
  /// Cosmetic-specific fields (for beauty products)
  final String? periodAfterOpening;
  final List<String> cosmeticIngredients;
  
  const OFFProduct({
    required this.barcode,
    required this.productType,
    this.name,
    this.brand,
    this.ingredients,
    this.allergens = const [],
    this.nutriScore,
    this.novaGroup,
    this.imageUrl,
    this.ingredientsImageUrl,
    this.nutritionImageUrl,
    required this.language,
    required this.cachedAt,
    this.currentPrice,
    this.recentPrices = const [],
    this.priceStats,
    this.periodAfterOpening,
    this.cosmeticIngredients = const [],
  });

  /// Create from OpenFoodFacts API response
  factory OFFProduct.fromOpenFoodFacts(
    off.Product product, 
    AppLanguage language,
    OFFProductType productType, {
    OFFPrice? currentPrice,
    List<OFFPrice> recentPrices = const [],
    OFFPriceStats? priceStats,
  }) {
    return OFFProduct(
      barcode: product.barcode ?? '',
      productType: productType,
      name: product.productName,
      brand: product.brands,
      ingredients: product.ingredientsText,
      allergens: product.allergens?.names ?? [],
      nutriScore: product.nutriscore?.toUpperCase(),
      novaGroup: product.novaGroup,
      imageUrl: product.imageFrontUrl,
      ingredientsImageUrl: product.imageIngredientsUrl,
      nutritionImageUrl: product.imageNutritionUrl,
      language: language,
      cachedAt: DateTime.now(),
      currentPrice: currentPrice,
      recentPrices: recentPrices,
      priceStats: priceStats,
      // Cosmetic fields (for future beauty products)
      periodAfterOpening: null, // TODO: Extract from product data
      cosmeticIngredients: [], // TODO: Parse cosmetic ingredients
    );
  }

  /// Create a copy with updated price data
  OFFProduct copyWithPrices({
    OFFPrice? currentPrice,
    List<OFFPrice>? recentPrices,
    OFFPriceStats? priceStats,
  }) {
    return OFFProduct(
      barcode: barcode,
      productType: productType,
      name: name,
      brand: brand,
      ingredients: ingredients,
      allergens: allergens,
      nutriScore: nutriScore,
      novaGroup: novaGroup,
      imageUrl: imageUrl,
      ingredientsImageUrl: ingredientsImageUrl,
      nutritionImageUrl: nutritionImageUrl,
      language: language,
      cachedAt: cachedAt,
      currentPrice: currentPrice ?? this.currentPrice,
      recentPrices: recentPrices ?? this.recentPrices,
      priceStats: priceStats ?? this.priceStats,
      periodAfterOpening: periodAfterOpening,
      cosmeticIngredients: cosmeticIngredients,
    );
  }

  @override
  String toString() {
    final priceInfo = currentPrice != null ? ' - $currentPrice' : '';
    return '${name ?? 'Unknown Product'} ($barcode)$priceInfo';
  }
} 