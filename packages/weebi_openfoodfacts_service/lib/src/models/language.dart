import 'package:openfoodfacts/openfoodfacts.dart' as off;

/// Supported languages for Weebi OpenFoodFacts integration
enum AppLanguage {
  english,
  french,
  spanish,
  german,
  italian,
  portuguese,
  dutch,
  chinese,
  japanese,
  arabic;

  /// Convert to OpenFoodFacts language
  off.OpenFoodFactsLanguage get openFoodFactsLanguage {
    switch (this) {
      case AppLanguage.english:
        return off.OpenFoodFactsLanguage.ENGLISH;
      case AppLanguage.french:
        return off.OpenFoodFactsLanguage.FRENCH;
      case AppLanguage.spanish:
        return off.OpenFoodFactsLanguage.SPANISH;
      case AppLanguage.german:
        return off.OpenFoodFactsLanguage.GERMAN;
      case AppLanguage.italian:
        return off.OpenFoodFactsLanguage.ITALIAN;
      case AppLanguage.portuguese:
        return off.OpenFoodFactsLanguage.PORTUGUESE;
      case AppLanguage.dutch:
        return off.OpenFoodFactsLanguage.DUTCH;
      case AppLanguage.chinese:
        return off.OpenFoodFactsLanguage.CHINESE;
      case AppLanguage.japanese:
        return off.OpenFoodFactsLanguage.JAPANESE;
      case AppLanguage.arabic:
        return off.OpenFoodFactsLanguage.ARABIC;
    }
  }

  /// Language code (ISO 639-1)
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.italian:
        return 'it';
      case AppLanguage.portuguese:
        return 'pt';
      case AppLanguage.dutch:
        return 'nl';
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.japanese:
        return 'ja';
      case AppLanguage.arabic:
        return 'ar';
    }
  }

  /// Display name
  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.italian:
        return 'Italiano';
      case AppLanguage.portuguese:
        return 'Português';
      case AppLanguage.dutch:
        return 'Nederlands';
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.japanese:
        return '日本語';
      case AppLanguage.arabic:
        return 'العربية';
    }
  }

  /// Create from language code
  static AppLanguage? fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return AppLanguage.english;
      case 'fr':
        return AppLanguage.french;
      case 'es':
        return AppLanguage.spanish;
      case 'de':
        return AppLanguage.german;
      case 'it':
        return AppLanguage.italian;
      case 'pt':
        return AppLanguage.portuguese;
      case 'nl':
        return AppLanguage.dutch;
      case 'zh':
        return AppLanguage.chinese;
      case 'ja':
        return AppLanguage.japanese;
      case 'ar':
        return AppLanguage.arabic;
      default:
        return null;
    }
  }
} 