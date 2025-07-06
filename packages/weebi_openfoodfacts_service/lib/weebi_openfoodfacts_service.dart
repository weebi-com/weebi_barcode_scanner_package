library weebi_openfoodfacts_service;

// Core service
export 'src/weebi_openfoodfacts_client.dart';

// Open Prices integration
export 'src/open_prices_client.dart';

// Open Beauty Facts integration
export 'src/open_beauty_facts_client.dart';

// Models
export 'src/models/product.dart';
export 'src/models/language.dart';
export 'src/models/cache_config.dart';

// Utilities
export 'src/utils/barcode_validator.dart';
export 'src/utils/nutrition_helper.dart';
export 'src/utils/credential_manager.dart';

// Cache managers (for advanced usage)
export 'src/product_cache_manager.dart';
export 'src/language_manager.dart';
