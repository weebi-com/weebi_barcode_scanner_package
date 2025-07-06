/// Configuration for caching behavior
class CacheConfig {
  /// Maximum age for cached products (in days)
  final int productCacheMaxAgeDays;
  
  /// Maximum age for cached images (in days)
  final int imageCacheMaxAgeDays;
  
  /// Maximum number of products to cache
  final int maxCachedProducts;
  
  /// Maximum number of images to cache
  final int maxCachedImages;
  
  /// Maximum size for image cache (in MB)
  final int maxImageCacheSizeMB;
  
  /// Whether to cache product images
  final bool enableImageCache;
  
  /// Whether to cache product data
  final bool enableProductCache;
  
  /// Whether to use cache when offline
  final bool useOfflineCache;

  const CacheConfig({
    this.productCacheMaxAgeDays = 7,
    this.imageCacheMaxAgeDays = 30,
    this.maxCachedProducts = 1000,
    this.maxCachedImages = 500,
    this.maxImageCacheSizeMB = 100,
    this.enableImageCache = true,
    this.enableProductCache = true,
    this.useOfflineCache = true,
  });

  /// Default configuration for production
  static const CacheConfig production = CacheConfig(
    productCacheMaxAgeDays: 7,
    imageCacheMaxAgeDays: 30,
    maxCachedProducts: 1000,
    maxCachedImages: 500,
    maxImageCacheSizeMB: 100,
  );

  /// Configuration for development/testing
  static const CacheConfig development = CacheConfig(
    productCacheMaxAgeDays: 1,
    imageCacheMaxAgeDays: 7,
    maxCachedProducts: 100,
    maxCachedImages: 50,
    maxImageCacheSizeMB: 20,
  );

  /// Minimal configuration (cache disabled)
  static const CacheConfig minimal = CacheConfig(
    enableImageCache: false,
    enableProductCache: false,
    useOfflineCache: false,
  );

  /// Copy with modified values
  CacheConfig copyWith({
    int? productCacheMaxAgeDays,
    int? imageCacheMaxAgeDays,
    int? maxCachedProducts,
    int? maxCachedImages,
    int? maxImageCacheSizeMB,
    bool? enableImageCache,
    bool? enableProductCache,
    bool? useOfflineCache,
  }) {
    return CacheConfig(
      productCacheMaxAgeDays: productCacheMaxAgeDays ?? this.productCacheMaxAgeDays,
      imageCacheMaxAgeDays: imageCacheMaxAgeDays ?? this.imageCacheMaxAgeDays,
      maxCachedProducts: maxCachedProducts ?? this.maxCachedProducts,
      maxCachedImages: maxCachedImages ?? this.maxCachedImages,
      maxImageCacheSizeMB: maxImageCacheSizeMB ?? this.maxImageCacheSizeMB,
      enableImageCache: enableImageCache ?? this.enableImageCache,
      enableProductCache: enableProductCache ?? this.enableProductCache,
      useOfflineCache: useOfflineCache ?? this.useOfflineCache,
    );
  }
} 