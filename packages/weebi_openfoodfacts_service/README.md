# Weebi OpenFoodFacts Service

A comprehensive, reusable Flutter package for integrating with OpenFoodFacts API with advanced features like multi-language support, intelligent caching, and **Open Prices integration** for real-world pricing data.

## 🌟 Features

### **Current Capabilities**
- **OpenFoodFacts Integration**: Full access to 2.9M+ food products - ✅ **Works without credentials!**
- **🆕 Open Prices Integration**: Real-world pricing data from crowdsourced receipts - Requires authentication
- **Multi-Language Support**: 10+ languages with automatic fallbacks
- **Advanced Caching**: Product and image caching for offline support
- **🔐 Secure Credential Management**: Automatic credential loading with .gitignore support
- **Framework-Agnostic**: Can be used in any Flutter project
- **Production Ready**: Comprehensive error handling and validation

### **🚀 Quick Start**
```dart
import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

// Initialize without pricing (works immediately)
await WeebiOpenFoodFactsService.initialize(
  appName: 'MyApp/1.0',
  enablePricing: false, // Disable pricing to work without credentials
  enableBeautyProducts: true, // Enable beauty products
);

// Get food product information immediately
final foodProduct = await WeebiOpenFoodFactsService.getProduct('3017620422003');
print('Food Product: ${foodProduct?.name}');

// Get beauty product information
final beautyProduct = await WeebiOpenFoodFactsService.getBeautyProduct('3560070791460');
print('Beauty Product: ${beautyProduct?.name}');
print('Period after opening: ${beautyProduct?.periodAfterOpening}');
```

### **🧾 Open Prices Features** (Requires Authentication)
- **Real-time Pricing**: Current prices from actual stores
- **Price History**: Track price changes over time
- **Store Locations**: Find products at specific stores
- **Price Statistics**: Average, min/max prices with trends
- **Crowdsourced Data**: Community-driven price validation
- **Receipt Integration**: Submit prices from receipts (with auth)

### **💄 Beauty Products (OpenBeautyFacts)**

The service now supports beauty and cosmetic products from OpenBeautyFacts:

```dart
// Get beauty product by barcode
final beautyProduct = await WeebiOpenFoodFactsService.getBeautyProduct('3560070791460');

if (beautyProduct != null) {
  print('Name: ${beautyProduct.name}');
  print('Brand: ${beautyProduct.brand}');
  print('Period after opening: ${beautyProduct.periodAfterOpening}');
  print('Cosmetic ingredients: ${beautyProduct.cosmeticIngredients.length} items');
  print('Allergens: ${beautyProduct.allergens.join(', ')}');
}

// Search beauty products
final shampooProducts = await WeebiOpenFoodFactsService.searchBeautyProducts(
  query: 'shampoo',
  limit: 10,
);

// Get beauty categories
final categories = await WeebiOpenFoodFactsService.getBeautyCategories();
print('Available categories: ${categories.join(', ')}');
```

**Beauty Product Features:**
- ✅ **Basic Info**: Name, brand, barcode
- ✅ **Cosmetic Data**: Period after opening, ingredients
- ✅ **Safety**: Allergen warnings, ingredient analysis
- ✅ **Images**: Product photos, ingredient lists
- ✅ **Multi-language**: All data in preferred languages
- 🔧 **Pricing**: Beauty product pricing (future)

### **Architecture Foundation for Future Expansion**
- **Multi-Database Ready**: Built with extensibility for OpenBeautyFacts and OpenProductsFacts
- **Product Type System**: Supports food, beauty, and general product types
- **Flexible Caching**: Database-aware caching system
- **Scalable Design**: Easy to extend for new databases and features

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
  weebi_openfoodfacts_service: ^1.3.0
```

## 🔐 Credential Setup (Optional - Only for Pricing Features)

**Basic product information works without any credentials!**

The service works in **read-only mode** without credentials for OpenFoodFacts API. Credentials are only required for Open Prices API features (pricing data, price submission).

### **What Works Without Credentials:**
- ✅ Product information (name, brand, ingredients, etc.)
- ✅ Product images and nutrition data
- ✅ Multi-language support
- ✅ Product caching
- ✅ All OpenFoodFacts features

### **What Requires Credentials:**
- ❌ Pricing data (current prices, price history)
- ❌ Price statistics and trends
- ❌ Price submission from receipts
- ❌ Store-specific pricing

### **Quick Start Without Credentials:**
```dart
await WeebiOpenFoodFactsService.initialize(
  appName: 'MyApp/1.0',
  enablePricing: false, // Disable pricing to work without credentials
);

// Get product information immediately
final product = await WeebiOpenFoodFactsService.getProduct('3017620422003');
print('Product: ${product?.name}'); // Works without credentials!
```

## Integrations

### OpenFoodFacts + Open Prices 
- [x] Multi-language API integration
- [x] Advanced caching system
- [x] Comprehensive error handling
- [x] **🆕 Open Prices integration**
- [x] **🆕 Real-time pricing data**
- [x] **🆕 Price history & statistics**
- [x] **🔐 Secure credential management**
- [x] Production-ready package

### OpenBeautyFacts
- [x] Beauty product API integration
- [x] Cosmetic-specific data fields
- [x] Period after opening support
- [x] Ingredient safety analysis

### OpenProductsFacts
- [x] General product API integration
- [x] Product category system
- [x] Multi-database search
- [x] Unified product interface

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenFoodFacts](https://openfoodfacts.org) for the amazing open data
- [**🆕 Open Prices**](https://prices.openfoodfacts.org) for crowdsourced pricing data
- [OpenBeautyFacts](https://openbeautyfacts.org) for cosmetic product data
- [OpenProductsFacts](https://openproductsfacts.org) for general product data
- The Dart/Flutter community for excellent tooling

### Beauty Products

```dart
// Get beauty product by barcode
final beautyProduct = await WeebiOpenFoodFactsService.getBeautyProduct('1234567890123');

// Search beauty products
final beautyResults = await WeebiOpenFoodFactsService.searchBeautyProducts(
  query: 'shampoo',
  brand: 'L\'Oreal',
  category: 'Hair Care',
);

// Get beauty categories
final beautyCategories = await WeebiOpenFoodFactsService.getBeautyCategories();
```

### General Products

```dart
// Get general product by barcode
final generalProduct = await WeebiOpenFoodFactsService.getGeneralProduct('1234567890123');

// Search general products
final generalResults = await WeebiOpenFoodFactsService.searchGeneralProducts(
  query: 'smartphone',
  brand: 'Apple',
  category: 'Electronics',
);

// Get general product categories
final generalCategories = await WeebiOpenFoodFactsService.getGeneralCategories();
```